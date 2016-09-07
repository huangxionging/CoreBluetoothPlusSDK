//
//  CBPWKLSynchronizeParameterAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/17.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLSynchronizeParameterAction.h"
#import "NSDate+CBPUtilityTool.h"
#import <objc/message.h>
#import "CBPHexStringManager.h"

@interface CBPWKLSynchronizeParameterAction ()

@end

@implementation CBPWKLSynchronizeParameterAction

+ (void)load {
    
    // 选取 方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x01", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 同步参数,
                            @"synchronize_parameter"];
    // 返回接口
    return interfaces;
}


- (NSData *)actionData {
    
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x01;
    
    
    NSDate *date = [NSDate date];
    
    NSInteger year = [date yearOfGregorian];
    NSInteger month = [date monthOfYear];
    NSInteger day = [date dayOfMonth];
    NSInteger hour = [date hour];
    NSInteger minute = [date minute];
    NSInteger second = [date second];
    
    // 年
    bytes[3] = year - 2000;
    bytes[4] = month;
    bytes[5] = day;
    bytes[6] = hour;
    bytes[7] = minute;
    bytes[8] = second;
    
    if (parameter) {
        
        // 运动目标
        NSString *stepGoal = parameter[@"step_goal"]?parameter[@"step_goal"]:@"100";
        bytes[9] = stepGoal.integerValue / 256;
        bytes[10] = stepGoal.integerValue % 256;
        
        // 佩戴位置
        NSString *wearType = parameter[@"wear_ype"]?parameter[@"wear_ype"]:@"1";
        bytes[11] = wearType.integerValue;
        
        // 运动类型
        NSString *sportType = parameter[@"sport_type"]?parameter[@"sport_type"]:@"1";
        bytes[12] = sportType.integerValue;
        
        // 标识
        NSString *synchronizeFlag = parameter[@"synchronize_flag"]?parameter[@"synchronize_flag"]:@"0";
        NSInteger flag = synchronizeFlag.integerValue;
        // 第一次同步
        if (flag == 0) {
            bytes[13] = 0x78; // 字符 'x'
        } else {
            bytes[13] = 0x00;
        }
    }
    
    // 性别和年龄
    NSString *genderType = parameter[@"gender_type"]?parameter[@"gender_type"]:@"0";
    NSString *age = parameter[@"age"]?parameter[@"age"]:@"25";
    bytes[16] = genderType.integerValue * 128 + age.integerValue;
    
    // 体重
    NSString *weight = parameter[@"weight"]?parameter[@"weight"]:@"60";
    bytes[17] = weight.integerValue;
    
    // 身高
    NSString *height = parameter[@"height"]?parameter[@"height"]:@"170";
    bytes[18] = height.integerValue;
    
    // 度量
    NSString *measure = parameter[@"measure"];
    // 断连提醒
    NSString *disconnectRemind = parameter[@"disconnect_remind"];
    
    // 只要任何一个存在, 则修改参数
    if (measure || disconnectRemind) {
        
        measure = measure?measure:@"0";
        disconnectRemind = disconnectRemind?disconnectRemind:@"0";
        bytes[19] = 128 + measure.integerValue * 64 + disconnectRemind.integerValue * 32;
    }
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    NSLog(@"同步参数:%@", data);
//    CBPDEBUG;
    return data;
}

#pragma mark- 重写接受数据方法
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser && updateDataModel.actionData) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 表示同步参数的返回数据
        if (bytes[0] == 0x5b && bytes[1] == 0x01) {
            
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
            
            // 设备编码
            NSString *deviceID = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[5] length: 6];
        
            NSLog(@"设备编号: %@", [deviceID lowercaseString]);
            if (deviceID) {
                [result setObject: [deviceID lowercaseString] forKey: @"device_id"];
            }
            
            // 协议版本
            NSString *protocolVersion = [NSString stringWithFormat: @"%ld", (long) bytes[12]];
            NSLog(@"协议版本: %@", [protocolVersion lowercaseString]);
            if (protocolVersion) {
                [result setObject: protocolVersion forKey: @"protocol_version"];
            }
            
            NSString *upgradedType = [NSString stringWithFormat: @"%ld", (long)bytes[11]];
            
            // 升级方式
            if (upgradedType) {
                [result setObject:[upgradedType lowercaseString] forKey: @"upgraded_type"];
            }
            
            if (bytes[11] == 0x01) {
                
                NSLog(@"昆天科升级");
            }
            else if (bytes[11] == 0x02) {
                NSLog(@"Dialog升级");
            }
            else if (bytes[11] == 0x00) {
                NSLog(@"普通升级");
            }
            // 固件版本
            NSInteger firmware = bytes[13] * 256 + bytes[14];
            NSString *firmwareVersion = [NSString stringWithFormat: @"%ld", (long)firmware];
            NSLog(@"固件版本: %@", [firmwareVersion lowercaseString]);
            if (firmwareVersion) {
                [result setObject: firmwareVersion forKey: @"firmware_version"];
            }
            
            // 设备类型 要大写
            NSString *deviceType = [NSString stringWithFormat: @"%c%c%c%c%c", bytes[15], bytes[16], bytes[17], bytes[18], bytes[19]];
            if (deviceType) {
                [result setObject: [deviceType uppercaseString] forKey: @"device_type"];
            }
            NSLog(@"设备类型: %@", [deviceType uppercaseString]);
            
            // 
            // 选取 方法
            SEL selector = NSSelectorFromString(@"callBackResult:");
            // 发送消息
            objc_msgSend(self, selector, result);
        }
    }
    
}

@end
