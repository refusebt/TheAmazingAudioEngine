//
//  RasSliderControl.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-20.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasSliderControl.h"

@interface RasSliderControl ()
{

}

@end

@implementation RasSliderControl
@synthesize start = _start;
@synthesize lmtStartX = _lmtStartX;
@synthesize lmtEndX = _lmtEndX;
@synthesize lmtStartY = _lmtStartY;
@synthesize lmtEndY = _lmtEndY;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_lmtStartX = 0;
		_lmtEndX = 0;
		_lmtStartY = 0;
		_lmtEndY = 0;
		
		self.backgroundColor = [UIColor clearColor];
		UIView *viewBlock = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		viewBlock.center = self.center;
		[viewBlock borderRed];
		[self addSubview:viewBlock];
	}
	return self;
}

- (void)setLimtStartX:(CGFloat)sx endX:(CGFloat)ex startY:(CGFloat)sy endY:(CGFloat)ey
{
	_lmtStartX = sx;
	_lmtEndX = ex;
	_lmtStartY = sy;
	_lmtEndY = ey;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	_start = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint nowPoint = [touch locationInView:self];
	
	CGFloat offsetX = nowPoint.x - _start.x;
	CGFloat offsetY = nowPoint.y - _start.y;
	
	CGPoint next = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
	
	if (next.x < _lmtStartX)
	{
		next.x = _lmtStartX;
	}
	else if (next.x > _lmtEndX)
	{
		next.x = _lmtEndX;
	}
	
	if (next.y < _lmtStartY)
	{
		next.y = _lmtStartY;
	}
	else if (next.y > _lmtEndY)
	{
		next.y = _lmtEndY;
	}
	
	self.center = next;
	
	if (_delegate != nil)
	{
		[_delegate onSliderMove:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_delegate != nil)
	{
		[_delegate onSliderMoveEnd:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_delegate != nil)
	{
		[_delegate onSliderMoveEnd:self];
	}
}

@end
