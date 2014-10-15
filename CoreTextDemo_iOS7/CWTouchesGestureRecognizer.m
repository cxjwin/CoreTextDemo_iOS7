//
//  CWTouchesGestureRecognizer.m
//  CoreTextDemo_iOS7
//
//  Created by cxjwin on 10/15/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "CWTouchesGestureRecognizer.h"

@implementation CWTouchesGestureRecognizer {
	CGPoint startPoint;
}

// mirror of the touch-delivery methods on UIResponder
// UIGestureRecognizers aren't in the responder chain, but observe touches hit-tested to their view and their view's subviews
// UIGestureRecognizers receive touches before the view to which the touch was hit-tested
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	startPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
	self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = (UITouch *)[touches anyObject];
	CGPoint currentPoint = [touch locationInView:self.view];
	CGFloat distanceX = (currentPoint.x - startPoint.x);
	CGFloat distanceY = (currentPoint.y - startPoint.y);
	CGFloat distance = sqrt(distanceX * distanceX + distanceY * distanceY);
	if (distance > 10.0) {
		self.state = UIGestureRecognizerStateCancelled;
	} else {
		self.state = UIGestureRecognizerStateChanged;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset {
	self.state = UIGestureRecognizerStatePossible;
}

@end
