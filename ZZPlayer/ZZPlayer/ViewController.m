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
    model.URLString = @"http://cdn1.bb-app.cn/f35e4dbb4e6a258a1496740615405.mp4?OSSAccessKeyId=9onpvIAMCEA8bWI7&Expires=1497607202&Signature=9yhm3vjabktJgkON5%2FXZLEM5OtQ%3D";
    
    [playerView addModel:model];
    
    [playerView play];
}


@end
