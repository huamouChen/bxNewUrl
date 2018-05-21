//
//  CHMPhotoBrowserCell.m
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import "CHMPhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+CHMLayout.h"

@implementation CHMPhotoBrowserCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
        self.browserView = [[CHMPhotoBrowserView alloc] initWithFrame:self.bounds];
        
        __weak typeof(self) weakSelf = self;
        self.browserView.singleTap = ^{
            if (weakSelf.singleTap) {
                weakSelf.singleTap();
            }
        };
        [self addSubview:self.browserView];
    }
    return self;
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    _browserView.urlString = _urlString;
}

- (void)recoverSubviews {
    [self.browserView recoverSubviews];
}
@end





@interface CHMPhotoBrowserView ()<UIScrollViewDelegate>

@end

@implementation CHMPhotoBrowserView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.maximumZoomScale = 2.5;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.multipleTouchEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delaysContentTouches = NO;
        self.scrollView.alwaysBounceVertical = NO;
        [self addSubview:self.scrollView];
        
        self.imageContainerView = [[UIView alloc] init];
        self.imageContainerView.clipsToBounds = YES;
        self.imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:self.imageContainerView];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.imageContainerView addSubview:self.imageView];
        
        // 单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
        // 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

#pragma mark - Setter
- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    // 这里用到三方库 SDWebImage
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_urlString]];
}

#pragma mark - 恢复到初始状态
- (void)recoverSubviews {
    [self.scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.imageContainerView.chm_origin = CGPointZero;
    self.imageContainerView.chm_width = self.scrollView.chm_width;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.chm_height / self.scrollView.chm_width)
    {
        self.imageContainerView.chm_height = image.size.height / (image.size.width / self.scrollView.chm_width);
    }
    else
    {
        CGFloat height = image.size.height / image.size.width * self.scrollView.chm_width;
        if (height < 1 || isnan(height)) {
            height = self.chm_height;
        }
        height = floor(height);
        self.imageContainerView.chm_height = height;
        self.imageContainerView.chm_centerY = self.chm_height / 2.0;
    }
    
    if (self.imageContainerView.chm_height > self.chm_height && self.imageContainerView.chm_height - self.chm_height <= 1)
    {
        self.imageContainerView.chm_height = self.chm_height;
    }
    CGFloat contentSizeH = MAX(self.imageContainerView.chm_height, self.chm_height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.chm_width, contentSizeH);
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.scrollView.alwaysBounceVertical = self.imageContainerView.chm_height <= self.chm_height ? NO : YES;
    self.imageView.frame = _imageContainerView.bounds;
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - 单击手势
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTap) {
        self.singleTap();
    }
}
#pragma mark - 双击手势
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollView.zoomScale > 1.0)
    { // 放大状态就缩小
        self.scrollView.contentInset = UIEdgeInsetsZero;
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    else
    { // 放大
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat width = self.frame.size.width / newZoomScale;
        CGFloat height = self.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - width / 2.0, touchPoint.y - height / 2.0, width, height) animated:YES];
    }
}

#pragma mark - scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshImageContainerViewCenter];
}

#pragma mark - 刷新图片的中点
- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = self.scrollView.chm_width > self.scrollView.contentSize.width ? (self.scrollView.chm_width - self.scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = self.scrollView.chm_height > self.scrollView.contentSize.height ? (self.scrollView.chm_height - self.scrollView.contentSize.width) * 0.5 : 0;
    self.imageContainerView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}

@end
