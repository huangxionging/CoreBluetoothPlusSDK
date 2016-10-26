//
//  CBPWKLCypressUpgradeServiceCharacteristicModel.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLCypressUpgradeServiceCharacteristicModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
/**
 生成 UUID
 
 @param x UUID 标识
 
 @return CBUUID 对象
 */

#define UUID(x) [CBUUID UUIDWithString: x]

// 生成 UUID 方法 - 方法
#define UUID_METHOD(x,y)  - (CBUUID *) x { return UUID(y);}

// 读写服务 UUID
#define CUSTOM_BOOT_LOADER_SERVICE_UUID @"00060000-F8CE-11E4-ABF4-0002A5D5C51B"
#define BOOT_LOADER_CHARACTERISTIC_UUID @"00060001-F8CE-11E4-ABF4-0002A5D5C51B"

@implementation CBPWKLCypressUpgradeServiceCharacteristicModel

- (void)setDiscoverService:(CBService *)discoverService {
    _discoverService = discoverService;
    for (CBCharacteristic *cha in _discoverService.characteristics) {
        if ([cha.UUID isEqual: self.notifyCharacteristicUUID]) {
            _notifyCharacteristic = cha;
        }
        
        if ([cha.UUID isEqual: self.writeCharacteristicUUID]) {
            _writeCharacteristic = cha;
        }
    }
}

// 扫描 UUID
UUID_METHOD(scanServiceUUID, CUSTOM_BOOT_LOADER_SERVICE_UUID);
UUID_METHOD(discoverServiceUUID, CUSTOM_BOOT_LOADER_SERVICE_UUID);
UUID_METHOD(notifyCharacteristicUUID, BOOT_LOADER_CHARACTERISTIC_UUID);
UUID_METHOD(writeCharacteristicUUID, BOOT_LOADER_CHARACTERISTIC_UUID);

@end
