//
//  CHMGroupTipCell.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/15.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMGroupTipCell.h"
#import "CHMGroupTipMessage.h"

@interface CHMGroupTipCell ()
@property (nonatomic, strong) UILabel *chm_tipLabel;
@end

@implementation CHMGroupTipCell


+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    
    CHMGroupTipMessage *message = (CHMGroupTipMessage *)model.content;
    CGSize size = [CHMGroupTipCell getTextLabelSize:message];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.chm_tipLabel = [[UILabel alloc] init];
        self.chm_tipLabel.textColor = [UIColor whiteColor];
        self.chm_tipLabel.backgroundColor = [UIColor colorWithRed:0.79 green:0.79 blue:0.79 alpha:1];
        self.chm_tipLabel.textAlignment = NSTextAlignmentCenter;
        self.chm_tipLabel.font = [UIFont systemFontOfSize:13];
        self.chm_tipLabel.layer.cornerRadius = 5;
        self.chm_tipLabel.layer.masksToBounds = YES;
        self.chm_tipLabel.numberOfLines = 0;
        [self.baseContentView addSubview:self.chm_tipLabel];
    }
    return self;
}

#pragma mark - 计算文字 size
+ (CGSize)getTextLabelSize:(CHMGroupTipMessage *)message {
    if ([message.content length] > 0) {
        float maxWidth = [UIScreen mainScreen].bounds.size.width -
        (10 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10) * 2 - 5 - 35;
        CGRect textRect = [message.content
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                           context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}


#pragma mark - 赋值
- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    CHMGroupTipMessage *message = (CHMGroupTipMessage *)model.content;
    CGSize size = [CHMGroupTipCell getTextLabelSize:message];
    _chm_tipLabel.frame = CGRectMake((SCREEN_WIDTH - size.width) / 2.0, 0, size.width, size.height);
    _chm_tipLabel.text = message.content;
}

@end
