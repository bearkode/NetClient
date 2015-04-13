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


NSData *BKEncodePacket(BKPacket *aPacket)
{
    NSMutableData *sResult  = [NSMutableData data];
    NSData        *sPayload = [aPacket payload];
    uint16_t       sLength  = htons([sPayload length]);
    
    [sResult appendBytes:&sLength length:sizeof(uint16_t)];
    [sResult appendData:sPayload];
    
    return sResult;
}


BKPacket *BKDecodePacket(NSData *aData)
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
        
        return [[[BKPacket alloc] initWithHeader:sPacketLen payload:sPayload] autorelease];
    }
    else
    {
        return nil;
    }
}


@implementation BKPacket
{
    uint16_t mHeader;
    NSData  *mPayload;
}


@synthesize payload = mPayload;


+ (BKPacket *)packetWithJSONObject:(id)aJSONObject
{
    NSData *sPayload = [NSJSONSerialization dataWithJSONObject:aJSONObject options:0 error:nil];

    return [[[self alloc] initWithHeader:[sPayload length] payload:sPayload] autorelease];
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
