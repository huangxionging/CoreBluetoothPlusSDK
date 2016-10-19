//
//  CBPDispatchMessageManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/9/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 消息调度
 */
@interface CBPDispatchMessageManager : NSObject


/**
 消息调度管理器, 单例

 @return 共享的管理器
 */
+ (instancetype) shareManager;


/**
 调度传送消息, 参数可变, method 后面最多支持 10 个参数, 且都为 id 对象类型, 必须要添加 nil 结尾 NS_REQUIRES_NIL_TERMINATION;
 此方法不支持返回值.

 @param target 目标
 @param method 方法名, 消息名
 */
- (void) dispatchTarget:(id) target method: (NSString *)method, ... NS_REQUIRES_NIL_TERMINATION;

/**
 调度传送消息, 参数可变, method 后面最多支持 10 个参数, 且都为 id 对象类型, 必须要添加 nil 结尾 NS_REQUIRES_NIL_TERMINATION;
 此方法有返回值.

 @param target 目标
 @param method 方法名, 消息名

 @return 返回调度方法的结果
 */
- (id) dispatchReturnValueTarget:(id) target method: (NSString *)method, ... NS_REQUIRES_NIL_TERMINATION;

@end
