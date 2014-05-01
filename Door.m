//
//  Door.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

/* represents objects that are transitions between levels or areas within levels */

#import "Door.h"
#import "MainScene.h"

@implementation Door

@synthesize area;
@synthesize buttonText;
@synthesize button;
@synthesize point;

- (id) init
{
    self = [super init];
    area = @"Placeholder";
    buttonText = @"Placeholder";
    button = [[CCButton alloc] initWithTitle:buttonText];
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGPoint position = ccp(screenSize.size.height/2, screenSize.size.width/2);
    point = position;
    [self.button setTarget:self selector:@selector(action)];

    return self;
}

- (void) action
{
    MainScene *scene = [MainScene scene];
    if (!scene.hero.dead)
    {
        scene.currLevel = self.area;
        scene.hero.position = point;
        [scene loadLevel];
    }
}

- (void) showButton
{
    if (button.parent == nil)
    {
        MainScene *scene = [MainScene scene];
        [scene.levelObjects addChild:button];
    }
    [button setAnchorPoint:ccp(0, 0)];
    [button setPosition:ccp(self.position.x, self.position.y + 80)];
    [button setVisible:YES];
}

- (void) removeButton
{
    [button setVisible:NO];
}

@end

@implementation DoorToA

-(id) init
{
    self = [super init];
    self.area = @"LevelA";
    self.buttonText = @"Continue Game?";
    self.button.title = self.buttonText;
    return self;
}

@end

@implementation DoorToB

-(id) init
{
    self = [super init];
    self.area = @"LevelB";
    self.buttonText = @"New Game?";
    self.button.title = self.buttonText;
    return self;
}

@end

@implementation DoorToC

-(id) init
{
    self = [super init];
    self.point  = ccp(630, 50);
    self.area = @"LevelC";
    self.buttonText = @"Descend?";
    self.button.title = self.buttonText;
    return self;
}

@end

@implementation DoorToB2

-(id) init
{
    self = [super init];
    self.point  = ccp(1046, 50);
    self.area = @"LevelB";
    self.buttonText = @"Climb?";
    self.button.title = self.buttonText;
    return self;
}

@end