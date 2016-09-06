//
//  CBPShowResultTableViewController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/1.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPShowResultTableViewController.h"

@interface CBPShowResultTableViewController ()

@end

@implementation CBPShowResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return _parameter.allKeys.count;
    } else {
        return _result.allKeys.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Cell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = _parameter.allKeys[indexPath.row];
        cell.detailTextLabel.text = [_parameter objectForKey: _parameter.allKeys[indexPath.row]];
        cell.textLabel.textColor = [UIColor greenColor];
        cell.detailTextLabel.textColor = [UIColor purpleColor];
    } else {
        cell.textLabel.text = _result.allKeys[indexPath.row];
        cell.detailTextLabel.text = [_result objectForKey: _result.allKeys[indexPath.row]];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"参数列表";
    } else {
        return @"返回值列表";
    }
}



@end
