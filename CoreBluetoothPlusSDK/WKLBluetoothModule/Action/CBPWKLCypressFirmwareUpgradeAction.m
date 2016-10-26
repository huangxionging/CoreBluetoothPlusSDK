//
//  CBPWKLCypressFirmwareUpgradeAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/10.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLCypressFirmwareUpgradeAction.h"
#import "CBPDispatchMessageManager.h"

@implementation CBPWKLCypressFirmwareUpgradeAction
+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x11", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 同步参数,
                            @"cypress_firmware_upgrade"];
    // 返回接口
    return interfaces;
}
- (void) actionData {
    Byte byteData[3]={0};
    byteData[0]= 0x5a;
    byteData[1]=0x11;
    NSData *data = [NSData dataWithBytes:byteData length:3];
}
@end
