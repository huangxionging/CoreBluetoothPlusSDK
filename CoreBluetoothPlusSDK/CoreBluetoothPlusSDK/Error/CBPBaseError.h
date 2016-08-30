//
//  CBPBaseError.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  错误码, 从 10000 开始编号, 与 code 相对应
 */
typedef NS_ENUM(NSInteger, BaseErrorType) {
    
    // 10000 表示管理器未配置
    kBaseErrorTypeWorkingManagerNotConfig = 10000,
    // 10001 表示URL参数非法
    kBaseErrorTypeURLIllegal                = 10001,
    // 10002 表示暂不支持的协议
    kBaseErrorTypeUnSupportedProtocol       = 10002,
    // 10003 表示暂不支持的操作
    kBaseErrorTypeUnSupportedAction         = 10003,
    // 10004 表示管理器配置错误
    kBaseErrorTypeWorkingManagerConfigError = 10004,
    // 10005 表示参数错误
    kBaseErrorTypeParameterError            = 10005,
    // 10006 表示 通道已被占用
    kBaseErrorTypeChannelUsed               = 10006,
    // 10007 表示未知错误
    kBaseErrorTypeUnknown                   = 10007,
};

@interface CBPBaseError : NSError

/**
 *  @author huangxiong, 2016/04/06 15:57:05
 *
 *  @brief 错误
 *
 *  @param errorType 错误类型
 *  @param info      错误信息
 *
 *  @return 错误对象
 *
 *  @since 1.0
 */
+ (instancetype)errorWithcode: (BaseErrorType) errorType info: (NSString *)info;

/**
 *  @author huangxiong, 2016/04/06 15:57:46
 *
 *  @brief 输出错误日志
 *
 *  @since 1.0
 */
- (void) errorLog;
@end
