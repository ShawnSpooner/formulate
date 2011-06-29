//
//  formulateAppDelegate.h
//  formulate
//
//  Created by Shawn Spooner on 6/27/11.
//  Copyright 2011 ssSoftwareCreations. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormulateViewController;
@interface formulateAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet FormulateViewController *viewController;

@end
