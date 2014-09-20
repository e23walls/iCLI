//
//  main.m
//  iCLI
//
//  Created by Emily Jennyne Carroll Walls on 2014-04-22.
//  Copyright (c) 2014 Emily Walls. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @try {
        @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    }
    @catch (NSException * e) {
        NSLog(@"Exception occurred!");
        NSLog(@"%@", e);
    }
    @finally {
    }
}
