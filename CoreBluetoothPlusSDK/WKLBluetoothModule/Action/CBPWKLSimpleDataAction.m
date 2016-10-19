//
//  CBPWKLSimpleDataAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/13.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLSimpleDataAction.h"
#import "NSDate+CBPUtilityTool.h"
#import "CBPHexStringManager.h"
#import "CBPBinStringManager.h"
#import "CBPDispatchMessageManager.h"

@implementation CBPWKLSimpleDataAction

+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x0d", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 检查电量,
                            @"check_battery_power",
                            @"check_device_serial",
                            @"set_device_serial",
                            @"call_remind_name",
                            @"heart_rate_feature",
                            @"pet_motion_parameter",
                            @"check_one_day_total_steps",
                            @"check_device_current_time",
                            @"temperature_function",
                            @"app_front_and_back_state",
                            @"debug_info",
                            @"device_debug_info",
                            @"device_current_steps",
                            @"device_heart_rate",
                            @"device_battery_power",
                            @"device_temperature",
                            ];
    // 返回接口
    return interfaces;
}

- (void) actionData {
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x0d;
    
    NSString *interface = parameter[@"interface"];
    
    // 指示接口
    NSInteger index = [[CBPWKLSimpleDataAction actionInterfaces] indexOfObject: interface];
    
    if (index <= 9) {
        bytes[3] = 0x80 + index;
    } else {
        return;
    }

    // 0, 1 都没有参数, 2 不需要实现
    switch (index) {
        case 4:
        case 8: { // 心率和体温参数一致
            NSString *switchValue = parameter[@"switch_value"];
            bytes[4] = switchValue.integerValue;
            
            // 间隔
            NSString *interval = parameter[@"interval"];
            bytes[5] = interval.integerValue / 256;
            bytes[6] = interval.integerValue % 256;
            
            // 次数
            NSString *frequency = parameter[@"frequency"];
            bytes[7] = frequency.integerValue / 256;
            bytes[8] = frequency.integerValue % 256;
            break;
        }
        case 6: { // 查询一天总步数
            NSString *dateString = parameter[@"date"];
            NSDate *date = [NSDate dateWithFormatString: @"yyyy-MM-dd" andWithDateString: dateString];
            
            bytes[4] = date.yearOfGregorian - 2000;
            bytes[5] = date.monthOfYear;
            bytes[6] = date.dayOfMonth;
            
            break;
        }
        
        case 9: {
            NSString *state = parameter[@"state"];
            bytes[4] = state.integerValue;
            
            NSString *timeOut = parameter[@"time_out"];
            bytes[5] = timeOut.integerValue / 256;
            bytes[6] = timeOut.integerValue % 256;
            
            break;
        }
        default:
            break;
    }
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    NSLog(@"%@", updateDataModel.actionData);
    
    Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        // 待回传的结果
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        // 设备回复数据
        if (bytes[0] == 0x5b && bytes[1] == 0x0d) {
            
            switch (bytes[3]) {
                case 0x80: {
                    Byte power = bytes[4];
                    NSString *batteryPower = [NSString stringWithFormat:@"%ld", (long)power];
                    [result setObject: batteryPower forKey: @"battery_power"];
                    break;
                }
                case 0x81: {
                    NSString *deviceSerial = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[4] length: 16];
                    
                    [result setObject: deviceSerial forKey: @"device_serial"];
                    break;
                }
                case 0x84:
                case 0x88:{
                    Byte resultValue = bytes[4];
                    NSString *resultString = [NSString stringWithFormat:@"%ld", (long)resultValue];
                    [result setObject: resultString forKey: @"result"];
                    break;
                }
                case 0x86: {
                    NSInteger year = bytes[4] + 2000;
                    NSInteger month = bytes[5];
                    NSInteger day = bytes[6];
                    
                    NSString *date = [NSString stringWithFormat: @"%04ld-%02ld-%02ld", (long)year, (long)month, (long)day];
                    
                    [result setObject:date forKey: @"date"];
                    
                    // 总步数
                    NSInteger step = (bytes[7] << 24) + (bytes[8] << 16) + (bytes[9] << 8) + bytes[10];
                    NSString *steps = [NSString stringWithFormat: @"%ld", (long)step];
                    [result setObject: steps forKey: @"steps"];
                }
                default:
                    break;
            }
            
        } else if (bytes[0] == 0x5a && bytes[1] == 0x0d) {
            // 设备主动发数据
            switch (bytes[3]) {
                case 0x00: {
                    break;
                }
                case 0x01: {
                    // 当天总步数
                    // 总步数
                    NSInteger step = (bytes[4] << 24) + (bytes[5] << 16) + (bytes[6] << 8) + bytes[7];
                    NSString *steps = [NSString stringWithFormat: @"%ld", (long)step];
                    [result setObject: steps forKey: @"steps"];
                    break;
                }
                case 0x02: {
                    // 心率
                    NSInteger heartRateValue = bytes[4];
                    NSString *heartRate = [NSString stringWithFormat: @"%ld", (long)heartRateValue];
                    [result setObject: heartRate forKey: @"heart_rate"];
                    
                    // 标识
                    NSInteger flagValue = bytes[5];
                    NSString *flag = [NSString stringWithFormat: @"%ld", (long)flagValue];
                    [result setObject: flag forKey: @"flag"];
                    break;
                }
                case 0x03: {
                    // 电池电量
                    Byte power = bytes[4];
                    NSString *batteryPower = [NSString stringWithFormat:@"%ld", (long)power];
                    [result setObject: batteryPower forKey: @"battery_power"];
                }
                case 4: {
                    break;
                }
                default:
                    break;
            }
        }
        
        //
        // 回调
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", result, nil];
    }
}

- (void)timeOut {
    
}


@end
