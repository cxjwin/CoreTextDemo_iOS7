//
//  CoreTextView.h
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kTouchedLinkNotification;

NS_CLASS_AVAILABLE_IOS(7_0) @interface CWCoreTextView : UIView <NSLayoutManagerDelegate>

@property (copy, nonatomic) NSTextStorage *textStorage;

@end

NS_CLASS_AVAILABLE_IOS(7_0) @interface CWLayoutManager : NSLayoutManager

@property (nonatomic) BOOL isTouched;
@property (nonatomic) NSRange touchRange;

@end