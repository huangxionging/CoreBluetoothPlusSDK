/*
 * Copyright Cypress Semiconductor Corporation, 2014-2015 All rights reserved.
 *
 * This software, associated documentation and materials ("Software") is
 * owned by Cypress Semiconductor Corporation ("Cypress") and is
 * protected by and subject to worldwide patent protection (UnitedStates and foreign), United States copyright laws and international
 * treaty provisions. Therefore, unless otherwise specified in a separate license agreement between you and Cypress, this Software
 * must be treated like any other copyrighted material. Reproduction,
 * modification, translation, compilation, or representation of this
 * Software in any other form (e.g., paper, magnetic, optical, silicon)
 * is prohibited without Cypress's express written permission.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
 * NONINFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes
 * to the Software without notice. Cypress does not assume any liability
 * arising out of the application or use of Software or any product or
 * circuit described in the Software. Cypress does not authorize its
 * products for use as critical components in any products where a
 * malfunction or failure may reasonably be expected to result in
 * significant injury or death ("High Risk Product"). By including
 * Cypress's product in a High Risk Product, the manufacturer of such
 * system or application assumes all risk of such use and in doing so
 * indemnifies Cypress against all liability.
 *
 * Use of this Software may be limited by and subject to the applicable
 * Cypress software license agreement.
 *
 *
 */

#import "BootLoaderServiceModel.h"

#import "CBPManager.h"
#import "Constants.h"

#define COMMAND_PACKET_MIN_SIZE  7

/*!
 *  @class BootLoaderServiceModel
 *
 *  @discussion Class to handle the bootloader service related operations
 *
 */


@interface BootLoaderServiceModel ()<cbCharacteristicManagerDelegate>
{
    void (^cbCharacteristicDiscoverHandler)(BOOL success, NSError *error);
    void (^cbCharacteristicUpdationHandler)(BOOL success,id command,NSError *error);
    CBCharacteristic *bootLoaderCharacteristic;
    
    NSMutableArray *commandArray;
    NSString *checkSumType;
}

@end



@implementation BootLoaderServiceModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        commandArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 *  @method setCheckSumType:
 *
 *  @discussion Method to set the checksum calculation type
 *
 */
-(void) setCheckSumType:(NSString *) type
{
    checkSumType = type;
}

/*!
 *  @method discoverCharacteristicsWithCompletionHandler:
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler
{
    cbCharacteristicDiscoverHandler = handler;
    [[CBPManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CBPManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:[[CBPManager sharedManager] myService]];
}

/*!
 *  @method updateValueForCharacteristicWithCompletionHandler:
 *
 *  @discussion Method to set notifications or indications for the value of a specified characteristic
 *
 */
-(void) updateValueForCharacteristicWithCompletionHandler:(void (^) (BOOL success,id command,NSError *error)) handler
{
    cbCharacteristicUpdationHandler = handler;
    
    if (bootLoaderCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:bootLoaderCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:bootLoaderCharacteristic.UUID] descriptor:nil operation:START_NOTIFY];
        
        [[[CBPManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:bootLoaderCharacteristic];
    }
}

/*!
 *  @method writeValueToCharacteristicWithData: bootLoaderCommandCode:
 *
 *  @discussion Method to write data to the device
 *
 */

-(void) writeValueToCharacteristicWithData:(NSData *)data bootLoaderCommandCode:(unsigned short)commandCode
{
    if (data != nil && bootLoaderCharacteristic != nil)
    {
        if (commandCode)
        {
            [commandArray addObject:@(commandCode)];
        }
        
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:bootLoaderCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:bootLoaderCharacteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",WRITE_REQUEST,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:data]]];
        
        [[[CBPManager sharedManager] myPeripheral] writeValue:data forCharacteristic:bootLoaderCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop notifications or indications for the specified characteristic.
 *
 */
-(void) stopUpdate
{
    cbCharacteristicUpdationHandler = nil;
    [commandArray removeAllObjects];
    
    if (bootLoaderCharacteristic != nil)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:bootLoaderCharacteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:bootLoaderCharacteristic.UUID] descriptor:nil operation:STOP_NOTIFY];
        
        [[[CBPManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:bootLoaderCharacteristic];
    }
}


#pragma mark - CBCharacteristicManagerDelegate Methods


/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:CUSTOM_BOOT_LOADER_SERVICE_UUID])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            if ([characteristic.UUID isEqual:BOOT_LOADER_CHARACTERISTIC_UUID])
            {
                bootLoaderCharacteristic = characteristic;
                cbCharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
    else
        cbCharacteristicDiscoverHandler(NO,error);
}


/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes or read value
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error == nil)
    {
        if ([characteristic.UUID isEqual:BOOT_LOADER_CHARACTERISTIC_UUID])
        {
            uint8_t *dataPointer = (uint8_t *) [characteristic.value bytes];
            NSString *errorCode = [NSString stringWithFormat:@"0x%2x",dataPointer[1]];
            errorCode = [errorCode stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            
            // Checking the error code from the response
            if ([errorCode isEqualToString:SUCCESS])
            {
                if ([[commandArray objectAtIndex:0] isEqual:@(ENTER_BOOTLOADER)])
                {
                    [self getBootLoaderDataFromCharacteristic:characteristic];
                }
                else if ([[commandArray objectAtIndex:0] isEqual:@(GET_FLASH_SIZE)])
                {
                    [self getFlashDataFromCharacteristic:characteristic];
                }
                else if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)])
                {
                    _isWritePacketDataSuccess = YES;
                }
                else if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_ROW)])
                {
                    _isWriteRowDataSuccess = YES;
                }
                else if ([[commandArray objectAtIndex:0] isEqual:@(VERIFY_ROW)])
                {
                    [self getRowCheckSumFromCharacteristic:characteristic];
                }
                else if([[commandArray objectAtIndex:0] isEqual:@(VERIFY_CHECKSUM)])
                {
                    [self checkApplicationCheckSumFromCharacteristic:characteristic];
                }
                
                if (cbCharacteristicUpdationHandler != nil)
                {
                    cbCharacteristicUpdationHandler(YES,[commandArray objectAtIndex:0],nil);
                    [commandArray removeObjectAtIndex:0];
                }
                
            }
            else
            {
                if ([[commandArray objectAtIndex:0] isEqual:@(PROGRAM_ROW)])
                {
                    _isWriteRowDataSuccess = NO;
                }
                else if ([[commandArray objectAtIndex:0] isEqual:@(SEND_DATA)])
                {
                    _isWritePacketDataSuccess = NO;
                }
                if (cbCharacteristicUpdationHandler != nil)
                {
                    cbCharacteristicUpdationHandler(YES,[commandArray objectAtIndex:0],nil);
                    [commandArray removeObjectAtIndex:0];
                }
            }
        }
        
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:characteristic.value]]];
    }
    else
        cbCharacteristicUpdationHandler(NO,0,error);
}

/*!
 *  @method getBootLoaderDataFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the siliconID and silicon rev string
 *
 */

-(void) getBootLoaderDataFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    // Move to the position of data field
    
    dataPointer +=4;
    
    // Get silicon Id
    
    NSMutableString *siliconIDString = [NSMutableString stringWithCapacity:8];
    
    for (int i = 3; i>=0; i--)
    {
        [siliconIDString appendFormat:@"%02x",(unsigned int)dataPointer[i]];
    }
    
    _siliconIDString = siliconIDString;
    
    // Get silicon Rev
    NSMutableString *siliconRevString = [NSMutableString stringWithCapacity:2];
    [siliconRevString appendFormat:@"%02x",(unsigned int)dataPointer[4]];
    
    _siliconRevString = siliconRevString;
    
}

/*!
 *  @method getFlashDataFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the flash start and end row number
 *
 */
-(void) getFlashDataFromCharacteristic:(CBCharacteristic *)charatceristic
{
    uint8_t *dataPointer = (uint8_t *)[charatceristic.value bytes];
    
    dataPointer+=4;

    uint16_t firstRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);
    
    dataPointer += 2;
    
    uint16_t lastRowNumber = CFSwapInt16LittleToHost(*(uint16_t *) dataPointer);

    _startRowNumber = firstRowNumber;
    _endRowNumber = lastRowNumber;

}

/*!
 *  @method getRowCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the row checksum
 *
 */
-(void) getRowCheckSumFromCharacteristic:(CBCharacteristic *)characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    _checkSum = dataPointer[4];
}

/*!
 *  @method checkApplicationCheckSumFromCharacteristic:
 *
 *  @discussion Method to parse the characteristic value to get the application checksum
 *
 */
-(void) checkApplicationCheckSumFromCharacteristic:(CBCharacteristic *) characteristic
{
    uint8_t *dataPointer = (uint8_t *)[characteristic.value bytes];
    
    int applicationChecksum = dataPointer[4];
    
    if (applicationChecksum > 0)
    {
        _isApplicationValid = YES;
    }
    else
        _isApplicationValid = NO;
}


/*!
 *  @method createCommandPacketWithCommand: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createCommandPacketWithCommand:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)packetDataDictionary
{
    NSData *data = [[NSData alloc] init];
    
    uint8_t startByte = COMMAND_START_BYTE;
    uint8_t endbyte = COMMAND_END_BYTE;
    int bitPosition = 0;
    
    unsigned char *commandPacket =  (unsigned char *)malloc((COMMAND_PACKET_MIN_SIZE + dataLength)* sizeof(unsigned char));
    
    commandPacket[bitPosition++] = startByte;
    commandPacket[bitPosition++] = commandCode;
    commandPacket[bitPosition++] = dataLength;
    commandPacket[bitPosition++] = dataLength >> 8;
    
    // Handle command code for GET_FLASH_SIZE command
    if (commandCode == GET_FLASH_SIZE)
    {
        uint8_t flashArrayID = [[packetDataDictionary objectForKey:FLASH_ARRAY_ID] integerValue];
        commandPacket[bitPosition++] = flashArrayID;
    }
    
    //Handle command code for PROGRAM_ROW command
    
    if (commandCode == PROGRAM_ROW || commandCode == VERIFY_ROW)
    {
        uint8_t flashArrayID = [[packetDataDictionary objectForKey:FLASH_ARRAY_ID] integerValue];
        unsigned short flashRowNumber = [[packetDataDictionary objectForKey:FLASH_ROW_NUMBER] integerValue];
        commandPacket[bitPosition++] = flashArrayID;
        commandPacket[bitPosition++] = flashRowNumber;
        commandPacket[bitPosition++] = flashRowNumber >> 8;
        
    }
    
    // Add the data to send to the command packet
    if (commandCode == SEND_DATA || commandCode == PROGRAM_ROW)
    {
        NSArray *dataArray = [packetDataDictionary objectForKey:ROW_DATA];
        
        for (int i =0; i<dataArray.count; i++)
        {
            NSString *value = dataArray[i];
            
            unsigned int outVal;
            NSScanner* scanner = [NSScanner scannerWithString:value];
            [scanner scanHexInt:&outVal];
            
            unsigned short valueToWrite = (unsigned short)outVal;
            commandPacket[bitPosition++] = valueToWrite;
        }
    }
   
    unsigned short checkSum  = [self calculateChacksumWithCommandPacket:commandPacket withSize:(bitPosition) type:checkSumType];
    
    commandPacket[bitPosition++] = checkSum;
    commandPacket[bitPosition++] = checkSum >> 8;
    commandPacket[bitPosition++] = endbyte;
    
    data = [NSData dataWithBytes:commandPacket length:(bitPosition)];
    
    free(commandPacket);
    
    return data;
}

/*!
 *  @method calculateChacksumWithCommandPacket: withSize: type:
 *
 *  @discussion Method to calculate the checksum
 *
 */
-(unsigned short) calculateChacksumWithCommandPacket:(unsigned char [])array withSize:(int)packetSize type:(NSString *)type
{
    if ([type isEqualToString:CHECK_SUM])
    {
        // Sum checksum
        unsigned short sum = 0;
        
        for (int i = 0; i<packetSize; i++)
        {
            sum = sum + array[i];
        }
        return ~sum+1;
    }
    else
    {
        // CRC 16
        unsigned short sum = 0xffff;
        
        unsigned short tmp;
        int i;
        
        if (packetSize == 0)
            return (~sum);
        
        do
        {
            for (i = 0, tmp = 0x00ff & *array++; i < 8; i++, tmp >>= 1)
            {
                if ((sum & 0x0001) ^ (tmp & 0x0001))
                    sum = (sum >> 1) ^ 0x8408;
                else
                    sum >>= 1;
            }
        }
        while (--packetSize);
        
        sum = ~sum;
        tmp = sum;
        sum = (sum << 8) | (tmp >> 8 & 0xFF);
        return sum;
    }
}

@end
