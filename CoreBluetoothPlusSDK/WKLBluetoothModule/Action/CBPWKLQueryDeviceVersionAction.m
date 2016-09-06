//
//  CBPWKLQueryDeviceVersionAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLQueryDeviceVersionAction.h"

@implementation CBPWKLQueryDeviceVersionAction


+ (void)load {
    
    // 选取 方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x0b", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 查询绑定状态,
                            @"check_bind_state",
                            // 申请绑定设备
                            @"apply_bind_device",
                            // 确认绑定
                            @"confirm_bind_device",
                            // 删除绑定
                            @"cancel_bind_device"];
    // 返回接口
    return interfaces;
}


@end
