//
//  CBPStepTableViewCell.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBPStepTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *topValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *downValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *topKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *downKeyLabel;
@end
