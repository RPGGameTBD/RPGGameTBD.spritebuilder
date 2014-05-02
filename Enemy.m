//
//  Enemy1.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"
#import "MainScene.h"
#import "CCAnimation.h"

@implementation Enemy

- (int) distanceToHero
{
    MainScene *scene = [MainScene scene];
    CGRect heroRect = scene.hero.boundingBox;
    CGRect enemyRect = self.boundingBox;
    
    CGPoint p1 = heroRect.origin;
    CGPoint p2 = enemyRect.origin;
    
    double temp1 = pow(p1.x - p2.x, 2);
    double temp2 = pow(p1.y - p2.y , 2);
    double distance = sqrt(temp1 + temp2);
    return (int)distance;
}

- (void) update
{
    NSLog(@"Unimplemented for Superclass");
    /* stand still */
}

@synthesize health;
@synthesize enemyHealthLabel;
@synthesize currDeathFrame;
@synthesize dead;

@end

@implementation Cultist
{
    CGRect zone;
}

@synthesize timesUpdated;
@synthesize shootspeed;

- (void)didLoadFromCCB
{
    [self setDead:NO];
    [self setCurrDeathFrame:0];
    [self setTimesUpdated:0];
    [self setHealth:40];
    [self.physicsBody setMass:1];
    [self setShootspeed:400];
}

- (void) deathAnim
{
    //Create an animation from the set of frames you created earlier
    NSMutableArray *frames = [[MainScene scene] deathAnimationsFrames];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames: frames delay:0.02];
    
    //Create an action with the animation that can then be assigned to a sprite
    CCActionAnimate *animationAction = [CCActionAnimate actionWithAnimation:animation];
    
    [self setScale:0.1];
    [self runAction:animationAction];
}

-(void) destroyEnemy
{
    [[[MainScene scene] enemies] removeObject:self];
    [self removeFromParent];}

- (void) update
{
    MainScene *scene = [MainScene scene];
    self.timesUpdated++;
    /* do a death check */
    if ([self health] < 0 && ![self dead])
    {
        [self setDead:YES];
        [self scheduleOnce:@selector(destroyEnemy) delay:1];
        [self deathAnim];
        [self.enemyHealthLabel removeFromParent];
        scene.score++;
        return;
    }
    zone = CGRectInset(self.boundingBox, -500, -100);
    
    
    int distance = self.distanceToHero;
    if (CGRectIntersectsRect(zone, scene.hero.boundingBox)) {

        if (distance < 568 && distance > 150)
        {
            CGRect heroRect = scene.hero.boundingBox;
            CGRect enemyRect = self.boundingBox;
            
            CGPoint heroOrigin = heroRect.origin;
            CGPoint enemyOrigin = enemyRect.origin;
            if (heroOrigin.x > enemyOrigin.x)
            {
                [self.physicsBody setVelocity:ccp(100, self.physicsBody.velocity.y)];
                [self setFlipX:FALSE];
            }
            else
            {
                [self.physicsBody setVelocity:ccp(-100, self.physicsBody.velocity.y)];
                [self setFlipX:TRUE];
            }
            
            if (heroOrigin.y > enemyOrigin.y + 40 && enemyOrigin.y < 50)
            {
                [self.physicsBody applyForce:ccp(0, 5000)];
            }
        }
        else
        {
            [self.physicsBody setVelocity:ccp(0, self.physicsBody.velocity.y)];
            /* shoot */
            if (timesUpdated > shootspeed)
            {
                timesUpdated = 0;
                CGPoint currentPos = ccp(scene.hero.position.x + scene.hero.boundingBox.size.width/2,
                                         scene.hero.position.y + scene.hero.boundingBox.size.height/2);
                CCNode *bullet = [CCBReader load:@"Bullet"];
                [bullet.physicsBody setCollisionGroup:self];
                [self.physicsBody setCollisionGroup:self];
                bullet.position = ccp(self.position.x + self.boundingBox.size.width/2, self.position.y + self.boundingBox.size.height/2);
            
                [scene.levelObjects addChild:bullet];
            
                CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
                double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
                CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
                CGPoint force = ccpMult(unitDir, 1000);
                [bullet.physicsBody applyForce:force];
            }
        }
    }
    else
    {
        [self.physicsBody setVelocity:ccp( 0, self.physicsBody.velocity.y)];
    }
}

@end

@implementation BigCultist

@synthesize timesUpdated;
@synthesize shootspeed;

- (void)didLoadFromCCB
{
    [self setTimesUpdated:0];
    [self setHealth:200];
    [self.physicsBody setMass:1];
    [self setShootspeed:70];
}

- (void) update
{
    self.timesUpdated++;
    /* do a death check */
    if ([self health] < 0)
    {
        [self.enemyHealthLabel removeFromParent];
        [self removeFromParent];
        return;
    }
    
    MainScene *scene = [MainScene scene];
    int distance = self.distanceToHero;

    if (distance < 568 && distance > 150)
    {
        CGRect heroRect = scene.hero.boundingBox;
        CGRect enemyRect = self.boundingBox;
        
        CGPoint heroOrigin = heroRect.origin;
        CGPoint enemyOrigin = enemyRect.origin;
        if (heroOrigin.x > enemyOrigin.x)
        {
            [self.physicsBody setVelocity:ccp(100, self.physicsBody.velocity.y)];
            [self setFlipX:FALSE];
        }
        else
        {
            [self.physicsBody setVelocity:ccp(-100, self.physicsBody.velocity.y)];
            [self setFlipX:TRUE];
        }
    }
    else
    {
        [self.physicsBody setVelocity:ccp(0, self.physicsBody.velocity.y)];
        /* shoot */
        if (timesUpdated > shootspeed)
        {
            timesUpdated = 0;
            CGPoint currentPos = ccp(scene.hero.position.x + scene.hero.boundingBox.size.width/2,
                                     scene.hero.position.y + scene.hero.boundingBox.size.height/2);
            CCNode *bullet = [CCBReader load:@"Bullet"];
            [[bullet physicsBody] setMass:1];
            [bullet setScale:5.0];
            [bullet.physicsBody setCollisionGroup:self];
            [self.physicsBody setCollisionGroup:self];
            bullet.position = ccp(self.position.x + self.boundingBox.size.width/2, self.position.y + self.boundingBox.size.height/2);
            
            [scene.levelObjects addChild:bullet];
            
            CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
            double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
            CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
            CGPoint force = ccpMult(unitDir, 10000);
            [bullet.physicsBody applyForce:force];
        }
    }
}




@end
