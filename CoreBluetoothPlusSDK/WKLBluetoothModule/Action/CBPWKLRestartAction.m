//
//  CBPWKLRestartAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLRestartAction.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "CBPHexStringManager.h"

@implementation CBPWKLRestartAction


+ (void)load {
    
    // 选取 方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x0f", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 查询设备版本,
                            @"restart_device"];
    // 返回接口
    return interfaces;
}

- (NSData *)actionData {
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x0f;
    
    // 内容
    NSString *contentType = parameter[@"content_type"];
    bytes[3] = contentType.integerValue;
    
    // 是否需要回复
    NSString *response = parameter[@"response"];
    bytes[4] = response.integerValue;
    
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
            SEL selector = NSSelectorFromString(@"callBackResult:");
            // 发送消息
            objc_msgSend(self, selector, result);
        }
    }
}

@end
