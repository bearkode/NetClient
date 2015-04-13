/*
 *  BKTestViewController.m
 *  NetClient
 *
 *  Created by cgkim on 2015. 4. 6..
 *  Copyright (c) 2015 cgkim. All rights reserved.
 *
 */

#import "BKTestViewController.h"
#import "BKMotionController.h"


@implementation BKTestViewController
{
    UIImageView        *mHandView;
    BKMotionController *mMotionController;
}


- (instancetype)initWithNibName:(NSString *)aNibNameOrNil bundle:(NSBundle *)aNibBundleOrNil
{
    self = [super initWithNibName:aNibNameOrNil bundle:aNibBundleOrNil];
    
    if (self)
    {
        mMotionController = [[BKMotionController alloc] init];
        [mMotionController setDelegate:self];
    }
    
    return self;
}


- (void)dealloc
{
    [mMotionController release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mHandView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 45)]autorelease];
    [[self view] addSubview:mHandView];
    
    [mMotionController start];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ![[self view] window])
    {
        mHandView = nil;
    }
}


- (void)motionController:(BKMotionController *)aMotionController didReceiveMotion:(BKMotion *)aMotion
{
//    NSLog(@"sMotion = %@", aMotion);
    
    NSInteger sCount     = [aMotion extenedFingerCount];
    NSString *sImageName = [NSString stringWithFormat:@"%d", (int)sCount];
    
    [mHandView setImage:[UIImage imageNamed:sImageName]];

    CGRect  sBounds   = [[self view] bounds];
    CGPoint sPosition = CGPointMake([[aMotion palmPosition] x], [[aMotion palmPosition] z]);
    CGPoint sMid      = CGPointMake(CGRectGetMidX(sBounds), CGRectGetMidY(sBounds));

    sPosition.x *= 3.0;
    sPosition.y *= 3.0;
    sPosition.x += sMid.x;
    sPosition.y += sMid.y;
    
    CGRect sFrame = [mHandView frame];
    sFrame.origin.x = 100;
    sFrame.origin.y = 100;
    [mHandView setFrame:sFrame];
    [mHandView setCenter:sPosition];
}


@end
