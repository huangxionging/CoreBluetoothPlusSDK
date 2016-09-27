//
//  CBPBasePeripheralModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPBasePeripheralModel : NSObject


/**
 信号量
 */
@property (nonatomic, assign) NSInteger singalValue;

/**
 *  外设
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 *  错误
 */
@property (nonatomic, strong) NSError *error;

@end
