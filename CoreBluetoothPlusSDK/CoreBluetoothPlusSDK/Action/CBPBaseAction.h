//
//  CBPBaseAction.h
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBPBaseActionDataModel.h"
#import "CoreBluetoothPlus.h"

/**
 *  操作完成的回调
 */
typedef void(^finishedBlock)(id result);

typedef void(^answerBlock)(CBPBaseActionDataModel *answerModel);

@interface CBPBaseAction : NSObject

/**
 *  操作的名字
 */
@property (nonatomic, copy, readonly) NSString *acionName;

/**
 *  操作的长度
 */
@property (nonatomic, assign, readonly) NSInteger actionLength;

/**
 *  对应的特征的标识符
 */
@property (nonatomic, copy) NSString *characteristicUUIDString;

/**
 *  是否长包操作
 */
@property (nonatomic, assign, readonly) BOOL isLongAction;

/**
 *  表示该操作是否已完成.
 */
@property (nonatomic, assign, readonly) BOOL finished;

/**
 *  操作的数据
 */
- (NSData *)actionData;



/**
 *  @author huangxiong, 2016/04/13 19:57:10
 *
 *  @brief 初始化 action 的参数和完成回调, 不同功能的 action 需要重写该方法
 *
 *  @param parameter 是需要的参数
 *  @answerActionBlock 是回复数据的回调
 *  @param finishedBlock ok
 *
 *  @since 1.0
 */
- (instancetype) initWithParameter: (id) parameter answer: (void(^)(CBPBaseActionDataModel *answerDataModel)) answerBlock finished: (void(^)(id result))finished;

/**
 *  @brief  接收更新数据
 *  @param  updateDataModel 是更新数据模型
 *  @return void
 */
- (void) receiveUpdateData: (CBPBaseActionDataModel *)updateDataModel;


@end
