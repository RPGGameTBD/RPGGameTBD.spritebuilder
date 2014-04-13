//
//  LeftButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LeftButton.h"

@implementation LeftButton
@synthesize dude;



-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"left touch");
    if (dude.scaleX > 0) {
        dude.scaleX *= -1;
        
    }
    [[dude physicsBody] setVelocity:ccp(-200, dude.physicsBody.velocity.y)];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
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
