//
//  CBPWKLSynchronizeParameterAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/17.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"
@interface CBPWKLSynchronizeParameterAction : CBPBaseAction

/**
 *  重写操作数据
 */
- (NSData *)actionData;

/**
 *  重写接收数据
 */
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel;

@end
