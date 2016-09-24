//
//  CBPWKLWaterCupsAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/8.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLWaterCupsAction.h"
#import "CBPHexStringManager.h"
#import "NSDate+CBPUtilityTool.h"
#import "CBPDispatchMessageManager.h"
@implementation CBPWKLWaterCupsAction


+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x08", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 查询设备版本
                            @"setting_cups_parameter",
                            @"check_cups_state"];
    // 返回接口
    return interfaces;
}

- (NSData *)actionData {
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    NSString *interface = parameter[@"interface"];
    
    // 指示接口
    NSInteger index = [[CBPWKLWaterCupsAction actionInterfaces] indexOfObject: interface];
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x08;
    
    // 接口
    bytes[3] = index;
    
    // 表明设置水杯参数
    if (index == 0) {
        
        // 时间
        NSString *time = parameter[@"time"];
        
        // 日期格式
        NSDate *date = [NSDate dateWithFormatString: @"yyyy-MM-dd hh:mm" andWithDateString: time];
        NSInteger year = date.yearOfGregorian - 2000;
        NSInteger month = date.monthOfYear;
        NSInteger day = date.dayOfMonth;
        NSInteger hour = date.hour;
        NSInteger minute = date.minute;
        NSInteger second = date.second;
        
        bytes[4] = year;
        bytes[5] = month;
        bytes[6] = day;
        bytes[7] = hour;
        bytes[8] = minute;
        bytes[9] = second;
        
        // led 提醒
        NSString *ledRemind = parameter[@"led_remind"];
        
        // 蜂鸣器提醒
        NSString *buzzerRemind = parameter[@"buzzer_remind"];
        
        // 是否有效
        NSString *valid = parameter[@"valid"];
        
        bytes[11] = ledRemind.integerValue * 4 + buzzerRemind.integerValue * 2 + valid.integerValue;
        
    }
    
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    //    NSLog(@"绑定指令: %@", data);
    return data;
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel) {
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 待回传的结果
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        // 被动接收
        if (bytes[0] == 0x5b && bytes[1] == 0x0f) {
            
            NSString *resultString = nil;
            if (bytes[3] == 0xff) {
                resultString = @"3";
            } else {
                NSInteger value = bytes[3];
                resultString = [NSString stringWithFormat: @"%ld", (long)value];
            }
            
            [result setObject: resultString forKey: @"result"];
            
            //  完成
           
            [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", result, nil];
        }
    }
}

@end
