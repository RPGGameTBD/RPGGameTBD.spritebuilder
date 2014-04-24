//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

/* buttons */
@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize freshGameButton;
@synthesize continueGameButton;

/* hero */
@synthesize hero;

/* */
@synthesize levelObjects;
@synthesize physicsNodeMS;
@synthesize ground;
@synthesize freshGame;
@synthesize continueGame;


- (void)didLoadFromCCB
{
    /* some initial setup for buttons and background */
    [self setUserInteractionEnabled:YES];
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setHero:hero];
    [rightButton setHero:hero];
    
    /* add two buttons */
    
    freshGame = [levelObjects.children objectAtIndex:3];
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
    
    [self schedule:@selector(checkPosition) interval:0.2];
    
    [hero.physicsBody setMass:1];
    [hero.physicsBody setCollisionGroup:hero];
    [physicsNodeMS setCollisionDelegate:self];
    
}

//touch sensing
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"in touchBegan");
    CGPoint currentPos = [touch locationInNode:physicsNodeMS];
    
    
    // loads the Bullet.ccb we have set up in Spritebuilder
    CCNode *bullet = [CCBReader load:@"Bullet"];
    [bullet.physicsBody setCollisionGroup:hero];
    
    // position the bullet at the penguin
    bullet.position = hero.position;
    
    // add the bullet to the physicsNode of this scene (because it has physics enabled)
    [physicsNodeMS addChild:bullet];
    
    CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
    double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
    CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
    CGPoint force = ccpMult(unitDir, 500);
    [bullet.physicsBody applyForce:force];
    
    
}

-(void)jump
{
    NSLog(@"CALLED JUMP");
    if (hero.physicsBody.velocity.y > .01 || hero.physicsBody.velocity.y < -.01) {
        NSLog(@"velocity of y: %f", hero.physicsBody.velocity.y);
        return;
    }else{
        [hero.physicsBody applyForce:ccp(0, 10000)];
        return;
    }
}

- (void) checkPosition
{
    CGRect dudeRect = hero.boundingBox;
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

- (void)bulletRemoved:(CCNode *)bullet
{
    
    // load particle effect
   // CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BulletExplosion"];
    // make the particle effect clean itself up, once it is completed
    //explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the bullets position
    //explosion.position = bullet.position;
    // add the particle effect to the same node the bullet is on
    //[bullet.parent addChild:explosion];
    
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
        [self bulletRemoved:nodeA];
    }
}

@end
