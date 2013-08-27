//
//  MSAppDelegate.m
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import "MSAppDelegate.h"
#import "MSRootViewController.h"
#import "MSWebImageCacher.h"
#import "MSFileHelper.h"
#import "Reachability.h"

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    UIAlertView *alertView = nil;
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            NSLog(@"NotReachable");
            alertView = [[UIAlertView alloc]initWithTitle:@"网络状态" message:@"当前网络未连接，无法使用系统！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            break;
        case ReachableViaWWAN:
            NSLog(@"ReachableViaWWAN");
            break;
        case ReachableViaWiFi:
            NSLog(@"ReachableViaWiFi");
            break;
    }
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.rootViewController = [[MSRootViewController alloc] initWithNibName:@"MSRootViewController" bundle:nil];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    //
    [MSWebImageCacher loadCacheItemsIndex];
    //
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        exit(0);
    }
}

@end