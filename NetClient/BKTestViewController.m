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
    BKMotionController *mMotionController;
}


- (instancetype)initWithNibName:(NSString *)aNibNameOrNil bundle:(NSBundle *)aNibBundleOrNil
{
    self = [super initWithNibName:aNibNameOrNil bundle:aNibBundleOrNil];
    
    if (self)
    {
        mMotionController = [[BKMotionController alloc] init];
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
    
    [mMotionController start];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
