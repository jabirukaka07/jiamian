//
//  NSString+Extenions.m
//  JiaMian
//
//  Created by wy on 14-4-27.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "NSString+Extenions.h"
#import "CommonMarco.h"

@implementation NSString (Extenions)

+ (CGFloat)textHeight:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size
{
    CGSize textSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    return textSize.height;
    
}
@end
