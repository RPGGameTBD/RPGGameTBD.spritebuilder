//
//  Bullet.m
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"bullet";
}


@end
