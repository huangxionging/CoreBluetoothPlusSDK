//
//  CBPSleepTableViewCell.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBPSleepTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *topValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *downKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *downValueLabel;

@end
