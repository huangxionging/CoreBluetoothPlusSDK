//
//  CBPWKLSynchronizeStepAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/1.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"

@interface CBPWKLSynchronizeStepAction : CBPBaseAction

- (NSData *)actionData;

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
