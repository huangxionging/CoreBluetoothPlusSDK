//
//  CBPBaseAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPBaseAction.h"
#import "CBPBaseActionDataModel.h"
#import "CBPBaseWorkingManager.h"

@interface CBPBaseWorkingManager ()

- (NSMutableDictionary *)actionDict;

@end

@interface CBPBaseAction () {
    finishedBlock _finishedBlock;
    answerBlock _answerBlock;
    NSTimer *_finishedActionTimer;
    id _parameter;
    // 进度
    void (^_progress)(double progress);
}

@end

@implementation CBPBaseAction


/**
 接口数组, 子类需重写

 @return 返回数组
 */
+ (NSArray *)actionInterfaces {
    return @[@""];
}

+ (void) registerAction: (id) action {
    
    NSLog(@"%@" ,[action actionInterfaces]);
    // 获得类名
    NSString *classString = NSStringFromClass([action class]);
    // 取得单例
    CBPBaseWorkingManager *manager = [CBPBaseWorkingManager manager];
    
    // 枚举设置
    NSArray *keys = [[action class] actionInterfaces];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (*stop == NO) {
            // 设置 action
            [manager.actionDict setObject: classString forKey: obj];
        }
    }];
    
}

+ (instancetype)actionWithFinishedBlock:(void (^)(id responseObject))finishedBlock {
    CBPBaseAction *action = [[super alloc] init];
    
    if (action) {
        action->_finishedBlock = finishedBlock;
        // 类名
        action->_acionName = [NSString stringWithUTF8String: object_getClassName(self)];
        // 默认命令长度
        action->_actionLength = 20;
    }
    
    return action;
}

- (NSData *)actionData {
    return [[NSData alloc] init];
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
}

- (void)setAnswerActionDataBlock:(void (^)(CBPBaseActionDataModel *))answerActionBlock {
    self->_answerBlock = answerActionBlock;
    
}

- (instancetype)initWithParameter:(id)parameter answer:(void (^)(CBPBaseActionDataModel *))answerBlock finished:(void (^)(id))finished {
    if (self = [super init]) {
        _parameter = parameter;
        _answerBlock = answerBlock;
        _finishedBlock = finished;
    }
    return self;
}

#pragma mark- 结果回调
- (void) callBackResult: (id) result {
    NSMutableDictionary *blockDiction = [NSMutableDictionary dictionaryWithCapacity: 2];
    [blockDiction setObject: result forKey: @"result"];
    [blockDiction setObject: self forKey: @"action"];
    [blockDiction setObject: @"1" forKey: @"state"];
    // 回调
    if (_finishedBlock) {
        _finishedBlock(blockDiction);
    }
}

#pragma mark-  回复数据
- (void) callAnswerResult: (id) result {
    NSLog(@"%@", [result actionData]);
    if (_answerBlock) {
        _answerBlock(result);
    }
}

#pragma mark- 失败的结果
- (void) callBackFailedResult: (id) result {
    NSMutableDictionary *blockDiction = [NSMutableDictionary dictionaryWithCapacity: 2];
    [blockDiction setObject: result forKey: @"result"];
    [blockDiction setObject: self forKey: @"action"];
    [blockDiction setObject: @"0" forKey: @"state"];
    
    // 回调
    if (_finishedBlock) {
        _finishedBlock(blockDiction);
    }
}

#pragma mark- 回调进度
- (void) callBackProgress: (NSNumber *)progress {
    double progressValue = [progress doubleValue];
    
    // 如果进度存在
    if (_progress) {
        _progress(progressValue);
    }
}

@end
