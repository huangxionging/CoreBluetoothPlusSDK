//
//  CBPBasePeripheralModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 *  外设连接状态
 */
typedef NS_ENUM(NSUInteger, BasePeripheralState) {
    kBasePeripheralStateConnected = 0,
    kBasePeripheralStateError,
};


@interface CBPBasePeripheralModel : NSObject

/**
 *  外设
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 *  连接状态
 */
@property (nonatomic, assign) BasePeripheralState state;

/**
 *  错误
 */
@property (nonatomic, strong) NSError *error;

@end
