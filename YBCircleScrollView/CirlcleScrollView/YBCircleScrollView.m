//
//  YBCircleScrollView.m
//  YBCircleScrollView
//
//  Created by wyb on 2017/4/7.
//  Copyright © 2017年 中天易观. All rights reserved.
//

#import "YBCircleScrollView.h"
#import <CommonCrypto/CommonDigest.h>

#define KWidth self.bounds.size.width
#define KHeight self.bounds.size.height


@interface YBCircleScrollView ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIPageControl *pageControl;
//当前显示的imageView
@property (nonatomic, strong) UIImageView *currImageView;
//滚动显示的imageView
@property (nonatomic, strong) UIImageView *otherImageView;
//轮播的图片数组
@property (nonatomic, strong) NSMutableArray *images;
//下载图片的队列
@property (nonatomic, strong) NSOperationQueue *queue;
//定时器
@property(nonatomic,strong)NSTimer *timer;
//当前显示图片的索引
@property (nonatomic, assign) NSInteger currIndex;
//将要显示图片的索引
@property (nonatomic, assign) NSInteger nextIndex;

@end

//缓存图片的文件夹
static NSString *imageCacheDirPath;

@implementation YBCircleScrollView


/**
 初始化静态变量时候使用
 */
+ (void)initialize
{
    imageCacheDirPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"YBimageCacheDir"];
    BOOL isDir = NO;
    BOOL isExistDir = [[NSFileManager defaultManager] fileExistsAtPath:imageCacheDirPath isDirectory:&isDir];
    if (!isDir || !isExistDir) {
        //创建文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCacheDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self loadUI];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self loadUI];
        
    }
    return self;
}



- (void)loadUI
{
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    //图片的点击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick)];
    [self.scrollView addGestureRecognizer:tap];
    
    self.currImageView = [[UIImageView alloc]init];
    [self.scrollView addSubview:self.currImageView];
    
    self.otherImageView = [[UIImageView alloc]init];
    [self.scrollView addSubview:self.otherImageView];
    
    self.pageControl = [[UIPageControl alloc]init];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [self addSubview:self.pageControl];
    
    self.queue = [[NSOperationQueue alloc]init];
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, KHeight - 20, KWidth, 20);
    
    if (self.images.count > 1) {
        
        self.scrollView.contentSize = CGSizeMake(5*KWidth, 0);
        self.scrollView.contentOffset = CGPointMake(2*KWidth, 0);
        self.currImageView.frame = CGRectMake(2*KWidth, 0, KWidth, KHeight);
        
        [self startTimer];
        
    }else{
        
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, KWidth, KHeight);
        
        [self stopTimer];
        
    }
    
    
}

- (void)setImageArray:(NSArray *)imageArray
{
    if (imageArray.count == 0) {
        return;
    }
    
    _imageArray = imageArray;
    self.images = [NSMutableArray array];
    
    for (NSInteger i=0; i<imageArray.count; i++) {
        
        id obj = imageArray[i];
        
        if ([obj isKindOfClass:[UIImage class]]) {
            
            [self.images addObject:obj];
            
        }else if ([obj isKindOfClass:[NSString class]]){
            
            //先添加占位图
            UIImage *placeHoder = [UIImage imageNamed:@"Placeholder.jpg"];
            [self.images addObject:placeHoder];
            
            //下载图片
            [self downloadImage:i];
            
        }
        
    }
    
    self.currImageView.image = self.images[self.currIndex];
    self.pageControl.numberOfPages = self.images.count;
    
    
}


/**
 下载图片

 @param index 图片索引
 */
- (void)downloadImage:(NSInteger)index
{
    NSString *urlString = [self.imageArray objectAtIndex:index];
    NSString *imageName = [self MD5ForImageUrl:urlString];
    NSString *imagePath = [imageCacheDirPath stringByAppendingPathComponent:imageName];
    
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    //先从沙盒里拿
    if (data) {
        self.images[index] = [UIImage imageWithData:data];
        
    }else{
        
       //下载图片
        NSBlockOperation *downLoadOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                
               self.images[index] = [UIImage imageWithData:data];
                if (self.currIndex == index) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        self.currImageView.image = self.images[index];
                        
                    });
                }
                
                [data writeToFile:imagePath atomically:YES];
                
            }
            
        }];
        
        [self.queue addOperation:downLoadOperation];
        
    }
}

- (void)startTimer
{
    if (self.timer) {
        
        [self stopTimer];
        
    }
    
    self.timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timeAction:(NSTimer *)timer
{
    [self.scrollView setContentOffset:CGPointMake(3*KWidth, 0) animated:YES];
}


/**
  将图片的urlMD5加密作为图片名称
 */
-(NSString *)MD5ForImageUrl:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}


#pragma mark 当图片滚动过半时就修改当前页码
- (void)changeCurrendPageWithOffsex:(CGFloat)offset
{
    if (offset < KWidth *1.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) {
            index = self.images.count - 1;
            
        }
        _pageControl.currentPage = index;
        
    }else if (offset > KWidth *2.5)
    {
        _pageControl.currentPage = (self.currIndex +1) % self.images.count;
    }else{
        
        _pageControl.currentPage = self.currIndex;
    }
}

#pragma mark-UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    //更改page
    [self changeCurrendPageWithOffsex:offsetX];
    
    //👉滚动
    if (offsetX < 2*KWidth) {
        
        self.otherImageView.frame = CGRectMake(KWidth, 0, KWidth, KHeight);
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) {
            self.nextIndex = self.images.count - 1;
        }
        self.otherImageView.image = self.images[self.nextIndex];
        if (offsetX <= KWidth) {
            
            [self changeToNextImage];
        }
        
    //👈滚动
    }else if (offsetX > 2*KWidth)
    {
       self.otherImageView.frame = CGRectMake(CGRectGetMaxX(self.currImageView.frame), 0, KWidth, KHeight);
        self.nextIndex = (self.currIndex + 1) % self.images.count;
        self.otherImageView.image = self.images[self.nextIndex];
        if (offsetX >= 3*KWidth) {
            [self changeToNextImage];
        }
    }
    
    
    
}

- (void)changeToNextImage
{
    //切换到下一张图片
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(KWidth * 2, 0);
    
    self.currIndex = self.nextIndex;
    self.pageControl.currentPage = self.currIndex;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}

+ (void)clearCache
{
    NSArray *imageFileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageCacheDirPath error:nil];
    
    for (NSString *imageName in imageFileNameArray) {
        
        NSString *imagePath = [imageCacheDirPath stringByAppendingPathComponent:imageName];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
    }
    
}

- (void)imageClick
{
    if ([self.delegate respondsToSelector:@selector(circleScrollView:clickImageWithIndex:)]) {
        
        [self.delegate circleScrollView:self clickImageWithIndex:self.currIndex];
        
    }
}



@end
