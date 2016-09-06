//
//  CBPWKLPedometerTimeIntervalAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/1.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLPedometerTimeIntervalAction.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "CBPHexStringManager.h"

@implementation CBPWKLPedometerTimeIntervalAction

+ (void)load {
    // 选取 方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x02", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    // 计步数据保存时间间隔
    NSArray *interfaces =  @[@"set_pedometer_data_save_time_interval"];
    // 返回接口
    return interfaces;
}

- (NSData *)actionData {
    NSDictionary *dict = [self valueForKey: @"parameter"];
    
    NSString *timeInterval = dict[@"time_interval"]?dict[@"time_interval"]:@"30"; // 默认值为 30
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x02;
    bytes[3] = timeInterval.integerValue;
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    
    //    NSLog(@"时间间隔: %@", data);
    return data;
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel) {
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 待回传的结果
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        // 被动接收
        if (bytes[0] == 0x5b && bytes[1] == 0x02) {
            [result setObject: @"0" forKey: @"code"];
        }
    }
}

@end
