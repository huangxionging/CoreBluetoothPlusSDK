//
//  CBPQuinticUpgradeController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPQuinticUpgradeController.h"
#import "CBPBaseWorkingManager.h"
#import "CBPBaseCharacteristicModel.h"
#import "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"
#import "CBPBaseWorkingManager.h"
#import "OtaApi.h"

@interface CBPQuinticUpgradeController () {
    qBleClient *_client;
}
// 长指令长度字节数
@property (nonatomic, assign) NSInteger longActionLength;
// 长指令个数
@property (nonatomic, assign) NSInteger longActionCount;

// 固件数据
@property (nonatomic, copy) NSData *firmwareData;

// 外设模型
@property (nonatomic, strong) CBPBasePeripheralModel *peripheralModel;

@end

@implementation CBPQuinticUpgradeController

+ (void)load {
    
    // 注册控制器
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method: @"registerController:", self, nil];
}

+ (NSString *)controllerKey {
    return @"com.quintic.controller";
}


- (void)sendAction:(NSString *)actionName parameters:(id)parameters progress:(void (^)(id))progress success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    // 只需要一次
    [CBPBaseWorkingManager manager].upgradeControllerKey = nil;
    
    // 连接
    self.baseDevice = [CBPBaseWorkingManager manager].baseController.baseDevice;
    // 获取外设
    self.peripheralModel = [self.baseDevice valueForKey:@"_peripheralModel"];
    
    // qBClient 配置
    _client = [qBleClient sharedInstance];
    _client.peripheral = self.peripheralModel.peripheral;
    _client.peripheral.delegate = _client;
    [self.peripheralModel.peripheral discoverServices: nil];
    [_client.bleDidConnectionsDelegate bleDidConnectPeripheral: _client.peripheral];
    
    // 指令
    CBPBaseAction *action = [[NSClassFromString(actionName) alloc] initWithParameter: parameters answer:^(CBPBaseActionDataModel *answerDataModel) {
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
        
//        [self.actionSheet removeAllObjects];
        // 重新恢复代理
//        self.peripheralModel.peripheral.delegate = self.baseDevice;
        // 清理升级控制器
//        [CBPBaseWorkingManager manager].upgradeControllerKey = @"com.quintic.controller";
//        [CBPBaseWorkingManager manager].upgradeControllerKey = nil;
        
    }];
    
    
    // 设置进度 block, 当需要进度的时候, 要在发送数据之前设置好
    if (progress) {
        [action setValue: progress forKey: @"_progress"];
    }

    // 调用
    [action actionData];
    
    // 保持 action
    [self.actionSheet setObject: action forKey: @"quintic_upgrade"];
    
}


- (void)dealloc {
    NSLog(@"挂了---");
}

@end
