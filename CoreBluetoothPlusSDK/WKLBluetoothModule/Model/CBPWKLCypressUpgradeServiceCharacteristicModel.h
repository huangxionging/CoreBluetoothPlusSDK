//
//  CBPWKLCypressUpgradeServiceCharacteristicModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBUUID, CBCharacteristic, CBService, CBPeripheral;

@interface CBPWKLCypressUpgradeServiceCharacteristicModel : NSObject

@property (nonatomic, copy) CBUUID *scanServiceUUID;

/**
 服务
 */
@property (nonatomic, strong) CBService *discoverService;

/**
 服务的 UUID
 */
@property (nonatomic, copy) CBUUID *discoverServiceUUID;

/**
 通知特征的 UUID
 */
@property (nonatomic, copy) CBUUID *notifyCharacteristicUUID;

/**
 写特征的 UUID
 */
@property (nonatomic, copy) CBUUID *writeCharacteristicUUID;


/**
 通知特征
 */
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;

/**
 写特征
 */
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

@end
