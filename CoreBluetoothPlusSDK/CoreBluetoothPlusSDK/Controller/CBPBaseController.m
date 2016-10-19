//
//  CBPBaseController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseController.h"
#import "CBPBaseWorkingManager.h"
#import "CBPDispatchMessageManager.h"

/**
 *  @author huangxiong
 *
 *  @brief 声明 CBPBaseWorkingManager 私有方法
 */
@interface CBPBaseWorkingManager ()

- (NSMutableDictionary *)controllerDict;

@end

@interface CBPBaseController ()

@end

@implementation CBPBaseController

+ (NSString *)controllerKey {
    return @"";
}

+ (void) registerController:(id) baseController {
    
    // 获得类名
    NSString *classString = NSStringFromClass([baseController class]);
    // 取得单例
    
    CBPBaseWorkingManager *manager = [CBPBaseWorkingManager manager];
    
    NSString *key = [[baseController class] controllerKey];
    // 设置 controller
    if (key) {
        [manager.controllerDict setObject: classString forKey: key];
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void) startWorkWithBlock: (void(^)(id result))block {
    [self startWorkWithClient: [CBPBaseClient shareBaseClient]];
}
#pragma mark---开始工作
- (void)startWorkWithClient:(CBPBaseClient *)baseClient{
    
#ifdef CBPLOG_FLAG
    CBPDEBUG;
#endif
    
    self->_baseClient = baseClient;
    __weak CBPBaseController *weakSelf = self;
    
    // 设置超时时间
    [weakSelf.baseClient setScanTimeOut: 15.0];
    
    // 设置扫描准备回调
    [weakSelf.baseClient setScanReadyBlock:^(CBManagerState ready) {
        
        // 根据状态做不同操作
        switch (ready) {
                // 正常打开, 可以进行搜索操作
            case CBCentralManagerStatePoweredOn: {
                // 开始搜索;
                [weakSelf.baseClient startScanPeripheralWithOptions: nil];
                break;
            }
                
            case CBCentralManagerStatePoweredOff: {
                
                break;
            }
                
            case CBCentralManagerStateUnauthorized: {
                
                break;
            }
                
            case CBCentralManagerStateUnsupported: {
                
                break;
            }
                
            case CBCentralManagerStateResetting: {
                
                break;
            }
                
            case CBCentralManagerStateUnknown: {
                
                break;
            }
            default:
                break;
        }
    }];
    
    // 设置已找到外设回调
    [weakSelf.baseClient setSearchedPeripheralBlock:^(CBPBasePeripheralModel *peripheral) {
        
        if (peripheral != nil) {
            [weakSelf.baseClient stopScan];
           // [weakSelf.baseClient connectPeripheralWithOptions: nil];
#ifdef CBPLOG_FLAG
            CBPDEBUG;
            NSLog(@"发现外设: %@ ====>", peripheral);
#endif
        }
        else {
            [weakSelf.baseClient startScanPeripheralWithOptions: nil];
        }
    }];
    
    // 已连接回调
    [weakSelf.baseClient setConnectionPeripheralBlock:^(CBPBasePeripheralModel *peripheral) {
        
        if (peripheral.error == nil) {
            [weakSelf deviceStartWorkWith: peripheral];
        }
        else {
            NSLog(@"断开链接");
           // [weakSelf.baseClient connectPeripheralWithOptions: nil];
        }
        
    }];
}

#pragma mark---设备开始工作
- (void) deviceStartWorkWith: (CBPBasePeripheralModel *) peripheralModel {
    [self.baseDevice startWorkWith: peripheralModel];
    [self deviceDeliverData];
}

#pragma mark- 
- (void) deviceDeliverData {
    
    __weak CBPBaseController *weakSelf = self;
    // 更新数据回调
    [weakSelf.baseDevice setUpdateDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
    
    // 写数据回调
    [weakSelf.baseDevice setWriteDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
}

- (void)sendAction:(NSString *)actionName parameters:(id)parameters progress:(void (^)(id))progress success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    __weak CBPBaseController *weakSelf = self;
    
    CBPBaseAction *action = [[NSClassFromString(actionName) alloc] initWithParameter: parameters answer:^(CBPBaseActionDataModel *answerDataModel) {
        
        CBPBasePeripheralModel *model = [weakSelf.baseDevice valueForKey: @"_peripheralModel"];
        // 查询 action
        CBPBaseAction *baseAction = [weakSelf.actionSheet objectForKey: answerDataModel.keyword];
        
        // 如果外设不存在
        if (!model.peripheral) {
            CBPBaseError *error = [CBPBaseError errorWithcode:kBaseErrorTypeBluetoothDisconnected info: @"蓝牙未连接"];
            failure(baseAction, error);
        } else {
            
            switch (model.peripheral.state) {
                case CBPeripheralStateDisconnected: {
                    CBPBaseError *error = [CBPBaseError errorWithcode:kBaseErrorTypePeripheralDisconnected info: @"当前外设断连"];
                    failure(baseAction, error);
                    break;
                }
                case CBPeripheralStateConnected: {
                    // 发送回复数据
                    [weakSelf.baseDevice sendActionWithModel: answerDataModel];
                    
                    // 启动超时定时器
                    [[CBPDispatchMessageManager shareManager] dispatchTarget: baseAction method: @"startTimer", nil];
                    break;
                }
                case CBPeripheralStateConnecting: {
                    CBPBaseError *error = [CBPBaseError errorWithcode:kBaseErrorTypePeripheralConnecting info: @"当前外设正在连接"];
                    failure(baseAction, error);
                    break;
                }
                case CBPeripheralStateDisconnecting: {
                    CBPBaseError *error = [CBPBaseError errorWithcode:kBaseErrorTypePeripheralDisconnecting info: @"当前外设正在断开连接"];
                    failure(baseAction, error);
                    break;
                }
                    
                default:
                    break;
            }
            
        }

    } finished:^(id result) {
        
        // 获得 action
        CBPBaseAction *action = [result objectForKey: @"action"];
        NSString *successState = [result objectForKey: @"state"];
        // 删除 action
        BOOL state = [weakSelf removeAction: action];
        
        if (state == YES && successState.integerValue) {
            // 成功回调
            success(action, [result objectForKey: @"result"]);
        } else {
            // 失败回调
            failure(action, [result objectForKey: @"result"]);
        }
    }];
    
    // 设置进度 block, 当需要进度的时候, 要在发送数据之前设置好
    if (progress) {
        [action setValue: progress forKey: @"_progress"];
    }
    
    action.characteristicUUIDString = self.writeCharacteristicUUIDString;

    // 获取注册状态
    BOOL state = [weakSelf registerAction: action];
    if (state == YES) {
        [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"actionData", nil];
    } else {
        CBPBaseError *error = [CBPBaseError errorWithcode:kBaseErrorTypeChannelUsed info: @"通道已被占用"];
        failure(action, error);
    }
    
}

#pragma mark- action 列表
- (NSMutableDictionary<NSString *,CBPBaseAction *> *)actionSheet {
    
    // 初始化 操作表
    if (_actionSheet == nil) {
        _actionSheet = [NSMutableDictionary dictionaryWithCapacity: 10];
    }
    return  _actionSheet;
}

#pragma mark- action 关键字集合
- (NSMutableSet<NSString *> *)actionKeywordSet {
    if (_actionKeywordSet == nil) {
        _actionKeywordSet = [NSMutableSet setWithCapacity: 10];
    }
    return _actionKeywordSet;
}

#pragma mark- 注册 action
- (BOOL) registerAction: (CBPBaseAction *) action {
    
    // 键值
    NSSet *keySet = [[CBPDispatchMessageManager shareManager] dispatchReturnValueTarget: [action class] method: @"keySetForAction", nil];
    
    // 子集 表明有这个指令存在
    if ([keySet isSubsetOfSet: self.actionKeywordSet]) {
        [keySet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            // 先删除原来的指令
            [self.actionSheet removeObjectForKey: obj];
            // 重新设置指令
            [self.actionSheet setObject: action forKey: obj];
        }];
        return YES;
    } else if ([self.actionKeywordSet intersectsSet: keySet]) {
        // 存在交集且不是子集, 表明通道正在被占用
        return NO;
    } else {
        // 通道存在, 则占用
        // 取并集
        [self.actionKeywordSet unionSet: keySet];
        [keySet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.actionSheet setObject: action forKey: obj];
        }];
        return YES;
    }
}

#pragma mark- 删除 action
- (BOOL) removeAction: (CBPBaseAction *) action  {
    // 释放通道
    
    // 获取 指令标识集合
    NSSet *keySet = [[CBPDispatchMessageManager shareManager] dispatchReturnValueTarget: [action class] method: @"keySetForAction", nil];
    
    if ([self.actionKeywordSet intersectsSet: keySet]) {
        // 求差集
        [self.actionKeywordSet minusSet: keySet];
        
        // 释放通道
        [keySet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.actionSheet removeObjectForKey: obj];
        }];
        return YES;
    } else {
        return NO;
    }
}



@end
