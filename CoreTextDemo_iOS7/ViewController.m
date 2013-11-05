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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTouchedRangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testTouch:) name:kTouchedRangeNotification object:nil];
    
    NSString *text = 
    @"http://t.cn/123QHz http://t.cn/1er6Hz [兔子][熊猫][给力][浮云][熊猫]   http://t.cn/1er6Hz   \
    [熊猫][熊猫][熊猫][熊猫] Hello World 你好世界[熊猫][熊猫]熊猫aaaaaaa";
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], 
                                 NSParagraphStyleAttributeName : [self myParagraphStyle]};
    
    // textStorage
    NSTextStorage *textStorage = [text transformText];//[[NSTextStorage alloc] initWithString:text attributes:attributes];
    [textStorage addAttributes:attributes range:NSMakeRange(0, [textStorage length])];
    
    CGSize size = CGSizeMake(200, 100);
    CGRect frame = (CGRect){10, 100, size};
    
    CoreTextView *textView = [[CoreTextView alloc] initWithFrame:frame];
    textView.tag = 101;
    textView.textStorage = textStorage;
    [self.view addSubview:textView];
    
//    UITextView* textView = [[UITextView alloc] initWithFrame:frame textContainer:textContainer];
//    textView.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:textView];
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

- (void)testTouch:(NSNotification *)notification
{
    NSValue *value = notification.object;
    NSRange range = [value rangeValue];
    
    CoreTextView *textView = (id)[self.view viewWithTag:101];
    NSString *string = [textView.textStorage.string substringWithRange:range];
    
    NSLog(@"touch string : %@", string);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
