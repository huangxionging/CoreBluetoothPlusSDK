//
//  CBPWKLStepAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/14.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"

typedef NS_ENUM(NSUInteger, WKLStepActionType) {
    
    /**
     *  设置计步保存时间间隔
     */
    kWKLStepActionTypeSettingSaveInterval = 0,
    
    /**
     *  同步计步数据
     */
    kWKLStepActionTypeSynchronizeStepData,
};

@interface CBPWKLStepAction : CBPBaseAction

/**
 *  操作类型
 */
@property (nonatomic, assign) WKLStepActionType stepActionType;

/**
 *  计步数据的保存时间间隔, 单位:分钟, 默认值为30
 */
@property (nonatomic, assign) NSInteger saveInterval;

/**
 *  起始日期, 格式要求: xxxx/xx/xx 表示 xxxx年 xx月 xx日, 必须如此
 */
@property (nonatomic, copy) NSString *startDate;

/**
 *  结束日期
 */
@property (nonatomic, copy) NSString *endDate;

/**
 *  设备编号, 要求是一串
 */
@property (nonatomic, copy) NSString *deviceNumber;

/**
 *  重写操作数据方法
 */
- (NSData *)actionData;

/**
 *  重写接收数据的处理方法
 */
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
