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

@implementation Cultist

@synthesize healthLabel;

- (void)didLoadFromCCB
{
    NSLog(@"CALLED");
    MainScene *scene = [MainScene scene];
    [self setHealth:100];
    [self.physicsBody setMass:1];
    
    healthLabel= [[CCLabelTTF alloc] init];
    [scene addChild:healthLabel];
    [healthLabel setAnchorPoint:ccp(0,0)];
    [healthLabel setPosition:ccp(self.position.x, self.position.y + 10)];
    [healthLabel setString:[NSString stringWithFormat:@"100"]];
}


- (void) update
{
    [healthLabel setPosition:ccp(self.position.x, self.position.y + 10)];
    
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
        
        if (heroOrigin.y > enemyOrigin.y + 40)
        {
            [self.physicsBody applyForce:ccp(0, 5000)];
        }
    }
    else
    {
        /* shoot */
    }
    
}

@end
