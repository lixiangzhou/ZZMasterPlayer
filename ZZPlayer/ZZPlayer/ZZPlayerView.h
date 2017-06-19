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

@interface ZZPlayerView : UIView

@property (nonatomic, assign) VLCRepeatMode repeatMode;
@property (nonatomic, strong, readonly) NSArray<ZZPlayerModel *> *models;

- (void)play;

- (void)addModel:(ZZPlayerModel *)model;

@end
