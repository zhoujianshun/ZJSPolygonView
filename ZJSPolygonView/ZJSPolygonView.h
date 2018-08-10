//
//  ZJSDemo3View.h
//  AS_DrawHealthIndexDemo
//
//  Created by 周建顺 on 2018/8/1.
//  Copyright © 2018年 周建顺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJSPolygonPoint : NSObject<NSCopying>

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

-(instancetype)initWithX:(CGFloat)x y:(CGFloat)y;

-(NSString*)toString;

@end

@interface ZJSPolygonView : UIControl


@property (nonatomic, copy) NSArray<ZJSPolygonPoint*> *points;
@property (nonatomic, assign) CGFloat polygonOpacity;
@property (nonatomic, strong) UIColor *polygonBorderColor;
@property (nonatomic, strong) UIColor *polygonFillColor;
@property (nonatomic, assign) CGFloat polygonBorderWidth;
@property (nonatomic, assign) CGFloat pointRadius;
@property (nonatomic, strong) UIColor *pointColor;


@end
