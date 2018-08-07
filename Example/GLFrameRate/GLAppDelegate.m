//
//  GLAppDelegate.m
//  GLFrameRate
//
//  Created by liguoliang on 08/07/2018.
//  Copyright (c) 2018 liguoliang. All rights reserved.
//

#import "GLAppDelegate.h"
#import <GLFrameRate.h>
@implementation GLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [GLFrameRate sharedFrameRate].enabled = YES;
    return YES;
}

@end
