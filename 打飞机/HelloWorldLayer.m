//
//  HelloWorldLayer.m
//  打飞机
//
//  Created by jewelz on 14-9-27.
//  Copyright yangtzeU 2014年. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "MenuLayer.h"
#import "SimpleAudioEngine.h"
#import "CCParallaxNode-Extras.h"
#import "FKSprite.h"
#define defaultCapacity 20

@interface HelloWorldLayer ()
{
    FKSprite *bossSprite;
    CCArray *bossBulletArray;
    BOOL isStartBoss, isMoveBoss, isShootBoss, isTemp,isStartSoldier,isSoldierShoot;
    //敌机数组
    CCArray *enemyPlaneArray;
    
    //子弹数组
    CCArray *bulletArray;
    
    //游戏帧计数器
    NSInteger count;
}

@end

@implementation HelloWorldLayer

//精灵表单tag
static NSInteger kTagBatchNode = 1;



+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(id) init
{
    if( (self=[super init]) ) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        sWidth = winSize.width;
        sHeight = winSize.height;
        
        batchNode =  [[CCSpriteBatchNode alloc] initWithFile:@"airfightSheet.png" capacity:defaultCapacity];
        batchNode.position = CGPointZero;
        [self addChild:batchNode z:0 tag:kTagBatchNode];
    }
	return self;
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    //播放背景音乐
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"s3.wav" loop:YES];
    
    //玩家飞机
     plantSprite = [[CCSprite alloc] initWithSpriteFrameName:@"plane0.png"];
    plantSprite.position = ccp(sWidth/2, plantSprite.contentSize.height-20);
    [batchNode addChild:plantSprite];
    //播放飞机动画
    CCAnimation *planeFly = [self getAnimationByName:@"plane" delay:0.08 animNum:2];
    id repeate = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:planeFly]];
    [plantSprite runAction:repeate];
    
    
    //激活层的touch事件的方式
    [[[CCDirector sharedDirector] touchDispatcher]addTargetedDelegate:self priority:0 swallowsTouches:YES];
    //retainCount=2
   // NSLog(@"onEnterTransitionDidFinish5：%d",self.retainCount);
    [self release];
    
    //初始化CCParallaxNode，添加到当前层中
    bgNode = [[CCParallaxNode alloc] init];
    [self addChild:bgNode z:-1];
    //设置CCParallaxNode移动时背景与其比率
    CGPoint ratio = ccp(1.0, 1.0);
   
    NSString *bgname;
    if (sHeight == 480) {
        bgname = @"bg1.png";
    } else {
        bgname = @"bg2.png";
    }
    CCSprite *bgSprite1 = [[CCSprite alloc] initWithFile:bgname];
    //用于解决拼接的背景形成间隙的问题
    [[bgSprite1 texture] setAliasTexParameters];
    bgSprite1.anchorPoint = ccp(0, 0);
    [bgNode addChild:bgSprite1 z:1 parallaxRatio:ratio positionOffset:ccp(0, 0)];
    [bgSprite1 release];
    
    CCSprite *bgSprite2 = [[CCSprite alloc] initWithFile:@"bg1.png"];
    //
    [[bgSprite2 texture] setAliasTexParameters];
    bgSprite2.anchorPoint = ccp(0, 0);
    //设置positionOffset 减去1像素可以消除背景拼接的间隙
    [bgNode addChild:bgSprite2 z:1 parallaxRatio:ratio positionOffset:ccp(0, sHeight-1)];
    [bgSprite2 release];
    
    //添加开始连续滚动背景的代码
    const int MAX_WIDTH = sWidth;
    const int MAX_HEIGHT = sHeight * 100;
    CCSprite *hiddenPlane = [[CCSprite alloc] initWithSpriteFrameName:@"plane0.png"];
    
    hiddenPlane.visible = NO;
    hiddenPlane.position = ccp(sWidth/2, sHeight/2);
    [batchNode addChild:hiddenPlane z:-4 tag:1024];
    
    CCMoveBy *moveBy = [[CCMoveBy alloc] initWithDuration:300.0f position:ccp(0, MAX_HEIGHT)];
    [hiddenPlane runAction:moveBy];
    [moveBy release];
    
    //背景开始跟随隐形飞机滚动
    CCFollow *follow = [[CCFollow alloc] initWithTarget:hiddenPlane worldBoundary:CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT)];
    [bgNode runAction:follow];
    [follow release];
    
    [hiddenPlane release];
    
    enemyPlaneArray = [[CCArray alloc] init];
    bulletArray = [[CCArray alloc] init];
    
    //初始化记分标签
    scoreLabel = [CCLabelTTF labelWithString:@"00" fontName:@"Arial" fontSize:20];
    scoreLabel.position = ccp(sWidth*0.1, sHeight-20);
    [self addChild:scoreLabel];
    scoreValue = 0;
    
    //游戏主循环，每帧都调用update:方法
    [self scheduleUpdate];
   // [self release];
    //NSLog(@"onEnterTransitionDidFinish6：%d",self.retainCount);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    //把touch坐标转换成局部node的坐标
    CGPoint touchLoaction = [self convertTouchToNodeSpace:touch];
    //把旧坐标也转换成局部node的坐标
    CGPoint oldTouchLoaction = [touch previousLocationInView:touch.view];
    oldTouchLoaction = [[CCDirector sharedDirector] convertToGL:oldTouchLoaction];
    
    //计算新点与旧点的差值
    CGPoint translation = ccpSub(touchLoaction, oldTouchLoaction);
    //ccpAdd让两坐标相加
    CGPoint newPoint = ccpAdd(plantSprite.position, translation);
    
    if (!isStartSoldier) {
        //给飞机设置新的坐标
        plantSprite.position = newPoint;
    } else {
        //给士兵设置新的坐标
        newPoint = ccpAdd(soldierSprite.position, translation);
        soldierSprite.position = newPoint;
        
        isSoldierShoot = YES;
    }
    
//    NSLog(@"1x:%f,1Y:%f", touchLoaction.x, touchLoaction.y);
//    NSLog(@"2x:%f,2Y:%f", newPoint.x, newPoint.y);
}

#pragma mark - 士兵方法
#pragma mark 士兵出动
- (void) startSoldierSpriter
{
    if (isStartSoldier) {
    
        soldierSprite = [[CCSprite alloc] initWithSpriteFrameName:@"solider.png"];
        soldierSprite.position = plantSprite.position;
        [batchNode addChild:soldierSprite];
        
        CCDelayTime *delay = [[CCDelayTime alloc] initWithDuration:2.0f];
        id block = [[CCCallBlock alloc]initWithBlock:^{
            [[SimpleAudioEngine sharedEngine]playEffect:@"bullet1.mp3"];
        }];
        
        id action = [CCSequence actions:delay,block, nil];
          CCRepeatForever *repeat = [[CCRepeatForever alloc] initWithAction:action];
        [delay release];
        [block release];
        [soldierSprite runAction:repeat];
        [repeat release];
    }

}



#pragma mark - 子弹方法
#pragma mark 更新子弹
- (void) updateShooting:(ccTime)delta
{
    CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
    
    CCSprite *sprite;
    if (isSoldierShoot && isSoldierShoot) {
         sprite = soldierSprite;
        
    } else
       sprite = plantSprite;
    
    CGPoint pos = sprite.position;
    //控制count为8的倍数时发射一颗子弹
    if (count % 8 == 0) {
        
        CCSprite *bulletSprite = [[CCSprite alloc] initWithSpriteFrameName:@"bullet.png"];
        
        CGPoint bulletPos = ccp(pos.x, pos.y+sprite.contentSize.height/2+bulletSprite.contentSize.height);
        bulletSprite.position = bulletPos;
        
        CCMoveBy *moveBy = [[CCMoveBy alloc] initWithDuration:0.4f position:ccp(0, sHeight-bulletPos.y)];
        [bulletSprite runAction:moveBy];
        [moveBy release];
        
        [batch addChild:bulletSprite z:4];
        [bulletArray addObject:bulletSprite];
        
        [bulletSprite release];
    }
}

#pragma mark 移除子弹
- (void) removeBulletSprite:(ccTime)delta
{
    CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
    CCSprite *bulletSprite;
    
    //遍历所以的子弹精灵
    CCARRAY_FOREACH(bulletArray, bulletSprite) {
        
        //如果子弹超出屏幕外，则移除
        if (bulletSprite.position.y >= sHeight-20) {
            
            //从精灵表单中删除
            [batch removeChild:bulletSprite cleanup:YES];
            
            //从子弹数组中删除
            [bulletArray removeObject:bulletSprite];
        }
    }

}

#pragma mark - 敌机方法
#pragma mark 添加敌机
- (void) updateEnemySprite:(ccTime)delta
{
    //随机设置敌机X坐标
    int randX = arc4random() % (sWidth -40) + 20;
    //敌机俯冲时间
    float duration = arc4random() % 2 + 2;
    
    if (count % 30 == 0 && !isStartBoss) {
        FKSprite *enemyPlaneSprite;
        //
        int rand = arc4random() % 2;
        
        switch (rand) {
            case 0:
                enemyPlaneSprite = [[FKSprite alloc] initWithSpriteFrameName:@"e0.png"];
                enemyPlaneSprite.position = ccp(randX, sHeight+enemyPlaneSprite.contentSize.height);
                enemyPlaneSprite.name = @"e0.png";
                enemyPlaneSprite.lifevalue = 1;
                break;
            case 1:
                enemyPlaneSprite = [[FKSprite alloc] initWithSpriteFrameName:@"e2.png"];
                enemyPlaneSprite.position = ccp(randX, sHeight+enemyPlaneSprite.contentSize.height);
                enemyPlaneSprite.name = @"e2.png";
                enemyPlaneSprite.lifevalue = 1;
                break;
        }
        
        CCMoveBy *moveBy = [[CCMoveBy alloc] initWithDuration:duration position:ccp(0, -enemyPlaneSprite.position.y-enemyPlaneSprite.contentSize.height)];
        [enemyPlaneSprite runAction:moveBy];
        [moveBy release];
        
        //将敌机精灵添加到数组中
        [enemyPlaneArray addObject:enemyPlaneSprite];
        
        //获取精灵表单
        CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
        //将敌机精灵添加到精灵表单中
         [batch addChild:enemyPlaneSprite z:4];
        
        [enemyPlaneSprite release];
        
    } else {
        
        if (count % 200 == 0 && !isStartBoss) {
            
            FKSprite *enemyPlaneSprite;
            enemyPlaneSprite = [[FKSprite alloc] initWithSpriteFrameName:@"e1.png"];
            enemyPlaneSprite.position = ccp(randX, sHeight+enemyPlaneSprite.contentSize.height);
            enemyPlaneSprite.name = @"e1.png";
            enemyPlaneSprite.lifevalue = 10;
            CCMoveBy *moveBy = [[CCMoveBy alloc] initWithDuration:duration position:ccp(0, -enemyPlaneSprite.position.y-enemyPlaneSprite.contentSize.height)];
            [enemyPlaneSprite runAction:moveBy];
            [moveBy release];
            
            [enemyPlaneArray addObject:enemyPlaneSprite];
            //获取精灵表单
            CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
            [batch addChild:enemyPlaneSprite z:4];
            
            //添加进度条精灵
            CCSprite *barSprite  = [[CCSprite alloc] initWithFile:@"planeHP.png"];
            CCProgressTimer *enemyPlaneHP = [[CCProgressTimer alloc] initWithSprite:barSprite];
            enemyPlaneHP.percentage = 0.0f;
            enemyPlaneHP.scale = 0.15;
            enemyPlaneHP.midpoint = ccp(0, 0.5);
            enemyPlaneHP.barChangeRate = ccp(1, 0);
            enemyPlaneHP.type = kCCProgressTimerTypeBar;
            enemyPlaneHP.percentage = 100;
            
            CGPoint pos = enemyPlaneSprite.position;
            enemyPlaneHP.position = ccp(pos.x, pos.y+sWidth*0.1f);
            [self addChild:enemyPlaneHP];
            
            CCMoveBy *moveBy2 = [[CCMoveBy alloc] initWithDuration:duration position:ccp(0, -enemyPlaneSprite.position.y-enemyPlaneSprite.contentSize.height)];
            [enemyPlaneHP runAction:moveBy2];
            [moveBy2 release];
            
            enemyPlaneSprite.enemyPlaneHP = enemyPlaneHP;
            enemyPlaneSprite.HPInterval = 100.0f / (float)enemyPlaneSprite.lifevalue;
            
            [enemyPlaneHP release];
            
            [barSprite release];
            [enemyPlaneSprite release];
        }
        
    }
    
    
    
}

#pragma mark 敌机离开屏幕删除
- (void) removeEnemySprite:(ccTime)delta
{
    CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
    CCSprite *enemySprite;
    
    //遍历所以的敌机精灵
    CCARRAY_FOREACH(enemyPlaneArray, enemySprite) {
        
        //如果敌机超出屏幕外，则移除敌机
        if (enemySprite.position.y <= -enemySprite.contentSize.height) {
            
            //从精灵表单中删除
            [batch removeChild:enemySprite cleanup:YES];
            
            //从敌机数组中删除
            [enemyPlaneArray removeObject:enemySprite];
        }
    }
}

#pragma mark - 敌机方法
#pragma mark Boss出动
- (void) startBossSprite:(ccTime)delta
{
    if (isStartBoss && !isMoveBoss && !isTemp) {
        isTemp = YES;
        
        CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
        FKSprite *enemy;
        CCARRAY_FOREACH(enemyPlaneArray, enemy)
        {
            [batch removeChild:enemy cleanup:YES];
        }
        [enemyPlaneArray removeAllObjects];
        
        bossSprite = [[FKSprite alloc] initWithSpriteFrameName:@"e-10.png"];
        bossSprite.position = ccp(sWidth/2, sHeight+bossSprite.contentSize.height);
        bossSprite.name = @"boss";
        bossSprite.lifevalue = 600;
        
        CCSprite *barSprite = [[CCSprite alloc] initWithFile:@"planeHP.png"];
        CCProgressTimer *bossHP = [[CCProgressTimer alloc] initWithSprite:barSprite];
        [barSprite release];
        [bossHP setPercentage:0.0f];
        bossHP.scale = 0.25;
        bossHP.midpoint = ccp(0, 0.5);
        bossHP.type = kCCProgressTimerTypeBar;
        bossHP.percentage = 100;
        bossHP.barChangeRate = ccp(1, 0);
        bossHP.position = ccp(sWidth/2, sHeight/2);
        bossHP.visible = NO;
        [self addChild:bossHP];
        bossSprite.enemyPlaneHP = bossHP;
        [bossHP release];
        
        bossSprite.HPInterval = 100.0 / (float)bossSprite.lifevalue;
        
        [enemyPlaneArray addObject:bossSprite];
        [batch addChild:bossSprite z:4];
        
        CCMoveTo *moveTo = [[CCMoveTo alloc] initWithDuration:2.0f position:ccp(sWidth/2, sHeight-bossSprite.contentSize.height-20)];
        CCCallBlock *block = [[CCCallBlock alloc] initWithBlock:^{
            isMoveBoss = YES;
        }];
        id action = [CCSequence actions:moveTo, block, nil];
        [moveTo release];
        [block release];
        
        [bossSprite runAction:action];
        
        bossBulletArray = [[CCArray alloc]init];
        
    }
}

#pragma mark Boss移动
- (void) moveBossSprite:(ccTime)delta
{
    if (isMoveBoss && !isShootBoss) {
        isShootBoss = YES;
        
        //
        CCMoveTo *moveLeft = [[CCMoveTo alloc] initWithDuration:3 position:ccp(sWidth-bossSprite.contentSize.width/2, sHeight-bossSprite.contentSize.height-20)];
        
        CCMoveTo *moveRight = [[CCMoveTo alloc] initWithDuration:3 position:ccp(0+bossSprite.contentSize.width/2, sHeight-bossSprite.contentSize.height-20)];
        
        CCDelayTime *delay = [[CCDelayTime alloc] initWithDuration:2];
        
        id action = [CCSequence actions:delay,moveLeft,moveRight, nil];
        
        CCRepeatForever *repate = [[CCRepeatForever alloc] initWithAction:action];
        [bossSprite runAction:repate];
        
        [moveLeft release];
        [moveRight release];
        [delay release];
        [repate release];
        
    }
}

#pragma mark Boss更新子弹
- (void) updateBossShooting:(ccTime)delta
{
    if (isShootBoss) {
        
        CGPoint pots = bossSprite.position;
        
        //血条位置
        bossSprite.enemyPlaneHP.position = ccp(pots.x, pots.y+bossSprite.contentSize.height/2);
        if (!bossSprite.enemyPlaneHP.visible) {
            bossSprite.enemyPlaneHP.visible = YES;
        }
        
        CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
        
        if (count % 80 == 0) {
            CCSprite *bossBullet = [[CCSprite alloc] initWithSpriteFrameName:@"bullet1.png"];
            
            CGPoint bulletPos = ccp(pots.x, pots.y-bossSprite.contentSize.height/2);
            bossBullet.position = bulletPos;
            bossBullet.visible = YES;
            
            id moveBy = [[CCMoveBy alloc] initWithDuration:2.0f position:ccp(0, -sHeight-bulletPos.y)];
            [bossBullet runAction:moveBy];
            [moveBy release];
            
            [bossBulletArray addObject:bossBullet];
            [batch addChild:bossBullet z:4];
            
            [bossBullet release];
        }
        
    }
}

#pragma mark - 其他
#pragma mark 碰撞检验
- (void) collisionDetection:(ccTime)delta
{
    CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
    CCSprite *bulletSprite;
    FKSprite *enemPlaneSprite;
    BOOL isPlaneDead;
    //遍历敌机数组
    CCARRAY_FOREACH(enemyPlaneArray, enemPlaneSprite)
    {
        [enemPlaneSprite retain];
        if (!isStartSoldier && !isSoldierShoot) {
            
            if (CGRectIntersectsRect(plantSprite.boundingBox, enemPlaneSprite.boundingBox)) {
                //播放爆炸动画
                [self bomAnimation:@"blast" position:enemPlaneSprite.position];
                
                //士兵出动
                isStartSoldier = YES;
                isSoldierShoot = YES;
                [self startSoldierSpriter];
                isPlaneDead = YES;
                
                //移除敌机精灵
                [enemyPlaneArray removeObject:enemPlaneSprite];
                [batch removeChild:enemPlaneSprite cleanup:YES];
                [plantSprite stopAllActions];
                
                //移除玩家精灵
                [batchNode removeChild:plantSprite cleanup:YES];
               
            }
           
        } else{
           
            if (CGRectIntersectsRect(soldierSprite.boundingBox, enemPlaneSprite.boundingBox)) {
                
                //播放爆炸动画
                [self bomAnimation:@"blast" position:enemPlaneSprite.position];
                //移除敌机精灵
                [enemyPlaneArray removeObject:enemPlaneSprite];
                [batch removeChild:enemPlaneSprite cleanup:YES];
                
                [soldierSprite stopAllActions];
                
                //移除玩家精灵
                [batchNode removeChild:soldierSprite cleanup:YES];
                
                [self gameOver:@"GAME OVER"];
            }
        }
            //遍历子弹数组
        CCARRAY_FOREACH(bulletArray, bulletSprite)
        {
            [bulletSprite retain];
            //如果敌机与子弹相撞
            if (CGRectIntersectsRect(enemPlaneSprite.boundingBox, bulletSprite.boundingBox)) {
                //播放爆炸音效
                [[SimpleAudioEngine sharedEngine] playEffect:@"bullet.mp3"];
                //移除子弹精灵
                [batch removeChild:bulletSprite cleanup:YES];
                [bulletArray removeObject:bulletSprite];
                
                //敌机生命值减1
                enemPlaneSprite.lifevalue --;
                //血条减少
                if (enemPlaneSprite.enemyPlaneHP != nil) {
                    enemPlaneSprite.enemyPlaneHP.percentage = enemPlaneSprite.HPInterval*enemPlaneSprite.lifevalue;
                }
                
                //判断敌机生命值
               if (enemPlaneSprite.lifevalue <= 0) {
                    if ([enemPlaneSprite.name isEqualToString:@"boss"]) {
                        
                        [self bomAnimation:@"bomb" position:enemPlaneSprite.position];
                   
                        [[SimpleAudioEngine sharedEngine] playEffect:@"b1.mp3"];
                   
                        scoreValue += 5000;
                   
                        [self gameOver:@"YOU WIN"];
                    } else {
                        
                        //播放爆炸动画
                        [self bomAnimation:@"blast" position:enemPlaneSprite.position];
                        //播放爆炸音效
                        [[SimpleAudioEngine sharedEngine] playEffect:@"b0.mp3"];
                        
                        //移除敌机精灵
                        [batch removeChild:enemPlaneSprite cleanup:YES];
                        [enemyPlaneArray removeObject:enemPlaneSprite];
                        
                        if ([enemPlaneSprite.name isEqualToString:@"e1"]) {
                            scoreValue += 500;
                        } else
                            scoreValue += 100;
                        
                        if (scoreValue >= 5000) {
                            isStartBoss = YES;
                            break;
                        }
                        
                    } //else end
 
                } //判断敌机生命值  if end
                
                [bulletSprite release];
                break;
            }   //如果敌机与子弹相撞 if end
            
        } //遍历子弹数组 if end
        
        //判断boss的子弹和玩家的碰撞
        if (isShootBoss) {
            CCSprite *bossbulletSprite;
            CCARRAY_FOREACH(bossBulletArray, bossbulletSprite)
            {
                [bossbulletSprite retain];
            
                if (!isPlaneDead) {
                    
                    if (CGRectIntersectsRect(plantSprite.boundingBox, bossbulletSprite.boundingBox)) {
                        [plantSprite stopAllActions];
                        
                        [batch removeChild:plantSprite cleanup:YES];
                        
                        [[SimpleAudioEngine sharedEngine] playEffect:@"b0.mp3"];
                        
                        [self bomAnimation:@"blast" position:soldierSprite.position];
                        
                        
                        [self gameOver:@"GAME OVER"];
                    }
                    
                } else {
                    if (CGRectIntersectsRect(soldierSprite.boundingBox, bossbulletSprite.boundingBox)) {
                            [soldierSprite stopAllActions];
                            
                            [batch removeChild:soldierSprite cleanup:YES];
                            
                            [[SimpleAudioEngine sharedEngine] playEffect:@"b0.mp3"];
                            
                            [self bomAnimation:@"blast" position:soldierSprite.position];
                            
                            
                            [self gameOver:@"GAME OVER"];
                        }
                
                }
                
                [bossbulletSprite release];
            }
            
        } //判断boss的子弹和玩家飞机的碰撞 if end
        
        [enemPlaneSprite release];
        //[sprite release];
    
        
    } //遍历敌机数组 if end
    
    
}

#pragma mark 爆炸动画
- (void) bomAnimation:(NSString *)name position:(CGPoint)position
{
    NSString *bomName = [NSString stringWithFormat:@"%@0.png",name];
    CCSpriteBatchNode *batch = (CCSpriteBatchNode *)[self getChildByTag:kTagBatchNode];
    NSMutableArray *animateArray = [[NSMutableArray alloc] init];
    NSString *spriteName;
    
    CCSprite *blastSprite = [[CCSprite alloc] initWithSpriteFrameName:bomName];
    blastSprite.position = position;
    [batch addChild:blastSprite z:4];
    for (int i=0; i<4; i++) {
        spriteName = [[NSString alloc] initWithFormat:@"%@%d.png",name,i];
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:spriteName];
        [animateArray addObject:frame];
    }
    
    CCAnimation *animation = [[CCAnimation alloc] initWithSpriteFrames:animateArray delay:0.08f];
    
    CCAnimate *bomAnimate = [[CCAnimate alloc] initWithAnimation:animation];
    
    CCCallBlock *remove = [[CCCallBlock alloc] initWithBlock:^{
        [batch removeChild:blastSprite cleanup:YES];
    }];
    id action = [CCSequence actions:bomAnimate, remove, nil];
    [blastSprite runAction:action];
    
    [spriteName release];
    [animateArray release];
    [animation release];
    [bomAnimate release];
    [remove release];
    [blastSprite release];
    
    
}

#pragma mark 游戏结束
- (void) updateHUD:(ccTime)delta
{
    NSString *score = [[NSString alloc]initWithFormat:@"%d",scoreValue];
    [scoreLabel setString:score];
    [score release];
}

#pragma mark 游戏结束
- (void) gameOver:(NSString *)labelString
{
    NSLog(@"gameOver");
    //停止所有动作
    [self unscheduleUpdate];
    
    //CCMenuItemFont *gameOver = [CCMenuItemFont itemWithString:labelString];
    
    CCLabelTTF *gameOverLabel = [[CCLabelTTF alloc ]initWithString:labelString fontName:@"Marker Felt" fontSize:40];
    gameOverLabel.position = ccp(sWidth/2, sHeight*0.55);
    [self addChild:gameOverLabel];
    
    CCMenuItemFont *gameItem = [CCMenuItemFont itemWithString:@"Restart" target:self selector:@selector(onRestartGame:)];
    gameItem.position = ccp(sWidth/2, sHeight*0.45);
    
    CCMenuItem *menu = [CCMenu menuWithItems:gameItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    NSLog(@"gameOver：%d",self.retainCount);
}

- (void) onRestartGame:(id)sender
{
    CCDelayTime *delay = [[CCDelayTime alloc]initWithDuration:1.0f];
    CCCallBlock *block = [[CCCallBlock alloc] initWithBlock:^{
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MenuLayer scene]]];
    }];
    
    CCAction *action = [CCSequence actions:delay, block, nil];
    [block release];
    [delay release];
    [[SimpleAudioEngine sharedEngine]stopBackgroundMusic];
    [self runAction:action];
    //执行action之后 retainCount＝0
   
}


#pragma mark 更新背景图片
- (void) updateBackground:(ccTime)delta
{
    CCSprite *sprite;
    int index = 0;
    CCARRAY_FOREACH([bgNode children], sprite)
    {
        CGPoint pt = [bgNode convertToWorldSpace:sprite.position];
        if (pt.y <= -sprite.contentSize.height) {
            [bgNode incrementOffset:ccp(0, (sprite.contentSize.height-1)*2.0f) forChild:sprite];
        }
        index ++;
    }
}


#pragma mark 播放动画的方法
- (CCAnimation *) getAnimationByName:(NSString *)animName delay:(float)delay animNum:(int)num
{
    NSMutableArray *animateFrames = [[NSMutableArray alloc] initWithCapacity:num];
    
    for (int i=0; i<num; i++) {
        NSString *frameName = [[NSString alloc] initWithFormat:@"%@%d.png", animName, i];
        NSLog(@"%@",frameName);
        //根据图片名获取动画帧
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        [animateFrames addObject:frame];
        [frameName release];
    }
    
    //通过精灵帧创建动画
    return [CCAnimation animationWithSpriteFrames:animateFrames delay:delay];

    [animateFrames release];
}

#pragma mark 主循环
- (void) update:(ccTime)delta
{
    count ++;
    [self updateBackground:delta];
    [self updateEnemySprite:delta];
    [self removeEnemySprite:delta];
    [self updateShooting:delta];
    [self removeBulletSprite:delta];
    [self collisionDetection:delta];
    [self updateHUD:delta];
    [self startBossSprite:delta];
    [self moveBossSprite:delta];
    [self updateBossShooting:delta];
    //[self startSoldierSpriter:delta];
}


- (void) dealloc
{
     NSLog(@"enemyPlaneArray dead");
    [enemyPlaneArray release];
    
    NSLog(@"bulletArray dead");
    [bulletArray release];
    
    [bossSprite release];
    [bossBulletArray release];
    
    NSLog(@"plantSprite dead");
    [plantSprite release];
    
    [soldierSprite release];

    
    NSLog(@"batchNode dead");
    [batchNode release];
    
     NSLog(@"bgNode dead");
    [bgNode release];
    
    NSLog(@"HelloWorldLayer dead");
	[super dealloc];
}


@end
