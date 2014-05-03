//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LeftButton.h"
#import "RightButton.h"
#import "Hero.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import <iAd/iAd.h>

@interface MainScene : CCNode <CCPhysicsCollisionDelegate, GKGameCenterControllerDelegate>
{

}

+ (MainScene*) scene;
extern const int JUMPLIMIT;
-(void) loadLevelWithHeroPosition:(CGPoint)position flipped:(BOOL)flip;
-(BOOL) heroOnObject;
-(void)reportScore;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;
/*Gamecenter leaderboard*/
@property (nonatomic) int64_t score;

/* any buttons */
@property (nonatomic, strong) CCButton *jumpButton;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;

/* Our hero */
@property (nonatomic, strong) Hero *hero;
@property (nonatomic, strong) CCLabelTTF *healthLabel;
@property (nonatomic) int numJumps;

/* Main Physics Node */
@property (nonatomic, strong) CCPhysicsNode *physicsNodeMS;

/* Various Level Objects */
@property (nonatomic, strong) CCNode *levelObjects;

/* Text description of current level we're on */
@property (nonatomic, strong) NSString *currLevel;

/* Arrays with all the Doors and Enemiesof the current level */
@property (nonatomic, strong) NSMutableArray *doors;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic, strong) NSMutableArray *grounds;

@end
