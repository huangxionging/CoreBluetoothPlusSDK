//
//  CBPWKLDialogUpgradeServiceCharacteristicManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/14.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLDialogUpgradeServiceCharacteristicManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPWKLDialogUpgradeServiceCharacteristicModel.h"
#import "CBPDispatchMessageManager.h"

@interface CBPWKLDialogUpgradeServiceCharacteristicManager ()
@property (nonatomic, strong) CBPWKLDialogUpgradeServiceCharacteristicModel *serviceCharacteristicModel;
@property (nonatomic, strong) NSArray *discoverServices;
@end

@implementation CBPWKLDialogUpgradeServiceCharacteristicManager
+ (instancetype)shareManager {
    static CBPWKLDialogUpgradeServiceCharacteristicManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.serviceCharacteristicModel = [[CBPWKLDialogUpgradeServiceCharacteristicModel alloc] init];
    });
    
    return manager;
}

#pragma mark- 发现特征的服务
- (NSArray<CBUUID *> *)discoverServiceUUIDs {
    if (_discoverServices == nil) {
        _discoverServices = @[self.serviceCharacteristicModel.serviceUUID];
    }
    return _discoverServices;
}

#pragma mark- 特征
- (NSArray<CBUUID *> *)charateristicUUIDs {
    // 有返回值的调度
    return [[CBPDispatchMessageManager shareManager] dispatchReturnValueTarget: self.serviceCharacteristicModel method: @"characteristicUUIDs", nil];
    
}

#pragma mark- 模型
- (CBPWKLDialogUpgradeServiceCharacteristicModel *)serviceCharacteristicModel {
    return _serviceCharacteristicModel;
}

- (void)setServiceCharacteristic:(CBService *)service {
    // 是这个 UUID
    if ([service.UUID isEqual: self.serviceCharacteristicModel.serviceUUID]) {
        // 设置特征
        for (CBCharacteristic *characteristic in service.characteristics) {
            // 调度设置特征
            [[CBPDispatchMessageManager shareManager] dispatchTarget: self.serviceCharacteristicModel method: @"setCharacteristic:", characteristic, nil];
        }
    }
}

@end
