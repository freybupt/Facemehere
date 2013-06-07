//
//  MapAppAppDelegate.m
//  MapApp
//
//  Created by Mithin on 21/06/09.
//  Copyright Techtinium Corporation 2009. All rights reserved.
//

#import "MapAppAppDelegate.h"
#import "MapViewController.h"

#ifdef UI_USER_INTERFACE_IDIOM()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (false)
#endif

@implementation MapAppAppDelegate

@synthesize window;

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    if (IS_IPAD()) {
        mapViewController = [[MapViewController alloc] initWithNibName:@"MapView_ipad" bundle:nil];
    }
    else{
        mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
    }

	[window addSubview:mapViewController.view];
    [window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


- (void)dealloc {
	[mapViewController release];
    [window release];
    [super dealloc];
}


@end
