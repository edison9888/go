//
//  AFKReviewTroller.m
//  AFKReviewTroller
//
//  Created by Marco Tabini on 11-02-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AFKReviewTroller.h"

#define kAFKReviewTrollerRunCountDefault @"kAFKReviewTrollerRunCountDefault"


@implementation AFKReviewTroller

+ (void) load {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    int numberOfExecutions = [standardDefaults integerForKey:kAFKReviewTrollerRunCountDefault] + 1;
    
    [[[AFKReviewTroller alloc] initWithNumberOfExecutions:numberOfExecutions] performSelector:@selector(setup) withObject:Nil afterDelay:1.0];
    
    [standardDefaults setInteger:numberOfExecutions forKey:kAFKReviewTrollerRunCountDefault];
    [standardDefaults synchronize];
    
    [pool release];
}


+ (int) numberOfExecutions {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kAFKReviewTrollerRunCountDefault];
}


- (id) initWithNumberOfExecutions:(int) executionCount {
    if ((self = [super init])) {
        numberOfExecutions = executionCount;
    }
    
    return self;
}


- (void) setup {
    NSDictionary *bundleDictionary = [[NSBundle mainBundle] infoDictionary];
    
    if (numberOfExecutions == [[bundleDictionary objectForKey:kAFKReviewTrollerRunCount] intValue]) {
        NSString *message = NSLocalizedString([bundleDictionary objectForKey:kAFKReviewTrollerMessage], Nil);
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NULL
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"无情地拒绝", Nil)
                                                   otherButtonTitles:NSLocalizedString(@"嗯!", Nil), Nil]
                                  autorelease];
        [alertView show];
    }
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id611640407"]];
    }
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

}


@end
