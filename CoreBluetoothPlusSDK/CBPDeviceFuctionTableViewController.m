//
//  CBPDeviceFuctionTableViewController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/20.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPDeviceFuctionTableViewController.h"
#import "CBPWKLController.h"
#import "CBPBaseWorkingManager.h"
#import "CBPShowResultTableViewController.h"
#import "SynchronizeStepTableViewController.h"
#import "SynchronizeSleepTableViewController.h"
#import "CBPBinStringManager.h"
#import "NSDate+CBPUtilityTool.h"

@interface CBPDeviceFuctionTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) CBPBaseWorkingManager *manager;

@end

@implementation CBPDeviceFuctionTableViewController

- (CBPBaseWorkingManager *)manager {
    if (_manager == nil) {
        _manager = [CBPBaseWorkingManager manager];
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
        NSString *path = [[NSBundle mainBundle] pathForResource: @"CBPInterface" ofType: @"plist"];
        self.dataArray = [NSMutableArray arrayWithContentsOfFile: path];
        [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Cell"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
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
            [self upgradeFirmware];
            break;
        }
        case 9: {
            [self restartDevice];
            break;
        }
        case 10: {
            [self lightLED];
            break;
        }
        case 11: {
            [self buzzerSound];
            break;
        }
        case 12: {
            break;
        }
        case 13: {
            break;
        }
        case 14: {
            [self changeColor];
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
- (void) upgradeFirmware {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
  
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"firmware" ofType: @"png"];
    
    // 文件路径名
    [parameter setObject: filePath forKey: @"file_path"];
    // 点亮 led
    [self.manager post: @"ble://firmware_upgrade" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];
}

- (void) changeColor {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    NSInteger coloreValue = arc4random() % 4;
    
    NSString *color = [NSString stringWithFormat:@"%ld", (long)coloreValue];
    [parameter setObject: color forKey: @"color_value"];
    
    // 点亮 led
    [self.manager post: @"ble://change_color" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];

}

- (void) buzzerSound {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    
    [parameter setObject: @"1" forKey: @"switch"];
    [parameter setObject: @"1000" forKey: @"duration_time"];
    [parameter setObject: @"1000" forKey: @"frequency"];
    [parameter setObject: @"20" forKey: @"repeat_count"];
    // 点亮 led
    [self.manager post: @"ble://buzzer_sound" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
    }];

}

- (void) lightLED {
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    
    [parameter setObject: @"0x000000ff" forKey: @"led"];
    [parameter setObject: @"1000" forKey: @"light_on_time"];
    [parameter setObject: @"1000" forKey: @"light_off_time"];
    [parameter setObject: @"20" forKey: @"repeat_count"];
    // 点亮 led
    [self.manager post: @"ble://light_led" parameters: parameter success:^(CBPBaseAction *action, id responseObject) {
        
    } failure:^(CBPBaseAction *action, CBPBaseError *error) {
        
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


- (void)synchronizeParameter {
    
    Byte bytes[5] = {0};
    
    Byte byte = bytes[3];
    NSString *bin = [[CBPBinStringManager shareManager] binStringForBytes: &byte length:1];
    NSString *sub = [bin substringToIndex: 2];
    //
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity: 10];
    // \\设置运动目标
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
    [parameter setObject: @"2016-09-01" forKey: @"start_date"];
    
    NSString *end = [[NSDate date] stringForCurrentDateWithFormatString: @"yyyy-MM-dd"];
    [parameter setObject: end forKey: @"end_date"];
    
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
    
    NSString *end = [[NSDate date] stringForCurrentDateWithFormatString: @"yyyy-MM-dd"];
    [parameter setObject: end forKey: @"end_date"];
    
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
