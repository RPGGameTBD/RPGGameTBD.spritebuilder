//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LeftButton.h"
#import "RightButton.h"

@interface MainScene : CCNode
{

}

/* SpriteBuilder variables */
@property (nonatomic, strong) CCButton *jumpButton;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;
@property (nonatomic, strong) CCSprite *dude;
@property (nonatomic, strong) CCPhysicsNode *physicsNodeMS;
@property (nonatomic, strong) CCSprite *ground;
@property (nonatomic, strong) CCSprite *freshGame;
@property (nonatomic, strong) CCSprite *continueGame;

/* Not from SpriteBuilder */
@property (nonatomic, strong) CCButton *freshGameButton;
@property (nonatomic, strong) CCButton *continueGameButton;

@end
