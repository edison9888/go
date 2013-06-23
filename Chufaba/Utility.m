//
//  Utility.m
//  出发吧
//
//  Created by 张 辛欣 on 13-1-24.
//  Copyright (c) 2013年 出发吧APP团队. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+(NSString *) getDatabasePath
{
    NSString *databasePath = [(ChufabaAppDelegate *)[[UIApplication sharedApplication] delegate] databasePath];
    
    return databasePath;
}

+(void) showAlert:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    [alert show];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (Boolean*)fileExists:(NSString *)file
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getFullPath:file]];
}

+ (NSString*)getFullPath:(NSString *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:file];
}

+ (void)saveData:(NSData *)data ToFile:(NSString *)file
{
    NSString *fullPath = [self getFullPath:file];
    [[NSFileManager defaultManager] createFileAtPath:fullPath contents:data attributes:nil];
}

+ (void)removeFile:(NSString *)file
{
    NSString *fullPath = [self getFullPath:file];
    if ([self fileExists:fullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:NULL];
    }
}

@end
