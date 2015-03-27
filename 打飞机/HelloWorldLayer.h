//
//  HelloWorldLayer.h
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright yangtzeU 2014年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer 
{
    CCSprite *plantSprite, *soldierSprite;
    NSInteger sWidth, sHeight;
    CCSpriteBatchNode *batchNode;
    CCParallaxNode *bgNode;
    CCLabelTTF *scoreLabel;
    int scoreValue;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
