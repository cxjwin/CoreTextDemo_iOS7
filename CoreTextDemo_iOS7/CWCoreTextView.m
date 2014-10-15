//
//  CoreTextView.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import "CWCoreTextView.h"
#import "NSString+Weibo.h"
#import "CWTouchesGestureRecognizer.h"

NSString *const kTouchedLinkNotification = @"kTouchedLinkNotification";
static const NSRange kCWInvalidRange = {.location = NSNotFound, .length = 0};

@implementation CWCoreTextView {
	OSSpinLock spinlock;
	
	CWLayoutManager	*layoutManager;
	NSTextContainer *textContainer;
	
	CWTouchesGestureRecognizer *touchesGestureRecognizer;
	
	NSRange touchRange;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}

	return self;
}

- (void)commonInit {
	// Initialization code
	spinlock = OS_SPINLOCK_INIT;
	
	// layoutManager
	layoutManager = [[CWLayoutManager alloc] init];
	layoutManager.delegate = self;
	
	// textContainer
	textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(200, CGFLOAT_MAX)];
	[layoutManager addTextContainer:textContainer];
	
	// gesture
	touchesGestureRecognizer = [[CWTouchesGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
	[self addGestureRecognizer:touchesGestureRecognizer];
	
	// range
	touchRange = kCWInvalidRange;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
	if (!_textStorage) {
		return;
	}

	// lock
	OSSpinLockLock(&spinlock);
	NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
	CGPoint point = [layoutManager locationForGlyphAtIndex:glyphRange.location];
	[layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:point];
	OSSpinLockUnlock(&spinlock);
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	if (textContainer) {
		textContainer.size = frame.size;
	}
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
	OSSpinLockLock(&spinlock);
	if (_textStorage != textStorage) {
		_textStorage = textStorage;
		[_textStorage addLayoutManager:layoutManager];
		
		[self setNeedsUpdateConstraints];
		[self setNeedsDisplay];
	}
	OSSpinLockUnlock(&spinlock);
}

- (void)handleTouch:(UIGestureRecognizer *)gestureRecognizer {
	UIGestureRecognizerState state = gestureRecognizer.state;
	if (state == UIGestureRecognizerStateBegan) {
		OSSpinLockLock(&spinlock);
		CGPoint location = [gestureRecognizer locationInView:self];
		CGPoint startPoint = [layoutManager locationForGlyphAtIndex:0];
		
		location = CGPointMake(location.x - startPoint.x, location.y - startPoint.y);
		
		CGFloat fraction;
		NSUInteger index = [layoutManager glyphIndexForPoint:location inTextContainer:textContainer fractionOfDistanceThroughGlyph:&fraction];
		
		NSLog(@"%f", fraction);
		if (0.01 < fraction && fraction < 0.99) {
			NSRange effectiveRange;
			
			id value = [_textStorage attribute:NSLinkAttributeName atIndex:index effectiveRange:&effectiveRange];
			
			if (value) {
				touchRange = effectiveRange;
				layoutManager.touchRange = touchRange;
				layoutManager.isTouched = YES;
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kTouchedLinkNotification object:value];
				
				[self setNeedsDisplay];
			} else {
				touchRange = kCWInvalidRange;
			}
		}
		OSSpinLockUnlock(&spinlock);
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
		if (touchRange.location != NSNotFound) {
			touchRange = kCWInvalidRange;
			layoutManager.isTouched = NO;
			[self setNeedsDisplay];
		}
	}
}

- (CGSize)intrinsicContentSize {
	CGRect rect = [layoutManager usedRectForTextContainer:textContainer];
	CGFloat width = ceil(CGRectGetWidth(rect)) + 30;
	CGFloat height = ceil(CGRectGetHeight(rect)) + 14;
	return CGSizeMake(width, height);
}

#pragma mark -
#pragma mark - NSLayoutManagerDelegate

//- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager shouldGenerateGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange NS_AVAILABLE_IOS(7_0)
//{
//    return 0;
//}

// Returns the spacing after the line ending with glyphIndex.
//- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect NS_AVAILABLE_IOS(7_0)
//{
//
//}

// Returns the paragraph spacing before the line starting with glyphIndex.
//- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingBeforeGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect NS_AVAILABLE_IOS(7_0)
//{
//    if (glyphIndex == 0) {
//        return -5.0;
//    } else {
//        return 10.0;
//    }
//}

// Returns the paragraph spacing after the line ending with glyphIndex.
//- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect NS_AVAILABLE_IOS(7_0)
//{
//
//}

// Returns the control character action for the control character at charIndex.
//- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager shouldUseAction:(NSControlCharacterAction)action forControlCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
//{
//
//}

// Invoked while determining the soft line break point.  When NO, NSLayoutManager tries to find the next line break opportunity before charIndex
//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
//{
//    return YES;
//}

// Invoked while determining the hyphenation point.  When NO, NSLayoutManager tries to find the next hyphenation opportunity before charIndex
//- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
//{
//    return YES;
//}

@end

@implementation CWLayoutManager

- (id)init {
	self = [super init];
	if (self) {
		_touchRange = kCWInvalidRange;
		_isTouched = NO;
	}

	return self;
}

- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin {
	
	// Left border (== position) of first underlined glyph
	CGFloat firstPosition = [self locationForGlyphAtIndex:glyphRange.location].x;

	// Right border (== position + width) of last underlined glyph
	CGFloat lastPosition;

	// When link is not the last text in line, just use the location of the next glyph
	if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
		lastPosition = [self locationForGlyphAtIndex:NSMaxRange(glyphRange)].x;
	}
	// Otherwise get the end of the actually used rect
	else {
		lastPosition = [self lineFragmentUsedRectForGlyphAtIndex:NSMaxRange(glyphRange) - 1 effectiveRange:NULL].size.width;
	}

	// Inset line fragment to underlined area
	lineRect.origin.x = lineRect.origin.x + firstPosition;
	lineRect.size.width = lastPosition - firstPosition;
	lineRect.size.height = lineRect.size.height - 3;

	// Offset line by container origin
	lineRect.origin.x = lineRect.origin.x + containerOrigin.x;
	lineRect.origin.y = lineRect.origin.y + containerOrigin.y - 1.5;

	// Align line to pixel boundaries, passed rects may be
	lineRect = CGRectInset(CGRectIntegral(lineRect), 0.5, 0.5);

	NSRange tempRange = NSIntersectionRange(_touchRange, glyphRange);
	if (_isTouched && tempRange.length != 0) {
		[[UIColor purpleColor] set];
	} else {
		[[UIColor greenColor] set];
	}

	[[UIBezierPath bezierPathWithRect:lineRect] fill];
}

@end
