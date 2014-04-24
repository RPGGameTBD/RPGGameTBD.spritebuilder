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
#import "Hero.h"

@interface MainScene : CCNode <CCPhysicsCollisionDelegate>
{

}

/* any buttons */
@property (nonatomic, strong) CCButton *jumpButton;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;
@property (nonatomic, strong) CCButton *freshGameButton;
@property (nonatomic, strong) CCButton *continueGameButton;

/* Our hero */
@property (nonatomic, strong) Hero *hero;

/* Main Physics Node */
@property (nonatomic, strong) CCPhysicsNode *physicsNodeMS;

/* Various Level Objects */
@property (nonatomic, strong) CCNode *levelObjects;
@property (nonatomic, strong) CCSprite *ground;
@property (nonatomic, strong) CCSprite *freshGame;
@property (nonatomic, strong) CCSprite *continueGame;

@end
