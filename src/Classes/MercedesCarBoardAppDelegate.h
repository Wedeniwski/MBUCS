//
//  MercedesCarBoardAppDelegate.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MercedesCarBoardViewController;

@interface MercedesCarBoardAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  MercedesCarBoardViewController *viewController;
}

//+(void)updateProgressIndicator:(int)maxValue value:(int)value;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MercedesCarBoardViewController *viewController;

@end

