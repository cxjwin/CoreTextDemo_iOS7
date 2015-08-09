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
+ (void)load {
	@synchronized(self) {
		NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
		emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
	}
}

- (NSTextStorage *)transformText {
    NSString *text = self;
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    
    static NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    static NSRegularExpression *exp_emoji = nil;
    if (!exp_emoji) {
        exp_emoji = [[NSRegularExpression alloc] initWithPattern:regex_emoji
                                                         options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                           error:nil];
    }
    
    // 匹配emoji
    {
        NSArray *emojis = [exp_emoji matchesInString:text
                                             options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                               range:NSMakeRange(0, text.length)];
        
        NSUInteger location = 0;
        for (NSTextCheckingResult *result in emojis) {
            NSRange range = result.range;
            
            // nomal text
            NSString *norSubStr = [text substringWithRange:NSMakeRange(location, range.location - location)];
            NSTextStorage *attSubStr = [[NSTextStorage alloc] initWithString:norSubStr];
            [textStorage appendAttributedString:attSubStr];
            location = range.location + range.length;
            
            // emoji
            NSString *emojiKey = [text substringWithRange:range];
            NSString *imageName = [emojiDictionary objectForKey:emojiKey];
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
                attachment.image = image;
                attachment.bounds = CGRectMake(0, -3, 14, 14);
                NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
                [textStorage appendAttributedString:attachmentStr];
            } else {
                NSString *rSubStr = [text substringWithRange:range];
                NSTextStorage *originalStr = [[NSTextStorage alloc] initWithString:rSubStr];
                [textStorage appendAttributedString:originalStr];
            }
        }
        
        if (location < text.length) {
            NSRange range = NSMakeRange(location, text.length - location);
            NSString *subStr = [text substringWithRange:range];
            NSTextStorage *attSubStr = [[NSTextStorage alloc] initWithString:subStr];
            [textStorage appendAttributedString:attSubStr];
        }
    }
    
    static NSDataDetector *linkDetector = nil;
    if (!linkDetector) {
        linkDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    }
    // 匹配链接
    {
        NSString *string = textStorage.string;
        
        NSArray *links = [linkDetector matchesInString:string
                                               options:0
                                                 range:NSMakeRange(0, string.length)];
        
        for (NSTextCheckingResult *result in links) {
            NSRange range = result.range;
            [textStorage addAttribute:NSLinkAttributeName value:[string substringWithRange:range] range:range];
        }
    }
    
    static NSDataDetector *phoneNumberDetector = nil;
    if (!phoneNumberDetector) {
        phoneNumberDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    }
    // 匹配电话号码
    {
        NSString *string = textStorage.string;
        
        NSArray *numbers = [phoneNumberDetector matchesInString:string
                                                        options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                          range:NSMakeRange(0, string.length)];
        
        for (NSTextCheckingResult *result in numbers) {
            NSRange range = result.range;
            [textStorage addAttribute:NSLinkAttributeName value:[string substringWithRange:range] range:range];
        }
    }
    
    return textStorage;
}

@end
