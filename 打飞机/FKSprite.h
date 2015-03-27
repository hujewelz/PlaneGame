//
//  FKSprite.h
//  打飞机
//
//  Created by jewelz on 14-9-28.
//  Copyright 2014年 yangtzeU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FKSprite : CCSprite {
    
}

//生命值
@property (nonatomic, assign) int lifevalue;

//精灵名称
@property (nonatomic, copy) NSString *name;

//敌机的血条
@property (nonatomic, strong) CCProgressTimer *enemyPlaneHP;

//血条更新量
@property (nonatomic, assign) float HPInterval;

@end
