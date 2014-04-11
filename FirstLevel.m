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
@synthesize level2;

@synthesize enemy1;
@synthesize healthLabel;

- (void)didLoadFromCCB
{
    [self setUserInteractionEnabled:TRUE];
    [hero.physicsBody setCollisionGroup:hero];
    [enemy1.physicsBody setCollisionGroup:enemy1];
    [physicsNodeFL setCollisionDelegate:self];
    
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
    
    /*set up enemy health */
    [enemy1 setHealth:30];
    
    
    ground = [[levelObjects children] objectAtIndex:1];
    CCSprite *background = [[levelObjects children] objectAtIndex:0];
    
    CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:background.boundingBox];
    [physicsNodeFL runAction:follow];
    
    [self schedule:@selector(enemyUpdate) interval:0.5];
    [self schedule:@selector(deathCheck) interval: 0.1];
    [hero.physicsBody setMass:10];
    [enemy1.physicsBody setMass:5];
    
    /*set up method to check position*/
    [self schedule:@selector(checkPosition) interval:0.2];
}

-(void)jump
{
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
    if (distance < 568 && distance > 150)
    {
        CGRect heroRect = hero.boundingBox;
        CGRect enemyRect = enemy1.boundingBox;
        
        CGPoint heroOrigin = heroRect.origin;
        CGPoint enemyOrigin = enemyRect.origin;
        if (heroOrigin.x > enemyOrigin.x)
        {
            [enemy1.physicsBody setVelocity:ccp(100, enemy1.physicsBody.velocity.y)];
            [enemy1 setFlipX:FALSE];
        }
        else
        {
            [enemy1.physicsBody setVelocity:ccp(-100, enemy1.physicsBody.velocity.y)];
            [enemy1 setFlipX:TRUE];
        }
        
        if (heroOrigin.y > enemyOrigin.y + 20)
        {
            [self enemyJump:enemy1];
        }
    }
    else
    {
        [enemy1.physicsBody setVelocity:ccp(0, enemy1.physicsBody.velocity.y)];
        
        CGPoint currentPos = hero.position;
        
        
        // loads the Bullet.ccb we have set up in Spritebuilder
        CCNode *bullet = [CCBReader load:@"Bullet"];
        [bullet.physicsBody setCollisionGroup:enemy1];
        
        // position the bullet at the hero
        bullet.position = enemy1.position;
        
        // add the bullet to the physicsNode of this scene (because it has physics enabled)
        [physicsNodeFL addChild:bullet];
        
        CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
        double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
        CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
        CGPoint force = ccpMult(unitDir, 500);
        [bullet.physicsBody applyForce:force];
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
    if ([hero position].y < -10 || [hero health] <= 0)
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
    
    /* check enemy deaths */
    if (enemy1.health <= 0)
    {
        [self unschedule:@selector(enemyUpdate)];
        [enemy1 removeFromParent];
    }
        
}

//touch sensing
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"in touchBegan");
    CGPoint currentPos = [touch locationInNode:physicsNodeFL];
    
    
    // loads the Bullet.ccb we have set up in Spritebuilder
    CCNode *bullet = [CCBReader load:@"Bullet"];
    [bullet.physicsBody setCollisionGroup:hero];
    
    // position the bullet at the hero
    bullet.position = hero.position;
    
    // add the bullet to the physicsNode of this scene (because it has physics enabled)
    [physicsNodeFL addChild:bullet];
    
    CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
    double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
    CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
    CGPoint force = ccpMult(unitDir, 500);
    [bullet.physicsBody applyForce:force];
}

- (void)bulletRemoved:(CCNode *)bullet {
    
    [bullet removeFromParent];
    NSLog(@"Boom!");
}
//Physics delegation
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    NSLog(@"Collision");
    
    float energy = [pair totalKineticEnergy];
    
    
    //if energy is large enough remove the bullet
    if (energy > 0.f)
    {
        if (nodeB == hero)
        {
            NSLog(@"Hit HERO!!!");
            [hero setHealth:hero.health - 6];
            [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
        }
        else if (nodeB == enemy1)
        {
            NSLog(@"Hit ENEMY");
            [enemy1 setHealth:enemy1.health - 6];
        }
        [self bulletRemoved:nodeA];
    }
}

- (void) checkPosition
{
    CCSprite *door = [[levelObjects children] objectAtIndex:2];
    CGRect dudeRect = hero.boundingBox;
    CGRect doorRect = door.boundingBox;
    if (CGRectIntersectsRect(dudeRect, doorRect))
    {
        [levelObjects removeFromParent];
        level2 = [CCBReader load:@"SecondLevelSchema"];
        [physicsNodeFL addChild:level2 z:0];
        [hero removeFromParent];
        [level2 addChild:hero];
        CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:level2.boundingBox];
        [physicsNodeFL runAction:follow];
        if (level2 == nil) {
            NSLog(@"you suck at this");
        }
    }
    
}

@end
