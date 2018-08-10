//
//  ViewController.m
//  ZJSPolygonViewDemo
//
//  Created by 周建顺 on 2018/8/10.
//  Copyright © 2018年 周建顺. All rights reserved.
//

#import "ViewController.h"

#import "ZJSPolygonView.h"


#define RGBHEX(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

#define RGBHEXA(hex ,a) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:a]

@interface ViewController ()

@property (nonatomic, strong) ZJSPolygonView *demo3View;

@property (nonatomic, strong) ZJSPolygonView *demo4View;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.demo3View = [[ZJSPolygonView alloc] init];
    
    CGFloat width = CGRectGetWidth(self.view.frame) - 20;
    self.demo3View.frame = CGRectMake(10, 80 , width, width);
    self.demo3View.polygonFillColor =  RGBHEXA(0x3CFF3C,0.4);
    self.demo3View.polygonBorderColor = RGBHEXA(0x3CFF3C,1);
    self.demo3View.polygonBorderWidth = 2;
    // self.demo3View.polygonOpacity = 0.4;
    //    self.demo3View.pointColor = RGBHEX(0x3CFF3C);
    self.demo3View.points = @[[[ZJSPolygonPoint alloc] initWithX:0.1 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.45],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.9],
                              [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.9],
                              ];
    //self.demo3View.userInteractionEnabled = NO;
    
    
    self.demo4View = [[ZJSPolygonView alloc] init];
    self.demo4View.polygonFillColor = [UIColor redColor];
    self.demo4View.polygonBorderColor = [UIColor blueColor];
    
    self.demo4View.pointColor = [UIColor yellowColor];
    self.demo4View.frame = CGRectMake(10, 80 , width, width);
    self.demo4View.points = @[[[ZJSPolygonPoint alloc] initWithX:0.1 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.1],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.45],
                              [[ZJSPolygonPoint alloc] initWithX:0.9 y:0.9],
                              [[ZJSPolygonPoint alloc] initWithX:0.45 y:0.9],
                              [[ZJSPolygonPoint alloc] initWithX:0.1 y:0.9],
                              [[ZJSPolygonPoint alloc] initWithX:0.1 y:0.45]];
    
    [self.view addSubview:self.demo4View];
    
    [self.view addSubview:self.demo3View];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // self.demo3View.pointColor = [UIColor whiteColor];
        //   self.demo3View.pointRadius = 10;
        //        self.demo3View.polygonBorderWidth = 6;
        //        self.demo3View.polygonBorderColor = [UIColor purpleColor];
        //        self.demo3View.polygonFillColor = [UIColor yellowColor];
    });

}

-(void)valueChangedAction:(ZJSPolygonView*)sender{
    CGFloat width = CGRectGetWidth(sender.frame);
    CGFloat height = CGRectGetHeight(sender.frame);
    [sender.points enumerateObjectsUsingBlock:^(ZJSPolygonPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"%@\n", [obj toString]);
        NSLog(@"%@, %@", @(width*obj.x), @(height*obj.y));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
