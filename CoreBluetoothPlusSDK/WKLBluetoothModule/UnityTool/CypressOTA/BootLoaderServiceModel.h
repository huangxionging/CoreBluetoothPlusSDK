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

#import <Foundation/Foundation.h>

@interface BootLoaderServiceModel : NSObject

/*!
 *  @property siliconIDString
 *
 *  @discussion siliconID from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconIDString;

/*!
 *  @property siliconRevString
 *
 *  @discussion silicon rev from the device response
 *
 */
@property (strong,nonatomic) NSString *siliconRevString;

/*!
 *  @property isWriteRowDataSuccess
 *
 *  @discussion flag used to check whether data writing is success
 *
 */

@property (nonatomic) BOOL isWriteRowDataSuccess;

/*!
 *  @property isWritePacketDataSuccess
 *
 *  @discussion flag used to check whether packet data writing is success
 *
 */

@property (nonatomic) BOOL isWritePacketDataSuccess;
/*!
 *  @property startRowNumber
 *
 *  @discussion Device flash start row number
 *
 */
@property (nonatomic) int startRowNumber;

/*!
 *  @property endRowNumber
 *
 *  @discussion Device flash end row number
 *
 */
@property (nonatomic) int endRowNumber;

/*!
 *  @property checkSum
 *
 *  @discussion checkSum received from the device for writing a single row
 *
 */
@property (nonatomic) uint8_t checkSum;

/*!
 *  @property isApplicationValid
 *
 *  @discussion flag used to check whether the application writing is success
 *
 */
@property (nonatomic) BOOL isApplicationValid;

/*!
 *  @method discoverCharacteristicsWithCompletionHandler:
 *
 *  @discussion Method to discover the specified characteristics of a service.
 *
 */
-(void) discoverCharacteristicsWithCompletionHandler:(void (^) (BOOL success, NSError *error)) handler;

/*!
 *  @method updateValueForCharacteristicWithCompletionHandler:
 *
 *  @discussion Method to set notifications or indications for the value of a specified characteristic
 *
 */
-(void) updateValueForCharacteristicWithCompletionHandler:(void (^) (BOOL success,id command,NSError *error)) handler;

/*!
 *  @method writeValueToCharacteristicWithData: bootLoaderCommandCode:
 *
 *  @discussion Method to write data to the device
 *
 */
-(void) writeValueToCharacteristicWithData:(NSData *)data bootLoaderCommandCode:(unsigned short)commandCode;

/*!
 *  @method stopUpdate
 *
 *  @discussion Method to stop notifications or indications for the specified characteristic.
 *
 */
-(void) stopUpdate;

/*!
 *  @method createCommandPacketWithCommand: dataLength: data:
 *
 *  @discussion Method to create the command packet from the host
 *
 */
-(NSData *) createCommandPacketWithCommand:(uint8_t)commandCode dataLength:(unsigned short)dataLength data:(NSDictionary *)packetDataDictionary ;

/*!
 *  @method setCheckSumType:
 *
 *  @discussion Method to set the checksum calculation type
 *
 */

-(void) setCheckSumType:(NSString *)type;

@end
