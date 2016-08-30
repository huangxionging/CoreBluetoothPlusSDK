//
//  ViewController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/8/15.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "ViewController.h"
#import "CBPWKLController.h"
#import "CBPBaseWorkingManager.h"

@interface ViewController ()

@property (nonatomic, strong) CBPBaseWorkingManager *manager;

@end

@implementation ViewController

- (CBPBaseWorkingManager *)manager {
    if (_manager == nil) {
        _manager = [CBPBaseWorkingManager manager];
        // 配置控制器的 key
        _manager.controllerKey = @"com.wkl.controller";
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 开始工作
    [self.manager.baseController startWorkWithBlock:^(id result) {
        // 同步参数
        [self synchronizeParameter];
    }];
    
    
    
    
}

- (void) checkDeviceBindState {
    // 检查绑定状态
    [self.manager post: @"ble://check_bind_state" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void)applyBindDevice {
    [self.manager post: @"ble://apply_bind_device" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) synchronizeParameter {
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    // 设置运动目标
    [parameter setObject: @"100" forKey: @"step_goal"];
    
    // 运动模式
    [parameter setObject: @"1" forKey: @"sport_type"];
    
    // 同步标识
    [parameter setObject: @"1" forKey: @"synchronize_flag"];
    // 性别
    [parameter setObject: @"0" forKey: @"gender_type"];
    
    // 年龄
    [parameter setObject: @"26" forKey: @"age"];
    
    // 体重
    [parameter setObject: @"76" forKey: @"weight"];
    
    // 身高
    [parameter setObject: @"173" forKey: @"weight"];
    
    // 度量 measure
    [parameter setObject: @"0" forKey: @"measure"];
    
    // 断连 disconnect_remind
    [parameter setObject: @"1" forKey: @"disconnect_remind"];
    
    [self.manager post: @"ble://synchronize_parameter" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
