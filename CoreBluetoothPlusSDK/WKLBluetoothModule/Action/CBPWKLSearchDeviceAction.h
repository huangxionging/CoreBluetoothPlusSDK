//
//  CBPWKLSearchDeviceAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"

@interface CBPWKLSearchDeviceAction : CBPBaseAction

/**
 *  重写
 */
- (NSData *)actionData;

/**
 *  重写
 */
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
