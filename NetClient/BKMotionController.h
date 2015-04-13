/*
 *  BKMotionController.h
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "BKStream.h"


@interface BKMotionController : NSObject <NSNetServiceBrowserDelegate>


- (void)start;
- (void)stop;

- (void)setupStreamWithNetService:(NSNetService *)aNetService;


@end
