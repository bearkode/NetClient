/*
 *  BKStream.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKStream.h"


static const NSInteger kMaxBufferSize = 1024;


@implementation BKStream
{
    id              mDelegate;
    
    NSInputStream  *mInStream;
    NSMutableData  *mInBuffer;
    
    NSOutputStream *mOutStream;
    NSMutableData  *mOutBuffer;
    
    BOOL            mOpened;
}


- (instancetype)initWithInputStream:(NSInputStream *)aInputStream outputStream:(NSOutputStream *)aOutputStream delegate:(id)aDelegate
{
    self = [super init];
    
    if (self)
    {
        mDelegate = aDelegate;
        
        mInStream = [aInputStream retain];
        mInBuffer = [[NSMutableData alloc] init];
        [mInStream setDelegate:self];
        
        mOutStream = [aOutputStream retain];
        mOutBuffer = [[NSMutableData alloc] init];
        [mOutStream setDelegate:self];
    }
    
    return self;
}


- (void)dealloc
{
    [self close];
    
    [mInStream release];
    [mInBuffer release];
    
    [mOutStream release];
    [mOutBuffer release];
    
    [super dealloc];
}


#pragma mark -


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEventCode
{
    static NSDictionary   *sDispatchTable = nil;
    static dispatch_once_t sOnceToken;
    
    dispatch_once(&sOnceToken, ^{
        sDispatchTable = [@{ [NSNumber numberWithUnsignedInteger:NSStreamEventNone]              : NSStringFromSelector(@selector(didReceiveStreamEventNone)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventOpenCompleted]     : NSStringFromSelector(@selector(didReceiveStreamEventOpenComplete)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventHasBytesAvailable] : NSStringFromSelector(@selector(didReceiveStreamEventHasBytesAvailable)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventHasSpaceAvailable] : NSStringFromSelector(@selector(didReceiveStreamEventHasSpaceAvailable)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventErrorOccurred]     : NSStringFromSelector(@selector(didReceiveStreamEventErrorOccurred)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventEndEncountered]    : NSStringFromSelector(@selector(didReceiveStreamEventEndEncountered)) } retain];
    });
    
    SEL sSelector = NSSelectorFromString([sDispatchTable objectForKey:[NSNumber numberWithUnsignedInteger:aEventCode]]);
    
    if (sSelector)
    {
        [self performSelector:sSelector withObject:nil];
    }
}


#pragma mark -


- (void)open
{
    [mInStream open];
    [mInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [mOutStream open];
    [mOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)close
{
    [mInStream close];
    [mInStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [mOutStream close];
    [mOutStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([mInStream streamStatus] == NSStreamStatusClosed &&
        [mOutStream streamStatus] == NSStreamStatusClosed)
    {
        [self setOpened:NO];
    }
}


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock
{
    if (!aBlock)
    {
        return;
    }

    NSInteger sHandeledLength = NSIntegerMax;
        
    while ([mInBuffer length] && sHandeledLength)
    {
        sHandeledLength = aBlock(mInBuffer);
        
        if (sHandeledLength)
        {
            [mInBuffer replaceBytesInRange:NSMakeRange(0, sHandeledLength) withBytes:NULL length:0];
        }
    }
}


- (void)writeData:(NSData *)aData
{
    [mOutBuffer appendData:aData];
    
    [self didAppendOutBufferData];
}


#pragma mark -


- (void)didReceiveStreamEventNone
{
    
}


- (void)didReceiveStreamEventOpenComplete
{
    if ([mInStream streamStatus] == NSStreamStatusOpen &&
        [mOutStream streamStatus] == NSStreamStatusOpen)
    {
        [self setOpened:YES];
    }
}


- (void)didReceiveStreamEventHasBytesAvailable
{
    UInt8      sBuffer[kMaxBufferSize];
    BOOL       sNeedsDelegation = [mDelegate respondsToSelector:@selector(stream:didReadData:)];
    NSData    *sReceivedData    = nil;
    NSUInteger sLength          = 0;
    
    while ([mInStream hasBytesAvailable])
    {
        sLength = [mInStream read:sBuffer maxLength:kMaxBufferSize];
        
        if (sLength)
        {
            [mInBuffer appendBytes:sBuffer length:sLength];
        }
        
        if (sLength && sNeedsDelegation)
        {
            sReceivedData = [NSData dataWithBytes:sBuffer length:sLength];
            [mDelegate stream:self didReadData:sReceivedData];
        }
    }
}


- (void)didReceiveStreamEventHasSpaceAvailable
{
    [self didAppendOutBufferData];
}


- (void)didReceiveStreamEventErrorOccurred
{
    
}


- (void)didReceiveStreamEventEndEncountered
{
    [self close];
}


#pragma mark -


- (void)setOpened:(BOOL)aOpened
{
    if (mOpened != aOpened)
    {
        mOpened = aOpened;
        
        [self didChangeOpened];
    }
}


- (void)didChangeOpened
{
    if (mOpened)
    {
        if ([mDelegate respondsToSelector:@selector(streamDidOpen:)])
        {
            [mDelegate streamDidOpen:self];
        }
    }
    else
    {
        if ([mDelegate respondsToSelector:@selector(streamDidClose:)])
        {
            [mDelegate streamDidClose:self];
        }
    }
}


- (void)didAppendOutBufferData
{
    if (![self canWriteData])
    {
        return;
    }

    NSInteger sLength = [mOutStream write:[mOutBuffer bytes] maxLength:[mOutBuffer length]];

    if (sLength)
    {
        [self didWriteDataLength:sLength];
    }
}


- (BOOL)canWriteData
{
    return ([mOutStream hasSpaceAvailable] && [mOutBuffer length]) ? YES : NO;
}


- (void)didWriteDataLength:(NSInteger)aLength
{
    NSRange sRange           = NSMakeRange(0, aLength);
    BOOL    sNeedsDelegation = [mDelegate respondsToSelector:@selector(stream:didWriteData:)];
    NSData *sWrittenData     = nil;
    
    if (sNeedsDelegation)
    {
        sWrittenData = [mOutBuffer subdataWithRange:sRange];
    }
    
    [mOutBuffer replaceBytesInRange:sRange withBytes:NULL length:0];
    
    if (sNeedsDelegation)
    {
        [mDelegate stream:self didWriteData:sWrittenData];
    }
}


@end
