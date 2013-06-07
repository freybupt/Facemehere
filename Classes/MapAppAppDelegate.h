//
//  MapAppAppDelegate.h
//  MapApp
//
//  Created by Mithin on 21/06/09.
//  Copyright Techtinium Corporation 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface MapAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MapViewController *mapViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

