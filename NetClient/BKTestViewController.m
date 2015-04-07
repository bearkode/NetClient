/*
 *  BKTestViewController.m
 *  NetClient
 *
 *  Created by cgkim on 2015. 4. 6..
 *  Copyright (c) 2015 cgkim. All rights reserved.
 *
 */

#import "BKTestViewController.h"


@implementation BKTestViewController
{
    NSInputStream  *mInStream;
    NSOutputStream *mOutStream;
    
    NSMutableData  *mReceiveBuffer;
    NSMutableData  *mSendBuffer;
    
}


- (instancetype)initWithNibName:(NSString *)aNibNameOrNil bundle:(NSBundle *)aNibBundleOrNil
{
    self = [super initWithNibName:aNibNameOrNil bundle:aNibBundleOrNil];
    
    if (self)
    {
        mReceiveBuffer = [[NSMutableData alloc] init];
        mSendBuffer    = [[NSMutableData alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    [mInStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [mOutStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [mInStream close];
    [mOutStream close];
    
    [mInStream release];
    [mOutStream release];
    
    [mReceiveBuffer release];
    [mSendBuffer release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    NSNetServiceBrowser *serviceBrowser;
    
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    [serviceBrowser searchForServicesOfType:@"_myservice._tcp" inDomain:@""];
    
//    [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerExpired:) userInfo:nil repeats:YES];
}


- (void)timerExpired:(NSTimer *)aTimer
{
    NSDictionary *sDict    = @{ @"a" : [NSNumber numberWithInteger:arc4random()], @"b" : @"help" };
    NSData       *sPayload = [NSJSONSerialization dataWithJSONObject:sDict options:NSJSONWritingPrettyPrinted error:nil];
    uint16_t      sLength  = htons([sPayload length]);

    [mSendBuffer appendBytes:&sLength length:2];
    [mSendBuffer appendData:sPayload];
    
    [self sendPayload];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)aDomainName moreComing:(BOOL)aMoreDomainsComing
{
    NSLog(@"netServiceBrowser:didFindDomain:moreComing:");
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)aDomainName moreComing:(BOOL)aMoreDomainsComing
{
    NSLog(@"netServiceBrowser:didRemoveDomain:moreComing:");
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)aMoreServicesComing
{
    NSLog(@"netServiceBrowser:didFindService:moreComing:");
    
    NSLog(@"NetService = %@", aNetService);
    NSLog(@"moreComing = %d", aMoreServicesComing);
    
    if (!mInStream && !mOutStream)
    {
        [aNetService getInputStream:&mInStream outputStream:&mOutStream];
        
        [mInStream retain];
        [mOutStream retain];

        [mInStream setDelegate:self];
        [mOutStream setDelegate:self];
        
        [mInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [mOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [mInStream open];
        [mOutStream open];
    }

    [aNetServiceBrowser stop];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)aMoreServicesComing
{
    NSLog(@"netServiceBrowser:didRemoveService:moreComing:");
}


- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserWillSearch:");
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)aErrorInfo
{
    NSLog(@"netServiceBrowser:didNotSearch:");
}


- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"netServiceBrowserDidStopSearch:");
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aStreamEvent
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (aStream == mInStream)
        {
            [self inputStreamHandleEvent:aStreamEvent];
        }
        else if (aStream == mOutStream)
        {
            [self outputStreamHandleEvent:aStreamEvent];
        }
    });
}


- (void)inputStreamHandleEvent:(NSStreamEvent)aStreamEvent
{
    if (aStreamEvent == NSStreamEventNone)
    {
        NSLog(@"in NSStreamEventNone");
    }
    else if (aStreamEvent == NSStreamEventOpenCompleted)
    {
        NSLog(@"in NSStreamEventOpenCompleted");
    }
    else if (aStreamEvent == NSStreamEventHasBytesAvailable)
    {
        uint8_t   sBuffer[1024];
        NSInteger sReadBytes = NSIntegerMax;
        
        while ([mInStream hasBytesAvailable])
        {
            sReadBytes = [mInStream read:sBuffer maxLength:1024];
            
            if (sReadBytes)
            {
                [mReceiveBuffer appendBytes:sBuffer length:sReadBytes];
            }
        }
        
        [self parseInputPackets];
    }
    else if (aStreamEvent == NSStreamEventHasSpaceAvailable)
    {
        NSLog(@"in NSStreamEventHasSpaceAvailable");
    }
    else if (aStreamEvent == NSStreamEventErrorOccurred)
    {
        NSLog(@"in NSStreamEventErrorOccurred");
    }
    else if (aStreamEvent == NSStreamEventEndEncountered)
    {
        NSLog(@"in NSStreamEventEndEncountered");
    }
}


- (void)outputStreamHandleEvent:(NSStreamEvent)aStreamEvent
{
    if (aStreamEvent == NSStreamEventNone)
    {
        NSLog(@"out NSStreamEventNone");
    }
    else if (aStreamEvent == NSStreamEventOpenCompleted)
    {
        NSLog(@"out NSStreamEventOpenCompleted");
    }
    else if (aStreamEvent == NSStreamEventHasBytesAvailable)
    {
        NSLog(@"out NSStreamEventHasBytesAvailable");
    }
    else if (aStreamEvent == NSStreamEventHasSpaceAvailable)
    {
        NSLog(@"out NSStreamEventHasSpaceAvailable");
        [self sendPayload];
    }
    else if (aStreamEvent == NSStreamEventErrorOccurred)
    {
        NSLog(@"out NSStreamEventErrorOccurred");
    }
    else if (aStreamEvent == NSStreamEventEndEncountered)
    {
        NSLog(@"out NSStreamEventEndEncountered");
    }
}


- (void)parseInputPackets
{
    NSLog(@"parseInputPackets");
    
    BOOL sWait = NO;
    
    while ([mReceiveBuffer length] && sWait == NO)
    {
        uint16_t sLength  = 0;
        NSData  *sPayload = nil;
        
        [mReceiveBuffer getBytes:&sLength length:2];
        
        sLength = ntohs(sLength);
        NSInteger sHandledLength = sLength + 2;
        
        if ([mReceiveBuffer length] >= sHandledLength)
        {
            sPayload = [mReceiveBuffer subdataWithRange:NSMakeRange(2, sLength)];
            [mReceiveBuffer replaceBytesInRange:NSMakeRange(0, sHandledLength) withBytes:NULL length:0];
            
            id sJSONObject = [NSJSONSerialization JSONObjectWithData:sPayload options:0 error:NULL];
            NSLog(@"sJSONObject = %@", sJSONObject);
        }
        else
        {
            sWait = YES;
        }
    }
}


- (void)sendPayload
{
    if ([mOutStream hasSpaceAvailable] && [mSendBuffer length])
    {
        NSInteger sWrittenLength = [(NSOutputStream *)mOutStream write:[mSendBuffer bytes] maxLength:[mSendBuffer length]];
        
        if (sWrittenLength > 0)
        {
            [mSendBuffer replaceBytesInRange:NSMakeRange(0, sWrittenLength) withBytes:NULL length:0];
        }
    }
}


@end
