//
//  ZJSDemo3View.m
//  AS_DrawHealthIndexDemo
//
//  Created by 周建顺 on 2018/8/1.
//  Copyright © 2018年 周建顺. All rights reserved.
//

#import "ZJSPolygonView.h"

#define kPointRadius 20


@implementation ZJSPolygonPoint

-(instancetype)initWithX:(CGFloat)x y:(CGFloat)y{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    ZJSPolygonPoint *new = [[ZJSPolygonPoint allocWithZone:zone] init];
    new.x = self.x;
    new.y = self.y;
    return new;
}

-(NSString*)toString{
    return [NSString stringWithFormat:@"(%@,%@)",@(_x),@(_y)];
}

@end

@interface ZJSPolygonView()

@property (nonatomic, strong) ZJSPolygonPoint *currentPoint;
@property (nonatomic, strong) ZJSPolygonPoint *oldPoint;

@property (nonatomic, copy) NSArray<CAShapeLayer*> *pointsArray;
@property (nonatomic, copy) NSArray *lines;

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation ZJSPolygonView

@synthesize polygonBorderColor = _polygonBorderColor;
@synthesize pointColor = _pointColor;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    self.backgroundColor = [UIColor clearColor];
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    _points = @[[[ZJSPolygonPoint alloc] initWithX:0.1 y:0.1],
                [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.1],
                [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.1],
                [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.45],
                [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.9],
                [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.9],
                [[ZJSPolygonPoint alloc] initWithX:0.1 y:0.9],
                [[ZJSPolygonPoint alloc] initWithX:0.1 y:0.45]];
    
    _polygonFillColor = [UIColor blueColor];
   
    _polygonBorderWidth = 2;
    _pointRadius = 5;
    
    
    [self initPointLayerArray];
    [self initLines];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; // 关闭动画效果
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = self.polygonBorderWidth;
    
    [self.points enumerateObjectsUsingBlock:^(ZJSPolygonPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZJSPolygonPoint *point = obj;
        CGFloat x = width * point.x;
        CGFloat y = height * point.y;
        if (idx == 0) {
            [path moveToPoint:CGPointMake(x, y)];
        }else{
            [path addLineToPoint:CGPointMake(x, y)];
        }
        
        CAShapeLayer *pointLayer = [self.pointsArray objectAtIndex:idx];
        pointLayer.frame = CGRectMake(x - self.pointRadius, y - self.pointRadius, self.pointRadius*2, self.pointRadius*2);
    }];
    [path closePath];
   // self.polygonLayer.path = path.CGPath;
    [self.polygonBorderColor setStroke];
    [self.polygonFillColor setFill];
    [path stroke];
    [path fill];
    self.path = path;
    
    [CATransaction commit];
    
}


-(CGFloat)distanceBetweenPoints:(CGPoint)first sencond:(CGPoint)second{
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
}



#pragma mark - tracking
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint location = [touch locationInView:self];
    ZJSPolygonPoint *currentPoint = [self getCurrentPointAtLocation:location];
    
    if (currentPoint) {
        self.currentPoint = currentPoint;
        self.oldPoint = [currentPoint copy];
        return  YES;
    }
    
    return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (!self.currentPoint) {
        
        return NO;
    }
    
    CGPoint location = [touch locationInView:self];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    // 移动
    if (location.x>width) {
        self.currentPoint.x = 1;
    }else if(location.x < 0){
        self.currentPoint.x = 0;
    }else{
        self.currentPoint.x = location.x/width;
    }
    
    if (location.y>height) {
        self.currentPoint.y = 1;
    }else if(location.y < 0){
        self.currentPoint.y = 0;
    }else{
        self.currentPoint.y = location.y/height;
    }
    
    [self setNeedsDisplay];
    
    
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self endHandler];
}

-(void)cancelTrackingWithEvent:(UIEvent *)event{
    [self endHandler];
}

-(void)endHandler{
    if (self.currentPoint) {
        
        // 判断是否有交叉点，如果有则还原到移动前的位置
        if ([self checkIntersect]) {
            
            self.currentPoint.x = self.oldPoint.x;
            self.currentPoint.y = self.oldPoint.y;
            [self setNeedsDisplay];
        }
        
        
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    
    self.currentPoint = nil;
    self.oldPoint = nil;
}

#pragma mark - private methods

-(ZJSPolygonPoint*)getCurrentPointAtLocation:(CGPoint)location{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat pointRadius = self.pointRadius > kPointRadius? self.pointRadius : kPointRadius;
    
    __block ZJSPolygonPoint *currentPoint;
    __block CGFloat minDistance = -1;
    // 找出触点区域内，距离触点中心最近的点
    [self.points enumerateObjectsUsingBlock:^(ZJSPolygonPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZJSPolygonPoint *polygonPoint = obj;
        CGPoint point = CGPointMake(polygonPoint.x * width, polygonPoint.y * height);
        // 可触控范围
        CGRect rect = CGRectMake(point.x - pointRadius, point.y - pointRadius, pointRadius*2, pointRadius*2);
        if (CGRectContainsPoint(rect, location)) {
            CGFloat distance = [self distanceBetweenPoints:point sencond:location];
            if (minDistance == -1) {
                minDistance = distance;
                currentPoint = obj;
            }else{
                if (distance < minDistance) {
                    minDistance = distance;
                    currentPoint = obj;
                }
            }
        }
    }];
    
    return currentPoint;
}

-(void)initPointLayerArray{
    
    if (self.pointsArray) {
        [self.pointsArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
    }
    
    NSMutableArray *array = [NSMutableArray new];
    for (int i =0; i < _points.count; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.cornerRadius = self.pointRadius;
        
        layer.backgroundColor = self.pointColor.CGColor;
    
        [array addObject:layer];
        [self.layer addSublayer:layer];
    }
    
    self.pointsArray = [array copy];
}


/**
 所有相邻的点连接起来的线段
 */
-(void)initLines{
    NSMutableArray *array = [NSMutableArray array];
    [self.points enumerateObjectsUsingBlock:^(ZJSPolygonPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx != self.points.count) {
            ZJSPolygonPoint *current = obj;
            ZJSPolygonPoint *next = [self getNextPointAtIndex:idx];
            [array addObject:@[current, next]];
        }
        
    }];
    self.lines = [array copy];
}

-(ZJSPolygonPoint*)getNextPointAtIndex:(NSInteger)index{
    ZJSPolygonPoint *nextPoint;
    
    if (index  == self.points.count - 1 ) {
        nextPoint = [self.points firstObject];
    }else{
        nextPoint = [self.points objectAtIndex:index + 1];
    }
    return nextPoint;
}


#pragma mark - 

/**
 判断是否有交点

 @return <#return value description#>
 */
-(BOOL)checkIntersect{
    NSInteger index = [self.points indexOfObject:self.currentPoint];
    
    ZJSPolygonPoint *prePoint;
    ZJSPolygonPoint *nextPoint;
    if (index  == self.points.count - 1) {
        prePoint = [self.points objectAtIndex:index - 1];
        nextPoint = [self.points firstObject];
    }else if (index == 0){
        prePoint = [self.points lastObject];
        nextPoint = [self.points objectAtIndex:index + 1];
    }else{
        prePoint = [self.points objectAtIndex:index - 1];
        nextPoint = [self.points objectAtIndex:index + 1];
    }
    
    return [self checkIntersectWithPoint1:self.currentPoint Point2:nextPoint]||
    [self checkIntersectWithPoint1:prePoint Point2:self.currentPoint];
}

-(BOOL)checkIntersectWithPoint1:(ZJSPolygonPoint*)Point1 Point2:(ZJSPolygonPoint*)Point2{
    
    __block BOOL intersect = NO;
    [self.lines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *line = obj;
        if ([line containsObject:Point1]||[line containsObject:Point2]) {
            
        }else{
            ZJSPolygonPoint *Point3 = [line firstObject];
            ZJSPolygonPoint *Point4 = [line lastObject];
            if ([self intersectA:CGPointMake(Point1.x, Point1.y) b:CGPointMake(Point2.x, Point2.y) c:CGPointMake(Point3.x, Point3.y) d:CGPointMake(Point4.x, Point4.y)]) {
                
                intersect = YES;
                *stop = YES;
            }else{
                
            }
        }
    }];
    
    return intersect;
}


//**计算两条线段是否有交点**//
-(double)determinantV1:(double) v1 v2:(double) v2 v3:(double) v3 v4:(double)v4 // 行列式
{
    return (v1*v3-v2*v4);
}

-(BOOL)intersectA:(CGPoint) aa b:(CGPoint) bb c:(CGPoint)cc d:(CGPoint) dd
{
    double delta = [self determinantV1:bb.x-aa.x v2:dd.x-cc.x v3:dd.y-cc.y v4:bb.y-aa.y];
    if ( delta<=(1e-6) && delta>=-(1e-6) )  // delta=0，表示两线段重合或平行
    {
        return false;
    }
    double namenda = [self determinantV1:dd.x-cc.x v2:aa.x-cc.x v3:aa.y-cc.y v4:dd.y-cc.y]/ delta;
    if ( namenda>1 || namenda<0 )
    {
        return false;
    }
    double miu = [self determinantV1:bb.x-aa.x v2:aa.x-cc.x v3:aa.y-cc.y v4:bb.y-aa.y]/ delta;
    if ( miu>1 || miu<0 )
    {
        return false;
    }
    return true;
}

#pragma mark - getters and setters
-(void)setPoints:(NSArray<ZJSPolygonPoint *> *)points{
    _points = [points copy];
    [self setNeedsDisplay];
    
    [self initPointLayerArray];
    [self initLines];
}

-(void)setPolygonBorderColor:(UIColor *)polygonBorderColor{
    _polygonBorderColor = polygonBorderColor;
    [self setNeedsDisplay];
}

-(UIColor *)polygonBorderColor{
    if (!_polygonBorderColor) {
        return self.polygonFillColor;
    }
    return _polygonBorderColor;
}

-(void)setPolygonFillColor:(UIColor *)polygonFillColor{
    _polygonFillColor = polygonFillColor;
     [self setNeedsDisplay];
}

-(void)setPolygonBorderWidth:(CGFloat)polygonBorderWidth{
    _polygonBorderWidth = polygonBorderWidth;
    [self setNeedsDisplay];
   
}

-(void)setPointRadius:(CGFloat)pointRadius{
    _pointRadius = pointRadius;
    [self.pointsArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.cornerRadius = pointRadius;
    }];
    
    [self setNeedsDisplay];
}

-(void)setPointColor:(UIColor *)pointColor{
    _pointColor = pointColor;
    [self.pointsArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = pointColor.CGColor;
    }];
}

-(UIColor *)pointColor{
    if (!_pointColor) {
        return self.polygonBorderColor;
    }
    return _pointColor;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint location = point;
    ZJSPolygonPoint *currentPoint = [self getCurrentPointAtLocation:location];
    
    if (currentPoint) {
        return [super hitTest:point withEvent:event];
    }else{
        return nil;
    }
    
}

-(void)setPolygonOpacity:(CGFloat)polygonOpacity{
    _polygonOpacity = polygonOpacity;
    [self setNeedsDisplay];
}

@end
