//
//  CBPWKLBindDeviceAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLBindDeviceAction.h"
#import <UIKit/UIKit.h>
#import "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"


@interface CBPWKLBindDeviceAction ()


@property (nonatomic, assign) NSInteger wklActionLength;

@end

@implementation CBPWKLBindDeviceAction

+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
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


- (NSInteger)actionLength {
    return self.wklActionLength;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.wklActionLength = 20;
    }
    
    return self;
}



#pragma mark---命令数据
- (NSData *)actionData {
    
    NSDictionary *dict = [self valueForKey: @"parameter"];
    
    NSString *interface = [dict objectForKey: @"interface"];
    // 类型
    NSUInteger index = [[CBPWKLBindDeviceAction actionInterfaces] indexOfObject: interface];
    
    // 当 interface 为 confirm_bind_device, 不发送数据
    if (index == 2) {
        return nil;
    }
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x0b;
    bytes[3] = index;
    
    // 解除绑定
    if (index == 3) {
        NSString *actionType = dict[@"action_type"]?dict[@"action_type"]:@"0";
        bytes[12] = actionType.integerValue;
    }
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
//    NSLog(@"绑定指令: %@", data);
    return data;
}

#pragma mark--- 接收数据的方法
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel) {
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        
        // 待回传的结果
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        // 被动接收
        if (bytes[0] == 0x5b && bytes[1] == 0x0b) {
            
            switch (bytes[3]) {
                case 0x00: {
                    
                    break;
                }
                case 0x01: {
                    
                    // 表示允许绑定
                    if (bytes[4] == 0x00) {
                        
                        // 结果
                        [result setObject: @"0" forKey: @"code"];
                        
                        NSString *hexTime = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[5] length: 2];
                        
                        // 转换为整数
                        NSInteger timeCount = [[CBPHexStringManager shareManager] integerForString: hexTime];
                        
                        // 获得时延
                        NSString *time = [NSString stringWithFormat: @"%ld", (long)timeCount];
                        
                        if (hexTime) {
                            // 设置时延参数
                            [result setObject: time forKey: @"time"];
                        }
                    }
                    break;
                }
                case 0x03: {
                    if (bytes[4] == 0x00) {
                        [result setObject: @"0" forKey: @"code"];
                    } else {
                        [result setObject: @"1" forKey: @"code"];
                    }
                    break;
                }
                default:
                    break;
            }
            
            // 回传结果
            [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", result, nil];
            
        } else if (bytes[0] == 0x5a && bytes[1] == 0x0b) {
            // 设备被绑定, 表示设备确认与APP绑定是否成功;
            if (bytes[3] == 0x02 && bytes[4] == 0x00) {
                
                // 准备回复绑定数据
                bytes[0] = 0x5b;
                //
                NSData *actionData = [NSData dataWithBytes: bytes length: 5];
                
                CBPBaseActionDataModel *actionDataModel = [CBPBaseActionDataModel modelWithAction: self];
                actionDataModel.actionData = actionData;
                actionDataModel.keyword = @"0x0b";
                id result = actionDataModel;
                // 回复数据
                [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
                // 回复指令完成
                
                NSDictionary *finishDict = @{@"code":@"0"};
                [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", finishDict, nil];
            }
        }
        
    }
    
}

- (void)timeOut {
    
    CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeTimeOut info: @"绑定流程超时"];
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
    NSLog(@"超时");
}


@end
