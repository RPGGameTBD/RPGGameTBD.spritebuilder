//
//  FirstLevel.m
//  RPGGameTBD
//
//  Created by Erik Artymiuk on 3/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FirstLevel.h"

@implementation FirstLevel

@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize hero;
@synthesize heroLeft;
@synthesize heroRight;
@synthesize physicsNodeFL;
@synthesize ground;
@synthesize levelObjects;
@synthesize level2;

@synthesize enemy1;
@synthesize enemies;
@synthesize healthLabel;


- (void)didLoadFromCCB
{
    [self setUserInteractionEnabled:TRUE];
    [physicsNodeFL setCollisionDelegate:self];
    
    [jumpButton setExclusiveTouch:NO];
    [leftButton setExclusiveTouch:NO];
    [rightButton setExclusiveTouch:NO];
    [leftButton setDude:hero];
    [rightButton setDude:hero];
    
    /* set up health label */
    [hero setHealth:100];
    healthLabel = [[CCLabelTTF alloc] init];
    [healthLabel setAnchorPoint:ccp(0,0)];
    [healthLabel setPosition:ccp(10, 300)];
    [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
    [self addChild:healthLabel];
    
    
    
    
    ground = [[levelObjects children] objectAtIndex:1];
    [ground.physicsBody setCollisionType:@"ground"];
    CCSprite *background = [[levelObjects children] objectAtIndex:0];
    
    CGRect rect = background.boundingBox;
    rect.size.height*=2;
    CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:rect];
    [physicsNodeFL runAction:follow];
    
    
    
    [self schedule:@selector(enemyUpdate) interval:0.1];
    //[self schedule:@selector(deathCheck) interval: 0.1];

    [hero.physicsBody setMass:1];
    
    /*set up method to check position*/
    [self schedule:@selector(checkPosition) interval:0.2];
    enemies = [[NSMutableArray alloc] initWithObjects:enemy1, nil];
    
    
    
}

-(void)jump
{
    NSLog(@"CALLED JUMP");
    if (hero.physicsBody.velocity.y > .01 || hero.physicsBody.velocity.y < -.01) {
        NSLog(@"velocity of y: %f", hero.physicsBody.velocity.y);
        return;
    }else{
            [hero.physicsBody applyForce:ccp(0, 10000)];
            return;
    }
    
    /* make sure he can't jump too high */
    /*CGRect playerRect = hero.boundingBox;
    playerRect.size.height = 5;
    
    for (CCSprite *sf in [levelObjects children])
    {
        CGRect groundRect = sf.boundingBox;
        groundRect.origin.y += (groundRect.size.height - 5);
        groundRect.size.height = 60;
        if (CGRectIntersectsRect(playerRect, groundRect))
        {
            [hero.physicsBody applyForce:ccp(0, 10000)];
        }
    }*/
}

- (void) enemyUpdate
{
    for (int i = 0; i < [enemies count]; i++){
        Enemy1 *enemy = [enemies objectAtIndex:i];
        NSLog(@"enemy array: %@",enemies);
        int randJump = arc4random() %15;
        if (randJump == 0) {
            [self enemyJump:enemy];
        }
        int distance = [self distanceToEnemy:enemy];
        if ([enemy health] < 30)
        {
            [enemy.physicsBody setVelocity:ccp(175, enemy.physicsBody.velocity.y)];
        }
        else if (distance < 568 && distance > 150)
        {
            NSLog(@"before");
            CGRect heroRect = hero.boundingBox;
            CGRect enemyRect = enemy.boundingBox;
        
            CGPoint heroOrigin = heroRect.origin;
            CGPoint enemyOrigin = enemyRect.origin;
            if (heroOrigin.x > enemyOrigin.x)
            {
                [enemy.physicsBody setVelocity:ccp(100, enemy.physicsBody.velocity.y)];
                [enemy setFlipX:FALSE];
            }
            else
            {
                [enemy.physicsBody setVelocity:ccp(-100, enemy.physicsBody.velocity.y)];
                [enemy setFlipX:TRUE];
            }
        
            if (heroOrigin.y > enemyOrigin.y + 40)
            {
                [self enemyJump:enemy];
            }
            NSLog(@"after");
        }
        else
        {
            [enemy.physicsBody setVelocity:ccp(0, enemy.physicsBody.velocity.y)];
        
            CGPoint currentPos = hero.position;
        
            int randShoot = arc4random() % 5;
        
        
            if (randShoot == 0) {
                // loads the Bullet.ccb we have set up in Spritebuilder
                CCNode *bullet = [CCBReader load:@"Bullet"];
                [bullet.physicsBody setCollisionGroup:enemy];
            
            // position the bullet at the hero
            bullet.position = enemy.position;
            
            // add the bullet to the physicsNode of this scene (because it has physics enabled)
            [physicsNodeFL addChild:bullet];
            
            CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
            double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
            CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
            CGPoint force = ccpMult(unitDir, 500);
            [bullet.physicsBody applyForce:force];
            }
        
        
        }
    }
    [self deathCheck];
}

- (int) distanceToEnemy:(CCSprite *)enemy
{
    CGRect heroRect = hero.boundingBox;
    CGRect enemyRect = enemy.boundingBox;
    
    CGPoint p1 = heroRect.origin;
    CGPoint p2 = enemyRect.origin;
    
    double temp1 = pow(p1.x - p2.x, 2);
    double temp2 = pow(p1.y - p2.y , 2);
    double distance = sqrt(temp1 + temp2);
    return (int)distance;
}

- (void) enemyJump:(CCSprite *)enemy
{
    if (enemy.physicsBody.velocity.y > .01 || enemy.physicsBody.velocity.y < -.01) {
        return;
    }else{
        [enemy.physicsBody applyForce:ccp(0, 7000)];
        return;
    }
    /* make sure he can't jump too high */
    /*CGRect enemyRect = enemy.boundingBox;
    enemyRect.size.height = 5;
    
    for (CCSprite *sf in [levelObjects children])
    {
        CGRect groundRect = sf.boundingBox;
        groundRect.origin.y += (groundRect.size.height - 5);
        groundRect.size.height = 60;
        if (CGRectIntersectsRect(enemyRect, groundRect))
        {
            [enemy.physicsBody applyForce:ccp(0, 1000)];
        }
    }*/
}

- (void) deathCheck
{
    if ([hero position].y < -10 || [hero health] <= 0)
    {
        
        NSLog(@"Dead");
        CCLabelTTF *deadLabel = [[CCLabelTTF alloc] init];
        [deadLabel setAnchorPoint:ccp(0,0)];
        [deadLabel setPosition:ccp(150, 150)];
        [deadLabel setString:@"DEAD"];
        [self addChild:deadLabel];
        
        
        
        
        CCScene *mainScreen = [CCBReader loadAsScene:@"MainScene"];
        [[CCDirector sharedDirector] replaceScene:mainScreen];
    }
    
    /* check enemy deaths */
    NSMutableArray *deadEnemies = [[NSMutableArray alloc] init];
    for(int i = 0; i < [enemies count]; i++){
        Enemy1 *enemy = [enemies objectAtIndex:i];
        if (enemy.health <= 0)
        {
            //[self unschedule:@selector(enemyUpdate)];
            [enemy removeFromParent];
            [enemy.enemyHealthLabel removeFromParent];
            [deadEnemies addObject:enemy];
        }
    }
    for (int i = 0; i < [deadEnemies count]; i++) {
        [enemies removeObject:[deadEnemies objectAtIndex:i]];
    }
}

//touch sensing
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"in touchBegan");
    CGPoint currentPos = [touch locationInNode:physicsNodeFL];
    
    
    // loads the Bullet.ccb we have set up in Spritebuilder
    CCNode *bullet = [CCBReader load:@"Bullet"];
    [bullet.physicsBody setCollisionGroup:hero];
    
    // position the bullet at the hero
    bullet.position = hero.position;
    
    // add the bullet to the physicsNode of this scene (because it has physics enabled)
    [physicsNodeFL addChild:bullet];
    
    CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), currentPos);
    double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
    CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
    CGPoint force = ccpMult(unitDir, 1000);
    //make sure facing in the direction shooting
    if (unitDir.x > 0) {
        if (hero.scaleX < 0) {
            hero.scaleX *= -1;
            
        }
    }else{
        if (hero.scaleX > 0) {
            hero.scaleX *= -1;
            
        }
    }
    [bullet.physicsBody applyForce:force];
}

- (void)bulletRemoved:(CCNode *)bullet {
    
    [bullet removeFromParent];
    NSLog(@"Boom!");
}
//Physics delegation
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    NSLog(@"Collision");
    
    float energy = [pair totalKineticEnergy];
    
    
    //if energy is large enough remove the bullet
    if (energy > 0.f)
    {
        if (nodeB == hero)
        {
            NSLog(@"Hit HERO!!!");
            [hero setHealth:hero.health - 6];
            [healthLabel setString:[NSString stringWithFormat:@"%d",[hero health]]];
        }
        else
        {
            
            for (int i = 0; i < [enemies count]; i++) {
                if (nodeB == [enemies objectAtIndex:i]) {
                    NSLog(@"Hit ENEMY");
                    Enemy1 *enemy = [enemies objectAtIndex:i];
                    [enemy setHealth:enemy.health - 6];
                    [enemy.enemyHealthLabel setString:[NSString stringWithFormat:@"%d",[enemy health]]];
                }
            }
            
            
        }
        [self bulletRemoved:nodeA];
    }
}


- (void) checkPosition
{
    CCSprite *door = [[levelObjects children] objectAtIndex:2];
    CGRect dudeRect = hero.boundingBox;
    CGRect doorRect = door.boundingBox;
    if (CGRectIntersectsRect(dudeRect, doorRect))
    {
        [levelObjects removeFromParent];
        level2 = [CCBReader load:@"SecondLevelSchema"];
        [physicsNodeFL addChild:level2 z:0];
        for (int i = 0; i < [enemies count]; i++) {
            Enemy1 *enemy = [enemies objectAtIndex:i];
            [enemy removeFromParent];
        }
        [enemies removeAllObjects];
        [hero removeFromParent];
        [level2 addChild:hero];
        CCActionFollow *follow = [CCActionFollow actionWithTarget:hero worldBoundary:level2.boundingBox];
        [physicsNodeFL runAction:follow];
         
        
    }
}

- (void)update:(CCTime)delta
{
    /* update health label */
    for (int i = 0; i < [enemies count]; i++) {
        Enemy1 *enemy = [enemies objectAtIndex:i];
        [enemy.enemyHealthLabel setPosition:ccp(enemy.position.x - 5, enemy.position.y + 20)];
    }
    
    if ([enemies count] < 3) {
     CCNode *enemy = [CCBReader load:@"enemy"];
     Enemy1 *badGuy = enemy;
     if(enemy == nil){
     NSLog(@"no enemy");
     }
     [physicsNodeFL addChild:enemy];
     [physicsNodeFL addChild:badGuy.enemyHealthLabel];
     [enemies addObject:enemy];
     enemy.position = ccp(50, 50);
     
    }
    
    
    
    
}

@end
