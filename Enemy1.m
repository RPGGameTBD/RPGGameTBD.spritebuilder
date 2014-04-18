//
//  Enemy1.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy1.h"

@implementation Enemy1

@synthesize health;
@synthesize enemyHealthLabel;

- (void)didLoadFromCCB{
    [self setHealth:100];
    [self.physicsBody setMass:1];
    [self.physicsBody setCollisionGroup:self];
    enemyHealthLabel= [[CCLabelTTF alloc] init];
    [enemyHealthLabel setAnchorPoint:ccp(0,0)];
    [enemyHealthLabel setPosition:ccp(self.position.x, self.position.y + 10)];
    [enemyHealthLabel setString:[NSString stringWithFormat:@"100"]];
    [[self parent] addChild:enemyHealthLabel];
}



@end
