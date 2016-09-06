//
//  CBPWKLQueryDeviceVersionAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"

@interface CBPWKLQueryDeviceVersionAction : CBPBaseAction
- (NSData *)actionData;

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;
@end
