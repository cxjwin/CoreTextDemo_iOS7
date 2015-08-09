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

    self.textView.preferredMaxLayoutWidth = 150;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testTouch:) name:kTouchedLinkNotification object:nil];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"]];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

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
//	paragraphStyle.paragraphSpacing = 5;
	paragraphStyle.alignment = NSTextAlignmentLeft;
	paragraphStyle.firstLineHeadIndent = 5;
	paragraphStyle.headIndent = 5;
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
    
    NSLog(@"%@", NSStringFromCGRect(self.textView.frame));
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
