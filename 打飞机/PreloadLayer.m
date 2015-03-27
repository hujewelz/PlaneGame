//
//  PreloadLayer.m
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright 2014年 yangtzeU. All rights reserved.
//

#import "PreloadLayer.h"
#import "SimpleAudioEngine.h"
#import "HelloWorldLayer.h"

@interface PreloadLayer ()

-(void) loadMusics:(NSArray *)musicFile;
-(void) loadSounds:(NSArray *)soundFile;
-(void) loadSpriteSheet:(NSArray *)spriteSheets;
-(void) loadingComplete;    //资源加载完，切换到下一个场景
-(void) progressUpdate;     //更新进度条，计算何时加载完成

@end


@implementation PreloadLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PreloadLayer *layer = [PreloadLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(id) init
{
	if( (self=[super init])) {
        
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *progressSprite = [CCSprite spriteWithFile:@"progressbar.png"];
        
        //初始化一个进度条对象
        _progress = [[CCProgressTimer alloc] initWithSprite:progressSprite];
        //表示未加载任何资源
        [_progress setPercentage:0.0f];
        _progress.scale = 0.5f;
        //设置进度条动画的起始位置，默认在图片的中的。如果要显示从左到右的动画效果，必须设置成(0,y).
        _progress.midpoint = ccp(0, 0.5f);
        //因为x方向需要改变，y方向不许改变，所以设置barChangeRate = ccp(1, 0)
        _progress.barChangeRate = ccp(1, 0);
        _progress.type = kCCProgressTimerTypeBar;
        _progress.position = ccp(winSize.width/2, winSize.height/2);
        
        [self addChild:_progress];
        
        
		
	}
	
	return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"preloadResources" ofType:@"plist"];
    NSDictionary *dictory = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //从字典中拿到对应的数组
    NSArray *spriteSheet = [dictory objectForKey:@"SpriteSheets"];
    NSArray *sounds = [dictory objectForKey:@"Sounds"];
    NSArray *musics = [dictory objectForKey:@"Musics"];
    
    //资源数
    _sourceCount = spriteSheet.count + sounds.count + musics.count;
    
    //设置进度条更新次数＝100/资源数
    _progressInterval = 100.0 / (float)_sourceCount;
    
    //在主线程上依次加载每种类型的资源 waitUntilDone为YES能保证所用的资源按序列依次加载
    if (sounds) {
        [self performSelectorOnMainThread:@selector(loadSounds:) withObject:sounds waitUntilDone:YES];
    }
    
    if (musics) {
        [self performSelectorOnMainThread:@selector(loadMusics:) withObject:musics waitUntilDone:YES];
    }
    
    if (sounds) {
        [self performSelectorOnMainThread:@selector(loadSpriteSheet:) withObject:spriteSheet waitUntilDone:YES];
    }
    
    
    
    [dictory release];

}

//加载背景音乐
-(void) loadMusics:(NSArray *)musicFile
{
    for (NSString *music in musicFile) {
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:music];
        [self progressUpdate];
    }
    
}

//加载声音
-(void) loadSounds:(NSArray *)soundFile
{
    for (NSString *sound in soundFile) {
        [[SimpleAudioEngine sharedEngine] preloadEffect:sound];
        [self progressUpdate];
    }
    
}

//加载精灵帧
-(void) loadSpriteSheet:(NSArray *)spriteSheets
{
    for (NSString *spriteSheet in spriteSheets) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheet];
        [self progressUpdate];
    }
}


-(void) progressUpdate
{
    if (--_sourceCount) {
        //进度条更新次数乘以资源数
        [_progress setPercentage:100.0f - (_progressInterval * _sourceCount)];
    } else {
        //CCProgressFromTo用于以渐进的方式显示图片
        //持续0.5秒后，进度条从0%到100%
        CCProgressFromTo *ac = [CCProgressFromTo actionWithDuration:0.5 from:_progress.percentage to:100];
        
        //资源加载完毕时调用loadingComplete
        CCCallBlock *calblock = [CCCallBlock actionWithBlock:^{
            [self loadingComplete];
        }];
        
        id action = [CCSequence actions:ac, calblock, nil];
        
        [_progress runAction:action];
    }
}


//加载完毕延迟2秒切换到下一个场景
-(void) loadingComplete
{
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0f];
    
    CCCallBlock *call = [CCCallBlock actionWithBlock:^{
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[HelloWorldLayer scene]]];
    }];
    
    CCAction *action = [CCSequence actions:delay, call, nil];
    [self runAction:action];
}

-(void)dealloc
{
    NSLog(@"_progress dead");
    [_progress release];
    NSLog(@"PreloadLayer dead");
    [super dealloc];
}

@end
