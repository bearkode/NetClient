/*
 *  BKMotionController.m
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKMotionController.h"
#import "BKStream.h"
#import "BKPacket.h"
#import "BKMotion.h"


@implementation BKMotionController
{
    BKStream            *mStream;
    NSNetServiceBrowser *mServiceBrowser;
    NSTimer             *mPingTimer;
    
    id                   mDelegate;
    NSMutableArray      *mMotionStream;
}


@synthesize delegate = mDelegate;


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        mServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [mServiceBrowser setDelegate:self];
        
        mMotionStream = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (instancetype)initWithDelegate:(id)aDelegate
{
    self = [self init];
    
    if (self)
    {
        [self setDelegate:aDelegate];
    }
    
    return self;
}


- (void)dealloc
{
    [mStream close];
    [mStream release];
    
    [mMotionStream release];

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
        BKPacket *sPacket = BKDecodePacket(aData);
        
        if (sPacket)
        {
            id        sJSONObject = [NSJSONSerialization JSONObjectWithData:[sPacket payload] options:0 error:NULL];
            BKMotion *sMotion     = [[[BKMotion alloc] initWithJSONObject:sJSONObject] autorelease];
            
            [mMotionStream addObject:sMotion];

            if (sMotion && [mDelegate respondsToSelector:@selector(motionController:didReceiveMotion:)])
            {
                [mDelegate motionController:self didReceiveMotion:sMotion];
            }
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
    BKPacket      *sPacket = [BKPacket packetWithJSONObject:sDict];
  
    [self sendPacket:sPacket];
}


- (void)sendPacket:(BKPacket *)aPacket
{
    [mStream writeData:BKEncodePacket(aPacket)];
}


@end
