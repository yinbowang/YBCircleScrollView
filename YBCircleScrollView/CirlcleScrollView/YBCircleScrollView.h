//
//  YBCircleScrollView.h
//  YBCircleScrollView
//
//  Created by wyb on 2017/4/7.
//  Copyright © 2017年 中天易观. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YBCircleScrollView;

@protocol YBCircleScrollViewDelegate <NSObject>

- (void)circleScrollView:(YBCircleScrollView *)circleScrollView clickImageWithIndex:(NSInteger)index;

@end

@interface YBCircleScrollView : UIView

/**
 *  轮播的图片数组，可以是本地图片（UIImage，不能是图片名称），也可以是网络url
 */
@property (nonatomic, strong) NSArray *imageArray;

@property(nonatomic,weak)id<YBCircleScrollViewDelegate> delegate;


/**
 清空图片缓存
 */
+ (void)clearCache;


@end
