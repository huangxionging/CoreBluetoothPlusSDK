//
//  CBPWKLFirmwareUpgradeAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 16/9/6.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLFirmwareUpgradeAction.h"
#import "CBPDispatchMessageManager.h"
#import "CBPHexStringManager.h"

// 每个长包内容的最大长度
static NSInteger max_content_length = 1024;

// 每个短包内容的最大长度 字节
static NSInteger max_short_content_length = 17;

// 短包最大程度 20字节
static NSInteger max_short_package_length = 20;

// 升级时间内 收不到数据认为超时
static NSInteger firmware_upgrade_time_out = 3;

// 重传次数, 超时重传次数
static NSInteger retransmission_times = 5;

static unsigned short ccitt_table[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7, 0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF, 0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6, 0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE, 0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485, 0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D, 0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4, 0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC, 0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823, 0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B, 0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A, 0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41, 0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49, 0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70, 0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78, 0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F, 0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067, 0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E, 0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256, 0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D, 0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C, 0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634, 0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB, 0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3, 0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A, 0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92, 0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9, 0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1, 0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8, 0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};

unsigned short crc_ccitt(unsigned char *q, int len) {
    unsigned short crc = 0;
    while (len-- > 0) {
        crc = ccitt_table[(crc >> 8 ^ *q++) & 0xff] ^ (crc << 8); }
    return ~crc;
}

@interface CBPWKLFirmwareUpgradeAction (){
    // 位域表
    Byte _bitControlTable[15];
}

// 升级包命令
@property (nonatomic, copy) NSData *actionFirstData;

// 固件数据
@property (nonatomic, copy) NSData *firmwareData;

#pragma mark- 长包指令相关
@property (nonatomic, assign) CBPHexStringManager *hexString;

// 指令被切割成长包指令数组

@property (nonatomic, assign) BOOL isSendFinished;

// 长指令长度字节数
@property (nonatomic, assign) NSInteger longActionLength;
// 长指令个数
@property (nonatomic, assign) NSInteger longActionCount;

// 每个长指令切割成短包指令数组
@property (nonatomic, strong) NSMutableArray *shortActionArray;

@property (nonatomic, assign) NSInteger shortActionCount;

// 指令的索引
@property (nonatomic, assign) NSInteger indexOfLongAction;

// 短包索引
@property (nonatomic, assign) NSInteger indexOfShortAction;

// 当前长指令索引, 用于位于表
@property (nonatomic, assign) NSInteger currentIndexOfLongAction;

@end

@implementation CBPWKLFirmwareUpgradeAction

+ (void)load {
    
    // 加载
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method:@"registerAction:", self, nil];
    
}

// 指令标识集合
+ (NSSet *)keySetForAction {
    return [NSSet setWithObjects:@"0x11", @"0x05", @"0x06", nil];
}

// 接口数组
+ (NSArray *)actionInterfaces {
    // 对应的 keys
    NSArray *interfaces = @[// 同步参数,
                            @"general_firmware_upgrade"];
    // 返回接口
    return interfaces;
}

#pragma mark- 数据
- (void) actionData {
    
    if (self.actionFirstData) {
        return;
    }
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    
    NSAssert(parameter, @"参数写错了");
    NSString *filePath = parameter[@"file_path"];
    self.firmwareData = [NSData dataWithContentsOfFile: filePath];
    self.longActionLength = self.firmwareData.length;
    // 设置超时时间为 15 s
    [self setValue: @"15.0" forKey: @"_timeOutInterval"];
    
    Byte bytes[20] = {0};
    
    // 普通升级
    bytes[0] = 0x5a;
    bytes[1] = 0x11;
    bytes[3] = (self.longActionLength & 0xff000000) >> 24;
    bytes[4] = (self.longActionLength & 0x00ff0000) >> 16;
    bytes[5] = (self.longActionLength & 0x0000ff00) >> 8;
    bytes[6] = self.longActionLength & 0x000000ff;
    
    // crc 校验
    unsigned short check = crc_ccitt((Byte *)[self.firmwareData bytes], (int)self.longActionLength);
    bytes[7] = (check & 0xff00) >> 8;
    bytes[8] = (check & 0x00ff);
    bytes[9] = (max_content_length & 0xff00) >> 8;
    bytes[10] = (max_content_length & 0x00ff);
    
    // 超时时间
    bytes[11] = firmware_upgrade_time_out;
    
    // 超时重传次数
    bytes[12] = retransmission_times;
    // 计算长包个数
    self.longActionCount = (self.longActionLength % max_content_length)?(self.longActionLength / max_content_length + 1):(self.longActionLength / max_content_length);
    
    
    self.actionFirstData = [NSData dataWithBytes: bytes length: 20];
    
    
    // 发送指令数据
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"sendActionData:", self.actionFirstData, nil];
}

#pragma mark- 处理返回数据
- (void)receiveUpdateData:(CBPBaseActionDataModel *)updateDataModel {
    NSLog(@"接受数据:%@", updateDataModel.actionData);
    
    if (updateDataModel) {
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
    
        // 升级初始状态
        if (bytes[0] == 0x5b && bytes[1] == 0x11) {
            
            // 接受升级数据
            if (bytes[3] != 0) {
                self.indexOfLongAction = 0;
                
                [self continueSendAction];
            }
        } else if (bytes[0] == 0x5b && bytes[1] == 0x05 && bytes[2] == 0x00) {
            // 接收回传的位域表
            [self handleBitControllTable: updateDataModel.actionData];
        } else if (bytes[0] == 0x5a && bytes[1] == 0x06 && bytes[2] == 0x00) {
            [self handleLongPackageControll: updateDataModel.actionData];
        }
    }
    
    
    
}


- (NSMutableArray *)shortActionArray {
    if (_shortActionArray == nil) {
        _shortActionArray = [NSMutableArray arrayWithCapacity: 10];
    }
    return  _shortActionArray;
}

// 发送每个长包的第一个数据
- (void) sendShortFirstAction {
    
    // 获得长包指令的长度
    NSInteger length = max_content_length;
    if (_indexOfLongAction == self.longActionCount - 1)  {
        length = self.longActionLength - _indexOfLongAction * max_content_length;
    }
    
    // 获得固件长包数据
    NSData *subData = [self.firmwareData subdataWithRange: NSMakeRange(self.indexOfLongAction * max_content_length, length)];
    
    // 获得长指令
    NSString *longAction = [[CBPHexStringManager shareManager] hexStringForData: subData];
   
    // 字节数 长度
    NSInteger actionLength = longAction.length / 2;
    
    // 短包计数
    self.shortActionCount = actionLength / max_short_content_length + ((actionLength % max_short_content_length) ? 1 : 0);
    
    // 清空数据
    [self.shortActionArray removeAllObjects];
    
    // 切割长指令为短包指令
    for (NSInteger index = 0; index < _shortActionCount; ++index) {
        NSInteger length = max_short_content_length;
        if (index == self.shortActionCount - 1) {
            length = actionLength - index * max_short_content_length;
        }
        
        NSRange range = NSMakeRange(index * max_short_content_length * 2, length * 2);
        
        NSString *shortAction = [longAction substringWithRange: range];
        //        DLog(@"短包指令%@", shortAction);
        // 添加短包指令
        [self.shortActionArray addObject: shortAction];
    }

    // 发送第长包的第一个数据
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    Byte bytes[20] = {0};
    // 确认数据
    bytes[0] = 0x5a;
    bytes[1] = 0x05;
    bytes[2] = 0x01;
    bytes[3] = (actionLength & 0xff00) >> 8;
    bytes[4] = (actionLength & 0x00ff);
    
    // 如果只有一个长包
    if (self.longActionCount == 1) {
        bytes[5] = 0x00;
        bytes[6] = 0x00;
    } else {
        bytes[5] = ((self.indexOfLongAction + 1) & 0xff00) >> 8;
        bytes[6] = ((self.indexOfLongAction + 1) & 0x00ff);
    }
    
    Byte *checkData = [[CBPHexStringManager shareManager] bytesForString: longAction];
    
    unsigned short crc_check = crc_ccitt(checkData, (int)actionLength);
    bytes[7] = (crc_check & 0xff00) >> 8;
    bytes[8] = (crc_check & 0x00ff);
    bytes[9] = 0x11;
    
    NSData *data = [NSData dataWithBytes: bytes length: max_short_package_length];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x05";
    // 回传位域表
    self.indexOfShortAction++;

    id result = model;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
    
    // 初始化位域表
    memset(_bitControlTable, 0xff, sizeof(_bitControlTable));
}

// 发送有效数据
- (void) sendShortEffectiveAction {
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认位域表
    bytes[0] = 0x5a;
    bytes[1] = 0x05;
    bytes[2] = _indexOfShortAction + 1;
    
    NSString *shortAction = _shortActionArray[_indexOfShortAction - 1];
    
    Byte *content = [[CBPHexStringManager shareManager] bytesForString: shortAction];
    // 拷贝命令数据
    memcpy(&bytes[3], content, sizeof(Byte) * shortAction.length / 2);
    NSData *data = [NSData dataWithBytes: bytes length: max_short_package_length];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x05";
    // 有效数据包
    _indexOfShortAction++;

    id result = model;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
}

// 发送除最后一个长包外的长包的最后一个短包
- (void) sendShortLastAction {
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    NSString *shortAction = _shortActionArray[_indexOfShortAction - 1];
    
    // 字节数
    NSInteger length = shortAction.length / 2;
    NSInteger count = length + 3;
    Byte *bytes = (Byte *)malloc(sizeof(Byte) * count);
    memset(bytes, 0x00, sizeof(Byte) * count);
    
    // 确认位域表
    bytes[0] = 0x5a;
    bytes[1] = 0x05;
    bytes[2] = 0xfe;
    
    Byte *content =[[CBPHexStringManager shareManager] bytesForString: shortAction];
    // 拷贝命令数据
    memcpy(&bytes[3], content, sizeof(Byte) * length);
    // 除最后一个长包外的最后一个短包
    NSData *data = [NSData dataWithBytes: bytes length: count];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x05";
    // 不是最后一个长包的最后一个短包
//    DLog(@"一个长包的最后一个短包: ======= %@", model.actionData);
    
    _isSendFinished = YES;
//    [self.timer setFireDate: [NSDate distantFuture]];
 
    id result = model;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
    
}

// 发送最后一个长包的最后一个短包
- (void) sendLastAction {
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    NSString *shortAction = _shortActionArray[_indexOfShortAction - 1];
    
    // 字节数
    NSInteger length = shortAction.length / 2;
    NSInteger count = length + 3;
    Byte *bytes = (Byte *)malloc(sizeof(Byte) * count);
    memset(bytes, 0x00, sizeof(Byte) * count);
    
    // 确认位域表
    bytes[0] = 0x5a;
    bytes[1] = 0x05;
    bytes[2] = 0xff;
    
    Byte *content = [[CBPHexStringManager shareManager] bytesForString: shortAction];
    // 拷贝命令数据
    memcpy(&bytes[3], content, sizeof(Byte) * length);
    // 除最后一个长包外的最后一个短包
    NSData *data = [NSData dataWithBytes: bytes length: count];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    _indexOfShortAction = 0;
    _isSendFinished = YES;
    if (_indexOfLongAction > _longActionCount) {
        _isSendFinished = YES;
    }
    model.keyword = @"0x05";
    // 最后一个长包的最后一个短包
    id result = model;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
    
}

- (void)continueSendAction {
    // 如果完成发送, 则不理会
    if (_isSendFinished == YES) {
        return;
    }
    
    // 发送 某长包的第一个短包
    if (_indexOfShortAction == 0) {
        [self sendShortFirstAction];
    } else if (_indexOfShortAction < _shortActionCount){
        // 发送有效数据
        [self sendShortEffectiveAction];
    } else if (_indexOfShortAction == _shortActionCount) {
        
        // 发送除最后一长包以外的长包的最后一包 或者最后一条数据
        if (_indexOfLongAction < _longActionCount - 1) {
            [self sendShortLastAction];
        } else {
            // 发送最后一条数据
            [self sendLastAction];
        }
    }
    
//    [self performSelector: @selector(continueSendAction) withObject: nil afterDelay: 1];
    // 调用本身
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"continueSendAction", nil];
}

- (void) handleLongPackageControll:(NSData *)longTable {
    NSInteger length = longTable.length;
    
    // 不够20
    if (length < 20 ) {
        return;
    }
    
    Byte *bytes = (Byte *)[longTable bytes];
    NSInteger longPackageSerial = (bytes[3] << 8) + bytes[4];
    
    if (self.indexOfLongAction == longPackageSerial - 2) {
        NSLog(@"已发完一个长包");
        
        if (self.indexOfLongAction < self.longActionCount - 1) {
            _indexOfLongAction++;
            _indexOfShortAction = 0;
            _isSendFinished = NO;
            // 进度
            NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
            
            double progressValue = (self.indexOfLongAction) / (double) self.longActionCount;
            // 取 4 位小数
            NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
            // 进度
            [progressData setObject: progress forKey: @"progress"];
            id result = progressData;
            // 调度进度
            [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", result, nil];
            
            // 调度 发送 方法
            [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"continueSendAction", nil];
        }
    } else if (longPackageSerial == 0xffff) {
        // 表示升级完成
        
        // 进度
        NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
        double progressValue = 1.0;
        // 取 4 位小数
        NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
        // 进度
        [progressData setObject: progress forKey: @"progress"];
        id result = progressData;
        // 调度进度
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", result, nil];
        
        // 完成信息
        // 待回传的结果
        NSMutableDictionary *success = [NSMutableDictionary dictionaryWithCapacity: 5];
        NSString *code = @"0";
        [success setObject: code forKey: @"code"];
        // 回传结果
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", success, nil];
    }
    
}

- (void) handleBitControllTable: (NSData *) bitControllTable {
    
    NSInteger length = bitControllTable.length;
    
    // 不够20
    if (length < 20 ) {
        return;
    }
    // 获得位域表
    Byte *bytes = (Byte *)[bitControllTable bytes];
    self.currentIndexOfLongAction = (bytes[3] << 8) + bytes[4];
    
//    memcpy(_bitControlTable, &(bytes[5]), 15);
    
    // 获得位域表
    [bitControllTable getBytes: _bitControlTable  range: NSMakeRange(5, 15)];
    
    // 判断位域表是否全部为 0
    BOOL flag = NO;
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {
            flag = YES;
//            NSInteger startLocation = index * 8;
//            NSInteger endLocation = startLocation + 7;
            for (NSInteger indexOfShort = 0; indexOfShort < 8; ++indexOfShort) {
                
            }
        }
    }
    
    // 回复
    if (flag == NO) {
        // 发送确认信号
        [self sendQuerySingal];
    }

}

- (BOOL) shortPackageFinished {
    
    // 判断位域表是否全部为 0
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {
            return NO;
        }
    }
    
    return YES;
}

// 发送 确认信号
- (void) sendQuerySingal {
    
    CBPBaseActionDataModel *model = [[CBPBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认数据
    bytes[0] = 0x5a;
    bytes[1] = 0x05;
    bytes[3] = ((self.indexOfLongAction + 1) & 0xff00) >> 8;
    bytes[4] = ((self.indexOfLongAction + 1) & 0x00ff);
    
    // 确认信号
    NSData *data = [NSData dataWithBytes: bytes length: max_short_package_length];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    model.keyword = @"0x05";

    // 最后一个长包的最后一个短包
    id result = model;
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callAnswerResult:", result, nil];
}


- (void)timeOut {
   
    CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeUpgradeTimeOut info: @"升级超时失败"];
    
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
}



@end
