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
@synthesize dude;
@synthesize physicsNodeFL;
@synthesize ground;
@synthesize levelObjects;

@synthesize enemy1;
@synthesize healthLabel;

- (void)didLoadFromCCB
{
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setDude:dude];
    [rightButton setDude:dude];
    
    /* set up health label */
    [dude setHealth:100];
    healthLabel = [[CCLabelTTF alloc] init];
    [healthLabel setAnchorPoint:ccp(0,0)];
    [healthLabel setPosition:ccp(10, 300)];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[dude health]]];
    [self addChild:healthLabel];
    
    
    //[physicsNodeFL setGravity:ccp(0, -250)];
    ground = [[levelObjects children] objectAtIndex:1];
    CCSprite *background = [[levelObjects children] objectAtIndex:0];
    
    CCActionFollow *follow = [CCActionFollow actionWithTarget:dude worldBoundary:background.boundingBox];
    [physicsNodeFL runAction:follow];
    
    //[self schedule:@selector(enemyUpdate) interval:0.5];
    [self schedule:@selector(deathCheck) interval: 0.1];
    NSLog(@"%f", [[dude physicsBody] mass]);
    NSLog(@"%f", [[enemy1 physicsBody] mass]);
}

-(void)jump
{
    [dude setHealth:dude.health - 1];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[dude health]]];
    NSLog(@"CALLED JUMP");
    /* make sure he can't jump too high */
    CGRect playerRect = dude.boundingBox;
    playerRect.size.height = 5;
    
    for (CCSprite *sf in [levelObjects children])
    {
        CGRect groundRect = sf.boundingBox;
        groundRect.origin.y += (groundRect.size.height - 5);
        groundRect.size.height = 60;
        if (CGRectIntersectsRect(playerRect, groundRect))
        {
            [dude.physicsBody applyForce:ccp(0, 1000000)];
        }
    }
}

- (void) enemyUpdate
{
    int distance = [self distanceToEnemy:enemy1];
    if (distance < 568 && distance > 50)
    {
        CGRect heroRect = dude.boundingBox;
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
    CGRect heroRect = dude.boundingBox;
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
    if ([dude position].y < -10 || [dude health] < 0)
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
