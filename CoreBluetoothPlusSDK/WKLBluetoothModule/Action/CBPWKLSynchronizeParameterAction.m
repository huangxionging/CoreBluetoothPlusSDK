//
//  CBPWKLSynchronizeParameterAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/17.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLSynchronizeParameterAction.h"
#import "NSDate+CBPUtilityTool.h"

@interface CBPWKLSynchronizeParameterAction ()

@end

@implementation CBPWKLSynchronizeParameterAction

- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x01;
    
    
    NSDate *date = [NSDate date];
    date.yearOfGregorian
    // 时间
    NSArray *dateTimes = [self.time componentsSeparatedByString: @" "];
    
    // 分割时间
    if (dateTimes.count == 2) {
        NSArray *dates = [dateTimes[0] componentsSeparatedByString: @"/"];
        NSArray *times = [dateTimes[1] componentsSeparatedByString: @":"];
        
        if (dates.count == 3 && times.count == 3) {
            bytes[3] = [dates[0] integerValue] - 2000;
            bytes[4] = [dates[1] integerValue];
            bytes[5] = [dates[2] integerValue];
            
            bytes[6] = [times[0] integerValue];
            bytes[7] = [times[1] integerValue];
            bytes[8] = [times[2] integerValue];
        }
    }
    
    bytes[9] = self.steps / 256;
    bytes[10] = self.steps % 256;
    bytes[11] = self.wearType;
    bytes[12] = self.sportType;
    
    if (self.isFirstSynchronize) {
        bytes[13] = 'x'; // 或者写 0x78
    }
    
    bytes[16] = self.genderType * 128 + self.age;
    bytes[17] = self.weight;
    bytes[18] = self.bodyHeight;
    bytes[19] = 0xa0;
    NSData *data = [NSData dataWithBytes: bytes length: 20];
//    CBPDEBUG;
    return data;
}

#pragma mark- 指令标识符
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x01", nil];
}

#pragma mark- 重写接受数据方法
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 表示同步参数的返回数据
        if (bytes[0] == 0x5b && bytes[1] == 0x01) {
            self.deviceNumber = [NSString stringWithFormat: @"%02x-%02x-%02x-%02x-%02x-%02x-%02x-%02x", bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10]];
            
            // 设备编号
            NSLog(@"设备编号: %@", [self.deviceNumber lowercaseString]);
            
            // 协议版本
            self.protocolEditionNumber = bytes[11] * 256 + bytes[12];
            
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
            NSInteger gujian = bytes[13] * 256 + bytes[14];
            
            NSString *string = [NSString stringWithFormat: @"%c%c%c%c%c", bytes[15], bytes[16], bytes[17], bytes[18], bytes[19]];
            NSLog(@"设备型号:%@ ==== 固件版本: %@", string, @(gujian));
            
        }
    }
    
}

@end
