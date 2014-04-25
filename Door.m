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

- (id) init
{
    self = [super init];
    area = @"Placeholder";
    buttonText = @"Placeholder";
    button = [[CCButton alloc] initWithTitle:buttonText];
    [self.button setTarget:self selector:@selector(action)];

    return self;
}

- (void) action
{
    MainScene *scene = [MainScene scene];
    scene.currLevel = self.area;
    [scene loadLevel];
}

- (void) showButton
{
    if (button.parent == nil)
    {
        MainScene *scene = [MainScene scene];
        [scene.levelObjects addChild:button];
    }
    [button setPosition:ccp(self.position.x, self.position.y + 60)];
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