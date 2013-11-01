//
//  CoreTextView.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 13-10-31.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "CoreTextView.h"

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
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager:layoutManager];
        layoutManager.usesFontLeading = NO;
        
        // textContainer
        CGSize size = CGSizeMake(190, 90);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
        textContainer.widthTracksTextView = NO;
        textContainer.heightTracksTextView = YES;
                
        [layoutManager addTextContainer:textContainer];  
        
        startPoint = [layoutManager locationForGlyphAtIndex:0];
        
//        NSRange range;
//        CGRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:0 effectiveRange:&range];        
//        [layoutManager setLineFragmentRect:rect forGlyphRange:range usedRect:CGRectZero];
//        
//        range = [layoutManager glyphRangeForTextContainer:textContainer];
//        [layoutManager setLocation:CGPointMake(5, 8) forStartOfGlyphRange:range];
        
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
                    
                    id value = [self.textStorage attribute:@"kTestKey" atIndex:index effectiveRange:&_range];
                    
                    // [manager lineFragmentRectForGlyphAtIndex:index effectiveRange:&_range];
                    
                    if (value) {
                        touchRange = _range;
                        NSLog(@"---- index : %d, %@, %@", index, NSStringFromRange(_range), value);
                    } else {
                        touchRange = NSMakeRange(NSNotFound, 0);
                    }
                }
            }
        }
    }
}

#pragma mark - 
#pragma mark - NSLayoutManagerDelegate
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

@end
