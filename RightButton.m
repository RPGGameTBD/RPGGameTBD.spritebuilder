//
//  RightButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RightButton.h"

@implementation RightButton
@synthesize dude;

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"right touch");
    [dude setFlipX:FALSE];
    for (CCSprite *child in [dude children])
    {
        [child setFlipX:FALSE];
    }
    [[dude physicsBody] setVelocity:ccp(200, dude.physicsBody.velocity.y)];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"right cancel");
    [[dude physicsBody] setVelocity:ccp(0, dude.physicsBody.velocity.y)];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[dude physicsBody] setVelocity:ccp(0, dude.physicsBody.velocity.y)];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Moved");
}

@end
