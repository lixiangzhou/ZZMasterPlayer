//
//  ZZPlayerView.h
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/6/15.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

/*
 下载 MobileVLCKit.framework 并添加到项目中
 MobileVLCKit.framework 依赖的框架如下：
 
 VideoToolbox.framework
 AudioToolbox.framework
 CoreMedia.framework
 CoreVideo.framework
 CoreAudio.framework
 AVFoundation.framework
 MediaPlayer.framework
 
 libstdc++.6.0.9.tbd
 libiconv.2.tbd
 libc++.1.tbd
 libz.1.tbd
 libbz2.1.0.tbd
 
 */

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZZPlayerModel.h"

@class ZZPlayerView;

@protocol ZZPlayerViewDelegate <NSObject>

@optional
- (void)playerViewDidClickBack:(ZZPlayerView *)playerView;

@end

@interface ZZPlayerView : UIView

@property (nonatomic, weak) id<ZZPlayerViewDelegate> delegate;
/// 视频模型
@property (nonatomic, strong) ZZPlayerModel *playerModel;

/// 播放视频
- (void)play;
/// 重置并重新播放视频
- (void)rePlay;
/// 暂停视频播放
- (void)pause;
/// 重置播放器
- (void)resetPlayer;
@end
