//
//  CBPWKLSimpleControlAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLSimpleControlAction.h"
#import <objc/message.h>


/**
 *  @author huangxiong
 *
 *  @brief 基于 蓝牙通讯协议V0.2_R20160105 4.14
 */
@implementation CBPWKLSimpleControlAction

+ (void)load {
    
    // 选取方法
    SEL selector = NSSelectorFromString(@"registerAction:forKeys:");
    // 发送消息
    objc_msgSend([self superclass], selector, self, [self actionInterfaces]);
    
}

+ (NSArray *)actionInterfaces {
    // 对应的 接口
    NSArray *interfaces = @[// 点亮 led,
                      @"light_led",
                      // // 控制蜂鸣器响
                      @"control_buzzer_sound",
                      // 防止丢失
                      @"prevent_lost",
                      // 按键锁
                      @"keyboars_lock",
                      // 改变三基色颜色
                      @"change_color",
                      // 查找设备
                      @"search_device",
                      // ANCS 功能开关
                      @"ancs_switch",
                      // 查询设备工作状态
                      @"check_device_state"];
    return interfaces;
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x0b", nil];
}

- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    
    // 0x5a 表示主动发送命令
    bytes[0] = 0x5a;
    
    // 0x0c 表示简单控制命令
    bytes[1] = 0x0c;
    
    // _type 就是相应的控制值
    bytes[3] = _type;
    
    // 处理其它参数
    switch (_type) {
        
        // LED 灯
        case  kCBPWKLSimpleControlTypeLED: {
            
            // 参数判断
            NSParameterAssert(_switchValue);
            
            // 字节指针
            Byte *locationPointer = &bytes[4];
            // 复制数据
            memcpy(locationPointer, _switchValue, 4);
            
            // 亮时长高字节
            bytes[8] = _lightLength / 256;
            // 亮时长低字节
            bytes[9] = _lightLength % 256;
            
            // 灭时长高字节
            bytes[10] = _extinguishLength / 256;
            // 灭时长低字节
            bytes[11] = _extinguishLength % 256;
            
            // 重复次数高字节
            bytes[12] = _recurNumbers / 256;
            // 重复次数低字节
            bytes[13] = _recurNumbers % 256;
            
            break;
        }
            
        // 蜂鸣器
        case kCBPWKLSimpleControlTypeBuzzer: {
            NSParameterAssert(_switchValue);
            
            // 字节指针, 开关
            Byte *locationPointer = &bytes[4];
            // 复制数据
            memcpy(locationPointer, _switchValue, 1);
            
            // 持续时长高字节
            bytes[5] = _lastLength / 256;
            // 持续时长低字节
            bytes[6] = _lastLength % 256;
            
            // 频率高字节
            bytes[7] = _frequency / 256;
            // 频率低字节
            bytes[8] = _frequency % 256;
            
            break;
        }
        
        // 防丢和按键锁的其他参数一样
        case kCBPWKLSimpleControlTypeLostSwitch:
        case kCBPWKLSimpleControlTypeKeyboardLock: {
            NSParameterAssert(_switchValue);
            // 字节指针, 开关
            Byte *locationPointer = &bytes[4];
            // 复制数据
            memcpy(locationPointer, _switchValue, 1);
            
            // 持续时长高字节
            bytes[5] = _lastLength / 256;
            // 持续时长低字节
            bytes[6] = _lastLength % 256;
            
            break;
        }
            
        // 更换三基色
        case kCBPWKLSimpleControlTypeChangeColor: {
            bytes[4] = _colorValue;
            break;
        }
        
        // 查找设备
        case kCBPWKLSimpleControlTypeSearchDevice: {
            
            // 查找设备无其他参数需要配置了
            break;
        }
            
        // ANCS 功能, 打开开关就行
        case kCBPWKLSimpleControlTypeANCS: {
            
            NSParameterAssert(_switchValue);
            // 字节指针, 开关
            Byte *locationPointer = &bytes[4];
            // 复制数据
            memcpy(locationPointer, _switchValue, 1);
            break;
        }
        default:
            break;
    }
    return [NSData dataWithBytes: bytes length: 20];
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
    }
    if (bytes ) {
        
    }
}




@end
