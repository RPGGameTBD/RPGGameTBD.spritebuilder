//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Door.h"
#import "Enemy.h"

@implementation MainScene
static MainScene* refSelf;

/* buttons */
@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;

/* hero */
@synthesize hero;
@synthesize healthLabel;

/* Level Objects */
@synthesize levelObjects;
@synthesize physicsNodeMS;

/* current Level */
@synthesize currLevel;

/*current doors in level */
@synthesize doors;

/*current enemies in level */
@synthesize enemies;

/* here is a class method to get ahold of our MainScene node */
+ (MainScene *) scene
{
    return refSelf;
}

/* this method is the essentially entrance location for our app, all setup should occur here
 * such as scheduling other worker threads
 */
- (void)didLoadFromCCB
{
    /* set refSelf */
    refSelf = self;
    
    /* some initial setup for buttons and background */
    [self setUserInteractionEnabled:YES];
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setHero:hero];
    [rightButton setHero:hero];
    
    /* shedeule various methods for gameplay */
    
    [self schedule:@selector(checkPosition) interval:0.2];
    [self schedule:@selector(deathCheck) interval:0.2];
    [self schedule:@selector(updateEnemies) interval:0.01];

    /* hero setup */
    [hero setDead:NO];
    [hero.physicsBody setMass:1];
    [hero.physicsBody setCollisionGroup:hero];
    
    /* set up health label */
    [hero setHealth:100];
    healthLabel = [[CCLabelTTF alloc] init];
    [healthLabel setAnchorPoint:ccp(0,0)];
    [healthLabel setPosition:ccp(10, 300)];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
    [self addChild:healthLabel];
    
    /* set self as collision delegate */
    [physicsNodeMS setCollisionDelegate:self];
    
    /*load the title screen manually */
    currLevel = @"LevelA";
    [self loadLevel];
}

/* loads the level specified by currLevel only the main buttons, hero, and health label stay */

-(void) loadLevel
{
    [levelObjects removeFromParent];
    doors = [[NSMutableArray alloc] init];
    enemies = [[NSMutableArray alloc] init];
    
    CCNode *newLevel = [CCBReader load:currLevel];
    levelObjects = newLevel;
    
    [physicsNodeMS addChild:newLevel z:0];
    [hero setZOrder:1];
    
    CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:levelObjects.boundingBox];
    [physicsNodeMS runAction:follow];
    
    /* set all objects above menu */
    for (CCNode *child in levelObjects.children)
    {
        [child setPosition:ccp(child.position.x, child.position.y + 40)];
        /* check to see if child is a door object */
        if ([child isKindOfClass:Door.class] )
        {
            [doors addObject:child];
        }
        /* check if child is an enemy */
        else if ([child isKindOfClass:Enemy.class])
        {
            [enemies addObject:child];
        }
    }
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGPoint position = ccp(screenSize.size.height/2, screenSize.size.width/2);
    [hero setPosition:position];
    [hero.physicsBody setVelocity:ccp(0, 0)];
    [hero setDead:NO];
}

/* checkposition will check the characters position against various objects in the
 * level and take the appropriate action. For example loading a new level when 
 * the player hits a door. Also movement while not on top of an object isn't allowed
 */
- (void) checkPosition
{
    CGRect heroRect = hero.boundingBox;
    
    /* get all relevent level objects for the current level */
    
    /* first all doors */
    for (Door *child in doors)
    {
        CGRect doorRect = child.boundingBox;
        if (CGRectIntersectsRect(heroRect, doorRect))
        {
            //Make a button with the specified text show up
            [child showButton];
        }
        else
        {
            //have the button disappear
            [child removeButton];
        }
    }
}

/* player jumping method called when jump button pressed 
 * only allows one jump off a jumpable object in the level
 */
-(void)jump
{
    [hero.physicsBody applyForce:ccp(0, 5000)];
}

/* death occurs if hero falls off a ledge or her heatlh reaches zero */
- (void) deathCheck
{
    if (!hero.dead && ([hero position].y < 30 || [hero health] < 0))
    {
        CCLabelTTF *deadLabel = [[CCLabelTTF alloc] init];
        CGRect screenSize = [UIScreen mainScreen].bounds;
        CGPoint position = ccp(screenSize.size.height/2, screenSize.size.width/2);
        [deadLabel setPosition:position];
        [deadLabel setString:@"DEAD"];
        [levelObjects addChild:deadLabel];
        currLevel = @"LevelA";
        hero.dead = YES;
        [self performSelector:@selector(loadLevel) withObject:self afterDelay:1];
    }
}

- (void) updateEnemies
{
    for (Enemy* enemy in enemies)
    {
        [enemy update];
    }
}

/* gets touches from anwhere within our scene which activates the shoot mechanism */
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPos = [touch locationInNode:physicsNodeMS];
    
    CCNode *bullet = [CCBReader load:@"Bullet"];
    [bullet.physicsBody setCollisionGroup:hero];
    
    bullet.position = hero.position;
    
    [levelObjects addChild:bullet];
    
    /* calculate the direction vector */
    CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), touchPos);
    double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
    CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
    CGPoint force = ccpMult(unitDir, 1000);
    
    [bullet.physicsBody applyForce:force];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    [nodeA removeFromParent];
}

@end
