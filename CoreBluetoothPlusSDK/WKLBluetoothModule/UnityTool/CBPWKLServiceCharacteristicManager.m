//
//  CBPWKLServiceCharacteristicManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/13.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLServiceCharacteristicManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPWKLServiceCharacteristicModel.h"

#pragma mark- 公司手环
static NSString* scanService1 = @"0xCC01";
static NSString* discoveredService1 = @"0xCC01";
static NSString* writeCBCharacteristice1 = @"0xCD20";
static NSString* notifyCBCharacteristic1 = @"0xCD01";

static NSString* scanService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* discoveredService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* writeCBCharacteristice2 = @"D44BC439-ABFD-45A2-B575-925416129600";
static NSString* notifyCBCharacteristic2 = @"D44BC439-ABFD-45A2-B575-925416129601";

static NSString* scanService3 = @"00001802-0000-1000-8000-00805f9b34fb";
static NSString* discoveredService3 = @"000056ef-0000-1000-8000-00805f9b34fb";
static NSString* writeCBCharacteristice3 = @"000034e1-0000-1000-8000-00805f9b34fb";
static NSString* notifyCBCharacteristic3 = @"000034e2-0000-1000-8000-00805f9b34fb";

static NSString* scanService4 = @"0x6666";
static NSString* discoveredService4 = @"0x6666";
static NSString* writeCBCharacteristice4 = @"0x8877";
static NSString* notifyCBCharacteristic4 = @"0x8888";

static NSString* scanService5 = @"0xFCFA";
static NSString* discoveredService5 = @"0xFCFA";
static NSString* writeCBCharacteristice5 = @"0x00D4";
static NSString* notifyCBCharacteristic5 = @"0x01D4";

static NSString* scanService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* discoveredService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* writeCBCharacteristice6 = @"A44BC439-ABFD-45A2-B575-925416129600";
static NSString* notifyCBCharacteristic6 = @"0xA44BC439-ABFD-45A2-B575-925416129601";

#pragma mark-32 手表
static NSString* scanService7 = nil; // 32手表
static NSString* discoveredService7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* writeCBCharacteristic7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* notifyCBCharacteristic7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";

#pragma mark- Cypress 普通的
static NSString* scanService8 = @"000056ef-0000-1000-8000-00805f9b34fb";//006F
// discoveredService 同 discoveredService3, 特征也一样

#pragma mark- Cypress 升级模式
static NSString* scanService9 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F
static NSString* discoveredService9 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F
static NSString* writeCBCharacteristice9 = @"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F
static NSString* notifyCBCharacteristic9 = @"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F
//读写服务UUID



static NSString * SPOTA_SERVICE_UUID     = @"0000fef5-0000-1000-8000-00805f9b34fb";
static NSString * SPOTA_MEM_DEV_UUID     = @"8082caa8-41a6-4021-91c6-56f9b954cc34";
static NSString * SPOTA_GPIO_MAP_UUID    = @"724249f0-5ec3-4b5f-8804-42345af08651";
static NSString * SPOTA_MEM_INFO_UUID    = @"6c53db25-47a1-45fe-a022-7c92fb334fd4";
static NSString * SPOTA_PATCH_LEN_UUID   = @"9d84b9a3-000c-49d8-9183-855b673fda31";
static NSString * SPOTA_PATCH_DATA_UUID  = @"457871e8-d516-4ca1-9116-57d0b17b9cb2";
static NSString * SPOTA_SERV_STATUS_UUID = @"5f78df94-798c-46f5-990a-b3eb6a065c88";


@interface CBPWKLServiceCharacteristicManager ()

@property (nonatomic, strong) NSArray *scanServices;

@property (nonatomic, strong) NSArray *discoverServices;

@property (nonatomic, strong) NSArray *charateristics;

@property (nonatomic, strong) NSArray *readCharateristics;

@property (nonatomic, strong) NSArray *writeCharateristics;

@property (nonatomic, strong) NSMutableArray<CBPWKLServiceCharacteristicModel *> *serviceCharacteristicModels;


@end

@implementation CBPWKLServiceCharacteristicManager


+ (instancetype)shareManager {
    static CBPWKLServiceCharacteristicManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (NSArray *)scanServiceUUIDs {
    if (_scanServices == nil) {
        _scanServices = @[[CBUUID UUIDWithString: scanService1], [CBUUID UUIDWithString: scanService2], [CBUUID UUIDWithString: scanService3], [CBUUID UUIDWithString: scanService4], [CBUUID UUIDWithString: scanService5], [CBUUID UUIDWithString: scanService6], [CBUUID UUIDWithString: scanService7], [CBUUID UUIDWithString: scanService8]];
    }
    return _scanServices;
}

- (NSArray<CBUUID *> *)discoverServiceUUIDs {
    if (_discoverServices == nil) {
        _discoverServices = @[[CBUUID UUIDWithString: discoveredService1], [CBUUID UUIDWithString: discoveredService2], [CBUUID UUIDWithString: discoveredService3], [CBUUID UUIDWithString: discoveredService4], [CBUUID UUIDWithString: discoveredService5], [CBUUID UUIDWithString: discoveredService6], [CBUUID UUIDWithString: discoveredService7]];
    }
    return _discoverServices;
}



- (NSArray<CBPWKLServiceCharacteristicModel *> *)serviceCharacteristicModels {
    
    if (_serviceCharacteristicModels == nil) {
        
        _serviceCharacteristicModels = [NSMutableArray arrayWithCapacity: 7];
        
        // 添加特征模型
        NSArray<CBUUID *> *discover = [self discoverServices];
        for (NSInteger index = 0; index < discover.count; ++index) {
            CBPWKLServiceCharacteristicModel *model = [[CBPWKLServiceCharacteristicModel alloc] init];
            [_serviceCharacteristicModels addObject: model];
            model.serviceUUID = discover[index];
            switch (index + 1) {
                case 1: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic1];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice1];
                    break;
                }
                case 2: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic2];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice2];
                    break;
                }
                case 3: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic3];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice3];
                    break;
                }
                case 4: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic4];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice4];
                    break;
                }
                case 5: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic5];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice5];
                    break;
                }
                case 6: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic6];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristice6];
                    break;
                }
                case 7: {
                    model.notifyCharacteristicUUID = [CBUUID UUIDWithString: notifyCBCharacteristic7];
                    model.writeCharacteristicUUID = [CBUUID UUIDWithString: writeCBCharacteristic7];
                    break;
                }
                    
                default:
                    break;
            }
            
        }

    }
    
    return _serviceCharacteristicModels;
}





@end
