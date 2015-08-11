//
//  NSString+Weibo.h
//  CoreTextDemo
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface NSString (Weibo)

- (NSString *)transformServerStringToClientString;

- (NSString *)transformClientStringToServerString;

- (NSTextStorage *)transformText;

@end
