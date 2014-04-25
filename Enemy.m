//
//  Enemy1.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"
#import "MainScene.h"

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

@end

@implementation Cultist{
    int timesUpdated;
    CGRect zone;
}

@synthesize healthLabel;


- (void)didLoadFromCCB
{
    NSLog(@"CALLED");
    timesUpdated = 0;
    [self setHealth:100];
    [self.physicsBody setMass:1];
}

-(void) updateHealthLabel
{
    MainScene *scene = [MainScene scene];
    if (healthLabel == nil)
    {
        healthLabel= [[CCLabelTTF alloc] init];
        [healthLabel setAnchorPoint:ccp(0,0)];
        [healthLabel setString:[NSString stringWithFormat:@"100"]];
        [scene.levelObjects addChild:healthLabel];
    }
    else
    {
        [healthLabel setPosition:ccp(self.position.x, self.position.y + 10)];
    }
}



- (void) update
{
    timesUpdated++;
    zone = CGRectInset(self.boundingBox, -500, -100);
    
    MainScene *scene = [MainScene scene];
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
            
            if (heroOrigin.y > enemyOrigin.y + 40)
            {
                [self.physicsBody applyForce:ccp(0, 5000)];
            }
        }
        else
        {
            [self.physicsBody setVelocity:ccp( 0, self.physicsBody.velocity.y)];
            /* shoot */
            if (timesUpdated == 5) {
        
                CGPoint currentPos = scene.hero.position;
                CCNode *bullet = [CCBReader load:@"Bullet"];
                [bullet.physicsBody setCollisionGroup:self];
                [self.physicsBody setCollisionGroup:self];
                bullet.position = self.position;
            
                [scene.levelObjects addChild:bullet];
            
                CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
                double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
                CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
                CGPoint force = ccpMult(unitDir, 1000);
                [bullet.physicsBody applyForce:force];
            }
        }
    }else{
        [self.physicsBody setVelocity:ccp( 0, self.physicsBody.velocity.y)];
    }
    if (timesUpdated == 5) {
        timesUpdated = 0;
    }
    
    [self updateHealthLabel];
    
}


@end
