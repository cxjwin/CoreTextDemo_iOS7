//
//  ViewController.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "CWCoreTextView.h"
#import "NSString+Weibo.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CWCoreTextView *textView;

@end

@implementation ViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kTouchedLinkNotification object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testTouch:) name:kTouchedLinkNotification object:nil];

	NSString *text =
	    @"http://t.cn/123QHz http://t.cn/1er6Hz [兔子][熊猫][给力][浮云][熊猫]   http://t.cn/1er6Hz   \
    [熊猫][熊猫][熊猫][熊猫] Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa[熊猫] Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa[熊猫] Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa[熊猫] Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa[熊猫] http://t.cn/6gb0Hz Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa"                                                                                              ;

	NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12],
		                         NSParagraphStyleAttributeName : [self myParagraphStyle]};

	// textStorage
	NSTextStorage *textStorage = [text transformText];
	[textStorage addAttributes:attributes range:NSMakeRange(0, [textStorage length])];

	_textView.textStorage = textStorage;
}

- (NSParagraphStyle *)myParagraphStyle {
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

	paragraphStyle.lineSpacing = 5;
	paragraphStyle.paragraphSpacing = 15;
	paragraphStyle.alignment = NSTextAlignmentLeft;
	paragraphStyle.firstLineHeadIndent = 5;
	paragraphStyle.headIndent = 5;
	paragraphStyle.tailIndent = 250;
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.minimumLineHeight = 10;
	paragraphStyle.maximumLineHeight = 20;
	paragraphStyle.baseWritingDirection = NSWritingDirectionNatural;
	paragraphStyle.lineHeightMultiple = 0.8;
	paragraphStyle.hyphenationFactor = 2;
	paragraphStyle.paragraphSpacingBefore = 0;

	return [paragraphStyle copy];
}

- (void)testTouch:(NSNotification *)notification {
	id value = notification.object;
	// NSURL
	if ([value isKindOfClass:[NSURL class]]) {
		NSLog(@"touch URL : %@", value);
	}
	// NSString
	else {
		NSLog(@"touch string : %@", value);
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
