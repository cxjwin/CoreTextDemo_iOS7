//
//  ViewController.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *text = 
    @"just for 你好 test...";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacingBefore = 0;
    
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13], 
                                 NSParagraphStyleAttributeName : paragraphStyle};
    
    // textStorage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text attributes:attributes];
    
    
    CGSize size = CGSizeMake(100, 100);
    CGRect frame = (CGRect){10, 100, size};
    
//    UITextView* textView = [[UITextView alloc] initWithFrame:frame textContainer:textContainer];
//    textView.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:textView];
    
    // textView
    CoreTextView *textView = [[CoreTextView alloc] initWithFrame:frame];
    textView.textStorage = textStorage;
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
