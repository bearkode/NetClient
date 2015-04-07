/*
 *  AppDelegate.m
 *  NetClient
 *
 *  Created by cgkim on 2015. 4. 6..
 *  Copyright (c) 2015 cgkim. All rights reserved.
 *
 */

#import "AppDelegate.h"
#import "BKTestViewController.h"


@implementation AppDelegate
{
    UIWindow *mWindow;
}


@synthesize window = mWindow;


- (BOOL)application:(UIApplication *)aApplication didFinishLaunchingWithOptions:(NSDictionary *)aLaunchOptions
{
    UIWindow *sWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [sWindow makeKeyAndVisible];
    [self setWindow:sWindow];
    
    BKTestViewController   *sViewController = [[[BKTestViewController alloc] init] autorelease];
    UINavigationController *sNaviController = [[[UINavigationController alloc] initWithRootViewController:sViewController] autorelease];
    
    [[self window] setRootViewController:sNaviController];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)aApplication
{

}


- (void)applicationDidEnterBackground:(UIApplication *)aApplication
{

}


- (void)applicationWillEnterForeground:(UIApplication *)aApplication
{

}


- (void)applicationDidBecomeActive:(UIApplication *)aApplication
{

}


- (void)applicationWillTerminate:(UIApplication *)aApplication
{

}


@end
