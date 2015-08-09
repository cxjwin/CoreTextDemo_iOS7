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
	CWLayoutManager	*_layoutManager;
	NSTextContainer *_textContainer;
	CWTouchesGestureRecognizer *_touchesGestureRecognizer;
	NSRange _touchRange;
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
    // UILabel
    _preferredMaxLayoutWidth = CGFLOAT_MAX;

	// layoutManager
	_layoutManager = [[CWLayoutManager alloc] init];
	_layoutManager.delegate = self;
	
	// textContainer
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
	_textContainer = [[NSTextContainer alloc] initWithSize:size];
	[_layoutManager addTextContainer:_textContainer];
	
	// gesture
	_touchesGestureRecognizer = [[CWTouchesGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
	[self addGestureRecognizer:_touchesGestureRecognizer];
	
	// range
	_touchRange = kCWInvalidRange;
    
    _contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
	if (!_textStorage) {
		return;
	}

    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
    CGPoint point = [_layoutManager locationForGlyphAtIndex:glyphRange.location];
    [_layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:point];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (_textContainer) {
        _textContainer.size = CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX);
    }
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
	if (_textStorage != textStorage) {
        [_textStorage removeLayoutManager:_layoutManager];
        
		_textStorage = textStorage;
        
		[_textStorage addLayoutManager:_layoutManager];
		
		[self setNeedsUpdateConstraints];
		[self setNeedsDisplay];
	}
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        
        [self setNeedsUpdateConstraints];
        [self setNeedsDisplay];
    }
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    if (_preferredMaxLayoutWidth != preferredMaxLayoutWidth) {
        _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
        
        if (_preferredMaxLayoutWidth > CGRectGetWidth(self.frame)) {
            CGRect frame = self.frame;
            frame.size.width = _preferredMaxLayoutWidth;
            self.frame = frame;
        }
        
        [self setNeedsUpdateConstraints];
        [self setNeedsDisplay];
    }
}

- (void)handleTouch:(UIGestureRecognizer *)gestureRecognizer {
	UIGestureRecognizerState state = gestureRecognizer.state;
	if (state == UIGestureRecognizerStateBegan) {
		CGPoint location = [gestureRecognizer locationInView:self];
		CGPoint startPoint = [_layoutManager locationForGlyphAtIndex:0];
		
		location = CGPointMake(location.x - startPoint.x, location.y - startPoint.y);
		
		CGFloat fraction;
		NSUInteger index = [_layoutManager glyphIndexForPoint:location inTextContainer:_textContainer fractionOfDistanceThroughGlyph:&fraction];
		
        CGRect glyphRect = [_layoutManager boundingRectForGlyphRange:NSMakeRange(index, 1) inTextContainer:_textContainer];
        
		NSLog(@"%lu", index);
		/*if (0.01 < fraction && fraction < 0.99) {*/
        if (CGRectContainsPoint(glyphRect, location)) {
			NSRange effectiveRange;
			
			id value = [_textStorage attribute:NSLinkAttributeName atIndex:index effectiveRange:&effectiveRange];
			
			if (value) {
				_touchRange = effectiveRange;
				_layoutManager.touchRange = _touchRange;
				_layoutManager.isTouched = YES;
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kTouchedLinkNotification object:value];
				
				[self setNeedsDisplay];
			} else {
				_touchRange = kCWInvalidRange;
			}
		}
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
		if (_touchRange.location != NSNotFound) {
			_touchRange = kCWInvalidRange;
			_layoutManager.isTouched = NO;
			[self setNeedsDisplay];
		}
	}
}

- (CGSize)intrinsicContentSize {
    NSRange glyphRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
	CGRect rect = [_layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:_textContainer];
    rect = CGRectInset(rect, -_textContainer.lineFragmentPadding, 0);
    CGSize size = rect.size;
    NSTextStorage *textStorage = _layoutManager.textStorage;
    if (textStorage) {
        NSDictionary *att = [textStorage attributesAtIndex:0 effectiveRange:NULL];
        NSParagraphStyle *p = att[NSParagraphStyleAttributeName];
        
        size.width += p.headIndent * 2;
        size.height += p.lineSpacing * 2;
    }
    
	return size;
}

#pragma mark -
#pragma mark - NSLayoutManagerDelegate

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex {
    NSRange range;
    NSURL *linkURL = [layoutManager.textStorage attribute:NSLinkAttributeName atIndex:charIndex effectiveRange:&range];
    
    // Do not break lines in links unless absolutely required
    if (linkURL && charIndex > range.location && charIndex <= NSMaxRange(range)) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex NS_AVAILABLE(10_11, 7_0) {
    return NO;
}

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
		[[UIColor clearColor] set];
	}

	[[UIBezierPath bezierPathWithRect:lineRect] fill];
}

@end
