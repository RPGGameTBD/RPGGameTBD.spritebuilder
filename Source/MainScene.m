//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize dude;
@synthesize physicsNodeMS;
@synthesize ground;

@synthesize freshGame;
@synthesize continueGame;

@synthesize freshGameButton;
@synthesize continueGameButton;

- (void)didLoadFromCCB
{
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setDude:dude];
    [rightButton setDude:dude];
    [physicsNodeMS setGravity:ccp(0, -250)];
    [self schedule:@selector(checkPosition) interval:0.2];
    
    /* add two buttons */
    CGRect door1Rect = freshGame.boundingBox;
    freshGameButton = [CCButton buttonWithTitle:@"New Game?"];
    [freshGameButton setAnchorPoint:ccp(0,0)];
    [freshGameButton setPosition:ccp(door1Rect.origin.x, door1Rect.origin.y + door1Rect.size.height)];
    [freshGameButton setVisible:NO];
    [freshGameButton setTarget:self selector:@selector(freshGameCreate)];
    [self addChild:freshGameButton];
    
    CGRect door2Rect = continueGame.boundingBox;
    continueGameButton = [CCButton buttonWithTitle:@"Continue Game?"];
    [continueGameButton setAnchorPoint:ccp(0,0)];
    [continueGameButton setPosition:ccp(door2Rect.origin.x, door2Rect.origin.y + door2Rect.size.height)];
    [continueGameButton setVisible:NO];
    [continueGameButton setTarget:self selector:@selector(continueGameCreate)];
    [self addChild:continueGameButton];
    
}

- (void)update:(CCTime)delta
{
    
}

-(void)jump
{
    NSLog(@"CALLED JUMP");
    NSLog(@"KJKJKJKJ");
    /* make sure he can't jump too high */
    CGRect playerRect = dude.boundingBox;
    playerRect.size.height = 5;
    

    CGRect groundRect = ground.boundingBox;
    groundRect.origin.y += (groundRect.size.height - 5);
    groundRect.size.height = 60;
    if (CGRectIntersectsRect(playerRect, groundRect))
    {
        [dude.physicsBody applyForce:ccp(0, 10000)];
    }


}

- (void) checkPosition
{
    CGRect dudeRect = dude.boundingBox;
    CGRect door1Rect = freshGame.boundingBox;
    CGRect door2Rect = continueGame.boundingBox;
    if (CGRectIntersectsRect(dudeRect, door1Rect))
    {
        //Make new game button visible and pressable
        [freshGameButton setVisible:YES];
        
    }
    else
    {
        [freshGameButton setVisible:NO];
    }
    if (CGRectIntersectsRect(dudeRect, door2Rect))
    {
        //make continue game button visible
        [continueGameButton setVisible:YES];
    }
    else
    {
        [continueGameButton setVisible:NO];
    }
    
}

- (void) freshGameCreate
{
    NSLog(@"New Game Pressed");
    CCScene *firstLevel = [CCBReader loadAsScene:@"FirstLevel"];
    [[CCDirector sharedDirector] replaceScene:firstLevel];
    NSLog(@"Nick's Change");
}

- (void) continueGameCreate
{
    NSLog(@"Continue Game Pressed");
}

- (void)bulletRemoved:(CCNode *)bullet {
    
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BulletExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the bullets position
    explosion.position = bullet.position;
    // add the particle effect to the same node the bullet is on
    [bullet.parent addChild:explosion];
    
    [bullet removeFromParent];
    NSLog(@"Boom!");
}

//Physics delegation
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    
    float energy = [pair totalKineticEnergy];
    
    
    //if energy is large enough remove the bullet
    if (energy > 0.f)
    {
        [self bulletRemoved:nodeA];
    }
}


@end
