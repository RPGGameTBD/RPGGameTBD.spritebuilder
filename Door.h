//
//  Door.h
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 4/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Door : CCSprite

@property (nonatomic) CGPoint point;
@property (nonatomic, strong) NSString* area;
@property (nonatomic, strong) NSString* buttonText;
@property (nonatomic, strong) CCButton* button;
@property (nonatomic) BOOL    flipHero;

- (void) showButton;
- (void) removeButton;

@end

@interface DoorToA : Door
@end

@interface DoorToB : Door
@end

@interface DoorToC : Door
@end

@interface DoorToB2 : Door
@end
