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
@synthesize flipHero;


- (id) init
{
    self = [super init];
    area = @"Placeholder";
    buttonText = @"Placeholder";
    button = [[CCButton alloc] initWithTitle:buttonText];
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGPoint position = ccp(screenSize.size.height/2, screenSize.size.width/2);
    point = position;
    flipHero = NO;
    [self.button setTarget:self selector:@selector(action)];

    return self;
}

- (void) action
{
    MainScene *scene = [MainScene scene];
    if ([self.buttonText isEqualToString:@"Deathmatch?"]) {
        //[scene showLeaderboardAndAchievements:YES];
        [scene.appDelegate.mpcHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
        [scene.appDelegate.mpcHandler setupSession];
        [scene.appDelegate.mpcHandler advertiseSelf:true];
        if (scene.appDelegate.mpcHandler.session != nil) {
            [[scene.appDelegate mpcHandler] setupBrowser];
            [[[scene.appDelegate mpcHandler] browser] setDelegate:scene];
            
            [[CCDirector sharedDirector] presentViewController:scene.appDelegate.mpcHandler.browser
                               animated:YES
                             completion:nil];
        }
        scene.currLevel = self.area;
        [scene loadLevelWithHeroPosition:point flipped:self.flipHero];
        //[scene addOpponent];
        
        return;
    }
    if (!scene.hero.dead)
    {
        scene.currLevel = self.area;
        [scene loadLevelWithHeroPosition:point flipped:self.flipHero];
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
    self.point  = ccp(630, 50);
    self.flipHero = YES;
    self.area = @"LevelC";
    self.buttonText = @"Deathmatch?";
    self.button.title = self.buttonText;
    return self;
}

@end

@implementation DoorToB

-(id) init
{
    self = [super init];
    self.area = @"LevelB";
    self.point = ccp(100, 50);
    self.flipHero = NO;
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
    self.flipHero = YES;
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
    self.flipHero = YES;
    self.area = @"LevelB";
    self.buttonText = @"Climb?";
    self.button.title = self.buttonText;
    return self;
}

@end