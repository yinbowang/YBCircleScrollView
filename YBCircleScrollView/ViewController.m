//
//  ViewController.m
//  YBCircleScrollView
//
//  Created by wyb on 2017/4/7.
//  Copyright © 2017年 中天易观. All rights reserved.
//

#import "ViewController.h"
#import "YBCircleScrollView.h"

@interface ViewController ()<YBCircleScrollViewDelegate>

@property(nonatomic,strong)YBCircleScrollView *ybview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *arr = @[
                     @"http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",//网络图片
                     [UIImage imageNamed:@"1.jpg"],//本地图片，传image，不能传名称
                     @"http://www.bz55.com/uploads/allimg/150917/139-15091G54409.jpg",
                     @"http://www.bz55.com/uploads/allimg/150917/139-15091G54425.jpg"
                     ];
    YBCircleScrollView *view = [[YBCircleScrollView alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200)];
    view.imageArray = arr;
    view.delegate = self;
    [self.view addSubview:view];
    self.ybview = view;
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [YBCircleScrollView clearCache];
    
}

- (void)circleScrollView:(YBCircleScrollView *)circleScrollView clickImageWithIndex:(NSInteger)index
{
    NSLog(@"%ld",(long)index);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
