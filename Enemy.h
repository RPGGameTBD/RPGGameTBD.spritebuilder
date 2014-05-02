//
//  Enemy1.h
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Ground.h"

@interface Enemy : Ground {
    
}

- (void) update;
@property (nonatomic) int health;
@property (nonatomic, strong) CCLabelTTF *enemyHealthLabel;
@property (nonatomic) BOOL dead;
@property (nonatomic) int currDeathFrame;


@end

@interface Cultist : Enemy

@property (nonatomic) int timesUpdated;
@property (nonatomic) int shootspeed;

@end

@interface BigCultist : Enemy

@property (nonatomic) int timesUpdated;
@property (nonatomic) int shootspeed;
@end
