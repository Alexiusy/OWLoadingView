//
//  OWLoadingView.m
//  RefreshControl
//
//  Created by Zeacone on 2017/1/16.
//  Copyright © 2017年 ics. All rights reserved.
//

#import "OWLoadingView.h"

@interface OWLoadingView ()

@property (nonatomic, strong) NSArray<NSValue *> *centers;
@property (nonatomic, strong) NSEnumerator *centerEnumerator;

@property (nonatomic, strong) NSArray<CAShapeLayer *> *shapeLayers;
@property (nonatomic, strong) NSEnumerator *shapeEnumerator;

@property (nonatomic, strong) NSValue *currentCenter;
@property (nonatomic, strong) CAShapeLayer *currentLayer;

@end

@implementation OWLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    CGPoint center = self.center;
    CGFloat radius = 20;
    
    self.centers = [self getCentersFromMainCenter:center Radius:20];
    NSMutableArray<CAShapeLayer *> *shapeLayers = [NSMutableArray array];
    
    for (NSValue *pointValue in self.centers) {
        UIBezierPath *bezierPath = [self hexagonPathWithCenter:pointValue.CGPointValue Radius:radius];
        CAShapeLayer *hexagonLayer = [self hexagonShapeWithPath:bezierPath];
        [self.layer addSublayer:hexagonLayer];
        [shapeLayers addObject:hexagonLayer];
    }
    
    self.shapeLayers = [shapeLayers copy];
    
    self.centerEnumerator = [self.centers objectEnumerator];
    self.shapeEnumerator = [self.shapeLayers objectEnumerator];
}

- (NSArray<NSValue *> *)getCentersFromMainCenter:(CGPoint)center Radius:(CGFloat)radius {
    
    CGFloat rad = 30 / 180.0 * M_PI;
    
    CGFloat length = (radius * cos(rad) * 2 + 2);
    
    CGFloat x1 = center.x - length * cos(rad);
    CGFloat y1 = center.y - length * sin(rad);
    
    CGFloat x2 = center.x;
    CGFloat y2 = center.y - length;
    
    CGFloat x3 = center.x + length * cos(rad);
    CGFloat y3 = center.y - length * sin(rad);
    
    CGFloat x4 = center.x + length * cos(rad);
    CGFloat y4 = center.y + length * sin(rad);
    
    CGFloat x5 = center.x;
    CGFloat y5 = center.y + length;
    
    CGFloat x6 = center.x - length * cos(rad);
    CGFloat y6 = center.y + length * sin(rad);
    
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(x1, y1)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(x2, y2)];
    NSValue *value3 = [NSValue valueWithCGPoint:CGPointMake(x3, y3)];
    NSValue *value4 = [NSValue valueWithCGPoint:CGPointMake(x4, y4)];
    NSValue *value5 = [NSValue valueWithCGPoint:CGPointMake(x5, y5)];
    NSValue *value6 = [NSValue valueWithCGPoint:CGPointMake(x6, y6)];
    NSValue *value7 = [NSValue valueWithCGPoint:center];
    
    NSMutableArray<NSValue *> *centers = [NSMutableArray arrayWithObjects:value1, value2, value3, value4, value5, value6, value7, nil];
    return [centers copy];
}

- (UIBezierPath *)hexagonPathWithCenter:(CGPoint)center Radius:(CGFloat)r {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat rad = 30 / 180.0 * M_PI;
    
    CGPoint point1 = CGPointMake(center.x - r * sin(rad), center.y - r * cos(rad));
    CGPoint point2 = CGPointMake(center.x - r, center.y);
    CGPoint point3 = CGPointMake(center.x - r * sin(rad), center.y + r * cos(rad));
    CGPoint point4 = CGPointMake(center.x + r * sin(rad), center.y + r * cos(rad));
    CGPoint point5 = CGPointMake(center.x + r, center.y);
    CGPoint point6 = CGPointMake(center.x + r * sin(rad), center.y - r * cos(rad));
    
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point5];
    [path addLineToPoint:point6];
    [path closePath];
    
    return path;
}

- (CAShapeLayer *)hexagonShapeWithPath:(UIBezierPath *)bezierPath {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bezierPath.CGPath;
    layer.fillColor = [UIColor colorWithRed:244/255.0 green:180/255.0 blue:40/255.0 alpha:1.0].CGColor;
    layer.opacity = 0;
    return layer;
}

- (void)startAnimation {
    
    self.currentLayer = self.shapeEnumerator.nextObject;
    self.currentCenter = self.centerEnumerator.nextObject;
    
    if (!self.currentLayer) {
        self.shapeEnumerator = [self.shapeLayers objectEnumerator];
        self.currentLayer = self.shapeEnumerator.nextObject;
        
        self.centerEnumerator = [self.centers objectEnumerator];
        self.currentCenter = self.centerEnumerator.nextObject;
    }

    CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    CGFloat fromRadius = self.currentLayer.opacity == 0 ? 10 : 20;
    CGFloat toRadius = self.currentLayer.opacity == 0 ? 20 : 10;
    CGPathRef fromPath = [self hexagonPathWithCenter:self.currentCenter.CGPointValue Radius:fromRadius].CGPath;
    CGPathRef toPath = [self hexagonPathWithCenter:self.currentCenter.CGPointValue Radius:toRadius].CGPath;
    
    pathAnim.fromValue = (__bridge id _Nullable)(fromPath);
    pathAnim.toValue = (__bridge id _Nullable)(toPath);
    
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = self.currentLayer.opacity == 0 ? @(0) : @(1);
    opacityAnim.toValue = self.currentLayer.opacity == 0 ? @(1) : @(0);

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[opacityAnim, pathAnim];
    group.duration = .2;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.repeatCount = 1;
    group.autoreverses = NO;
    group.delegate = self;
    
    [self.currentLayer addAnimation:group forKey:@"group"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.currentLayer.opacity = self.currentLayer.opacity == 0 ? 1 : 0;
    
    if (flag) {
        [self startAnimation];
    }
}

@end
