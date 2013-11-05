//
//  CoreTextView.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "CoreTextView.h"
#import "NSString+Weibo.h"

NSString *const kTouchedRangeNotification = @"kTouchedRangeNotification";

@implementation CoreTextView
{
    CGPoint startPoint;
    NSRange touchRange;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor yellowColor];
        touchRange = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.textStorage == nil) {
        return;
    }
    
    @synchronized(self) {
                
        for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
            for (NSTextContainer *container in manager.textContainers) {
                NSRange glyphRange = [manager glyphRangeForTextContainer:container];
                CGPoint point = [manager locationForGlyphAtIndex:glyphRange.location];
                [manager drawGlyphsForGlyphRange:glyphRange atPoint:point];
            }
        }
    }
}

- (void)setTextStorage:(NSTextStorage *)textStorage
{
    if (_textStorage != textStorage) {
        _textStorage = textStorage;
        
        // layoutManager
        CWLayoutManager *layoutManager = [[CWLayoutManager alloc] init];
        layoutManager.delegate = self;
        [textStorage addLayoutManager:layoutManager];
        
        // textContainer
        CGSize size = CGSizeMake(190, 90);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
                
        [layoutManager addTextContainer:textContainer];  
        
        startPoint = [layoutManager locationForGlyphAtIndex:0];
        
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    @synchronized (self) {
        for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
            for (NSTextContainer *container in manager.textContainers) {
                
                location = CGPointMake(location.x - startPoint.x, location.y - startPoint.y);
                
                CGFloat f;
                NSUInteger index = [manager glyphIndexForPoint:location inTextContainer:container fractionOfDistanceThroughGlyph:&f];
                
                if (0.01 < f && f < 0.99) {
                    NSRange _range;
                    
                    id value = [self.textStorage attribute:NSLinkAttributeName atIndex:index effectiveRange:&_range];
                                        
                    if (value) {
                        touchRange = _range;
                        
                        [(CWLayoutManager *)manager setTouchRange:touchRange];
                        [(CWLayoutManager *)manager setIsTouched:YES];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTouchedRangeNotification object:[NSValue valueWithRange:touchRange]];
                        
                        [self setNeedsDisplay];
                    } else {
                        touchRange = NSMakeRange(NSNotFound, 0);
                    }
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchRange.location != NSNotFound) {
        touchRange = NSMakeRange(NSNotFound, 0);
        for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
            [(CWLayoutManager *)manager setIsTouched:NO];
        }

        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchRange.location != NSNotFound) {
        touchRange = NSMakeRange(NSNotFound, 0);
        for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
            [(CWLayoutManager *)manager setIsTouched:NO];
        }
        [self setNeedsDisplay];
    }
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

- (id)init
{
    self = [super init];
    if (self) {
        self.touchRange = NSMakeRange(NSNotFound, 0);
        self.isTouched = NO;
    }
    return self;
}

- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange underlineType:(NSUnderlineStyle)underlineVal baselineOffset:(CGFloat)baselineOffset lineFragmentRect:(CGRect)lineRect lineFragmentGlyphRange:(NSRange)lineGlyphRange containerOrigin:(CGPoint)containerOrigin
{
	// Left border (== position) of first underlined glyph
	CGFloat firstPosition = [self locationForGlyphAtIndex: glyphRange.location].x;
	
	// Right border (== position + width) of last underlined glyph
	CGFloat lastPosition;
	
	// When link is not the last text in line, just use the location of the next glyph
	if (NSMaxRange(glyphRange) < NSMaxRange(lineGlyphRange)) {
		lastPosition = [self locationForGlyphAtIndex: NSMaxRange(glyphRange)].x;
	}
	// Otherwise get the end of the actually used rect
	else {
		lastPosition = [self lineFragmentUsedRectForGlyphAtIndex:NSMaxRange(glyphRange)-1 effectiveRange:NULL].size.width;
	}
	
	// Inset line fragment to underlined area
	lineRect.origin.x = lineRect.origin.x + firstPosition;
	lineRect.size.width = lastPosition - firstPosition;
	lineRect.size.height = lineRect.size.height - 3;
    
	// Offset line by container origin
	lineRect.origin.x = lineRect.origin.x + containerOrigin.x;
	lineRect.origin.y = lineRect.origin.y + containerOrigin.y - 1.5;
	
	// Align line to pixel boundaries, passed rects may be
	lineRect = CGRectInset(CGRectIntegral(lineRect), .5, .5);

    NSRange tempRange = NSIntersectionRange(self.touchRange, glyphRange);
	if (self.isTouched && tempRange.length != 0) {
        [[UIColor purpleColor] set];
    } else {
        [[UIColor greenColor] set];
    }
        
	[[UIBezierPath bezierPathWithRect: lineRect] fill];
}

@end