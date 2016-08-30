//
//  CBPBaseActionDataModel.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseActionDataModel.h"
#import "CBPBaseAction.h"

@implementation CBPBaseActionDataModel

+ (instancetype) modelWithAction: (CBPBaseAction *)action {
    CBPBaseActionDataModel *actionDataModel = [[CBPBaseActionDataModel alloc] init];
    
    if (actionDataModel) {
        actionDataModel.actionData = [action actionData];
        actionDataModel.characteristicString = [action.characteristicUUIDString lowercaseString];
        actionDataModel.actionDatatype = kBaseActionDataTypeUpdateSend;
        actionDataModel.writeType = CBCharacteristicWriteWithResponse;
    }
    
    return actionDataModel;
}


@end
