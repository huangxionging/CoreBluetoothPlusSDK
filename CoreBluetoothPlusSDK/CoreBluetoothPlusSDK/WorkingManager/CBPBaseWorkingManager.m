//
//  CBPBaseWorking.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseWorkingManager.h"
#import "CBPBaseController.h"
#import "CBPBaseError.h"

/**
 *  @author huangxiong, 2016/04/06 10:16:42
 *
 *  @brief 工作管理器, 单例
 *
 *  @since 1.0
 */
static CBPBaseWorkingManager *baseWorkingManager = nil;

#pragma mark- Extension
@interface CBPBaseWorkingManager ()

/**
 *  @author huangxiong
 *
 *  @brief 流程控制器
 */
@property (nonatomic, strong) CBPBaseController *baseController;

@property (nonatomic, strong) CBPBaseController *upgradeController;

/**
 *  @author huangxiong
 *
 *  @brief 控制器数组
 */
@property (nonatomic, strong) NSMutableDictionary *controllerDict;

/**
 *  @author huangxiong
 *
 *  @brief 操作指令数组
 */
@property (nonatomic, strong) NSMutableDictionary *actionDict;

- (dispatch_queue_t) gloabQueue;

@end

#pragma mark- 实现
@implementation CBPBaseWorkingManager

#pragma mark- 默认管理器
+ (instancetype)manager {
    // 如果已存在
    if (baseWorkingManager) {
        return baseWorkingManager;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseWorkingManager = [[super alloc] init];
    });
    
    return baseWorkingManager;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 默认未配置
        baseWorkingManager = [super allocWithZone:zone];
    });
    
    return baseWorkingManager;

}

#pragma mark- 私有 API
- (NSMutableDictionary *)controllerDict {
    if (_controllerDict == nil) {
        _controllerDict = [NSMutableDictionary dictionaryWithCapacity: 10];
    }
    return _controllerDict;
}

- (NSMutableDictionary *)actionDict {
    if (_actionDict == nil) {
        _actionDict = [NSMutableDictionary dictionaryWithCapacity: 20];
    }
    return _actionDict;
}

- (CBPBaseController *)baseController {
    if (_baseController == nil) {
        
        if (_controllerKey) {
            NSString *classString = [self.controllerDict objectForKey: _controllerKey];
            if (classString) {
                _baseController = [[NSClassFromString(classString) alloc] init];
            }
        }
    }
    return _baseController;
}

#pragma mark- 固件更新使用的控制器的 key
- (void)setUpgradeControllerKey:(NSString *)upgradeControllerKey {
    // 需要从新配置
    if (upgradeControllerKey) {
        _upgradeController = nil;
    }
    _upgradeControllerKey = upgradeControllerKey;
}

#pragma mark- 更新使用的控制器
- (CBPBaseController *)upgradeController {
    if (_upgradeController == nil) {
        
        if (_upgradeControllerKey) {
            NSString *classString = [self.controllerDict objectForKey: _upgradeControllerKey];
            if (classString) {
                _upgradeController = [[NSClassFromString(classString) alloc] init];
            }
        }
    }
    return _upgradeController;
}


- (void)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    // 跟 post 一样
    [self post: URLString parameters: parameters success: success failure: failure];
}

- (void)post:(NSString *)URLString parameters:(id)parameters progress:(void (^)(id progressData))progress success:(void (^)(CBPBaseAction *action, id responseObject))success failure:(void (^)(CBPBaseAction *action, CBPBaseError *error))failure {
    
    CBPBaseError *error = [self checkConfig];
    if (error) {
        failure(nil, error);
    }
    // 处理参数
    [self handleURLString: URLString parameters: parameters progress: progress success: success failure: failure];
}

- (void) post:(NSString *)URLString parameters:(id)parameters success:(void (^)(CBPBaseAction *action, id responseObject))success failure:(void (^)(CBPBaseAction *action, CBPBaseError *error))failure {
    
    CBPBaseError *error = [self checkConfig];
    if (error) {
        failure(nil, error);
    }
    // 处理参数
    [self handleURLString: URLString parameters: parameters progress: nil success: success failure: failure];
}

#pragma mark---检查配置
- (CBPBaseError *) checkConfig {
    
    if (!self.baseController) {
        return [CBPBaseError errorWithcode: kBaseErrorTypeWorkingManagerNotConfig info: @"没有为管理器加载配置文件"];
    }
    
    return nil;
}

#pragma mark---处理参数
- (void ) handleURLString: (NSString *)URLString parameters:(id)parameters progress:(void (^)(id progress))progress success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithCapacity: 4];
    
    CBPBaseError *error = nil;
    
    NSParameterAssert(URLString);
    
    NSURL *URL = [NSURL URLWithString: URLString];
    
    // scheme 协议
    NSString *protocol = URL.scheme;
    
    if (![protocol isEqualToString: @"ble"]) {
        NSAssert(0, @"协议使用有误");
    }
    
    // host
    NSString *host = URL.host;
    NSParameterAssert(host);
    
    // 参数
    NSString *param = URL.query;
    if (param) {
        // 获取参数
        NSArray *paramArray = [param componentsSeparatedByString: @"&"];
        for (NSString *param in paramArray) {
            NSArray *keyValues = [param componentsSeparatedByString: @"="];
            
            if (keyValues.count != 2) {
                error = [CBPBaseError errorWithcode: kBaseErrorTypeUnSupportedAction info: @"参数错误"];
                failure(nil, error);
                return;
            }
            [allParameters setObject: keyValues[1] forKey: keyValues[0]];
        }
    }
    
    // 支持 NSDictionary 
    if (parameters && [parameters isKindOfClass: [NSDictionary class]]) {
        // 添加参数
        [allParameters addEntriesFromDictionary: parameters];
    }
    
    [allParameters setObject: host forKey: @"interface"];
    
    NSString *workingAction = [self.actionDict objectForKey: host];
    
    if (workingAction) {
        // 异步调用
        __weak typeof(self)weakSelf = self;
        dispatch_async(weakSelf.gloabQueue, ^{
            
            // 如果升级的控制 key 不为空, 则优先处理固件升级
            if (weakSelf.upgradeControllerKey) {
                // 处理参数和回调数据
                [weakSelf.upgradeController sendAction: workingAction parameters: allParameters progress: progress success: success failure: failure];
            } else if (_baseController) {
                // 处理参数和回调数据
                [_baseController sendAction: workingAction parameters: allParameters progress: progress success: success failure: failure];
            }
            
        });
    } else {
        
        error = [CBPBaseError errorWithcode: kBaseErrorTypeUnSupportedAction info: @"接口错误或者暂未支持"];
        
        failure(nil, error);
    }
    
}

- (dispatch_queue_t)gloabQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

@end
