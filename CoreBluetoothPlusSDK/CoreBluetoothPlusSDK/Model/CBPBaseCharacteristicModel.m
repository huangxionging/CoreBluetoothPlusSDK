//
//  CBPBaseCharacteristicModel.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseCharacteristicModel.h"



@interface CBPBaseCharacteristicModel ()


@end

@implementation CBPBaseCharacteristicModel

+ (instancetype) modelWithDictionary: (NSDictionary *) diction {
    
    CBPBaseCharacteristicModel *model = [[super alloc] init];
    
    if (model) {
        model.chracteristic = diction[@"chracteristic"];
        model.flag = diction[@"flag"];
    }
    
    return model;
}

@end
