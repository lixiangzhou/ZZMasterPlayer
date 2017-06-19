//
//  ZZPlayerView.m
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/6/15.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

#import "ZZPlayerView.h"

@interface ZZPlayerView () <VLCMediaPlayerDelegate>
@property (nonatomic, strong) VLCMediaListPlayer *mediaListPlayer;
@property (nonatomic, strong) NSMutableArray<ZZPlayerModel *> *playerModels;

@property (nonatomic, weak) UIView *controlView;

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) CAGradientLayer *topGradientLayer;
@property (nonatomic, weak) CAGradientLayer *bottomGradientLayer;

@property (nonatomic, weak) UIView *bottomView;
@end

@implementation ZZPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mediaListPlayer = [[VLCMediaListPlayer alloc] initWithDrawable:self];
        self.repeatMode = VLCRepeatAllItems;
        self.playerModels = [NSMutableArray new];
        self.mediaListPlayer.mediaPlayer.delegate = self;
        [self setUI];
        
        [self layoutIfNeeded];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topGradientLayer.frame = self.topView.frame;
//    self.bottomGradientLayer.frame = self.bottomView.frame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - UI
- (void)setUI {
    [self setControl];
    [self setTop];
    [self setBottom];
}

- (void)setControl {
    UIView *controlView = [UIView new];
    [self addSubview:controlView];
    self.controlView = controlView;
    
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setTop {
    UIView *topView = [UIView new];
    [self.controlView addSubview:topView];
    self.topView = topView;
    
    self.topGradientLayer = [self addGradientLayerToView:topView colors:@[
                                                                          (id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor,
                                                                          (id)[UIColor clearColor].CGColor
                                                                          ]];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    UIButton *backBtn = [UIButton new];
    backBtn.imageView.contentMode = UIViewContentModeCenter;
    [backBtn setImage:[UIImage imageNamed:@"zzplayer_back"] forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    self.backBtn = backBtn;
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView);
        make.left.equalTo(@10);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    [topView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView);
        make.left.equalTo(backBtn.mas_right).offset(10);
    }];
}

- (void)setBottom {
    
}

- (CAGradientLayer *)addGradientLayerToView:(UIView *)toView colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer new];
    gradientLayer.colors = colors;
    [toView.layer addSublayer:gradientLayer];
    return gradientLayer;
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    NSLog(@"%@", aNotification);
    [self bringSubviewToFront:self.controlView];
    
    NSInteger index = [self.mediaListPlayer.mediaList indexOfMedia:self.mediaListPlayer.mediaPlayer.media];
    ZZPlayerModel *model = self.playerModels[index];
    self.titleLabel.text = model.title;

}
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
//    NSLog(@"%@", aNotification);
//    [self bringSubviewToFront:self.controlView];
}

#pragma mark - Public
- (NSArray<ZZPlayerModel *> *)models {
    return [self.playerModels copy];
}

- (void)setRepeatMode:(VLCRepeatMode)repeatMode {
    _repeatMode = repeatMode;
    self.mediaListPlayer.repeatMode = repeatMode;
}


- (void)addModel:(ZZPlayerModel *)model {
    
    if (model == nil) {
        return;
    }
    
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:model.URLString]];
    if (self.mediaListPlayer.mediaList == nil) {
        VLCMediaList *mediaList = [VLCMediaList new];
        self.mediaListPlayer.mediaList = mediaList;
    }
    
    [self.playerModels addObject:model];
    [self.mediaListPlayer.mediaList addMedia:media];
}

- (void)play {
    [self.mediaListPlayer play];
}

@end
