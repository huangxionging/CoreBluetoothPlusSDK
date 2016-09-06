//
//  ViewController.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/8/15.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

