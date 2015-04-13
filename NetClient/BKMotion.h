/*
 *  BKMotion.h
 *  NetServer
 *
 *  Created by bearkode on 2015. 4. 10..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "BKVector.h"


@interface BKMotion : NSObject


@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) NSInteger      extenedFingerCount;
@property (nonatomic, retain) BKVector      *palmPosition;
@property (nonatomic, retain) BKVector      *palmNormal;


- (instancetype)initWithJSONObject:(id)aJSONObject;

- (BOOL)isEqualToMotion:(BKMotion *)aMotion;

- (NSDictionary *)JSONObject;


@end
