//
//  CBPWKLStepAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 15/11/14.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "CBPWKLStepAction.h"


@interface CBPWKLStepAction () {
    /**
     *  位域控制表
     */

    Byte _bitControlTable[15];
    
    /**
     *  短包数
     */
    Byte _shortPackage[120][17];
}

/**
 *  计步数据的总天数, 同时表示长包的个数
 */
@property (nonatomic, assign) NSInteger dayCount;

/**
 *  长包计数, 也即长包序号
 */
@property (nonatomic, assign) NSInteger longPackageNumber;

/**
 *  一个长包有效数据个数
 */
@property (nonatomic, assign) NSInteger effectiveDataCount;

/**
 *  短包个数
 */
@property (nonatomic, assign) NSInteger shortPackageCount;

/**
 * 短包序号计数
 */
@property (nonatomic, assign) NSInteger shortPackageNumber;


/**
 *  单个长包数据
 */
@property (nonatomic, strong) NSMutableData *longPackageData;

/**
 *  指示日期
 */
@property (nonatomic, copy) NSString *indicatorDate;

/**
 *  一天的总步数
 */
@property (nonatomic, copy) NSString *oneDayTotalSteps;

/**
 *  每天的数据步数信息
 */
@property (nonatomic, strong) NSMutableDictionary *stepInfo;

/**
 * 包含所有长包数据
 */
@property (nonatomic, strong) NSMutableArray *allStepData;




@end

@implementation CBPWKLStepAction

- (instancetype)init {
    
    if (self = [super init]) {
        self.saveInterval = 30.0;
        memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
    }
    return self;
}

- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    bytes[0] = 0x5a;
    bytes[1] = 0x02;
    
    // 间隔时间
    bytes[3] = self.saveInterval;
    
    if (self.stepActionType == kWKLStepActionTypeSynchronizeStepData) {
        bytes[1] = 0x03;
        if ([self.endDate isEqualToString: @"0"]) {
            
            
            // 算法问题, 年份 - 2000, 表示两千年以后的年份
            // 开始日期
            bytes[3] = 0;
            bytes[4] = 0;
            bytes[5] = 0;
            // 结束日期
            bytes[6] = 0;
            bytes[7] = 0;
            bytes[8] = 0;
        }
        else {
            NSArray *startDateArray = [self.startDate componentsSeparatedByString: @"/"];
            NSArray *endDataArray = [self.endDate componentsSeparatedByString: @"/"];
            
            if (startDateArray.count != 3 || endDataArray.count != 3) {
//                CBPDEBUG;
                NSLog(@"日期不正确");
                exit(0);
            }
            
            // 算法问题, 年份 - 2000, 表示两千年以后的年份
            // 开始日期
            bytes[3] = [startDateArray[0] integerValue] - 2000;
            bytes[4] = [startDateArray[1] integerValue];
            bytes[5] = [startDateArray[2] integerValue];
            // 结束日期
            bytes[6] = [endDataArray[0] integerValue] - 2000;
            bytes[7] = [endDataArray[1] integerValue];
            bytes[8] = [endDataArray[2] integerValue];
        }
        
       
    }
    
    NSData *actionData = [NSData dataWithBytes: bytes length: self.actionLength];
    
    NSLog(@"%@", actionData);
    return actionData;
}

- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 同步命令回复
        if (bytes[0] == 0x5b && bytes[1] == 0x03) {
            
            // 处理回复的第一个数据
            [self handleFirstAnswer: (Byte *) bytes];
            
            return;
        }
        
        // 设备开始主动发数据
        if (bytes[0] == 0x5a && bytes[1] == 0x05) {
            
            if (bytes[2] == 0x01) {
                
                // 处理短包 操作信息
                [self handleShortPackageActionAnswer: bytes];
            } else if (bytes[2] >= 0x02 && bytes[2] < 0xfe) {
                
                // 处理短包有效信息
                [self handleShortPackageEffectiveAnswer: bytes];
                
            } else if (bytes[2] == 0xfe) {
                // 每个长包的最后一个短包
                [self handleShortPackageLastAnswer: bytes];
                
            } else if (bytes[2] == 0xff) {
                // 最后一天数据
                [self handleLastDayPackage: bytes];
                
            } else if (bytes[2] == 0x00) {
                // 特殊回应
                [self handleNextDayDataPackage];
            }
        }
       
    }
}

#pragma mark---处理第一个数据
- (void) handleFirstAnswer: (Byte *) bytes {
    
    // 总长包的个数
    self.dayCount = bytes[3] * 256 + bytes[4];
    
    NSLog(@"总天数%@", @(self.dayCount));
    
    if (bytes[5] == 0x00) {
       
    } else if (bytes[5] == 0x01) {
        NSLog(@"数据有效");
        // 总步数
        NSInteger steps = bytes[6] * 256 + bytes[7];
        
        NSLog(@"最后一天总步数%@", @(steps));
    }
    
    if (_stepInfo == nil) {
        _stepInfo = [NSMutableDictionary dictionaryWithCapacity: _dayCount];
    }
    
    // 清空所有数据
    [_stepInfo removeAllObjects];
}

#pragma mark--- 处理每个长包的第一个短包数据
- (void) handleShortPackageActionAnswer: (Byte *) bytes {
    
    // 有效数据个数
    self.effectiveDataCount = bytes[3] * 256 + bytes[4];
    
    // 记录长包数据
    if (_longPackageData == nil) {
        _longPackageData = [NSMutableData data];
    }
        
    // 清空
    _longPackageData.length = 0;
    
    _shortPackageNumber = bytes[2];
    
    // 短包个数,
    _shortPackageCount = self.effectiveDataCount / 17 + ((self.effectiveDataCount % 17)?1:0);
    
    // 记录长包序号
    _longPackageNumber = bytes[5] * 256 + bytes[6];
    
    // 第一个分包位域控制, 以下三种算法都 ok, 采用取反的方法 ! 不行
    //_bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff - (1<< ((_shortPackageNumber - 1) % 8));
    
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<(_shortPackageNumber - 1) % 8);
    
    // 最后一包所在位域
    NSInteger bitIndex = _shortPackageCount % 8 + 1;
    for (NSInteger index = bitIndex; index < 8; ++index) {
        _bitControlTable[(_shortPackageCount) / 8] &= 0xff^(1<<index);
    }
    
    // 0xff - pow(2, (_shortPackageNumber - 1) / 8))
    
    // 位域控制
    for (NSInteger index = (_shortPackageCount) / 8 + 1; index < 15; ++index) {
        _bitControlTable[index] = 0x00;
    }
    
    // 年月日
    NSInteger year = bytes[10] + 2000;
    NSInteger month = bytes[11];
    NSInteger day = bytes[12];
    
    // 当前指示日期
    _indicatorDate = [NSString stringWithFormat:@"%@/%@/%@", @(year), @(month), @(day)];
    
    memset(_shortPackage, '\0', sizeof(_shortPackage));
}

- (void) handleShortPackageEffectiveAnswer: (Byte *) bytes {
    
    // 屏蔽掉不合理数据
    if (bytes[2] < 0x02 || bytes[2] >= 0xfe) {
        return;
    }
    
    
    // 获取短包序号 是从 0x02 开始
    _shortPackageNumber = bytes[2];
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<((_shortPackageNumber - 1) % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
     // 获取短包序号 是从 0x02 开始, 所以要减去 2
    memcpy(_shortPackage[_shortPackageNumber - 2], effectiveByte, sizeof(Byte) * 17);
}

- (void) handleShortPackageLastAnswer: (Byte *) bytes {
    
    // 过滤数据
    if (bytes[2] != 0xfe) {
        return;
    }
    
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    // 最后一个数据位
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
   
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDaySteps];
    }
    
    [self sendBitControllTable];
}

#pragma mark---判断位域表
- (BOOL) shortPackageFinished {
    
    // 预先假设全部接收
    
    // 判断位域表是否全部为 0
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {

            return NO;
        }
    }
    
    return YES;
}

- (void) handleOneDaySteps {
    
    for (NSInteger index = 0; index < _shortPackageCount; ++index) {
        
        if (index == _shortPackageCount - 1) {
            // 最后一个有效数据的长度
            NSInteger effectiveLength = _effectiveDataCount % 17;
            
            // 有效数据
            if (!effectiveLength) {
                effectiveLength = 17;
            }
            
            // 最后一个短包
            [_longPackageData appendBytes: _shortPackage[index] length: effectiveLength];
          
        } else {
            [_longPackageData appendBytes: &_shortPackage[index] length: 17];
        }
    }
    
    NSLog(@"%@: 所有数据:%@ ====> %@", _indicatorDate, _longPackageData, @(_longPackageData.length));
    
    if (_longPackageData.length % 2 != 0) {
//        CBPDEBUG;
        exit(0);
    }
    
    // 获得数据
    Byte *bytes = (Byte *)[_longPackageData bytes];
    
    NSMutableArray *sportDataArray = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    
    for (NSInteger index = 0; index < _longPackageData.length; index += 2) {
        
        NSString *timeSection = [NSString stringWithFormat:@"%02ld:%02ld~%02ld:%02ld", (long)(index/2 * 30/ 60), (long)(index/2 * 30 % 60), (long)(long)((index/2 + 1)*30/60), (long)((index/2 + 1)*30%60)];
        
        NSInteger stepData = bytes[index] * 256 + bytes[index + 1];
        
        if (stepData >= 0x000 && stepData <= 0xfeff) {
            NSDictionary *dictInfo = @{@"time" : timeSection, @"steps" : @(stepData)};
            [sportDataArray addObject: dictInfo];
        } else if (stepData == 0xffff) {
            NSDictionary *dictInfo = @{@"time" : timeSection, @"steps" : @"未佩戴设备"};
            [sportDataArray addObject: dictInfo];
        } else {
            NSDictionary *dictInfo = @{@"time" : timeSection, @"steps" : @"未知状态"};
            [sportDataArray addObject: dictInfo];
        }
    }
    
    [dictionary setObject: sportDataArray forKey: @"sportData"];
    [dictionary setObject: _indicatorDate forKey: @"date"];
    
    if (_allStepData == nil) {
        _allStepData = [NSMutableArray array];
    }
    // 将一天的长包数据组装回数组
    [_allStepData addObject: dictionary];
    
}

#pragma mark---发送位域控制表
- (void) sendBitControllTable {
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认位域表
    bytes[0] = 0x5b;
    bytes[1] = 0x05;
    bytes[3] = _longPackageNumber / 256;
    bytes[4] = _longPackageNumber % 256;
    
    Byte *bitControlTable = &bytes[5];
    memcpy(bitControlTable, _bitControlTable, sizeof(_bitControlTable) / sizeof(Byte));

    NSData *bitControlTableData = [NSData dataWithBytes: bytes length: 20];
    
    model.actionData = bitControlTableData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    // 回传位域表
//    self->_answerBlock(model);
}

#pragma mark---处理请求下一天的数据
- (void) handleNextDayDataPackage {
    
    if (_longPackageNumber == _dayCount || _dayCount == 1) {
        // 表示所有数据发送完成
        
        if (_stepInfo == nil) {
            _stepInfo = [NSMutableDictionary dictionary];
        }
        [_stepInfo setObject: @"YES" forKey: @"state"];
        [_stepInfo setObject: @"1000" forKey: @"code"];
        [_stepInfo setObject: _allStepData forKey: @"data"];
//        self->_finishedBlock(_stepInfo);
        
        return;
    }
    
    memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
    
    // 请求下一个长包数据
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认长包
    bytes[0] = 0x5a;
    bytes[1] = 0x06;
    bytes[3] = _longPackageNumber / 256;
    bytes[4] = _longPackageNumber % 256;
    
    if (_longPackageNumber == _dayCount || _dayCount == 1) {
        bytes[3] = 0xff;
        bytes[4] = 0xff;
    }
   
    // 下一个长包数据, 若无则无返回数据
    NSData *nextData = [NSData dataWithBytes: bytes length: 20];
    model.actionData = nextData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    // 回传信息
//    self->_answerBlock(model);

}

#pragma mark---每个长包最后一包数据
- (void) handleLastDayPackage: (Byte *)bytes {
    
    // 有效数据放行
    if (bytes[2] != 0xff) {
        return;
    }
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    // 每天最后一包数据
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDaySteps];
    }
    
    [self sendBitControllTable];
}

@end
