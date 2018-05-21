//
//  CHMPhotoBrowserController.m
//  CHMPhotoBrower
//
//  Created by 陈华谋 on 2017/8/29.
//  Copyright © 2017年 陈华谋. All rights reserved.
//

#import "CHMPhotoBrowserController.h"
#import "UIView+CHMLayout.h"
#import "CHMPhotoBrowserCell.h"

static NSString * const chm_photoBrowserCell_ReuseIdentifier = @"CHMPhotoBrowserCell";

@interface CHMPhotoBrowserController ()<UICollectionViewDataSource, UICollectionViewDelegate>

/**
 collectionView
 */
@property (strong, nonatomic) UICollectionView *collectionView;

/**
 显示页码的Label
 */
@property (strong, nonatomic) UILabel *pageLabel;

/**
 照片数组
 */
@property (strong, nonatomic) NSMutableArray *photosArray;

/**
 当前下标
 */
@property (assign, nonatomic) NSInteger currentIndex;

/**
 呈现方式
 */
@property (assign, nonatomic) CHMPhotoBrowserTransition transitionStyle;

/*-----------可选项，可忽略--------------*/
/**
 当前图片
 */
@property (strong, nonatomic) UIImage *currentImage;

/**
 当前IndexPath
 */
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@end

@implementation CHMPhotoBrowserController

- (instancetype)initWithPhotosArray:(NSArray *)photosArray currentIndex:(NSInteger)currentIndex transitionStyle:(CHMPhotoBrowserTransition)transitonStyle {
    if (self = [super init]) {
        self.transitionStyle = transitonStyle;
        for (NSString *urlString in photosArray) {
            [self.photosArray addObject:urlString];
        }
        self.currentIndex = currentIndex;
    }
    return self;
}

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CHMPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:chm_photoBrowserCell_ReuseIdentifier forIndexPath:indexPath];
    cell.urlString = self.photosArray[indexPath.item];
    
    cell.singleTap = ^{
        if (self.transitionStyle == CHMPhotoBrowserTransitionPush) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    self.currentImage = cell.browserView.imageView.image;
    self.currentIndexPath = indexPath;
    return cell;
}


#pragma mark - collection view delegate 
// 减速完成，设置页码
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = _collectionView.contentOffset.x / self.view.chm_width;
    _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd", page + 1, _photosArray.count];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CHMPhotoBrowserCell class]])
    {
        [(CHMPhotoBrowserCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CHMPhotoBrowserCell class]])
    {
        [(CHMPhotoBrowserCell *)cell recoverSubviews];
    }
}


#pragma mark - View life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * self.view.chm_width, 0)];
    // 状态栏、导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _pageLabel.hidden = _isShowPageLabel;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 状态栏、导航栏
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageLabel];
}

#pragma mark - Setter
- (void)setIsShowPageLabel:(BOOL)isShowPageLabel {
    _isShowPageLabel = isShowPageLabel;
    _pageLabel.hidden = _isShowPageLabel;
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // layout
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(self.view.chm_width, self.view.chm_height);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.contentSize = CGSizeMake(_photosArray.count * self.view.chm_width, 0);
        // register cell
        [_collectionView registerClass:[CHMPhotoBrowserCell class] forCellWithReuseIdentifier:chm_photoBrowserCell_ReuseIdentifier];
    }
    return _collectionView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, self.view.chm_width, 20)];
        _pageLabel.backgroundColor = [UIColor clearColor];
        _pageLabel.font = [UIFont systemFontOfSize:18];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd", _currentIndex + 1, _photosArray.count];
    }
    return _pageLabel;
}

- (NSMutableArray *)photosArray {
    if (!_photosArray) {
        _photosArray = [NSMutableArray array];
    }
    return _photosArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
