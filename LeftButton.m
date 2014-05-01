//
//  LeftButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LeftButton.h"
#import "MainScene.h"
#import "Ground.h"

@implementation LeftButton
@synthesize hero;

/* will move player to the left, but only if player is on a surface */
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([[MainScene scene] heroOnObject])
    {
        hero.flipX = true;
        [[hero physicsBody] setVelocity:ccp(-200, hero.physicsBody.velocity.y)];
    }
}


-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([[MainScene scene] heroOnObject])
    {
        [[hero physicsBody] setVelocity:ccp(0, hero.physicsBody.velocity.y)];
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([[MainScene scene] heroOnObject])
    {
        [[hero physicsBody] setVelocity:ccp(0, hero.physicsBody.velocity.y)];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void) checkStatus
{
    
}


@end
