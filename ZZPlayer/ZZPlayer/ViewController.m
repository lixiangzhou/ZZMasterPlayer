//
//  ViewController.m
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/6/15.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

#import "ViewController.h"
#import "ZZPlayerView.h"

@interface ViewController ()
@property (nonatomic, weak) ZZPlayerView *playerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.bounds.size.width;
    
    ZZPlayerView *playerView = [[ZZPlayerView alloc] initWithFrame:CGRectMake(0, 50, width, 9.0 / 16 * width)];
    playerView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:playerView];
    
    ZZPlayerModel *model = [ZZPlayerModel new];
    model.title = @"这里是标题";
    model.URLString = @"http://baobab.wdjcdn.com/14525705791193.mp4";

    
    playerView.playerModel = model;
    
    [playerView play];
    
    self.playerView = playerView;
    
    UIButton *replayBtn = [[UIButton alloc] init];
    [replayBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [replayBtn setTitle:@"重播" forState:UIControlStateNormal];
    [replayBtn addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:replayBtn];
    [replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)replay {
    [self.playerView rePlay];
}

@end
