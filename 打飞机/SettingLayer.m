//
//  Setting.m
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright 2014年 yangtzeU. All rights reserved.
//

#import "SettingLayer.h"
#import "MenuLayer.h"
#import "CDAudioManager.h"


@implementation SettingLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    SettingLayer *settingLayer = [SettingLayer node];
    [scene addChild:settingLayer];
    return scene;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCMenuItemFont *musicItem = [CCMenuItemFont itemWithString:@"Music:"];
        musicItem.position = ccp(winSize.width*0.4f, winSize.height*0.6f);
        
        CCMenuItemFont *musicOn = [CCMenuItemFont itemWithString:@"On"];
        CCMenuItemFont *musicOff = [CCMenuItemFont itemWithString:@"Off"];
        
        CCMenuItemToggle *togglen = [CCMenuItemToggle itemWithTarget:self selector:@selector(change:) items:
                                      musicOn, musicOff, nil];
        togglen.position = ccp(winSize.width*0.6f, winSize.height*0.6f);
        
        CCMenuItem *backItem = [CCMenuItemFont itemWithString:@"Back" block:^(id sender) {
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MenuLayer scene] ]];
        }];
        backItem.position = ccp(winSize.width/2, winSize.height*0.4f);
        
        CCMenu *menu = [CCMenu menuWithItems:musicItem, togglen, backItem, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    return self;
}

- (void)change:(id)sender
{
    if ([CDAudioManager sharedManager].mute == TRUE) {
        [CDAudioManager sharedManager].mute = FALSE;
    } else {
        [CDAudioManager sharedManager].mute = TRUE;
    }
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    CCMenuItemToggle *toggle = (CCMenuItemToggle *)sender;
    
    //开＝0.关＝1
    if (toggle.selectedIndex == 1) {
        [userDef setBool:NO forKey:@"music"];
    } else {
        [userDef setBool:YES forKey:@"music"];
    }
}

- (void)dealloc
{
    NSLog(@"SettingLayer dead");
    [super dealloc];
}

@end
