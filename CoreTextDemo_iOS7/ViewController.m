//
//  ViewController.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextView.h"
#import "NSString+Weibo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *text = 
    @"http://t.cn/123QHz http://t.cn/1er6Hz [兔子][熊猫][给力][浮云][熊猫]   http://t.cn/1er6Hz   \
    [熊猫][熊猫][熊猫][熊猫] Hello World 你好世界[熊猫][熊猫]熊猫熊猫熊猫熊猫熊猫熊猫熊猫熊猫熊猫熊猫熊猫aaaaaaaaaaa";
    
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], 
                                 NSParagraphStyleAttributeName : [self myParagraphStyle]};
    
    // textStorage
    NSTextStorage *textStorage = [text transformText];//[[NSTextStorage alloc] initWithString:text attributes:attributes];
    [textStorage addAttributes:attributes range:NSMakeRange(0, [textStorage length])];
    
    
    [textStorage addAttribute:@"kTestKey" value:@"Test" range:NSMakeRange(9, 6)];
    
    CGSize size = CGSizeMake(200, 100);
    CGRect frame = (CGRect){10, 100, size};
    
//    UITextView* textView = [[UITextView alloc] initWithFrame:frame textContainer:textContainer];
//    textView.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:textView];
    
    // textView
    CoreTextView *textView = [[CoreTextView alloc] initWithFrame:frame];
    textView.textStorage = textStorage;
    [self.view addSubview:textView];
}

- (NSMutableParagraphStyle *)myParagraphStyle
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.paragraphSpacing = 15;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.firstLineHeadIndent = 5;
    paragraphStyle.headIndent = 5;
    paragraphStyle.tailIndent = 160;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.minimumLineHeight = 10;
    paragraphStyle.maximumLineHeight = 20;
    paragraphStyle.baseWritingDirection = NSWritingDirectionNatural;
    paragraphStyle.lineHeightMultiple = 0.8;
    paragraphStyle.hyphenationFactor = 2;
    paragraphStyle.paragraphSpacingBefore = 0;
    
    return paragraphStyle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
