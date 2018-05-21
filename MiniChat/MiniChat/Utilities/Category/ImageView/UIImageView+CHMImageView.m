//
//  UIImageView+CHMImageView.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "UIImageView+CHMImageView.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (CHMImageView)

- (void)chm_imageViewWithURL:(NSString *)urlString placeholder:(NSString *)placeholder {
    
    if ([urlString hasPrefix:@"/"]) {
        NSString *resultString = [NSString stringWithFormat:@"%@%@", BaseURL, urlString];
        [self sd_setImageWithURL:[NSURL URLWithString:resultString] placeholderImage:[UIImage imageNamed:placeholder]];
        return;
    }
    
    if (![urlString hasPrefix:@"http"] && ![urlString isEqualToString:@""]) { // 主要是为了兼容设置本地图片，且占位图不是一样的时候
        self.image = [UIImage imageNamed:urlString];
        return;
    }
    
    if ([urlString isEqualToString:@""]) {
        self.image = [UIImage imageNamed:placeholder];
        return;
    }
    
    
    
    NSString *resultString = [NSString stringWithFormat:@"%@", urlString];
    [self sd_setImageWithURL:[NSURL URLWithString:resultString] placeholderImage:[UIImage imageNamed:placeholder]];
}

@end
