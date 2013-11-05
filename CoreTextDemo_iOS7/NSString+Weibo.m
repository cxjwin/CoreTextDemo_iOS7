//
//  NSString+Weibo.m
//  CoreTextDemo
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "NSString+Weibo.h"

@implementation NSString (Weibo)

static NSDictionary *emojiDictionary = nil;
NSDictionary *SinaEmojiDictionary()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
        emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
    });
    return emojiDictionary;
}

- (NSTextStorage *)transformText
{
    // 匹配emoji
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSRegularExpression *exp_emoji = 
    [[NSRegularExpression alloc] initWithPattern:regex_emoji 
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           error:nil]; 
    NSArray *emojis = [exp_emoji matchesInString:self 
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           range:NSMakeRange(0, [self length])];
    
    NSTextStorage *newStr = [[NSTextStorage alloc] init];
    NSUInteger location = 0;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
        NSString *subStr = [self substringWithRange:NSMakeRange(location, range.location - location)];
        NSTextStorage *attSubStr = [[NSTextStorage alloc] initWithString:subStr];
        [newStr appendAttributedString:attSubStr];
        
        location = range.location + range.length;
        
        NSString *emojiKey = [self substringWithRange:range];
        NSString *imageName = [SinaEmojiDictionary() objectForKey:emojiKey];
        if (imageName) {
            
            UIImage *image = [UIImage imageNamed:imageName];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, -3, 14, 14);
            NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
            [newStr appendAttributedString:attachmentStr];
        } else {
            NSString *rSubStr = [self substringWithRange:range];
            NSTextStorage *originalStr = [[NSTextStorage alloc] initWithString:rSubStr];
            [newStr appendAttributedString:originalStr];
        }
    }
    
    if (location < [self length]) {
        NSRange range = NSMakeRange(location, [self length] - location);
        NSString *subStr = [self substringWithRange:range];
        NSTextStorage *attSubStr = [[NSTextStorage alloc] initWithString:subStr];
        [newStr appendAttributedString:attSubStr];
    }
    
    // 匹配短链接
    NSString *__newStr = [newStr string];
    NSString *regex_http = @"http://t.cn/[a-zA-Z0-9]+";// 短链接的算法是固定的，格式比较一致，所以比较好匹配
    NSRegularExpression *exp_http = 
    [[NSRegularExpression alloc] initWithPattern:regex_http
                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                           error:nil];
    NSArray *https = [exp_http matchesInString:__newStr
                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators 
                                         range:NSMakeRange(0, [__newStr length])];
    
    for (NSTextCheckingResult *result in https) {
        NSRange _range = [result range];
        [newStr addAttribute:NSLinkAttributeName value:[NSNull null] range:_range];
    }
    
    return newStr;
}

@end