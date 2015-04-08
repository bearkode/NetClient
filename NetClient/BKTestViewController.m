/*
 *  BKTestViewController.m
 *  NetClient
 *
 *  Created by cgkim on 2015. 4. 6..
 *  Copyright (c) 2015 cgkim. All rights reserved.
 *
 */

#import "BKTestViewController.h"
#import "BKStream.h"


@implementation BKTestViewController
{
    BKStream *mStream;
}


- (instancetype)initWithNibName:(NSString *)aNibNameOrNil bundle:(NSBundle *)aNibBundleOrNil
{
    self = [super initWithNibName:aNibNameOrNil bundle:aNibBundleOrNil];
    
    if (self)
    {

    }
    
    return self;
}


- (void)dealloc
{
    [mStream close];
    [mStream release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    NSNetServiceBrowser *sServiceBrowser;
    
    sServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [sServiceBrowser setDelegate:self];
    [sServiceBrowser searchForServicesOfType:@"_myservice._tcp" inDomain:@""];
    
    [NSTimer scheduledTimerWithTimeInterval:(1.0 / 30.0) target:self selector:@selector(timerExpired:) userInfo:nil repeats:YES];
}


- (void)timerExpired:(NSTimer *)aTimer
{
    NSDictionary  *sDict    = @{ @"a" : [NSNumber numberWithInteger:arc4random()],
                                 @"b" : @"help",
                                 @"c" : @"asdfjas lkdfjaslkdfj asdjf lsaj lsakjd laskjd lkasjd vlasj dvlaskjd vlaksj vladk fvlkaj fvl",
                                 @"d" : @"asdjfasd sjd vlasjd vjsa dv lkjsaldv kjsalkdvj slkj dvlsak jdvlskj dvlsk jdvlsak vl  skdlj",
                                 @"e" : @"sd  sdjlskdjvsadvkl jsadv lksjd lksjdv lksjv asdv aslkdvj alksdjv asd vs dv",
                                 @"f" : @11223 };
    NSData        *sPayload = [NSJSONSerialization dataWithJSONObject:sDict options:NSJSONWritingPrettyPrinted error:nil];
    uint16_t       sLength  = htons([sPayload length]);
    NSMutableData *sPacket  = [NSMutableData data];
    
    [sPacket appendBytes:&sLength length:sizeof(uint16_t)];
    [sPacket appendData:sPayload];
    
    [mStream writeData:sPacket];
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


#pragma mark -


- (void)streamDidOpen:(BKStream *)aStream
{
    NSLog(@"streamDidOpen");
}


- (void)streamDidClose:(BKStream *)aStream
{
    NSLog(@"streamDidClose");
}


- (void)stream:(BKStream *)aStream didWriteData:(NSData *)aData
{
    NSLog(@"stream:didWriteData:");
}


- (void)stream:(BKStream *)aStream didReadData:(NSData *)aData
{
    [aStream handleDataUsingBlock:^NSInteger(NSData *aData) {
        
        if ([aData length] < 2)
        {
            return 0;
        }

        uint16_t sLength  = 0;
        NSData  *sPayload = nil;

        [aData getBytes:&sLength length:2];

        sLength = ntohs(sLength);
        NSInteger sHandledLength = sLength + 2;

        if ([aData length] >= sHandledLength)
        {
            sPayload = [aData subdataWithRange:NSMakeRange(2, sLength)];

            id sJSONObject = [NSJSONSerialization JSONObjectWithData:sPayload options:0 error:NULL];
            NSLog(@"sJSONObject = %@", sJSONObject);
            
            return sHandledLength;
        }
        else
        {
            return 0;
        }
 
    }];
}


#pragma mark -


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


@end
