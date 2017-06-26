//
//  ZZPlayerView.h
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/6/15.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

/*
 
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
#import "ZZPlayerModel.h"

@class ZZPlayerView;

@protocol ZZPlayerViewDelegate <NSObject>

@optional
- (void)playerViewDidClickBack:(ZZPlayerView *)playerView;

@end

@interface ZZPlayerView : UIView

@property (nonatomic, weak) id<ZZPlayerViewDelegate> delegate;
@property (nonatomic, strong) ZZPlayerModel *playerModel;

- (void)play;
- (void)rePlay;
@end
