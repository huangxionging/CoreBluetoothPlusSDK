//
//  CBPWKLDiaogUpgradeServiceCharacteristicModel.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/14.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLDialogUpgradeServiceCharacteristicModel.h"
#import <CoreBluetooth/CoreBluetooth.h>


/**
 生成 UUID

 @param x UUID 标识

 @return CBUUID 对象
 */

#define UUID(x) [CBUUID UUIDWithString: x]

// 生成 UUID 方法 - 方法
#define UUID_METHOD(x,y)  - (CBUUID *) x { return UUID(y);}


static NSString * SPOTA_SERVICE_UUID     = @"0000fef5-0000-1000-8000-00805f9b34fb";
static NSString * SPOTA_MEM_DEV_UUID     = @"8082caa8-41a6-4021-91c6-56f9b954cc34";
static NSString * SPOTA_GPIO_MAP_UUID    = @"724249f0-5ec3-4b5f-8804-42345af08651";
static NSString * SPOTA_MEM_INFO_UUID    = @"6c53db25-47a1-45fe-a022-7c92fb334fd4";
static NSString * SPOTA_PATCH_LEN_UUID   = @"9d84b9a3-000c-49d8-9183-855b673fda31";
static NSString * SPOTA_PATCH_DATA_UUID  = @"457871e8-d516-4ca1-9116-57d0b17b9cb2";
static NSString * SPOTA_SERV_STATUS_UUID = @"5f78df94-798c-46f5-990a-b3eb6a065c88";
@interface CBPWKLDialogUpgradeServiceCharacteristicModel ()
@property (nonatomic, strong) NSArray<CBUUID *> *characteristicUUIDs;
@end
@implementation CBPWKLDialogUpgradeServiceCharacteristicModel

- (NSArray<CBUUID *> *)characteristicUUIDs {
    
    if (_characteristicUUIDs == nil) {
        
        _characteristicUUIDs = @[self.MEM_DEV_UUID, self.GPIO_MAP_UUID, self.MEM_INFO_UUID,self.PATCH_LEN_UUID, self.PATCH_DATA_UUID, self.SERV_STATUS_UUID];

    }
    return _characteristicUUIDs;
}

- (BOOL)isReady {
    if (self.MEM_DEV_Characteristic && self.GPIO_MAP_Characteristic && self.MEM_INFO_Characteristic && self.PATCH_LEN_Characteristic && self.PATCH_DATA_Characteristic && self.SERV_STATUS_Characteristic) {
        return YES;
    }
    return NO;
}


- (void) setCharacteristic:(CBCharacteristic *)characteristic {
    
    CBUUID *UUID = characteristic.UUID;
    
    // 存在
    if ([self.characteristicUUIDs containsObject: UUID]) {
        NSInteger index = [self.characteristicUUIDs indexOfObject: UUID];
        
        NSArray *array = @[@"MEM_DEV", @"GPIO_MAP", @"MEM_INFO", @"PATCH_LEN", @"PATCH_DATA", @"SERV_STATUS"];
        
        // 用个毛 switch 语句, 使用 KVC 减少代码
        NSString *characteristicName = array[index];
        NSString *characteristicKey = [NSString stringWithFormat: @"%@_Characteristic", characteristicName];
        
        // 设置特征值
        [self setValue:characteristic forKey: characteristicKey];
    }
}

// 宏定义生成 UUID 方法
UUID_METHOD(serviceUUID, SPOTA_SERVICE_UUID)
UUID_METHOD(MEM_DEV_UUID, SPOTA_MEM_DEV_UUID)
UUID_METHOD(GPIO_MAP_UUID, SPOTA_GPIO_MAP_UUID)
UUID_METHOD(MEM_INFO_UUID, SPOTA_MEM_INFO_UUID)
UUID_METHOD(PATCH_LEN_UUID, SPOTA_PATCH_LEN_UUID)
UUID_METHOD(PATCH_DATA_UUID, SPOTA_PATCH_DATA_UUID)
UUID_METHOD(SERV_STATUS_UUID, SPOTA_SERV_STATUS_UUID)

@end
