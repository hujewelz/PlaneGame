//
//  MenuLayer.m
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright 2014年 yangtzeU. All rights reserved.
//

#import "MenuLayer.h"
#import "PreloadLayer.h"
#import "SettingLayer.h"

@implementation MenuLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    MenuLayer *menuLayer = [MenuLayer node];
    [scene addChild:menuLayer];
    return scene;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCMenuItem *startItem = [CCMenuItemFont itemWithString:@"Start" block:^(id sender) {
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[PreloadLayer scene] ]];
            
        }];
        startItem.position = ccp(winSize.width/2, winSize.height*0.6f);
        
        CCMenuItem *settingItem = [CCMenuItemFont itemWithString:@"Setting" block:^(id sender) {
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[SettingLayer scene] ]];
            
        }];
        settingItem.position = ccp(winSize.width/2, winSize.height*0.45f);
        
        CCMenu *menu = [CCMenu menuWithItems:startItem, settingItem, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"MenuLayer dead");
    [super dealloc];
}
@end
