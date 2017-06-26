//
//  ZZPlayerView.m
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/6/15.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

#import "ZZPlayerView.h"

#define ZZPlayerViewAnimationDuration 0.3
#define ZZPlayerViewAnimationInterval 4

@interface ZZPlayerView () <VLCMediaPlayerDelegate>
@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;
@property (nonatomic, weak) UIView *playerView;
@property (nonatomic, weak) UIView *controlView;

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) CAGradientLayer *topGradientLayer;
@property (nonatomic, weak) CAGradientLayer *bottomGradientLayer;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *playBtn;
@property (nonatomic, weak) UIButton *fullBtn;
@property (nonatomic, weak) UILabel *startTimeLabel;
@property (nonatomic, weak) UILabel *endTimeLabel;
@property (nonatomic, weak) UISlider *progressSlider;

@property (nonatomic, assign) BOOL hasShowControl;

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, assign) BOOL isPausedBeforeEnterBackground;
@end

@implementation ZZPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self resetPlayer];
        
        self.hasShowControl = YES;
        
        [self setUI];
        
        [self layoutIfNeeded];
        
        [self addNotifications];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.topGradientLayer.frame = self.topView.bounds;
    self.bottomGradientLayer.frame = self.bottomView.bounds;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (![newSuperview isKindOfClass:[UIWindow class]]) {
        self.superView = newSuperview;
        self.originFrame = self.frame;
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 通知
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark 前后台切换
- (void)resignActive:(NSNotification *)notification {
    self.isPausedBeforeEnterBackground = self.mediaPlayer.isPlaying == NO;
    if (self.mediaPlayer.isPlaying) {
        [self pauseState];
    }
}

- (void)becomeActive:(NSNotification *)notification {
    if (self.isPausedBeforeEnterBackground == NO) {
        [self playState];
    }
}

#pragma mark 屏幕旋转
- (void)orientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self toOrientation:orientation];
}

- (void)toOrientation:(UIDeviceOrientation)orientation {
    if (orientation == UIDeviceOrientationPortrait) {
        
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
        
        self.frame = self.originFrame;
        [self.superView addSubview:self];
        
        self.fullBtn.selected = YES;
    } else if (orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft) {
        [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
        [UIApplication sharedApplication].statusBarOrientation = orientation == UIDeviceOrientationLandscapeRight ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([UIApplication sharedApplication].keyWindow);
        }];
        
        [self layoutIfNeeded];
        
        self.fullBtn.selected = NO;
    }
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
    
    [controlView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoScreen:)]];
    
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setTop {
    UIView *topView = [UIView new];
    [self.controlView addSubview:topView];
    self.topView = topView;
    [topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTop:)]];
    
    // 渐变层
    self.topGradientLayer = [self addGradientLayerToView:topView colors:@[
                                                                          (id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor,
                                                                          (id)[UIColor clearColor].CGColor
                                                                          ]];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    // 返回按钮
    UIButton *backBtn = [UIButton new];
    backBtn.imageView.contentMode = UIViewContentModeCenter;
    [backBtn setImage:[UIImage imageNamed:@"zzplayer_back"] forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    self.backBtn = backBtn;
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    // 标题
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    [topView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topView);
        make.left.equalTo(@10);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView);
        make.left.equalTo(backBtn.mas_right).offset(10);
    }];
}

- (void)setBottom {
    UIView *bottomView = [UIView new];
    [self.controlView addSubview:bottomView];
    self.bottomView = bottomView;
    [bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBottom:)]];
    
    // 渐变层
    self.bottomGradientLayer = [self addGradientLayerToView:bottomView colors:@[
                                                                        (id)[UIColor clearColor].CGColor,
                                                                        (id)[UIColor colorWithWhite:0.0 alpha:0.9].CGColor
                                                                        ]];
    // 播放、暂停
    UIButton *playBtn = [UIButton new];
    [playBtn setImage:[UIImage imageNamed:@"zzplayer_play"] forState:UIControlStateSelected];
    [playBtn setImage:[UIImage imageNamed:@"zzplayer_pause"] forState:UIControlStateNormal];
    [bottomView addSubview:playBtn];
    self.playBtn = playBtn;
    [playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    
    // 开始时间
    UILabel *startTimeLabel = [UILabel new];
    startTimeLabel.font = [UIFont systemFontOfSize:10];
    startTimeLabel.textColor = [UIColor whiteColor];
    startTimeLabel.text = @"00:00";
    startTimeLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:startTimeLabel];
    self.startTimeLabel = startTimeLabel;
    
    // 播放进度
    UISlider *progressSlider = [UISlider new];
    [progressSlider setThumbImage:[UIImage imageNamed:@"zzplayer_progress_dot"] forState:UIControlStateNormal];
    [bottomView addSubview:progressSlider];
    self.progressSlider = progressSlider;
    [progressSlider addTarget:self action:@selector(sliderBegin) forControlEvents:UIControlEventTouchDown];
    [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [progressSlider addTarget:self action:@selector(sliderEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    // 结束时间
    UILabel *endTimeLabel = [UILabel new];
    endTimeLabel.font = [UIFont systemFontOfSize:10];
    endTimeLabel.textColor = [UIColor whiteColor];
    endTimeLabel.text = @"00:00";
    [bottomView addSubview:endTimeLabel];
    self.endTimeLabel = endTimeLabel;
    
    // 全屏
    UIButton *fullBtn = [UIButton new];
    [fullBtn setImage:[UIImage imageNamed:@"zzplayer_full"] forState:UIControlStateNormal];
    [fullBtn setImage:[UIImage imageNamed:@"zzplayer_unfull"] forState:UIControlStateSelected];
    [bottomView addSubview:fullBtn];
    self.fullBtn = fullBtn;
    [fullBtn addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(self);
        make.height.equalTo(@44);
    }];
    
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.bottom.equalTo(bottomView);
    }];

    CGFloat width = ceil([@"000:00" sizeWithAttributes:@{NSFontAttributeName: self.startTimeLabel.font}].width);
    [startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.equalTo(playBtn.mas_right).offset(5);
        make.width.equalTo(@(width));
    }];
    
    [progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomView);
        make.left.equalTo(startTimeLabel.mas_right).offset(5);
    }];

    [endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.equalTo(progressSlider.mas_right).offset(5);
        make.width.equalTo(@(width));
    }];
    
    [fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(bottomView);
        make.left.equalTo(endTimeLabel.mas_right).offset(5);
        make.right.equalTo(bottomView).offset(-10);
    }];
}

#pragma mark - VLCMediaPlayerDelegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {

    NSInteger startTime = self.startTime;
    NSInteger totalTime = self.totalTime;
    BOOL isLong = totalTime / 1000 / 60 >= 100;
    
    self.startTimeLabel.text = [self processTime:startTime isLong:isLong];
    self.endTimeLabel.text = [self processTime:totalTime isLong:isLong];
    self.progressSlider.value = startTime * 1.0 / totalTime;
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    
    VLCMediaPlayerState state = self.mediaPlayer.state;
    
    switch (state) {
        case VLCMediaPlayerStateOpening:
        {
            NSLog(@"VLCMediaPlayerStateOpening");
            break;
        }
        case VLCMediaPlayerStateStopped:    // 当个视频播放器没有该功能
        {
            NSLog(@"VLCMediaPlayerStateStopped");
            break;
        }
        case VLCMediaPlayerStateBuffering:
        {
            NSLog(@"VLCMediaPlayerStateBuffering");
            break;
        }
        case VLCMediaPlayerStatePlaying:
        {
            NSLog(@"VLCMediaPlayerStatePlaying");
            break;
        }
        case VLCMediaPlayerStatePaused:
        {
            NSLog(@"VLCMediaPlayerStatePaused");
            break;
        }
        case VLCMediaPlayerStateError:
        {
            NSLog(@"VLCMediaPlayerStateError");
            break;
        }
        case VLCMediaPlayerStateEnded:
        {
            NSLog(@"VLCMediaPlayerStateEnded");
            break;
        }
    }
}

#pragma mark - VLCMediaPlayerState
- (void)stateOpening {
    
}

- (void)stateStopped {
    
}

- (void)stateBuffering {
    
}

- (void)statePlaying {
    
}

- (void)statePaused {
    
}

- (void)stateError {
    
}

- (void)stateEnded {
    
}


#pragma mark - Action
- (void)playAction {
    [self showControl];
    
    if (self.mediaPlayer.isPlaying) {
        [self pauseState];
    } else {
        [self playState];
    }
}

- (void)playState {
    [self.mediaPlayer play];
    self.playBtn.selected = NO;
}

- (void)pauseState {
    [self.mediaPlayer pause];
    self.playBtn.selected = YES;
}

- (void)sliderBegin {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
}

- (void)sliderValueChanged {
    int startTime = self.progressSlider.value * self.totalTime;
    self.mediaPlayer.time = [VLCTime timeWithInt:startTime];
    
    NSInteger totalTime = self.totalTime;
    BOOL isLong = totalTime / 1000 / 60 >= 100;
    self.startTimeLabel.text = [self processTime:startTime isLong:isLong];
}

- (void)sliderEnd {
    [self autoHideControl];

    [self sliderValueChanged];
}

- (void)fullScreenAction {
    [self showControl];
    
    BOOL isFullScreen = [UIApplication sharedApplication].statusBarOrientation != UIDeviceOrientationPortrait;
    if (isFullScreen) {
        [self toOrientation:UIDeviceOrientationPortrait];
    } else {
        [self toOrientation:UIDeviceOrientationLandscapeRight];
    }
}

- (void)backAction {
    if ([self.delegate respondsToSelector:@selector(playerViewDidClickBack:)]) {
        [self.delegate playerViewDidClickBack:self];
    }
}

- (void)tapVideoScreen:(UITapGestureRecognizer *)gesture {
    if (self.hasShowControl == YES) {
        [self hideControl];
    } else {
        [self showControl];
    }
}

- (void)tapTop:(UITapGestureRecognizer *)gesture {
    [self showControl];
}

- (void)tapBottom:(UITapGestureRecognizer *)gesture {
    [self showControl];
}

#pragma mark - Control hide / show
- (void)showControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    
    [UIView animateWithDuration:ZZPlayerViewAnimationDuration animations:^{
        self.topView.alpha = 1;
        self.bottomView.alpha = 1;
    } completion:^(BOOL finished) {
        self.hasShowControl = YES;
        [self autoHideControl];
    }];
}

- (void)hideControl {
    if (self.hasShowControl == NO) {
        return;
    }
    
    [UIView animateWithDuration:ZZPlayerViewAnimationDuration animations:^{
        self.topView.alpha = 0;
        self.bottomView.alpha = 0;
    } completion:^(BOOL finished) {
        self.hasShowControl = NO;
    }];
}

- (void)autoHideControl {
    if (self.hasShowControl == NO) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControl) object:nil];
    [self performSelector:@selector(hideControl) withObject:nil afterDelay:ZZPlayerViewAnimationInterval];
}


#pragma mark - Public

- (void)setPlayerModel:(ZZPlayerModel *)playerModel {
    if (playerModel == nil) {
        return;
    }
    _playerModel = playerModel;
    
    self.titleLabel.text = playerModel.title;
    
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:playerModel.URLString]];
    self.mediaPlayer.media = media;
}

- (void)play {
    [self.mediaPlayer play];
    [self autoHideControl];
}

- (void)rePlay {
    [self resetPlayer];
    self.playerModel = self.playerModel;
    [self.mediaPlayer play];
}

#pragma mark - Helper
- (CAGradientLayer *)addGradientLayerToView:(UIView *)toView colors:(NSArray *)colors {
    CAGradientLayer *gradientLayer = [CAGradientLayer new];
    gradientLayer.colors = colors;
    [toView.layer addSublayer:gradientLayer];
    return gradientLayer;
}

- (void)resetPlayer {
    [self.mediaPlayer stop];
    self.mediaPlayer.delegate = nil;
    self.mediaPlayer.drawable = nil;
    self.mediaPlayer = nil;
    [self.playerView removeFromSuperview];
    
    UIView *playerView = [UIView new];
    [self insertSubview:playerView atIndex:0];
    self.playerView = playerView;
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.startTimeLabel.text = @"00:00";
    self.endTimeLabel.text = @"00:00";
    
    
    self.mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:nil];
    self.mediaPlayer.drawable = playerView;
    self.mediaPlayer.delegate = self;
}

// 单位秒
- (int)startTime {
    return self.mediaPlayer.time.intValue;
}

// 单位秒
- (int)totalTime {
    return self.mediaPlayer.media.length.intValue;
}

// isLong 是否超过100分钟
- (NSString *)processTime:(NSInteger)time isLong:(BOOL)isLong {
    NSInteger newTime = time / 1000;
    
    if (isLong) {
        return [NSString stringWithFormat:@"%03zd:%02zd", newTime / 60, newTime % 60];
    } else {
        return [NSString stringWithFormat:@"%02zd:%02zd", newTime / 60, newTime % 60];
    }
}

@end
