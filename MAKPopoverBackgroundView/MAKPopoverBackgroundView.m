//
//  MAKPopoverBackgroundView.h
//  MAKPopoverBackgroundView
//
//  Created by Martin Kloepfel on 30.08.15.
//  Copyright (c) 2014 Martin Klöpfel. All rights reserved.
//

#import "MAKPopoverBackgroundView.h"


const CGFloat bubbleCornerRadius   = 8.0;
const CGSize bubbleNoseSize        = {30.0, 12.0};
const CGSize minBubbleSize         = {20.0, 20.0};


@interface MAKPopoverBackgroundView ()

@property (nonatomic) CGFloat _arrowOffset;
@property (nonatomic) UIPopoverArrowDirection _arrowDirection;

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) UIView *dimmingView;

@end


@implementation MAKPopoverBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = NO;
        self.clipsToBounds = YES;
        
        self.maskLayer = [CAShapeLayer layer];
        self.maskLayer.frame = self.bounds;
        self.layer.mask = self.maskLayer;
        
        self.layer.masksToBounds = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        self.layer.shadowRadius = [UIScreen mainScreen].scale == 1 ? 1.0 : 2.0;
//        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1].CGColor;
//        self.layer.shadowOffset = CGSizeZero;
        
        // TODO: add a separate shadow / border layer
        
        self.dimmingView = [[UIView alloc] initWithFrame:CGRectMake(0 - self.frame.origin.x,
                                                                   0 - self.frame.origin.y,
                                                                   [UIScreen mainScreen].bounds.size.width,
                                                                   [UIScreen mainScreen].bounds.size.height)];
        self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
        self.dimmingView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if ([self.superview isKindOfClass:NSClassFromString(@"_UIPopoverView")])
        [self.superview insertSubview:self.dimmingView belowSubview:self];
    else if (self.dimmingView.superview)
        [self.dimmingView removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateMaskLayer];
}

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    
    contentView.frame = CGRectMake(0.0, 0.0, contentView.width, contentView.height);
    [self addSubview:contentView];
}


- (UIPopoverArrowDirection)arrowDirection
{
    return self._arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    self._arrowDirection = arrowDirection;
    
    [self setNeedsLayout];
}

- (CGFloat)arrowOffset
{
    return self._arrowOffset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    self._arrowOffset = arrowOffset;
    
    [self setNeedsLayout];
}


- (void)updateMaskLayer
{
    CGRect bounds = self.maskLayer.bounds;
    CGRect roundedRect = bounds;
    CGPoint arrowStartPoint = CGPointZero;
    CGPoint arrowMiddlePoint = CGPointZero;
    CGPoint arrowEndPoint = CGPointZero;

    switch (self.arrowDirection)
    {
        case UIPopoverArrowDirectionUp:
            roundedRect = CGRectMake(bounds.origin.x, bounds.origin.y+bubbleNoseSize.height, bounds.size.width, bounds.size.height-bubbleNoseSize.height);
            arrowStartPoint = CGPointMake(roundedRect.origin.x+roundedRect.size.width*0.5-self.class.halfArrowBase,
                                          roundedRect.origin.y);
            arrowMiddlePoint = CGPointMake(roundedRect.origin.x+roundedRect.size.width*0.5,
                                           0.0);
            arrowEndPoint = CGPointMake(roundedRect.origin.x+bounds.size.width*0.5+self.class.halfArrowBase,
                                        roundedRect.origin.y);
            break;
        case UIPopoverArrowDirectionLeft:
            roundedRect = CGRectMake(roundedRect.origin.x+bubbleNoseSize.height, roundedRect.origin.y, roundedRect.size.width-bubbleNoseSize.height, roundedRect.size.height);
        
            break;
        case UIPopoverArrowDirectionDown:
            roundedRect = CGRectMake(roundedRect.origin.x, roundedRect.origin.y, roundedRect.size.width, roundedRect.size.height-bubbleNoseSize.height);
            arrowStartPoint = CGPointMake(roundedRect.origin.x+roundedRect.size.width*0.5-self.class.halfArrowBase,
                                          roundedRect.origin.y+roundedRect.size.height);
            arrowMiddlePoint = CGPointMake(roundedRect.origin.x+roundedRect.size.width*0.5,
                                           bounds.origin.y+bounds.size.height);
            arrowEndPoint = CGPointMake(roundedRect.origin.x+roundedRect.size.width*0.5+self.class.halfArrowBase,
                                        roundedRect.origin.y+roundedRect.size.height);
            break;
        case UIPopoverArrowDirectionRight:
            roundedRect = CGRectMake(roundedRect.origin.x, roundedRect.origin.y, roundedRect.size.width-bubbleNoseSize.height, roundedRect.size.height);
            break;
    }
    
  
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:bubbleCornerRadius];
    
    [path appendPath:[self.class quadCurvedPathWithPoints:@[[NSValue valueWithCGPoint:arrowStartPoint],
                                                            [NSValue valueWithCGPoint:arrowMiddlePoint],
                                                            [NSValue valueWithCGPoint:arrowEndPoint]]]];
    
    self.maskLayer.path = path.CGPath;
}


+ (CGFloat)arrowBase
{
    return bubbleNoseSize.width;
}

+ (CGFloat)halfArrowBase
{
    return self.arrowBase*0.5;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsZero;
}

+ (CGFloat)arrowHeight
{
    return bubbleNoseSize.height;
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}




+ (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2)
{
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = abs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
//    CGFloat diffX = abs(p2.x - controlPoint.x);
//    
//    if (p1.x < p2.x)
//        controlPoint.x += diffX;
//    else if (p1.x > p2.x)
//        controlPoint.x -= diffX;
    
    return controlPoint;
}

@end
