//
//  CBPWKLQueryDeviceVersionAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLQueryDeviceVersionAction.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "CBPHexStringManager.h"

@implementation CBPWKLQueryDeviceVersionAction


+ (void)load {
    
    // 选取 方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x10", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 查询设备版本,
                            @"query_device_version"];
    // 返回接口
    return interfaces;
}

- (NSData *)actionData {
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x10;
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    //    NSLog(@"绑定指令: %@", data);
    return data;
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser && updateDataModel.actionData) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 表示同步参数的返回数据
        if (bytes[0] == 0x5b && bytes[1] == 0x10) {
            
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
            
            
            NSInteger firmware = bytes[3] * 256 + bytes[4];
            NSString *firmwareVersion = [NSString stringWithFormat: @"%ld", (long)firmware];
            NSLog(@"固件版本: %@", [firmwareVersion lowercaseString]);
            if (firmwareVersion) {
                [result setObject: firmwareVersion forKey: @"firmware_version"];
            }
            
            // 设备编码
            NSString *deviceID = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[7] length: 6];
            
            NSLog(@"设备编号: %@", [deviceID lowercaseString]);
            if (deviceID) {
                [result setObject: [deviceID lowercaseString] forKey: @"device_id"];
            }
            
            // 协议版本
            NSString *protocolVersion = [NSString stringWithFormat: @"%ld", (long) bytes[14]];
            NSLog(@"协议版本: %@", [protocolVersion lowercaseString]);
            if (protocolVersion) {
                [result setObject: protocolVersion forKey: @"protocol_version"];
            }
            
            NSString *upgradedType = [NSString stringWithFormat: @"%ld", (long)bytes[13]];
            
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
