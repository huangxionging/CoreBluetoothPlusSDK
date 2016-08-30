//
//  CBPWKLSleepAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/20.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"

@interface CBPWKLSleepAction : CBPBaseAction

/**
 *  操作类型
 */
//@property (nonatomic, assign) WKLStepActionType stepActionType;

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

- (NSData *)actionData;

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
