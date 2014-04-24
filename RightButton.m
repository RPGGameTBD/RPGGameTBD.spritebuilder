//
//  RightButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RightButton.h"

@implementation RightButton
@synthesize hero;

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"right touch");
    if (hero.scaleX < 0) {
        hero.scaleX *= -1;
    }
    [[hero physicsBody] setVelocity:ccp(200, hero.physicsBody.velocity.y)];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{

    NSLog(@"right cancel");
    [[hero physicsBody] setVelocity:ccp(0, hero.physicsBody.velocity.y)];
    
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[hero physicsBody] setVelocity:ccp(0, hero.physicsBody.velocity.y)];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Moved");
}

@end
