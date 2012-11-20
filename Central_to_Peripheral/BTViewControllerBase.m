//
//  BTViewControllerBase.m
//  MD_Peripheral_iOS
//
//  Created by Christian Giordano on 14/11/2012.
//  Copyright (c) 2012 Christian Giordano. All rights reserved.
//

#import "BTViewControllerBase.h"

@implementation UITextView(append)

- (void) append:(NSString *)str
{
    self.text = [self.text stringByAppendingString:str];
}

- (void) log:(NSString *)str
{
    [self append:str];
    [self append:@"\n"];
}

@end

@implementation BTViewControllerBase

@synthesize logView = _logView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _logView.text = @"";
}

- (void) applicationDidEnterBackground
{
    NSLog(@"%@ is likely to be need overriden by the subclass", NSStringFromSelector(_cmd));
}

- (void) applicationWillEnterForeground
{
    NSLog(@"%@ is likely to be need overriden by the subclass", NSStringFromSelector(_cmd));
}

- (void) log:(NSString *)str
{
    [self.logView log:str];
    NSLog(@"%@", str);
}


@end
