//
//  PreloadLayer.h
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright 2014年 yangtzeU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PreloadLayer : CCLayer {
    //进度条
    CCProgressTimer *_progress;
    //进度条更新次数
    float _progressInterval;
    //加载的资源数
    int _sourceCount;
}

+(CCScene *) scene;

@end
