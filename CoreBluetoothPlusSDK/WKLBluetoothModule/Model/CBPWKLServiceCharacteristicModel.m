//
//  CBPWKLServiceCharacteristicModel.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/13.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLServiceCharacteristicModel.h"

@implementation CBPWKLServiceCharacteristicModel

#pragma mark- 通知和写特征都有
- (BOOL)isReady {
    if (self.notifyCharacteristic && self.writeCharacteristic) {
        return YES;
    } else {
        return NO;
    }
}

- (NSArray<CBUUID *> *)characteristicUUIDs {
    
    // 写和通知同时存在
    if (self.writeCharacteristicUUID && self.notifyCharacteristicUUID) {
        return @[self.notifyCharacteristicUUID, self.writeCharacteristicUUID];
    }
    return nil;
}

@end
