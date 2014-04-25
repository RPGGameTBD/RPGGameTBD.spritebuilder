//
//  Door.h
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Door : CCSprite

@property (nonatomic, strong) NSString* area;
@property (nonatomic, strong) NSString* buttonText;
@property (nonatomic, strong) CCButton* button;

- (void) showButton;
- (void) removeButton;

@end

@interface DoorToA : Door
@end

@interface DoorToB : Door
@end
