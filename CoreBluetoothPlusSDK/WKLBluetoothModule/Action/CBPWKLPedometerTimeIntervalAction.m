//
//  CBPWKLPedometerTimeIntervalAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/1.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLPedometerTimeIntervalAction.h"
#import "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"

@implementation CBPWKLPedometerTimeIntervalAction

+ (void)load {
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
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

- (void)actionData {
    NSDictionary *dict = [self valueForKey: @"parameter"];
    
    NSString *timeInterval = dict[@"time_interval"]?dict[@"time_interval"]:@"30"; // 默认值为 30
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x02;
    bytes[3] = timeInterval.integerValue;
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
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

- (void)timeOut {
    
}

@end
