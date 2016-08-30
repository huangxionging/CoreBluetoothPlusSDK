//
//  CBPWKLBindDeviceAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLBindDeviceAction.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "CBPHexStringManager.h"

typedef NS_ENUM(NSUInteger, WKLBindDeviceState) {
    /**
     *  查询绑定状态
     */
    kWKLBindDeviceStateQuery = 10001,
    /**
     *  申请绑定
     */
    kWKLBindDeviceStateApply,
    
    /**
     *  确认绑定
     */
    kWKLBindDeviceStateConfirm,
    
    /**
     * 解除绑定
     */
    kWKLBindDeviceStateCancel
};

@interface CBPWKLBindDeviceAction ()


@property (nonatomic, assign) NSInteger wklActionLength;

/**
 *  绑定状态
 */
@property (nonatomic, assign) WKLBindDeviceState bindDeviceState;

@end

@implementation CBPWKLBindDeviceAction

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


- (instancetype)initWithParameter:(id)parameter answer:(void (^)(CBPBaseActionDataModel *))answerBlock finished:(void (^)(id))finished {
    if (self = [super initWithParameter:parameter answer:answerBlock finished:finished]) {
        id param = nil;
        
        param = [self valueForKey: @"parameter"];
        
        NSLog(@"%@", param);
    }
    return self;
}


#pragma mark---命令数据
- (NSData *)actionData {
    
    NSDictionary *dict = [self valueForKey: @"parameter"];
    
    NSString *interface = [dict objectForKey: @"interface"];
    // 类型
    NSUInteger index = [[CBPWKLBindDeviceAction actionInterfaces] indexOfObject: interface];
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x0b;
    bytes[3] = index;
    
    // 回复确认绑定
    if (self->_bindDeviceState == kWKLBindDeviceStateConfirm) {
        bytes[0] = 0x5a;
    }
    
    // 解除绑定
    if (self->_bindDeviceState == kWKLBindDeviceStateCancel) {
        
    }
    
    return [NSData dataWithBytes: bytes length: 20];
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
                        
                        
                        // 16 位编码
                        NSString *hexCode =  [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[7] length: 8];
                        
                        if (hexCode) {
                            [result setObject: hexCode forKey: @"device_id"];
                        }
                    }
                    break;
                }
                case 0x02: {
                    break;
                }
                case 0x03: {
                    break;
                }
                default:
                    break;
            }
        }
        
    }
    
}


@end
