//
//  CBPWKLServiceCharacteristicManager.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/13.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBUUID, CBPWKLServiceCharacteristicModel;

/**
 特征服务管理器
 */
@interface CBPWKLServiceCharacteristicManager : NSObject

+ (instancetype)shareManager;


/**
 扫描服务

 @return 扫描服务 UUID
 */
- (NSArray<CBUUID *> *)scanServiceUUIDs;

/**
 发现服务

 @return 发现服务 UUID 的数组
 */
- (NSArray<CBUUID *> *)discoverServiceUUIDs;


/**
 服务特征模型

 @return 服务特征模型数组
 */
- (NSArray<CBPWKLServiceCharacteristicModel *> *)serviceCharacteristicModels;

@end
