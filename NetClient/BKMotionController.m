/*
 *  BKMotionController.m
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKMotionController.h"
#import "BKPacket.h"


@implementation BKMotionController
{
    BKStream            *mStream;
    NSNetServiceBrowser *mServiceBrowser;
    NSTimer             *mPingTimer;
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        mServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [mServiceBrowser setDelegate:self];
    }
    
    return self;
}


- (void)dealloc
{
    [mStream close];
    [mStream release];

    [super dealloc];
}


#pragma mark -


- (void)streamDidOpen:(BKStream *)aStream
{
    NSLog(@"streamDidOpen");
    
    mPingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pingTimerExpired:) userInfo:nil repeats:YES];
}


- (void)streamDidClose:(BKStream *)aStream
{
    NSLog(@"streamDidClose");
    
    [mPingTimer invalidate];
    mPingTimer = nil;
}


- (void)stream:(BKStream *)aStream didWriteData:(NSData *)aData
{
    NSLog(@"stream:didWriteData:");
}


- (void)stream:(BKStream *)aStream didReadData:(NSData *)aData
{
    [aStream handleDataUsingBlock:^NSInteger(NSData *aData) {
        BKPacket *sPacket = [BKPacket packetWithData:aData];
        
        if (sPacket)
        {
            id sJSONObject = [NSJSONSerialization JSONObjectWithData:[sPacket payload] options:0 error:NULL];
            NSLog(@"sJSONObject = %@", sJSONObject);
        }

        return [sPacket length];
    }];
}


#pragma mark -


- (void)start
{
    [mServiceBrowser searchForServicesOfType:@"_myservice._tcp" inDomain:@""];
}


- (void)stop
{
    [mServiceBrowser stop];
    [mStream close];
}


#pragma mark - private


- (void)setupStreamWithNetService:(NSNetService *)aNetService
{
    NSInputStream  *sInputStream  = nil;
    NSOutputStream *sOutputStream = nil;
    
    [aNetService getInputStream:&sInputStream outputStream:&sOutputStream];
    
    [mStream close];
    [mStream release];
    
    mStream = [[BKStream alloc] initWithInputStream:sInputStream outputStream:sOutputStream delegate:self];
    [mStream open];
}


- (void)pingTimerExpired:(NSTimer *)aTimer
{
    NSDictionary  *sDict = @{ @"class" : @"ping",
                              @"ti"    : [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] };
    [self sendJSONObject:sDict];
}


- (void)sendJSONObject:(id)aJSONObject
{
    NSData        *sPayload = [NSJSONSerialization dataWithJSONObject:aJSONObject options:0 error:nil];
    uint16_t       sLength  = htons([sPayload length]);
    NSMutableData *sPacket  = [NSMutableData data];
    
    [sPacket appendBytes:&sLength length:sizeof(uint16_t)];
    [sPacket appendData:sPayload];
    
    [mStream writeData:sPacket];
}


@end
