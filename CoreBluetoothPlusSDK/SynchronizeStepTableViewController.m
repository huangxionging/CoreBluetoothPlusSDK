//
//  SynchronizeStepTableViewController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/2.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "SynchronizeStepTableViewController.h"
#import "CBPStepTableViewCell.h"

@interface SynchronizeStepTableViewController ()

@end

@implementation SynchronizeStepTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib: [UINib nibWithNibName: @"CBPStepTableViewCell" bundle: nil] forCellReuseIdentifier: @"StepCell"];
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
        
        NSArray *sectionArray = [self.result objectForKey: @"all_day_step_data"];
        
        NSArray *rowArray = sectionArray[section - 1][@"step_data"];
        
        return rowArray.count;
    }
    
}

- (CBPStepTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPStepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"StepCell"];
    
    
    if (indexPath.section == 0) {
        cell.topKeyLabel.text = _parameter.allKeys[indexPath.row];
        cell.topValueLabel.text = [_parameter objectForKey: _parameter.allKeys[indexPath.row]];
        cell.topKeyLabel.textColor = [UIColor greenColor];
        cell.topValueLabel.textColor = [UIColor purpleColor];
        
        cell.downKeyLabel.hidden = YES;
        cell.downValueLabel.hidden = YES;
    } else {
        cell.downKeyLabel.hidden = NO;
        cell.downValueLabel.hidden = NO;
        NSArray *sectionArray = [self.result objectForKey: @"all_day_step_data"];
        
        NSArray *rowArray = sectionArray[indexPath.section - 1][@"step_data"];
        
        NSDictionary *timeInfo = rowArray[indexPath.row];
        cell.topKeyLabel.text = @"time";
        cell.downKeyLabel.text = @"steps";
        
        cell.topValueLabel.text = timeInfo[@"time"];
        cell.downValueLabel.text = timeInfo[@"steps"];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"参数";
    } else {
        NSArray *sectionArray = [self.result objectForKey: @"all_day_step_data"];
        
        NSString *title= sectionArray[section - 1][@"date"];
        return title;
    }
}



@end
