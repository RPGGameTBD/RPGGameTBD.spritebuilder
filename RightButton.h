//
//  RightButton.h
//  RPGGameTBD
//
//  Created by Nicholas Hyatt on 3/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CCButton.h"
#import "Hero.h"

@interface RightButton : CCButton
@property Hero *hero;
@property (nonatomic) BOOL pressed;
@end
