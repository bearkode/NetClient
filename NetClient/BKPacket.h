/*
 *  BKPacket.h
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface BKPacket : NSObject


@property (nonatomic, readonly) NSData *payload;


+ (instancetype)packetWithData:(NSData *)aData;

- (instancetype)initWithHeader:(uint16_t)aHeader payload:(NSData *)aPayload;

- (NSInteger)length;


@end
