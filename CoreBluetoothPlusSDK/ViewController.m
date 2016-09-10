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
#import "CBPShowResultTableViewController.h"
#import "SynchronizeStepTableViewController.h"
#import "SynchronizeSleepTableViewController.h"
@interface ViewController ()

@property (nonatomic, strong) CBPBaseWorkingManager *manager;

@property (nonatomic, strong) NSMutableArray *dataArray;

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
        NSLog(@"连接成功");
        self.navigationItem.title = [NSString stringWithFormat: @"蓝牙连接成功"];
    }];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"CBPInterface" ofType: @"plist"];
    self.dataArray = [NSMutableArray arrayWithContentsOfFile: path];
    [self.mainTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
    }
    
    NSString *title = self.dataArray[indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            [self synchronizeParameter];
            break;
        }
        case 1: {
            [self applyBindDevice];
            break;
        }
        case 2: {
            [self answerBindDevice];
            break;
        }
        case 3: {
            [self deleteBind];
            break;
        }
        case 4: {
            [self setPedometerTimeinterval];
        }
        case 5: {
            [self synchronizeStep];
            break;
        }
        case 6: {
            [self synchronizeSleep];
            break;
        }
        case 7: {
            [self queryDeviceVersion];
            break;
        }
        case 8: {
            break;
        }
        case 9: {
            [self restartDevice];
            break;
        }
        case 10: {
            break;
        }
        case 15: {
            [self searchDevice];
            break;
        }
        case 17: {
            [self checkDeviceWorkingState];
            break;
        }
        default:
            break;
    }
}

- (void) checkDeviceBindState {
    // 检查绑定状态
    [self.manager post: @"ble://check_bind_state" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void)applyBindDevice {
    
    [self.manager post: @"ble://apply_bind_device" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"申请绑定: %@", responseObject);
        
        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        vc.parameter = @{@"没有参数":@"没有参数"};
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
//        [self answerBindDevice];
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) answerBindDevice {
    [self.manager post: @"ble://confirm_bind_device" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        
        NSLog(@"回复数据: %@", responseObject);
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)synchronizeParameter {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    // 设置运动目标
    [parameter setObject: @"100" forKey: @"step_goal"];
    
    // 佩戴目标
    [parameter setObject: @"1" forKey: @"wear_type"];
    
    // 运动模式
    [parameter setObject: @"1" forKey: @"sport_type"];
    
    // 同步标识
    [parameter setObject: @"0" forKey: @"synchronize_flag"];
    // 性别
    [parameter setObject: @"0" forKey: @"gender_type"];
    
    // 年龄
    [parameter setObject: @"26" forKey: @"age"];
    
    // 体重
    [parameter setObject: @"76" forKey: @"weight"];
    
    // 身高
    [parameter setObject: @"173" forKey: @"height"];
    
    // 度量 measure
    [parameter setObject: @"0" forKey: @"measure"];
    
    // 断连 disconnect_remind
    [parameter setObject: @"1" forKey: @"disconnect_remind"];
    
    NSDictionary *dict = parameter;
    [self.manager post: @"ble://synchronize_parameter" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"%@", responseObject);
        
        // 设备类型
        NSString *deviceType = responseObject[@"device_type"];
        
        NSLog(@"%@", parameter);
        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        vc.parameter = parameter;
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
        // 申请绑定
        //        if([deviceType isEqualToString: @"W079A"]) {
        //            [self applyBindDevice];
        //        }
//        [self applyBindDevice];
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}



- (void)deleteBind {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
    // 操作类型
    [parameter setObject: @"0" forKey: @"action_type"];
    
    [self.manager post: @"ble://cancel_bind_device" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
        NSLog(@"解除绑定: %@", responseObject);
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) setPedometerTimeinterval {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
    // 操作类型
    [parameter setObject: @"30" forKey: @"time_interval"];
    
    [self.manager post: @"ble://set_pedometer_data_save_time_interval" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
        NSLog(@"设置时间间隔: %@", responseObject);
        NSLog(@"%@", parameter);
        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        vc.parameter = parameter;
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) synchronizeStep {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
    // 操作类型
    [parameter setObject: @"2016-08-01" forKey: @"start_date"];
    
    [parameter setObject: @"2016-09-05" forKey: @"end_date"];
    
    [self.manager post: @"ble://synchronize_step_data" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
        NSLog(@"计步数据: %@", responseObject);
        NSLog(@"计步参数%@", parameter);
        SynchronizeStepTableViewController *vc = [[SynchronizeStepTableViewController alloc] init];
        vc.parameter = parameter;
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
       
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) synchronizeSleep {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
    // 操作类型
    [parameter setObject: @"2016-08-01" forKey: @"start_date"];
    
    [parameter setObject: @"2016-09-05" forKey: @"end_date"];
    
    [self.manager post: @"ble://synchronize_sleep_data" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
        NSLog(@"睡眠数据: %@", responseObject);
        NSLog(@"睡眠参数%@", parameter);
        SynchronizeSleepTableViewController *vc = [[SynchronizeSleepTableViewController alloc] init];
        vc.parameter = parameter;
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) queryDeviceVersion {
    
    [self.manager post: @"ble://query_device_version" parameters: nil success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"%@", responseObject);
        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        vc.parameter = @{@"无":@"无"};
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];

}

- (void)restartDevice {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 5];
    // 重启设备
    [parameter setObject: @"1" forKey: @"content_type"];
    
    [parameter setObject: @"1" forKey: @"response"];
    
    [self.manager post: @"ble://restart_device" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"%@", responseObject);
        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        vc.parameter = parameter;
        vc.result = responseObject;
        [self.navigationController pushViewController: vc animated: YES];
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) searchDevice {
    [self.manager post: @"ble://search_device" parameters:  nil success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"%@", responseObject);
        //        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
        //        vc.parameter = parameter;
        //        vc.result = responseObject;
        //        [self.navigationController pushViewController: vc animated: YES];
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];

}

- (void) checkDeviceWorkingState {
   
    
    [self.manager post: @"ble://check_device_working_state" parameters:  nil success:^(CBPBaseAction *action, id responseObject) {
        NSLog(@"%@", responseObject);
//        CBPShowResultTableViewController *vc = [[CBPShowResultTableViewController alloc] init];
//        vc.parameter = parameter;
//        vc.result = responseObject;
//        [self.navigationController pushViewController: vc animated: YES];
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

@end
