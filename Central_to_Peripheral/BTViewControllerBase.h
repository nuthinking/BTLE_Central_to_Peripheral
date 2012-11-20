//
//  BTViewControllerBase.h
//  MD_Peripheral_iOS
//
//  Created by Christian Giordano on 14/11/2012.
//  Copyright (c) 2012 Christian Giordano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Settings.h"

@interface UITextView(append)

- (void) append:(NSString *)str;
- (void) log:(NSString *)str;

@end

@interface BTViewControllerBase : UIViewController

- (void) applicationDidEnterBackground;
- (void) applicationWillEnterForeground;
- (void) log:(NSString *)str;

@property IBOutlet UITextView *logView;

@end
