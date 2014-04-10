//
//  FirstLevel.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 3/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FirstLevel.h"

@implementation FirstLevel

@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize hero;
@synthesize heroLeft;
@synthesize heroRight;
@synthesize physicsNodeFL;
@synthesize ground;
@synthesize levelObjects;

@synthesize enemy1;
@synthesize healthLabel;

- (void)didLoadFromCCB
{
    
    NSLog(@"%d", heroRight.children.count);
    for (CCSprite *child in heroRight.children)
    {
        [heroRight removeChild:child];
        [hero addChild:child];
    }
        
    
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setDude:hero];
    [rightButton setDude:hero];
    
    /* set up health label */
    [hero setHealth:100];
    healthLabel = [[CCLabelTTF alloc] init];
    [healthLabel setAnchorPoint:ccp(0,0)];
    [healthLabel setPosition:ccp(10, 300)];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
    [self addChild:healthLabel];
    
    ground = [[levelObjects children] objectAtIndex:1];
    CCSprite *background = [[levelObjects children] objectAtIndex:0];
    
    CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:background.boundingBox];
    [physicsNodeFL runAction:follow];
    
    [self schedule:@selector(enemyUpdate) interval:0.5];
    [self schedule:@selector(deathCheck) interval: 0.1];
    [hero.physicsBody setMass:10];
    [enemy1.physicsBody setMass:5];
}

-(void)jump
{
    [hero setHealth:hero.health - 1];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
    NSLog(@"CALLED JUMP");
    /* make sure he can't jump too high */
    CGRect playerRect = hero.boundingBox;
    playerRect.size.height = 5;
    
    for (CCSprite *sf in [levelObjects children])
    {
        CGRect groundRect = sf.boundingBox;
        groundRect.origin.y += (groundRect.size.height - 5);
        groundRect.size.height = 60;
        if (CGRectIntersectsRect(playerRect, groundRect))
        {
            [hero.physicsBody applyForce:ccp(0, 50000)];
        }
    }
}

- (void) enemyUpdate
{
    int distance = [self distanceToEnemy:enemy1];
    if (distance < 568 && distance > 50)
    {
        CGRect heroRect = hero.boundingBox;
        CGRect enemyRect = enemy1.boundingBox;
        
        CGPoint heroOrigin = heroRect.origin;
        CGPoint enemyOrigin = enemyRect.origin;
        if (heroOrigin.x > enemyOrigin.x)
        {
            [enemy1.physicsBody setVelocity:ccp(100, enemy1.physicsBody.velocity.y)];
        }
        else
        {
            [enemy1.physicsBody setVelocity:ccp(-100, enemy1.physicsBody.velocity.y)];
        }
        
        if (heroOrigin.y > enemyOrigin.y)
        {
            [self enemyJump:enemy1];
        }
    }
    else
    {
        [enemy1.physicsBody setVelocity:ccp(0, enemy1.physicsBody.velocity.y)];
    }
    
}

- (int) distanceToEnemy:(CCSprite *)enemy
{
    CGRect heroRect = hero.boundingBox;
    CGRect enemyRect = enemy.boundingBox;
    
    CGPoint p1 = heroRect.origin;
    CGPoint p2 = enemyRect.origin;
    
    double temp1 = pow(p1.x - p2.x, 2);
    double temp2 = pow(p1.y - p2.y , 2);
    double distance = sqrt(temp1 + temp2);
    return (int)distance;
}

- (void) enemyJump:(CCSprite *)enemy
{
    /* make sure he can't jump too high */
    CGRect enemyRect = enemy.boundingBox;
    enemyRect.size.height = 5;
    
    for (CCSprite *sf in [levelObjects children])
    {
        CGRect groundRect = sf.boundingBox;
        groundRect.origin.y += (groundRect.size.height - 5);
        groundRect.size.height = 60;
        if (CGRectIntersectsRect(enemyRect, groundRect))
        {
            [enemy.physicsBody applyForce:ccp(0, 10000)];
        }
    }}

- (void) deathCheck
{
    if ([hero position].y < -10 || [hero health] < 0)
    {
        
        NSLog(@"Dead");
        CCLabelTTF *deadLabel = [[CCLabelTTF alloc] init];
        [deadLabel setAnchorPoint:ccp(0,0)];
        [deadLabel setPosition:ccp(150, 150)];
        [deadLabel setString:@"DEAD"];
        [self addChild:deadLabel];
        
        
        
        
        CCScene *mainScreen = [CCBReader loadAsScene:@"MainScene"];
        [[CCDirector sharedDirector] replaceScene:mainScreen];
    }
        
}
@end
