//
//  CBPWKLSearchDeviceAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLSearchDeviceAction.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation CBPWKLSearchDeviceAction


- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    if (updateDataModel.actionDatatype == kBaseActionDataTypeWriteAnswer) {
        
        // 表明查找成功
        if (!updateDataModel.error) {
            NSLog(@"查找成功");
            
            Ivar ivar = class_getInstanceVariable([self class], "_finishedBlock");
            finishedBlock _finishedBlock = object_getIvar(self, ivar);
            _finishedBlock(nil);
            
        }
        else {
            Ivar ivar = class_getInstanceVariable([self class], "_finishedBlock");
            finishedBlock _finishedBlock = object_getIvar(self, ivar);
            _finishedBlock(nil);
        }
    }
}


#pragma mark---操作数据, 每个子类需重写
- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    // 0x5a 表示主动发送, 0x5b 表示回复
    bytes[0] = 0x5a;
    // 表示命令
    bytes[1] = 0x0c;
    bytes[3] = 0x06;
    return [NSData dataWithBytes: bytes length: 20];
}

@end
