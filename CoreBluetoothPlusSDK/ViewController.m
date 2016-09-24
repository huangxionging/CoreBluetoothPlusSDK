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
#import "CBPBinStringManager.h"
#import "CBPDeviceFuctionTableViewController.h"
#import "MJRefresh.h"

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
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self.dataArray removeAllObjects];
        [self.mainTableView reloadData];
        [self.manager.baseController.baseClient startScanPeripheralWithOptions: nil];
        [((MJRefreshNormalHeader *)self.mainTableView.mj_header) endRefreshing];
    }];
//    [((MJRefreshNormalHeader *)self.mainTableView.mj_header) endRefreshing];
    [self.manager.baseController startWorkWithBlock:^(id result) {
//         同步参数
//        NSLog(@"连接成功");
//        self.navigationItem.title = [NSString stringWithFormat: @"蓝牙连接成功"];
        
        if ([result isKindOfClass: [CBPBasePeripheralModel class]]) {
            NSLog(@"%@", result);
            
            [self.dataArray addObject: result];
            [self.dataArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                CBPBasePeripheralModel *model1 = obj1;
                CBPBasePeripheralModel *model2 = obj2;
                
                if (model1.singalValue > model2.singalValue) {
                    return NSOrderedAscending;
                } else if (model1.singalValue < model2.singalValue) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
                
            }];
            [self.mainTableView reloadData];
        } else {
            [self device];
        }
        
    }];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource: @"CBPInterface" ofType: @"plist"];
//    self.dataArray = [NSMutableArray arrayWithContentsOfFile: path];
//    [self.mainTableView reloadData];
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithCapacity: 10];
    }
    return _dataArray;
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
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Cell"];
    }
    
    CBPBasePeripheralModel *model = self.dataArray[indexPath.row];
    
    cell.textLabel.text = model.peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%ld", (long)model.singalValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPBasePeripheralModel *model = self.dataArray[indexPath.row];
    [self.manager.baseController.baseClient connectPeripheral: model options: nil];
//    [MBProgressHUD showHUDAddedTo: animated:<#(BOOL)#>]
}

- (void) device {
    CBPDeviceFuctionTableViewController *vc = [[CBPDeviceFuctionTableViewController alloc] init];
    [self.navigationController pushViewController: vc animated: YES];
}


@end
