//
//  NSString+Jingoal.m
//  CoreTextDemo
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "NSString+Jingoal.h"

@implementation NSString (Jingoal)

static NSDictionary *emojiDictionaryCN = nil;
static NSDictionary *emojiDictionaryTW = nil;
static NSDictionary *faceDictionary = nil;

+ (void)load {
	@synchronized(self) {
		NSString *facePlist = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"face.plist"];
		NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:facePlist];
        NSArray *faceArray = tempDict[@"faceList"];
        
        NSMutableDictionary *_emojiDictionaryCN = [NSMutableDictionary dictionary];
        NSMutableDictionary *_emojiDictionaryTW = [NSMutableDictionary dictionary];
        NSMutableDictionary *_faceDictionary = [NSMutableDictionary dictionary];

        [faceArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *cn_key = obj[@"phraseCN"];
            _emojiDictionaryCN[cn_key] = obj;
            
            NSString *tw_key = obj[@"phraseTW"];
            _emojiDictionaryTW[tw_key] = obj;
            
            NSString *f_cn_key = obj[@"faceID"];
            _faceDictionary[f_cn_key] = obj;
        }];
        
        emojiDictionaryCN = [_emojiDictionaryCN copy];
        emojiDictionaryTW = [_emojiDictionaryTW copy];
        faceDictionary = [_faceDictionary copy];
	}
}

static JGLanguageType lanType;

+ (void)setLanType:(JGLanguageType)type {
    lanType = type;
}

+ (JGLanguageType)lanType {
    return lanType;
}

- (NSString *)transformServerStringToClientString {
    NSString *text = self;
    static NSString *regex_face = @"\\/fs:[0-9]+\\/";
    
    static NSRegularExpression *exp_face = nil;
    if (!exp_face) {
        exp_face = [[NSRegularExpression alloc] initWithPattern:regex_face
                                                        options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                          error:nil];
    }
    
    NSArray *faces = [exp_face matchesInString:text
                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                         range:NSMakeRange(0, text.length)];
    
    if (!faces || faces.count == 0) {
        return text;
    }
    
    NSUInteger location = 0;
    NSMutableString *string = [NSMutableString string];
    for (NSTextCheckingResult *result in faces) {
        NSRange range = result.range;
        NSString *norSubStr = [text substringWithRange:NSMakeRange(location, range.location - location)];
        [string appendString:norSubStr];
        
        NSString *subStr = [text substringWithRange:range];
        NSString *faceNum = [subStr substringWithRange:NSMakeRange(4, subStr.length - 5)];
        if (faceNum) {
            NSDictionary *info = faceDictionary[faceNum];
            NSString *exchange = info[@"phraseCN"];
            [string appendFormat:@"[%@]", exchange];
        }
        
        location = range.location + range.length;
    }
    
    if (location < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        NSString *subStr = [text substringWithRange:range];
        [string appendString:subStr];
    }
    
    // 去掉转义字符
    (void)[string replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    (void)[string replaceOccurrencesOfString:@"\\/" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    
    return [string copy];
}

- (NSRegularExpression *)emoticonRegexCN {
    static NSRegularExpression *emoticonRegexCN = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *info in emojiDictionaryCN) {
            NSString *tempString = [NSString stringWithFormat:@"\\[%@\\]", info[@"phrase_CN"]];
            [tempArray addObject:tempString];
        }
        NSString *pattern = [tempArray componentsJoinedByString:@"|"];
        
        emoticonRegexCN = [[NSRegularExpression alloc] initWithPattern:pattern
                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                 error:nil];
    });
    return emoticonRegexCN;
}

- (NSRegularExpression *)emoticonRegexTW {
    static NSRegularExpression *emoticonRegexTW = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *info in emojiDictionaryTW) {
            NSString *tempString = [NSString stringWithFormat:@"\\[%@\\]", info[@"phrase_TW"]];
            [tempArray addObject:tempString];
        }
        NSString *pattern = [tempArray componentsJoinedByString:@"|"];
        
        emoticonRegexTW = [[NSRegularExpression alloc] initWithPattern:pattern
                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                 error:nil];
    });
    return emoticonRegexTW;
}

// 将[xx] 转成/fs:x/
- (NSString *)transformClientStringToServerStringIsFace:(BOOL *)face {
    NSString *text = self;
    
    NSRegularExpression *emoticonRegex = (lanType == JGLanguage_TW ? [self emoticonRegexTW] : [self emoticonRegexCN]);
    
    NSArray *emojis = [emoticonRegex matchesInString:text
                                             options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                               range:NSMakeRange(0, text.length)];
    
    if (!emojis || emojis.count == 0) {
        *face = NO;
        return text;
    }
    
    *face = YES;
    NSMutableString *string = [NSMutableString stringWithString:text];
    // 加转义字符
    (void)[string replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    (void)[string replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    
    text = [string copy];
    string = [NSMutableString string];
    
    NSUInteger location = 0;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
        NSString *norSubStr = [text substringWithRange:NSMakeRange(location, range.location - location)];
        [string appendString:norSubStr];
        
        NSString *subStr = [text substringWithRange:range];
        NSString *faceKey = [subStr substringWithRange:NSMakeRange(1, subStr.length - 2)];
        if (faceKey) {
            if (lanType == JGLanguage_TW) {
                NSDictionary *info = emojiDictionaryTW[faceKey];
                NSString *faceID = info[@"faceID"];
                [string appendFormat:@"/fs:%@/", faceID];
            }
            else {
                NSDictionary *info = emojiDictionaryCN[faceKey];
                NSString *faceID = info[@"faceID"];
                [string appendFormat:@"/fs:%@/", faceID];
            }
        }
        
        location = range.location + range.length;
    }
    
    if (location < text.length) {
        NSRange range = NSMakeRange(location, text.length - location);
        NSString *subStr = [text substringWithRange:range];
        [string appendString:subStr];
    }
    
    return [string copy];
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
            NSString *emojiKey = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
            NSDictionary *emojiItem = emojiDictionaryCN[emojiKey];
            NSString *imageName = emojiItem[@"fileName"];
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
                attachment.image = image;
                attachment.bounds = CGRectMake(0, -4, 16, 16);
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
