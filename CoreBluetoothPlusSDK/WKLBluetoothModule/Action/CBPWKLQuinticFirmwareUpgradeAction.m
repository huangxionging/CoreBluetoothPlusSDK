//
//  CBPWKLQuinticFirmwareUpgradeAction.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/10.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPWKLQuinticFirmwareUpgradeAction.h"
#import "CBPDispatchMessageManager.h"
#import "CBPHexStringManager.h"
#import "OtaApi.h"

NSInteger max_content_length = 1024;

@interface CBPWKLQuinticFirmwareUpgradeAction ()<otaEnableConfirmDelegate, otaApiUpdateAppDataDelegate>

// 长指令长度字节数
@property (nonatomic, assign) NSInteger longActionLength;
// 长指令个数
@property (nonatomic, assign) NSInteger longActionCount;

@property (nonatomic, copy) NSData *firmwareData;


@end

@implementation CBPWKLQuinticFirmwareUpgradeAction

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
                            @"quintic_firmware_upgrade"];
    // 返回接口
    return interfaces;
}


- (NSData *)actionData {
    
    // 1 表示 Quintic OTA Profile升级固件
    NSDictionary *parameter = [self valueForKey: @"parameter"];
    NSString *filePath = parameter[@"file_path"];
    self.firmwareData = [NSData dataWithContentsOfFile: filePath];
    self.longActionLength = self.firmwareData.length;

    [self setValue: @"1500.0" forKey: @"_timeOutInterval"];
    [otaApi sharedInstance].otaEnableConfirmDelegate = self;
    [otaApi sharedInstance].otaApiUpdateAppDataDelegate =self;
    return nil;
}

#pragma mark --------------------昆电科OTA升级 部分-------------------

#pragma mark 昆电科OTA升级
-(void)didOtaEnableConfirm : (CBPeripheral *)aPeripheral
                withStatus : (enum otaEnableResult) otaEnableStatus
{
    
    
    Byte *fileBytes = (Byte *)[self.firmwareData bytes];
    
    NSLog(@"升级长度 : %ld", (long)self.longActionLength);
    
    if(self.longActionLength == 0)
    {
        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileInvalid info: @"固件数据无效"];
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
        return;
    }
    
    // 大于 50 个长包 表示文件太大
    if(self.longActionLength > 50 * max_content_length)
    {
        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileTooLarge info: @"固件数据太大"];
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
        return;
    }
    
    // ===== to start download ======
    [[otaApi sharedInstance] otaStart : aPeripheral
                         withDataByte : fileBytes
                           withLength : (uint32_t)self.longActionLength
                             withFlag : FALSE];
}

-(void)didOtaAppProgress : (enum otaResult)otaPackageSentStatus
            withDataSent : (uint16_t)otaDataSent
{
    
    // 进度
    NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
    
    double progressValue = (otaDataSent) / (double) self.longActionLength;
    // 取 4 位小数
    NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
    // 进度
    [progressData setObject: progress forKey: @"progress"];
    id result = progressData;
    // 调度进度
    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", result, nil];
}

-(void)didOtaMetaDataResult : (enum otaResult)otaMetaDataSentStatus
{
    
}
-(void)didOtaAppResult : (enum otaResult )otaResult
{
    if (otaResult == OTA_RESULT_SUCCESS ) {
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
    }else
    {
        NSString *error= @"";
        switch (otaResult) {
            case OTA_RESULT_PKT_CHECKSUM_ERROR:
                error = @"OTA_RESULT_PKT_CHECKSUM_ERROR";
                break;
            case OTA_RESULT_PKT_LEN_ERROR:
                error = @"OTA_RESULT_PKT_LEN_ERROR";
                break;
            case OTA_RESULT_DEVICE_NOT_SUPPORT_OTA:
                error = @"OTA_RESULT_DEVICE_NOT_SUPPORT_OTA";
                break;
            case OTA_RESULT_FW_SIZE_ERROR:
                error = @"OTA_RESULT_FW_SIZE_ERROR";
                break;
            case OTA_RESULT_FW_VERIFY_ERROR:
                error = @"OTA_RESULT_FW_VERIFY_ERROR";
                break;
                
            default:
                break;
        }
        
        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileInvalid info: error];
        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
    }
}

- (void)timeOut {
    
}

@end
