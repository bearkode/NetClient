/*
 *  BKMotion.m
 *  NetServer
 *
 *  Created by bearkode on 2015. 4. 10..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKMotion.h"


@implementation BKMotion
{
    NSTimeInterval mTimeInterval;
    NSInteger      mExtendedFingerCount;
    BKVector      *mPalmPosition;
    BKVector      *mPalmNormal;
}


@synthesize timeInterval       = mTimeInterval;
@synthesize extenedFingerCount = mExtendedFingerCount;
@synthesize palmPosition       = mPalmPosition;
@synthesize palmNormal         = mPalmNormal;


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
    
    }
    
    return self;
}


- (instancetype)initWithJSONObject:(id)aJSONObject
{
    self = [self init];
    
    if (self)
    {
        [self setTimeInterval:[[aJSONObject objectForKey:@"ti"] doubleValue]];
        [self setExtenedFingerCount:[[aJSONObject objectForKey:@"extendedFingerCount"] integerValue]];
        [self setPalmPosition:[BKVector vectorWithJSONObject:[aJSONObject objectForKey:@"palmPosition"]]];
        [self setPalmNormal:[BKVector vectorWithJSONObject:[aJSONObject objectForKey:@"palmNormal"]]];
    }
    
    return self;
}


- (void)dealloc
{
    [mPalmPosition release];
    [mPalmNormal release];
    
    [super dealloc];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%d, pos = [%f, %f, %f] nor = [%f, %f, %f]", (int)mExtendedFingerCount, [mPalmPosition x], [mPalmPosition y], [mPalmPosition z], [mPalmNormal x], [mPalmNormal y], [mPalmNormal z]];
}


- (BOOL)isEqualToMotion:(BKMotion *)aMotion
{
    if (mTimeInterval == [aMotion timeInterval] &&
        mExtendedFingerCount == [aMotion extenedFingerCount] &&
        [mPalmPosition isEqualToVector:[aMotion palmPosition]] &&
        [mPalmNormal isEqualToVector:[aMotion palmNormal]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (NSDictionary *)JSONObject
{
    return @{ @"class" : @"motion",
              @"ti" : [NSNumber numberWithDouble:mTimeInterval],
              @"extendedFingerCount" : [NSNumber numberWithInteger:mExtendedFingerCount],
              @"palmPosition" : [mPalmPosition JSONObject],
              @"palmNormal" : [mPalmNormal JSONObject] };
}


@end
