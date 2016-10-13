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
    // 10008 表示超时
    kBaseErrorTypeTimeOut                   = 10008,
    // 10009 表示蓝牙未连接
    kBaseErrorTypeBluetoothDisconnected     = 10009,
    // 10010 表示外设断连
    kBaseErrorTypePeripheralDisconnected    = 10010,
    // 10011 表示外设正在连接
    kBaseErrorTypePeripheralConnecting      = 10011,
    // 10012 表示外设正在断连
    kBaseErrorTypePeripheralDisconnecting   = 10012,
    // 10013 表示无有效数据
    kBaseErrorTypeInvalidData               = 10013,
    // 10014 表示升级超时失失败
    kBaseErrorTypeUpgradeTimeOut            = 10014,
    // 10015 表示文件无效
    kBaseErrorTypeFileInvalid               = 10015,
    // 10016 表示文件太大
    kBaseErrorTypeFileTooLarge              = 10016,
    // 10017 表示不允许升级
    kBaseErrorTypeNotAllowUpgrade           = 10017,
    // 10018 表示同步数据超时
    kBaseErrorTypeSynchronizeDataTimeOut    = 10018,
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
