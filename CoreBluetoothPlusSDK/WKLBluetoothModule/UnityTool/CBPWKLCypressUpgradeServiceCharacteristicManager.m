//
//  CBPWKLCypressUpgradeServiceCharacteristicManager.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLCypressUpgradeServiceCharacteristicManager.h"
#import "CBPWKLCypressUpgradeServiceCharacteristicModel.h"

@interface CBPWKLCypressUpgradeServiceCharacteristicManager()


/**
 服务特征模型
 */
@property (nonatomic, strong) CBPWKLCypressUpgradeServiceCharacteristicModel *serviceCharacteristicModel;

@end

@implementation CBPWKLCypressUpgradeServiceCharacteristicManager

+ (instancetype)shareManager {
    static CBPWKLCypressUpgradeServiceCharacteristicManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.serviceCharacteristicModel = [[CBPWKLCypressUpgradeServiceCharacteristicModel alloc] init];
    });
    
    return manager;
}

- (NSArray<CBUUID *> *)scanServiceUUIDs {
    return @[self.serviceCharacteristicModel.scanServiceUUID];
}

- (NSArray<CBUUID *> *)discoverServiceUUIDs {
    return @[self.serviceCharacteristicModel.discoverServiceUUID];
}

- (CBPWKLCypressUpgradeServiceCharacteristicModel *)serviceCharacteristicModel {
    return _serviceCharacteristicModel;
}

- (void)setServiceCharacteristic:(CBService *)service {
    [self.serviceCharacteristicModel setDiscoverService: service];
}


@end
