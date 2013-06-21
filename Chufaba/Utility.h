//
//  Utility.h
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChufabaAppDelegate.h"

@interface Utility : NSObject
{
    
}

+(NSString *) getDatabasePath;
+(void) showAlert:(NSString *) title message:(NSString *) msg;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (Boolean*)fileExists:(NSString *)file;
+ (NSString*)getFullPath:(NSString *)file;

@end
