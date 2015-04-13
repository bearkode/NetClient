/*
 *  BKPacket.m
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKPacket.h"


static size_t kHeaderSize = sizeof(uint16_t);


@implementation BKPacket
{
    uint16_t mHeader;
    NSData  *mPayload;
}


@synthesize payload = mPayload;


+ (instancetype)packetWithData:(NSData *)aData
{
    uint16_t  sPacketLen     = 0;
    NSData   *sPayload       = nil;
    NSInteger sHandledLength = 0;
    
    if ([aData length] < kHeaderSize)
    {
        return nil;
    }
    
    [aData getBytes:&sPacketLen length:kHeaderSize];
    sPacketLen = ntohs(sPacketLen);
    
    sHandledLength = kHeaderSize + sPacketLen;
    
    if ([aData length] >= sHandledLength)
    {
        sPayload = [aData subdataWithRange:NSMakeRange(kHeaderSize, sPacketLen)];

        return [[[self alloc] initWithHeader:sPacketLen payload:sPayload] autorelease];
    }
    else
    {
        return nil;
    }
}


- (instancetype)initWithHeader:(uint16_t)aHeader payload:(NSData *)aPayload
{
    self = [super init];
    
    if (self)
    {
        mHeader  = aHeader;
        mPayload = [aPayload retain];
    }
    
    return self;
}


- (void)dealloc
{
    [mPayload release];

    [super dealloc];
}


- (NSInteger)length
{
    return kHeaderSize + mHeader;
}


@end
