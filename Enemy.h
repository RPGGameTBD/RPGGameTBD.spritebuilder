//
//  Enemy1.h
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Enemy : CCSprite

- (void) update;
@property (nonatomic) int health;
@property (nonatomic, strong) CCLabelTTF *enemyHealthLabel;

@end

@interface Cultist : Enemy

@property (nonatomic, strong) CCLabelTTF* healthLabel;

@end
