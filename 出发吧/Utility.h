//
//  Utility.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "itineraryAppDelegate.h"

@interface Utility : NSObject
{
    
}

+(NSString *) getDatabasePath;
+(void) showAlert:(NSString *) title message:(NSString *) msg;

@end
