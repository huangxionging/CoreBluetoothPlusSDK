//
//  CBPWKLSimpleControlAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLSimpleControlAction.h"
#import "CBPHexStringManager.h"
#import "CBPBinStringManager.h"
#import "CBPDispatchMessageManager.h"
/**
 *  @author huangxiong
 *
 *  @brief 基于 蓝牙通讯协议V0.2_R20160105 4.14
 */
@implementation CBPWKLSimpleControlAction

+ (void)load {
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

+ (NSArray *)actionInterfaces {
    // 对应的 接口
    NSArray *interfaces = @[// 点亮 led,
                      @"light_led",
                      // // 控制蜂鸣器响
                      @"buzzer_sound",
                      // 防止丢失
                      @"anti_lost",
                      // 按键锁
                      @"key_lock",
                      // 改变三基色颜色
                      @"change_color",
                      // 查找设备
                      @"search_device",
                      // ANCS 功能开关
                      @"ancs_switch",
                      // 查询设备工作状态
                      @"check_device_working_state"];
    return interfaces;
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x0c", nil];
}

- (void) actionData {
    
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    NSString *interface = parameter[@"interface"];
    
    // 指示接口
    NSInteger index = [[CBPWKLSimpleControlAction actionInterfaces] indexOfObject: interface];
    
    Byte bytes[20] = {0};
    
    // 0x5a 表示主动发送命令
    bytes[0] = 0x5a;
    
    // 0x0c 表示简单控制命令
    bytes[1] = 0x0c;
    
    // _type 就是相应的控制值
    bytes[3] = index + 1;
    
    // 6和8无特别参数
    // 处理其它参数
    switch (index + 1) {
        
        // LED 灯
        case  1: {
            
            NSString *led = parameter[@"led"];
            
            Byte *ledBytes = [[CBPHexStringManager shareManager] bytesForString: led];
            bytes[4] = ledBytes[0];
            bytes[5] = ledBytes[1];
            bytes[6] = ledBytes[2];
            bytes[7] = ledBytes[3];
            
            NSString *lightOnTime = parameter[@"light_on_time"];
            
            // 亮时长高字节
            bytes[8] = lightOnTime.integerValue / 256;
            // 亮时长低字节
            bytes[9] = lightOnTime.integerValue % 256;
            
            NSString *lightOffTime = parameter[@"light_off_time"];
            
            // 灭时长高字节
            bytes[10] = lightOffTime.integerValue / 256;
            // 灭时长低字节
            bytes[11] = lightOffTime.integerValue % 256;
            
            NSString *repeatCount = parameter[@"repeat_count"];
            
            // 重复次数高字节
            bytes[12] = repeatCount.integerValue / 256;
            // 重复次数低字节
            bytes[13] = repeatCount.integerValue % 256;
            
            break;
        }
            
        // 蜂鸣器
        case 2: {
        
            // 开关
            NSString *buzzerSwitch = parameter[@"switch"];
            bytes[4] = buzzerSwitch.integerValue;
            
            // 持续时长
            NSString *durationTime = parameter[@"duration_time"];
            bytes[5] = durationTime.integerValue / 256;
            bytes[6] = durationTime.integerValue % 256;
            
            NSString *frequency = parameter[@"frequency"];
            // 频率高字节
            bytes[7] = frequency.integerValue / 256;
            // 频率低字节
            bytes[8] = frequency.absolutePath % 256;
            
            break;
        }
        
        // 防丢和按键锁的其他参数一样
        case 3:
        case 4: {
            
            // 开关
            NSString *deviceSwitch = parameter[@"switch"];
            bytes[4] = deviceSwitch.integerValue;
            
            // 持续时长
            NSString *durationTime = parameter[@"duration_time"];
            bytes[5] = durationTime.integerValue / 256;
            bytes[6] = durationTime.integerValue % 256;
            break;
        }
            
        // 更换三基色
        case 5: {
            // 颜色
            NSString *colorValue = parameter[@"color_value"];
            bytes[4] = colorValue.integerValue;
            break;
        }
            
        // ANCS 功能, 打开开关就行
        case 7: {
            NSString *switchValue = parameter[@"switch"];
            bytes[4] = switchValue.integerValue;
            break;
        }
        default:
            break;
    }
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", data, nil];
}

- (void) receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
    
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        // 待回传的结果
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: 5];
        
        if (bytes[0] == 0x5b && bytes[1] == 0x0c) {
            
            switch (bytes[3]) {
                case 1: { // led 灯亮灭
                    
                    NSString *ledState = [[CBPHexStringManager shareManager] hexStringForBytes: &bytes[4] length: 4];
                    ledState = [ledState stringByAppendingString: @"0x"];
                    
                    // led 结果
                    [result setObject: ledState forKey: @"led_state"];
                    break;
                }
                case 2:
                case 3:
                case 4:
                case 5: {
                    NSInteger state = bytes[4];
                    
                    NSString *stateString = [NSString stringWithFormat: @"%ld", (long) state];
                    
                    // 结果
                    [result setObject: stateString forKey: @"state"];
                    break;
                }
                case 8: {
                    // 蓝牙状态
                    Byte ble = bytes[4];
                    
                    NSString *bin = [[CBPBinStringManager shareManager] binStringForBytes: &ble length: 1];
                    
                    // 蓝牙状态
                    NSString *bleState = [bin substringToIndex: 2];
                    NSLog(@"%@", bleState);
                    [result setObject: bleState forKey: @"bluetooth_state"];
                    
                    // 敲击中断
                    NSString *percussionInterrupt = [bin substringWithRange: NSMakeRange(2, 2)];
                    [result setObject: percussionInterrupt forKey: @"gravity_sensor_percussion_interrupt"];
                    // 运动中断
                    NSString *motionInterrupt = [bin substringWithRange: NSMakeRange(4, 2)];
                    [result setObject: motionInterrupt forKey: @"gravity_sensor_motion_interrupt"];
                    
                    // 通讯状态
                    NSString *communicationState = [bin substringWithRange: NSMakeRange(6, 2)];
                    [result setObject: communicationState forKey: @"gravity_sensor_communication_state"];
                    
                    if (updateDataModel.actionData.length > 5) {
                        ble = bytes[5];
                    } else {
                        ble = 0x00;
                    }
                    
                    bin = [[CBPBinStringManager shareManager] binStringForBytes: &ble length: 1];
                    // 供电电压检测
                    NSString *voltageDetection = [bin substringToIndex: 2];
                    NSLog(@"%@", bleState);
                    [result setObject: voltageDetection forKey: @"supply_voltage_detection"];
                    
                    // 充电检测
                    NSString *chargeDetection = [bin substringWithRange: NSMakeRange(2, 2)];
                    [result setObject: chargeDetection forKey: @"charge_detection"];
                    // 三维坐标数据改变
                    NSString *triaxialDataChange = [bin substringWithRange: NSMakeRange(4, 4)];
                    [result setObject: triaxialDataChange forKey: @"gravity_sensor_triaxial_data_change"];
                    
                    
                    if (updateDataModel.actionData.length > 6) {
                        ble = bytes[6];
                    } else {
                        ble = 0x00;
                    }
                    
                    bin = [[CBPBinStringManager shareManager] binStringForBytes: &ble length: 1];
                    // 外部 flash 读写操作
                    NSString *rwOperation = [bin substringWithRange: NSMakeRange(5, 3)];
                    [result setObject: rwOperation forKey: @"external_flash_rw_operation"];
                    break;
                }
                default:
                    break;
            }
        }
        
        //
        // 回调
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", result, nil];
    }
}

- (void)timeOut {
    
}





@end
