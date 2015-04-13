/*
 *  BKMotionController.h
 *  NetClient
 *
 *  Created by bearkode on 2015. 4. 13..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "BKMotion.h"


@interface BKMotionController : NSObject <NSNetServiceBrowserDelegate>


@property (nonatomic, assign) id delegate;


- (instancetype)initWithDelegate:(id)aDelegate;


- (void)start;
- (void)stop;

- (void)setupStreamWithNetService:(NSNetService *)aNetService;


@end


@protocol BKMotionControllerDelegate <NSObject>


- (void)motionController:(BKMotionController *)aMotionController didReceiveMotion:(BKMotion *)aMotion;


@end
