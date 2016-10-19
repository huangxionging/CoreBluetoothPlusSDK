//
//  CBPWKLDialogUpgradeServiceCharacteristicModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/14.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBUUID, CBCharacteristic, CBService, CBPeripheral;

@interface CBPWKLDialogUpgradeServiceCharacteristicModel : NSObject

/**
 服务的 UUID
 */
@property (nonatomic, copy) CBUUID *serviceUUID;


/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *MEM_DEV_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *MEM_DEV_Characteristic;

/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *GPIO_MAP_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *GPIO_MAP_Characteristic;

/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *MEM_INFO_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *MEM_INFO_Characteristic;

/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *PATCH_LEN_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *PATCH_LEN_Characteristic;

/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *PATCH_DATA_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *PATCH_DATA_Characteristic;

/**
 MEM_DEV
 */
@property (nonatomic, copy) CBUUID *SERV_STATUS_UUID;

/**
 特征
 */
@property (nonatomic, strong) CBCharacteristic *SERV_STATUS_Characteristic;

- (BOOL) isReady;

@end
