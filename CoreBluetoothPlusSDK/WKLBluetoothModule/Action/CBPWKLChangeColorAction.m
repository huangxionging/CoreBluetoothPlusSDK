//
//  CBPWKLChangeColorAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/14.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLChangeColorAction.h"

@implementation CBPWKLChangeColorAction

- (NSData *)actionData {
    Byte bytes[20] = {0};

    // 更换颜色的关键参数
    bytes[0] = 0x5a;
    bytes[1] = 0x0c;
    bytes[3] = 0x05;
    
    // 颜色数据
    bytes[4] = self->_colorType;
    
    return [NSData dataWithBytes: bytes length: 20];
}

#pragma mark--接收操作数据
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
   
    NSLog(@"切换颜色的回复数据 : %@", [updateDataModel actionData]);
    
    // 判断回复数据
    if (updateDataModel.actionData && updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        if (bytes[0] == 0x5b && bytes[1] == 0x0c && bytes[2] == 0x00 && bytes[3] == 0x05 && bytes[4] == 0x00) {
//            self->_finishedBlock(nil);
        }
        else {
//            self->_finishedBlock(nil);
        }
    }
    
}

@end
