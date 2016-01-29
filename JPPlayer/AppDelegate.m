//
//  AppDelegate.m
//  JPPlayer
//
//  Created by Prime on 12/7/15.
//  Copyright © 2015 Prime. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        if (error != nil) {
            NSLog(@"openURL error: %@", error);
            return;
        }
        
        [SPTAuth defaultInstance].session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotifySession" object:nil userInfo:@{@"SpotifySession": session}];
    };
    
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    srand48(arc4random());
    
    NSData *spotifySessionData = [[NSUserDefaults standardUserDefaults] objectForKey:@"SpotifySession"];
    SPTSession *session = [NSKeyedUnarchiver unarchiveObjectWithData:spotifySessionData];
    if (session) {
        NSLog(@"available old session");
        [SPTAuth defaultInstance].session = session;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"will resign active");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *spotifySessionData = [NSKeyedArchiver archivedDataWithRootObject:[[SPTAuth defaultInstance] session]];
    [userDefaults setObject:spotifySessionData forKey:@"SpotifySession"];
    [userDefaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
