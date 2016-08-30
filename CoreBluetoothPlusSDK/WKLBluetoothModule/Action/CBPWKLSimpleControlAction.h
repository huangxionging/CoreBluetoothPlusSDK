//
//  CBPWKLSimpleControlAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"
typedef NS_ENUM(NSUInteger, CBPWKLSimpleControlType) {
    // 点亮 LED 灯
    kCBPWKLSimpleControlTypeLED =  10001,
    // 蜂鸣器
    kCBPWKLSimpleControlTypeBuzzer,
    // 防丢开关
    kCBPWKLSimpleControlTypeLostSwitch,
    // 按键锁
    kCBPWKLSimpleControlTypeKeyboardLock,
    // 变颜色
    kCBPWKLSimpleControlTypeChangeColor,
    // 查找设备
    kCBPWKLSimpleControlTypeSearchDevice,
    // ANCS 开关
    kCBPWKLSimpleControlTypeANCS,
    // 查询设备工作状态
    // kCBPWKLSimpleControlTypeQueryDeviceState,
};

@interface CBPWKLSimpleControlAction : CBPBaseAction
/**
 *  简单控制命令类型
 */
@property (nonatomic, assign) CBPWKLSimpleControlType type;

/**
 *  开关, 在 type 为 kWKLSimpleControlTypeLED , 最大为 4 字节数组指针是
 *  在 type kWKLSimpleControlTypeBuzzer, kWKLSimpleControlTypeLostSwitch, 
 *  kWKLSimpleControlTypeKeyboardLock,kWKLSimpleControlTypeANCS 时, 为单字节指针
 */
@property (nonatomic, assign) Byte *switchValue;

#pragma mark-
#pragma mark--- 点亮指定LED其他参数
/**
 *  亮时长
 */
@property (nonatomic, assign) NSInteger lightLength;

/**
 *  灭时长
 */
@property (nonatomic, assign) NSInteger extinguishLength;

/**
 *  重复次数
 */
@property (nonatomic, assign) NSInteger recurNumbers;
#pragma mark-
#pragma mark---控制蜂鸣器响和防丢指令以及按键锁共有参数
/**
 *  持续时长
 */
@property (nonatomic, assign) NSInteger lastLength;

#pragma mark---控制蜂鸣器
/**
 *  频率
 */
@property (nonatomic, assign) NSInteger frequency;

#pragma mark---更换三基色灯
/**
 *  颜色:取值为0-蓝、1-橙、2-绿、3-红
 */
@property (nonatomic, assign) NSInteger colorValue;

#pragma mark-
/**
 *  重写
 */
- (NSData *)actionData;

/**
 *  重写
 */
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
