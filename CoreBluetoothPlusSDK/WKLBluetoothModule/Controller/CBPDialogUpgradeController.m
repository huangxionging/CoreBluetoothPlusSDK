//
//  CBPDialogUpgradeController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPDialogUpgradeController.h"
#import "CBPDispatchMessageManager.h"

@implementation CBPDialogUpgradeController

+ (void)load {
    
    // 注册控制器
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method: @"registerController:", self, nil];
}

+ (NSString *)controllerKey {
    return @"com.dialog.controller";
}


@end
