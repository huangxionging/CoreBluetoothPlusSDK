//
//  CBPDialogUpgradeController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPDialogUpgradeController.h"
#import "CBPDispatchMessageManager.h"
#import "CBPBaseWorkingManager.h"
#import "CBPWKLDialogUpgradeServiceCharacteristicManager.h"
#import "CBPHexStringManager.h"
#import "CBPWKLDialogUpgradeServiceCharacteristicModel.h"
#import "CBPBaseCharacteristicModel.h"

@interface CBPDialogUpgradeController ()

/**
 *  外设
 */
@property (nonatomic, strong) CBPBasePeripheralModel *peripheralModel;

@property (nonatomic, strong) CBPWKLDialogUpgradeServiceCharacteristicManager *serviceCharacteristicManager;

@end

@implementation CBPDialogUpgradeController

+ (void)load {
    
    // 注册控制器
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method: @"registerController:", self, nil];
}

+ (NSString *)controllerKey {
    return @"com.dialog.controller";
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        // 单例
        self.serviceCharacteristicManager =[CBPWKLDialogUpgradeServiceCharacteristicManager shareManager];
        self.baseClient = [CBPBaseClient shareBaseClient];
    }
    return self;
}

- (void)sendAction:(NSString *)actionName parameters:(id)parameters progress:(void (^)(id))progress success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    __weak CBPDialogUpgradeController *weakSelf = self;
    // 只需要一次
    [CBPBaseWorkingManager manager].upgradeControllerKey = nil;
    
    // 连接
    weakSelf.baseDevice = [CBPBaseWorkingManager manager].baseController.baseDevice;
    // 获取外设
    weakSelf.peripheralModel = [self.baseDevice valueForKey:@"_peripheralModel"];
    
    // 指令
    CBPBaseAction *action = [[NSClassFromString(actionName) alloc] initWithParameter: parameters answer:^(CBPBaseActionDataModel *answerDataModel) {
        [weakSelf.baseDevice sendActionWithModel: answerDataModel];
        // 无需回复
    } finished:^(id result) {
        NSLog(@"%@", result);
        // 获得 action
        CBPBaseAction *action = [result objectForKey: @"action"];
        NSString *successState = [result objectForKey: @"state"];
        if (successState.integerValue) {
            // 成功回调
            success(action, [result objectForKey: @"result"]);
        } else {
            // 失败回调
            failure(action, [result objectForKey: @"result"]);
        }
        
    }];
    
    
    // 设置进度 block, 当需要进度的时候, 要在发送数据之前设置好
    if (progress) {
        [action setValue: progress forKey: @"_progress"];
    }
    
    // 设置 特征值
    action.characteristicUUIDString = [[CBPBaseWorkingManager manager].baseController.writeCharacteristicUUIDString lowercaseString];
    // 调用数据
    [action actionData];
    
    // 启用接收数据
    [weakSelf reciveUpdateData];
    // 保持 action
    [self.actionSheet setObject: action forKey: @"dialog_upgrade"];
    
    void (^changeDeviceServiceSingal)() = ^(){
        
        [weakSelf.baseClient connectPeripheral: weakSelf.peripheralModel options: nil];
        [weakSelf.baseClient setUpgradeConnectionPeripheralBlock:^(CBPBasePeripheralModel *peripheral) {
            // 只需一次就够
            [weakSelf.baseClient setUpgradeConnectionPeripheralBlock: nil];
            // 收到切换信号, 发现升级服务
            weakSelf.peripheralModel = peripheral;
            [weakSelf.peripheralModel.peripheral discoverServices: [self.serviceCharacteristicManager discoverServiceUUIDs]];
        }];
        
        
        // 发现服务回调
        [weakSelf.baseDevice setDiscoverServiceBlock:^NSArray<CBUUID *> *(CBPBaseServiceModel *discoverServiceModel) {
            
            // 这下便可保证只发现该服务的特征
            CBUUID *UUID = weakSelf.serviceCharacteristicManager.serviceCharacteristicModel.serviceUUID;
            if ([discoverServiceModel.service.UUID isEqual: UUID]) {
                return weakSelf.serviceCharacteristicManager.charateristicUUIDs;
            } else {
                return nil;
            }
                
        }];
        
        // 特征服务回调
        [weakSelf.baseDevice setDiscoverServiceCharacteristicBlock:^(CBPBaseServiceModel *discoverServiceCharacteristicModel, CBPBasePeripheralModel *peripheralModel) {
            
            for (CBCharacteristic *cha in discoverServiceCharacteristicModel.service.characteristics) {
                
                CBPBaseCharacteristicModel *chaModel = [[CBPBaseCharacteristicModel alloc] init];
                chaModel.chracteristic = cha;
                chaModel.flag = @"2";
                [weakSelf.baseDevice addCharacteristic: chaModel];
                
                // 只有这个特征是通知特征
                if ([cha.UUID isEqual: weakSelf.serviceCharacteristicManager.serviceCharacteristicModel.SERV_STATUS_UUID]) {
                  
                    // 预定通知
                    [weakSelf.peripheralModel.peripheral setNotifyValue: YES forCharacteristic: cha];
                }
            }
            // 设置 特征
            [weakSelf.serviceCharacteristicManager setServiceCharacteristic: discoverServiceCharacteristicModel.service];
            
            // 查询 action
            CBPBaseAction *action = [weakSelf.actionSheet objectForKey: @"dialog_upgrade"];
            // 调整数据
            [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"handleFirstAnswer", nil];
            
            // 正式启用接收写数据传送
            [weakSelf reciveWriteData];
            
        }];

    };
    
    // 设置切换服务信号回调
    [action setValue: changeDeviceServiceSingal forKey: @"_changeDeviceServiceSingal"];
    
}

- (void) reciveUpdateData {
    // 不同的 weak 写法
    __weak typeof(self) weakSelf = self;
    // 更新数据回调
    [weakSelf.baseDevice setUpdateDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: @"dialog_upgrade"];
        
        CBPWKLDialogUpgradeServiceCharacteristicModel *model = [weakSelf.serviceCharacteristicManager serviceCharacteristicModel];
        // 等于
        if ([actionDataModel.characteristic.UUID isEqual: model.SERV_STATUS_UUID]) {
            [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"onSuotaServiceStatusChange:", actionDataModel, nil];
            
        } else if ([actionDataModel.characteristic.UUID isEqual: model.MEM_INFO_UUID]) {
            [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"suotaWriteEnd", nil];
        } else {
            // 或者投送
            if ([action respondsToSelector: @selector(receiveUpdateData:)]) {
                // 投送消息
                // 关闭超时定时器
//                [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"stopTimer", nil];
                [action receiveUpdateData: actionDataModel];
                
            }
        }
        
    }];

}

- (void) reciveWriteData {
    
    __weak typeof(self) weakSelf = self;
    // 写数据回调
    [weakSelf.baseDevice setWriteDataBlock:^(CBPBaseActionDataModel *actionDataModel) {
        
        // 查询 action
        CBPBaseAction *action = [weakSelf.actionSheet objectForKey: @"dialog_upgrade"];
        
        // 写状态改变
//        [action performSelector: @selector(writeStatusChange:) withObject:actionDataModel afterDelay: 1.0];
        [[CBPDispatchMessageManager shareManager] dispatchTarget: action method: @"writeStatusChange:", actionDataModel, nil];
       
    }];
}


@end
