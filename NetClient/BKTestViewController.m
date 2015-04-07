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
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    NSNetServiceBrowser *serviceBrowser;
    
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    [serviceBrowser searchForServicesOfType:@"_myservice._tcp" inDomain:@""];
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
        
        [mInStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [mOutStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        NSLog(@"input  stream = %@", mInStream);
        NSLog(@"output stream = %@", mOutStream);
        NSLog(@"stream status = %d", (int)[mInStream streamStatus]);
        
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
    if (aStream == mInStream)
    {
        [self inputStreamHandleEvent:aStreamEvent];
    }
    else if (aStream == mOutStream)
    {
        [self outputStreamHandleEvent:aStreamEvent];
    }
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
        NSLog(@"in NSStreamEventHasBytesAvailable");
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
        
        NSDictionary *sDict    = @{ @"a" : [NSNumber numberWithInteger:arc4random()], @"b" : @"help" };
        NSData       *sPayload = [NSJSONSerialization dataWithJSONObject:sDict options:NSJSONWritingPrettyPrinted error:nil];
        uint16_t      sLength  = htons([sPayload length]);
        
        [mOutStream write:(uint8_t *)&sLength maxLength:2];
        [mOutStream write:[sPayload bytes] maxLength:[sPayload length]];
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


@end
