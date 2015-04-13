/*
 *  BKMotionController+ServiceBrowser.m
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKMotionController+ServiceBrowser.h"


@implementation BKMotionController (ServiceBrowser)


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
    
    [self setupStreamWithNetService:aNetService];
    
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


@end
