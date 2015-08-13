//
//  NSString+Jingoal.h
//  CoreTextDemo
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSUInteger, JGLanguageType) {
    JGLanguage_Default = 0,       // 默认值
    JGLanguage_CN,            // 简体中文
    JGLanguage_TW,            // 繁体中文
    JGLanguage_EN             // 英文
};

@interface NSString (Jingoal)

+ (void)setLanType:(JGLanguageType)type;

+ (JGLanguageType)lanType;

- (NSString *)transformServerStringToClientString;

- (NSString *)transformClientStringToServerStringIsFace:(BOOL *)face;

- (NSTextStorage *)transformText;

@end
