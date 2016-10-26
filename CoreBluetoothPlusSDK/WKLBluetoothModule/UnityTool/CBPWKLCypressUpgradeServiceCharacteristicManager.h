//
//  CBPWKLCypressUpgradeServiceCharacteristicManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/22.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBService, CBUUID, CBPWKLCypressUpgradeServiceCharacteristicModel;
@interface CBPWKLCypressUpgradeServiceCharacteristicManager : NSObject


/**
 cypress 升级服务管理器
 
 @return cypress 升级服务管理器
 */
+ (instancetype)shareManager;

- (NSArray<CBUUID *> *)scanServiceUUIDs;

/**
 发现服务
 
 @return 发现服务 UUID 的数组
 */
- (NSArray<CBUUID *> *)discoverServiceUUIDs;


/**
 发现特征
 
 @return 特征数组
 */
- (NSArray<CBUUID *> *)charateristicUUIDs;


/**
 升级服务特征模型
 
 @return
 */
- (CBPWKLCypressUpgradeServiceCharacteristicModel *)serviceCharacteristicModel;

/**
 设置服务特征
 
 @param service 服务
 */
- (void) setServiceCharacteristic: (CBService *) service;

@end
