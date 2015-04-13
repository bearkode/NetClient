/*
 *  BKVector.h
 *  NetServer
 *
 *  Created by bearkode on 2015. 4. 10..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>


@interface BKVector : NSObject


@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat z;


+ (instancetype)vectorWithJSONObject:(id)aJSONObject;

- (instancetype)initWithX:(CGFloat)aX y:(CGFloat)aY z:(CGFloat)aZ;
- (instancetype)initWithJSONObject:(id)aJSONObject;

- (BOOL)isEqualToVector:(BKVector *)aVector;

- (NSDictionary *)JSONObject;


@end
