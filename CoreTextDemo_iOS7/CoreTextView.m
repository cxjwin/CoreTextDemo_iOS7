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
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

    for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
        for (NSTextContainer *container in manager.textContainers) {
            NSRange glyphRange = [manager glyphRangeForTextContainer:container];
            CGPoint point = [manager locationForGlyphAtIndex:glyphRange.location];
            [manager drawGlyphsForGlyphRange:glyphRange atPoint:point];
            
            
            
            
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

        // textContainer
        CGSize size = CGSizeMake(100, 100);
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];        
        [layoutManager addTextContainer:textContainer];  
        
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    for (NSLayoutManager *manager in self.textStorage.layoutManagers) {
        for (NSTextContainer *container in manager.textContainers) {
            
            NSRange glyphRange = [manager glyphRangeForTextContainer:container];
            CGPoint point = [manager locationForGlyphAtIndex:glyphRange.location];
            location = CGPointMake(location.x - point.x, location.y - point.y);
            
            CGFloat f;
            NSUInteger index = [manager glyphIndexForPoint:location inTextContainer:container fractionOfDistanceThroughGlyph:&f];
            
            
            if (f > 0.01 && f < 0.99) {
                
                index = [manager characterIndexForGlyphAtIndex:index];

                
                NSLog(@"---- index : %d, %f", index, f);
                
                
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
