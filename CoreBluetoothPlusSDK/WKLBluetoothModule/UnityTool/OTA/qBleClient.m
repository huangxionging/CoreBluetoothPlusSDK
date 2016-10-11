//
//  QBleClient.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "QBleClient.h"
#import "OtaApi.h"
static NSString* braceletScanService1 = @"0xCC01";
static NSString* braceletScanService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* braceletScanService3 = @"00001802-0000-1000-8000-00805f9b34fb";
static NSString* braceletScanService4 = @"0x6666";
static NSString* braceletScanService5 = @"0xFCFA";
static NSString* braceletScanService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* braceletScanService7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 32手表
static NSString* braceletScanService8 = @"000056ef-0000-1000-8000-00805f9b34fb";//006F
static NSString* braceletScanService9 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F

//读写服务UUID
static NSString* braceletDiscoveredService1 = @"0xCC01";
static NSString* braceletDiscoveredService2 = @"0000FEE9-0000-1000-8000-00805F9B34FB";
static NSString* braceletDiscoveredService3 = @"000056ef-0000-1000-8000-00805f9b34fb";
static NSString* braceletDiscoveredService4 = @"0x6666";
static NSString* braceletDiscoveredService5 = @"0xFCFA";
static NSString* braceletDiscoveredService6 = @"0000FEE9-0000-1000-8000-00805F9B34FD";
static NSString* braceletDiscoveredService7 = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletDiscoveredService8 = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";//006F

//写数据UUID
static NSString* braceletWriteCBCharacteristice1 = @"0xCD20";
static NSString* braceletWriteCBCharacteristice2 = @"D44BC439-ABFD-45A2-B575-925416129600";
static NSString* braceletWriteCBCharacteristice3 = @"000034e1-0000-1000-8000-00805f9b34fb";
static NSString* braceletWriteCBCharacteristice4 = @"0x8877";
static NSString* braceletWriteCBCharacteristice5 = @"0x00D4";
static NSString* braceletWriteCBCharacteristice6 = @"A44BC439-ABFD-45A2-B575-925416129600";
static NSString* braceletWriteCBCharacteristice7 = @"0x6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletWriteCBCharacteristice8 = @"0x8888";
static NSString* braceletWriteCBCharacteristice9 = @"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F
//Notify数据UUID,读数据UUID
static NSString* braceletReadCBCharacteristic1 = @"0xCD01";
static NSString* braceletReadCBCharacteristic2 = @"D44BC439-ABFD-45A2-B575-925416129601";
static NSString* braceletReadCBCharacteristic3 = @"000034e2-0000-1000-8000-00805f9b34fb";
static NSString* braceletReadCBCharacteristic4 = @"0x8888";
static NSString* braceletReadCBCharacteristic5 = @"0x01D4";
static NSString* braceletReadCBCharacteristic6 = @"0xA44BC439-ABFD-45A2-B575-925416129601";
static NSString* braceletReadCBCharacteristic7 = @"0x6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString* braceletReadCBCharacteristic8 = @"0x8877";
static NSString* braceletReadCBCharacteristic9 =@"00060001-F8CE-11E4-ABF4-0002A5D5C51B";//006F

static NSString * Cypress_OTA_SERVICE_UUID = @"00060000-F8CE-11E4-ABF4-0002A5D5C51B";
static NSString * SPOTA_SERVICE_UUID     = @"0000fef5-0000-1000-8000-00805f9b34fb";
static NSString * SPOTA_MEM_DEV_UUID     = @"8082caa8-41a6-4021-91c6-56f9b954cc34";
static NSString * SPOTA_GPIO_MAP_UUID    = @"724249f0-5ec3-4b5f-8804-42345af08651";
static NSString * SPOTA_MEM_INFO_UUID    = @"6c53db25-47a1-45fe-a022-7c92fb334fd4";
static NSString * SPOTA_PATCH_LEN_UUID   = @"9d84b9a3-000c-49d8-9183-855b673fda31";
static NSString * SPOTA_PATCH_DATA_UUID  = @"457871e8-d516-4ca1-9116-57d0b17b9cb2";
static NSString * SPOTA_SERV_STATUS_UUID = @"5f78df94-798c-46f5-990a-b3eb6a065c88";

@implementation qBleClient

+(qBleClient *)sharedInstance
{
    static qBleClient *_client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[qBleClient alloc] init];
    });
    return _client;
}


#pragma mark  ----------------------外设设备代理 CBPeripheralDelegate---------------------------------------
#pragma mark -- 发现服务代理

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"代理3");
               /*********************************************************************
             LibOTA升级部分
             *********************************************************************/
            [_discoveredServices removeAllObjects];
            
            for (CBService *aService in peripheral.services)
            {
                [peripheral discoverCharacteristics : nil forService : aService];
                
                if( ![_discoveredServices containsObject : aService] )
                {
                    [_discoveredServices addObject : aService];
                }
            }
    
            

    
    NSLog(@"找到服务");
    
    @try {
        for (CBService *service in peripheral.services) {
            NSLog(@"service.uuid=%@",service.UUID);
            if ([[service.UUID UUIDString] isEqualToString:braceletScanService7]) {
                [_peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:braceletDiscoveredService7]] forService:service];
                break;
            }
            
            if ([[service.UUID UUIDString] isEqualToString:braceletDiscoveredService8]) {
                [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:braceletReadCBCharacteristic9]] forService:service];
                break;
            }
        }
    } @catch (NSException *exception) {
        
    }
    
}

#pragma mark --发现特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"代理4");
    @try {

                      /*********************************************************************
                 OTA升级部分
                 *********************************************************************/
                if(_bleUpdateForOtaDelegate)
                {
                    [_bleUpdateForOtaDelegate bleDidUpdateCharForOtaService:peripheral withService:service error:error];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName : bleDiscoveredCharacteristicsNoti
                                                                        object : nil
                                                                      userInfo : nil];
                }
    }
    @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
    }
    
    
    NSLog(@"找到特征");
    NSLog(@"service.uuid=%@",service.UUID);
    
    for (CBCharacteristic *car in service.characteristics) {
        if ([[car.UUID UUIDString] isEqualToString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"]) {
            [_peripheral setNotifyValue:YES forCharacteristic:car];

            break;
        }
        
        if ([[car.UUID UUIDString] isEqualToString:braceletDiscoveredService8]) {
            [peripheral setNotifyValue:YES forCharacteristic:car];
//            [self privateStopConnectTimer];
//            connectSuccessBlock_(@"cypress111");
            break;
        }
    }
    
}

#pragma mark -- 蓝牙信号强度
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
//    if (_rssiDataDelegate && [_rssiDataDelegate respondsToSelector:@selector(pubReadRssi:)]) {
//        [_rssiDataDelegate pubReadRssi:abs(RSSI.intValue)];
//    }
}


#pragma mark -- 蓝牙数据写成功代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

#pragma mark -- 数据返回代理（与外设做数据交互）
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    @try {
    
        for (CBService *aService in aPeripheral.services)
        {
            [_bleUpdateForOtaDelegate bleDidUpdateValueForOtaChar : aService withChar : characteristic error : error];
            NSLog(@"文件数据: %@", characteristic.value);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
    }
}


@end
