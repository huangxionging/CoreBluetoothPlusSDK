//
//  CBPBaseServiceModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPBaseServiceModel : NSObject

/**
 *  蓝牙服务
 */
@property (nonatomic, strong) CBService *service;

/**
 *  错误信息
 */
@property (nonatomic, strong) NSError *error;

@end
