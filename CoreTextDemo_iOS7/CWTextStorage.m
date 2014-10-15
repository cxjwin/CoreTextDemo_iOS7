//
//  CWTextStorage.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 10/15/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import "CWTextStorage.h"

@implementation CWTextStorage {
	NSTextStorage *_textStorage;
}

static NSDictionary *emojiDictionary = nil;
+ (void)initialize {
	if (self == [CWTextStorage class]) {
		NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
		emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
	}
}

- (void)setText:(NSString *)text {
	if (_text != text) {
		_text = [text copy];
		_textStorage = [self textStorageWithText:_text];
	}
}

- (NSTextStorage *)textStorageWithText:(NSString *)text {
	NSTextStorage *textStorage = [[NSTextStorage alloc] init];
	
	// 匹配emoji
	{
		NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
		NSRegularExpression *exp_emoji =
		[[NSRegularExpression alloc] initWithPattern:regex_emoji
											 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
											   error:nil];
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
	
	// 匹配短链接
	{
		NSString *newText = textStorage.string;
		// 短链接的算法是固定的，格式比较一致，所以比较好匹配
		NSString *regex_http = @"http://t.cn/[a-zA-Z0-9]+";
		NSRegularExpression *exp_http =
		[[NSRegularExpression alloc] initWithPattern:regex_http
											 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
											   error:nil];
		NSArray *https = [exp_http matchesInString:newText
										   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
											 range:NSMakeRange(0, newText.length)];
		
		for (NSTextCheckingResult *result in https) {
			NSRange range = result.range;
			[textStorage addAttribute:NSLinkAttributeName value:[newText substringWithRange:range] range:range];
		}
	}
	
	return textStorage;
}


@end
