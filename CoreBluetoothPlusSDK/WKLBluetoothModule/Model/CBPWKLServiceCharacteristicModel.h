//
//  CBPWKLServiceCharacteristicModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/13.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPWKLServiceCharacteristicModel : NSObject


/**
 外设
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 服务的 UUID
 */
@property (nonatomic, copy) CBUUID *serviceUUID;


/**
 通知特征的 UUID
 */
@property (nonatomic, copy) CBUUID *notifyCharacteristicUUID;

/**
 写特征的 UUID
 */
@property (nonatomic, copy) CBUUID *writeCharacteristicUUID;

/**
 服务
 */
@property (nonatomic, strong) CBService *service;

/**
 通知特征
 */
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;

/**
 写特征
 */
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

/**
 是否已准备好
 
 @return bool 值
 */
- (BOOL) isReady;


/**
 写和通知的 UUID

 @return UUID 数组
 */
- (NSArray<CBUUID *> *)characteristicUUIDs;

@end
