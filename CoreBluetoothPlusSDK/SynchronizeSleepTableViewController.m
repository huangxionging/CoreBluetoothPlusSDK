//
//  SynchronizeSleepTableViewController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "SynchronizeSleepTableViewController.h"
#import "CBPSleepTableViewCell.h"

@interface SynchronizeSleepTableViewController ()

@end

@implementation SynchronizeSleepTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib: [UINib nibWithNibName: @"CBPSleepTableViewCell" bundle: nil] forCellReuseIdentifier: @"SleepCell"];
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
    NSString *count = self.result[@"total_count"];
    return count.integerValue + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.parameter.allKeys.count;
    } else {
        
        NSArray *sectionArray = [self.result objectForKey: @"all_day_sleep_data"];
        
        NSArray *rowArray = sectionArray[section - 1][@"sleep_data"];
        
        return rowArray.count;
    }
    
}

- (CBPSleepTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPSleepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SleepCell"];
    
    
    if (indexPath.section == 0) {
        cell.topKeyLabel.text = _parameter.allKeys[indexPath.row];
        cell.topValueLabel.text = [_parameter objectForKey: _parameter.allKeys[indexPath.row]];
        cell.topKeyLabel.textColor = [UIColor greenColor];
        cell.topValueLabel.textColor = [UIColor purpleColor];
        
        cell.downKeyLabel.hidden = YES;
        cell.downValueLabel.hidden = YES;
        cell.middleKeyLabel.hidden = YES;
        cell.middleValueLabel.hidden = YES;
    } else {
        cell.downKeyLabel.hidden = NO;
        cell.downValueLabel.hidden = NO;
        cell.middleKeyLabel.hidden = NO;
        cell.middleValueLabel.hidden = NO;
        NSArray *sectionArray = [self.result objectForKey: @"all_day_sleep_data"];
        
        NSArray *rowArray = sectionArray[indexPath.section - 1][@"sleep_data"];
        
        NSDictionary *timeInfo = rowArray[indexPath.row];
        cell.topKeyLabel.text = @"start_minute";
        cell.middleKeyLabel.text = @"sleep_minute";
        cell.downKeyLabel.text = @"sleep_flag";
        
        cell.topValueLabel.text = timeInfo[@"start_minute"];
        cell.middleValueLabel.text = timeInfo[@"sleep_minute"];
        cell.downValueLabel.text = timeInfo[@"sleep_flag"];
        
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"参数";
    } else {
        NSArray *sectionArray = [self.result objectForKey: @"all_day_sleep_data"];
        
        NSString *title= sectionArray[section - 1][@"date"];
        return title;
    }
}


@end
