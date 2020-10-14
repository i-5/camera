//
//  sepiaCameraAppDelegate.h
//  sepiaCamera
//
//  Created by 子民 駱 on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class sepiaCameraViewController;

@interface sepiaCameraAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet sepiaCameraViewController *viewController;

@end
