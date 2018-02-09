//
//  NSString+fastProperty.m
//  FastProperty
//
//  Created by collegepre on 2018/2/9.
//  Copyright © 2018年 CP. All rights reserved.
//

#import "NSString+fastProperty.h"

@implementation NSString (fastProperty)
- (NSString *)removeBlankString{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}
@end
