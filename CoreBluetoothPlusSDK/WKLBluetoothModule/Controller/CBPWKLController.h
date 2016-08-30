//
//  CBPWKLController.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseController.h"

@interface CBPWKLController : CBPBaseController

// 重写父类方法
- (void) startWorkWithBlock:(void (^)(id))block;

@end
