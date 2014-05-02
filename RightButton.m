//
//  RightButton.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RightButton.h"
#import "MainScene.h"
#import "Ground.h"

@implementation RightButton
@synthesize hero;
@synthesize pressed;

/* will move player to the right, but only if player is on a surface */
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    pressed = YES;
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    pressed = NO;
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    pressed = NO;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

@end
