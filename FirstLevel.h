//
//  FirstLevel.h
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 3/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeftButton.h"
#import "RightButton.h"

@interface FirstLevel : CCNode

/* SpriteBuilder variables */
@property (nonatomic, strong) CCButton *jumpButton;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;
@property (nonatomic, strong) CCSprite *dude;
@property (nonatomic, strong) CCPhysicsNode *physicsNodeFL;
@property (nonatomic, strong) CCSprite *ground;
@property (nonatomic, strong) CCNode *levelObjects;

@property (nonatomic, strong) CCSprite *enemy1;

@end
