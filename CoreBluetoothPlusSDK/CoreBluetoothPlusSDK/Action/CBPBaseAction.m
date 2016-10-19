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
#import "CBPDispatchMessageManager.h"

@interface CBPBaseWorkingManager ()

- (NSMutableDictionary *)actionDict;

@end

@interface CBPBaseAction () {
    finishedBlock _finishedBlock;
    answerBlock _answerBlock;
    NSTimer *_finishedActionTimer;
    // 参数
    id _parameter;
    // 进度
    void (^_progress)(id progress);
    // 定时器
    NSTimer *_timer;
    // 超时间隔
    NSString *_timeOutInterval;
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
        // 默认时长为 3.0
        action->_timeOutInterval = @"3.0";
    }
    
    return action;
}

- (void) actionData {
    
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
        _actionLength = 20;
        // 默认时长为 3.0
        _timeOutInterval = @"3.0";
        _acionName = [NSString stringWithUTF8String: object_getClassName(self)];
    }
    return self;
}

#pragma mark- 开启定时器
- (void) startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval: [_timeOutInterval doubleValue] target: self selector: @selector(timeOut) userInfo: nil repeats: NO];
    [[NSRunLoop mainRunLoop] addTimer: _timer forMode:NSRunLoopCommonModes];
}

- (void) stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timeOut {
    
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

#pragma mark- 发送设备命令, 非回复数据
- (void) sendActionData: (NSData *) actionData {
    
    NSLog(@"命令数据: %@", actionData);
    
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    model.actionData = actionData;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    
    NSSet *keySet = [[CBPDispatchMessageManager shareManager] dispatchReturnValueTarget: [self class] method: @"keySetForAction", nil];
    model.keyword = [keySet anyObject];
    // 回复数据
    id result = model;
    // 利用回复数据的通道
    [self callAnswerResult: result];
}

#pragma mark-  回复数据
- (void) callAnswerResult: (id) result {
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
- (void) callBackProgress: (id )progressData {
    // 如果进度存在
    if (_progress) {
        _progress(progressData);
    }
}

@end
