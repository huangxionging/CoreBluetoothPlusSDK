//
//  CBPQuinticUpgradeController.m
//  CoreBluetoothPlusSDK
//
//  Created by huangxiong on 2016/10/11.
//  Copyright © 2016年 huangxiong. All rights reserved.
//

#import "CBPQuinticUpgradeController.h"
#import "CBPBaseWorkingManager.h"
#import "CBPBaseCharacteristicModel.h"
#import "CBPHexStringManager.h"
#import "CBPDispatchMessageManager.h"
#import "CBPBaseWorkingManager.h"
#import "OtaApi.h"

static NSInteger max_content_length = 1024;

@interface CBPQuinticUpgradeController () {
    qBleClient *_client;
}
// 长指令长度字节数
@property (nonatomic, assign) NSInteger longActionLength;
// 长指令个数
@property (nonatomic, assign) NSInteger longActionCount;

@property (nonatomic, copy) NSData *firmwareData;

@end

@implementation CBPQuinticUpgradeController

+ (void)load {
    
    // 注册控制器
    [[CBPDispatchMessageManager shareManager] dispatchTarget: [self superclass] method: @"registerController:", self, nil];
}

+ (NSString *)controllerKey {
    return @"com.quintic.controller";
}

- (void)startWorkWithBlock:(void (^)(id))block {
}

- (void)deviceStartWorkWith:(CBPBasePeripheralModel *)peripheralModel  {
  
    _client.peripheral = peripheralModel.peripheral;
    _client.peripheral.delegate = _client;
    [_client.peripheral discoverServices: nil];
    
    [_client.bleDidConnectionsDelegate bleDidConnectPeripheral: _client.peripheral];
}

- (void)sendAction:(NSString *)actionName parameters:(id)parameters progress:(void (^)(id))progress success:(void (^)(CBPBaseAction *, id))success failure:(void (^)(CBPBaseAction *, CBPBaseError *))failure {
    
    // 只需要一次
    [CBPBaseWorkingManager manager].upgradeControllerKey = nil;
    
    _client = [qBleClient sharedInstance];
    
    __weak CBPQuinticUpgradeController *weakSelf = self;
    
    // 共享的连接
    weakSelf.baseClient = [CBPBaseClient shareBaseClient];
    
    // 获取外设
    CBPBasePeripheralModel *model = [[CBPBaseWorkingManager manager].baseController.baseDevice valueForKey:@"_peripheralModel"];
    

    
    CBPBaseAction *action = [[NSClassFromString(actionName) alloc] initWithParameter: parameters answer:^(CBPBaseActionDataModel *answerDataModel) {
        
    } finished:^(id result) {
//        [weakSelf.baseClient setUpgradeConnectionPeripheralBlock: nil];
    }];
    
    [weakSelf.actionSheet setObject: action forKey: @"quintic_upgrade"];
    
    // 设置进度 block, 当需要进度的时候, 要在发送数据之前设置好
    if (progress) {
        [action setValue: progress forKey: @"_progress"];
    }
    
    [weakSelf deviceStartWorkWith: model];
    // 调用
    [action actionData];
    
    
}

//#pragma mark --------------------昆电科OTA升级 部分-------------------
//
//#pragma mark 昆电科OTA升级
//-(void)didOtaEnableConfirm : (CBPeripheral *)aPeripheral
//                withStatus : (enum otaEnableResult) otaEnableStatus
//{
//    
//    
//    Byte *fileBytes = (Byte *)[self.firmwareData bytes];
//    
//    NSLog(@"升级长度 : %ld", (long)self.longActionLength);
//    
//    if(self.longActionLength == 0)
//    {
//        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileInvalid info: @"固件数据无效"];
//        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
//        return;
//    }
//    
//    // 大于 50 个长包 表示文件太大
//    if(self.longActionLength > 50 * max_content_length)
//    {
//        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileTooLarge info: @"固件数据太大"];
//        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
//        return;
//    }
//    
//    // ===== to start download ======
//    [[otaApi sharedInstance] otaStart : aPeripheral
//                         withDataByte : fileBytes
//                           withLength : (uint32_t)self.longActionLength
//                             withFlag : FALSE];
//}
//
//-(void)didOtaAppProgress : (enum otaResult)otaPackageSentStatus
//            withDataSent : (uint16_t)otaDataSent
//{
//    
//    // 进度
//    NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
//    
//    double progressValue = (otaDataSent) / (double) self.longActionLength;
//    // 取 4 位小数
//    NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
//    // 进度
//    [progressData setObject: progress forKey: @"progress"];
//    id result = progressData;
//    // 调度进度
//    [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", result, nil];
//}
//
//-(void)didOtaMetaDataResult : (enum otaResult)otaMetaDataSentStatus
//{
//    
//}
//-(void)didOtaAppResult : (enum otaResult )otaResult
//{
//    if (otaResult == OTA_RESULT_SUCCESS ) {
//        // 进度
//        NSMutableDictionary *progressData = [NSMutableDictionary dictionaryWithCapacity: 4];
//        double progressValue = 1.0;
//        // 取 4 位小数
//        NSString *progress = [NSString stringWithFormat: @"%0.4lf", progressValue];
//        // 进度
//        [progressData setObject: progress forKey: @"progress"];
//        id result = progressData;
//        // 调度进度
//        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackProgress:", result, nil];
//        
//        // 完成信息
//        // 待回传的结果
//        NSMutableDictionary *success = [NSMutableDictionary dictionaryWithCapacity: 5];
//        NSString *code = @"0";
//        [success setObject: code forKey: @"code"];
//        // 回传结果
//        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackResult:", success, nil];
//    }else
//    {
//        NSString *error= @"";
//        switch (otaResult) {
//            case OTA_RESULT_PKT_CHECKSUM_ERROR:
//                error = @"OTA_RESULT_PKT_CHECKSUM_ERROR";
//                break;
//            case OTA_RESULT_PKT_LEN_ERROR:
//                error = @"OTA_RESULT_PKT_LEN_ERROR";
//                break;
//            case OTA_RESULT_DEVICE_NOT_SUPPORT_OTA:
//                error = @"OTA_RESULT_DEVICE_NOT_SUPPORT_OTA";
//                break;
//            case OTA_RESULT_FW_SIZE_ERROR:
//                error = @"OTA_RESULT_FW_SIZE_ERROR";
//                break;
//            case OTA_RESULT_FW_VERIFY_ERROR:
//                error = @"OTA_RESULT_FW_VERIFY_ERROR";
//                break;
//                
//            default:
//                break;
//        }
//        
//        CBPBaseError *baseError = [CBPBaseError errorWithcode:kBaseErrorTypeFileInvalid info: error];
//        [[CBPDispatchMessageManager shareManager] dispatchTarget: self method: @"callBackFailedResult:", baseError, nil];
//    }
//}

- (void)dealloc {
    NSLog(@"挂了---");
}

@end
