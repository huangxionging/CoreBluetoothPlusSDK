//
//  CBPBaseWorkingManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPBaseController, CBPBaseAction, CBPBaseError;


@interface CBPBaseWorkingManager : NSObject

/**
 *  @author huangxiong
 *
 *  @brief 控制器的 key, 用来指明 服务的控制器
 */
@property (nonatomic, copy) NSString *controllerKey;

/**
 *  @author huangxiong
 *
 *  @brief 控制器
 */
@property (nonatomic, readonly, strong) CBPBaseController *baseController;

/**
 *  @brief  管理器单例
 *  @param  void
 *  @return 管理器实例
 */
+ (instancetype) manager;

/**
 *  get
 */
- (void) get:(NSString *)URLString parameters:(id)parameters success:(void (^)(CBPBaseAction *action, id responseObject))success failure:(void (^)(CBPBaseAction *action, CBPBaseError *error))failure;

/**
 *  post 方法
 */
/**
 *  @author huangxiong, 2016/04/06 15:52:43
 *
 *  @brief post 方法提交请求
 *
 *  @param URLString  这个是 URL 地址
 *  @param parameters 参数, 支持 NSDictionary, NSString, NSData 三种类型
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @since 1.0
 */
- (void) post:(NSString *)URLString parameters:(id)parameters success:(void (^)(CBPBaseAction *action, id responseObject))success failure:(void (^)(CBPBaseAction *action, CBPBaseError *error))failure;

@end
