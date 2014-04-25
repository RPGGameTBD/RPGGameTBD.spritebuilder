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
#import "Hero.h"
#import "Enemy.h"

@interface FirstLevel : CCNode <CCPhysicsCollisionDelegate>

/* SpriteBuilder variables */
@property (nonatomic, strong) CCButton *jumpButton;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;
@property (nonatomic, strong) CCSprite *heroLeft;
@property (nonatomic, strong) CCSprite *heroRight;
@property (nonatomic, strong) CCPhysicsNode *physicsNodeFL;
@property (nonatomic, strong) CCSprite *ground;
@property (nonatomic, strong) CCNode *levelObjects;
@property (nonatomic, strong) CCNode *level2;

@property (nonatomic, strong) Enemy *enemy1;

@property (nonatomic, strong) CCLabelTTF *healthLabel;
@property (nonatomic, strong) CCLabelTTF *enemyHealthLabel;

@property (nonatomic, strong) Hero *hero;

@end
