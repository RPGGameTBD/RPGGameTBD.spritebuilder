//
//  LeftButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LeftButton.h"

@implementation LeftButton
@synthesize hero;



-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"left touch");
    if (hero.scaleX > 0) {
        hero.scaleX *= -1;
    }
    [[hero physicsBody] setVelocity:ccp(-200, hero.physicsBody.velocity.y)];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
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
