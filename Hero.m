//
//  Hero.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Hero.h"

@implementation Hero

@synthesize health;
@synthesize dead;

- (void)didLoadFromCCB
{
    [self.physicsBody setCollisionGroup:self];
    [self.physicsBody setCollisionType:@"hero"];
}

@end
