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
#import "Ground.h"

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

/*current ground objects in level */
@synthesize grounds;

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
    
    /* set up health */
    [hero setHealth:100];
    
    /* set self as collision delegate */
    [physicsNodeMS setCollisionDelegate:self];
    
    /*load the title screen manually */
    currLevel = @"LevelA";
    [self loadLevelWithHeroPosition:ccp(935, 50) flipped:YES];
}

/* loads the level specified by currLevel only the main buttons, hero, and health label stay */

-(void) loadLevelWithHeroPosition:(CGPoint)position flipped:(BOOL) flip
{
    /* check if level transition from hero death */
    if ([hero dead])
    {
        [hero setDead:NO];
        hero.dead = NO;
        hero.health = 100;
    }
    hero.position = position;
    hero.flipX = flip;
    [levelObjects removeFromParent];
    healthLabel = nil;
    doors = [[NSMutableArray alloc] init];
    enemies = [[NSMutableArray alloc] init];
    grounds = [[NSMutableArray alloc] init];
    
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
        
        if ([child isKindOfClass:Ground.class])
        {
            [grounds addObject:child];
        }
    }
    
    
    [hero.physicsBody setVelocity:ccp(0, 0)];
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
    for (Ground* ground in grounds)
    {
        /* make it so hero can only jump off of objects */
        CGRect groundRect = ground.boundingBox;
        groundRect.origin.y += groundRect.size.height;
        groundRect.size.height = 1;
        CGRect heroRect = hero.boundingBox;
        if (CGRectIntersectsRect(groundRect, heroRect))
        {
            [hero.physicsBody applyForce:ccp(0, 5000)];
            break;
        }
    }
}

/* death occurs if hero falls off a ledge or her heatlh reaches zero */
- (void) deathCheck
{
    if (!hero.dead && ([hero position].y < 30 || [hero health] < 0))
    {
        currLevel = @"LevelA";
        hero.dead = YES;
        [self performSelector:@selector(loadLevelAfterDeath) withObject:nil afterDelay:1];
    }
}

- (void) loadLevelAfterDeath
{
    [self loadLevelWithHeroPosition:ccp(935, 50) flipped:YES];
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
    
    bullet.position = ccp(hero.position.x + hero.boundingBox.size.width/2, hero.position.y + hero.boundingBox.size.height/2);
    
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
    /* a bullet hit our hero */
    if (nodeB == hero)
    {
        hero.health-=6;
    }
    /* bullet hit an enemy */
    else if ([nodeB isKindOfClass:Enemy.class])
    {
        ((Enemy*)nodeB).health-=6;
    }
}


/* anything that needs to be redrawn for every frame like health labels */
- (void) update:(CCTime)delta
{
    if (healthLabel == nil)
    {
        healthLabel = [[CCLabelTTF alloc] init];
        [healthLabel setAnchorPoint:ccp(0,0)];
        [healthLabel setPosition:ccp(hero.position.x, hero.position.y)];
        [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
        [self.levelObjects addChild:healthLabel];
    }
    else
    {
        if (hero.dead)
        {
            [healthLabel setColor:[CCColor redColor]];
            [healthLabel setString:[NSString stringWithFormat:@"DEAD"]];
            [healthLabel setPosition:ccp(hero.position.x, hero.position.y + hero.boundingBox.size.height)];
        }
        else
        {
            [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
            [healthLabel setPosition:ccp(hero.position.x, hero.position.y + hero.boundingBox.size.height)];
        }
    }
    for (Enemy *enemy in enemies)
    {
        CCLabelTTF *enemyHealthLabel = enemy.enemyHealthLabel;
        if (enemyHealthLabel == nil)
        {
            enemyHealthLabel= [[CCLabelTTF alloc] init];
            [enemyHealthLabel setAnchorPoint:ccp(0,0)];
            [enemyHealthLabel setString:[NSString stringWithFormat:@"%d",[enemy health]]];
            enemy.enemyHealthLabel = enemyHealthLabel;
            [self.levelObjects addChild:enemy.enemyHealthLabel];
        }
        else
        {
            [enemyHealthLabel setString:[NSString stringWithFormat:@"%d",[enemy health]]];
            [enemyHealthLabel setPosition:ccp(enemy.position.x, enemy.position.y + enemy.boundingBox.size.height)];
        }
    }
}

- (BOOL) heroOnObject
{
    for (Ground* ground in [MainScene scene].grounds)
    {
        CGRect groundRect = ground.boundingBox;
        groundRect.origin.y += groundRect.size.height;
        groundRect.size.height = 1;
        CGRect heroRect = hero.boundingBox;
        if (CGRectIntersectsRect(groundRect, heroRect))
        {
            return true;
        }
    }
    return false;
}

@end
