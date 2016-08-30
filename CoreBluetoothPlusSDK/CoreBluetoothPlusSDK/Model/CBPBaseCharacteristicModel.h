//
//  CBPBaseCharacteristicModel.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPBaseCharacteristicModel : NSObject

/**
 *  特征
 */
@property (nonatomic, strong) CBCharacteristic *chracteristic;

/**
 *  @author huangxiong
 *
 *  @brief flag, @"1" 标识读, @"2" 表示写
 */
@property (nonatomic, copy) NSString *flag;

/**
 *  @author huangxiong
 *
 *  @brief 通过字典产生模型
 *
 *  @param diction 参数字典
 *
 *  @return 模型
 */
+ (instancetype) modelWithDictionary: (NSDictionary *) diction;

@end
