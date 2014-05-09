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
#import "Bullet.h"
#import "CCAnimation.h" 

@implementation MainScene
const int JUMPLIMIT = 3;
static MainScene* refSelf;

/* buttons */
@synthesize jumpButton;
@synthesize leftButton;
@synthesize rightButton;

/* hero */
@synthesize hero;
@synthesize healthLabel;
@synthesize numJumps;
@synthesize walking;

/* Level Objects */
@synthesize levelObjects;
@synthesize physicsNodeMS;

/* current Level */
@synthesize currLevel;
@synthesize levelNum;

/*current doors in level */
@synthesize doors;

/*current enemies in level */
@synthesize enemies;

/*current ground objects in level */
@synthesize grounds;

/* our scoring variables */
@synthesize score;
@synthesize scoreBoard;

/* the group Enemy */
@synthesize groupEnemy;

/* iAd variables */
ADBannerView *adView;
bool adIsShowing;

//multiplayer match stuff
bool multiPlayerMode;
bool multWalk;
bool oldFlip;
bool isHost;
Hero *opponent;

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
    //[physicsNodeMS setDebugDraw:YES];
    adIsShowing = false;
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
    [self schedule:@selector(updateMovement) interval:0.01];
    [self schedule:@selector(updateEnemies) interval:0.01];
    [self schedule:@selector(showAd) interval:10.0];
    
    /* setup the group enemy for the enemy's collision id */
    groupEnemy = [[Enemy alloc] init];

    /* hero setup */
    numJumps = 0;
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
    
    /* init score and level number */
    score = 0;
    levelNum = 0;
    
    //setup iAD
    /*
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    [[[CCDirector sharedDirector] view] addSubview:adView];
    adIsShowing = true;
     */
    
    //init multiplayer stuff
    multiPlayerMode = false;
    multWalk = nil;
    oldFlip = nil;
    isHost = true;
    opponent = [CCBReader load:@"Hero"];
    
    //setup appDelegate
    _appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    //setup as observer of connected state notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)
                                                 name:@"MPCDemo_DidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:@"MPCDemo_DidReceiveDataNotification"
                                               object:nil];
    
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
    numJumps = 0;
    
    for (CCSprite *child in hero.children)
    {
        if (flip)
        {
            [child setFlipX:YES];
            [child setPosition:ccp(44, 76)];
            [child setAnchorPoint:ccp(0.69, 0.79)];
        }
        else
        {
            [child setFlipX:NO];
            [child setPosition:ccp(27, 76)];
            [child setAnchorPoint:ccp(0.38, 0.79)];
        }
    }


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
    
    
    /* depending on the currLevel and the levelNum we will put in various
     numbers of enemies with various difficulty settings */
    if ([currLevel isEqualToString:@"LevelB"])
    {
        int startX = 100;
        for (int i = 0; i <= levelNum; i++)
        {
            Enemy *toAdd = (Enemy *)[CCBReader load:@"Cultist"];
            [toAdd setPosition:ccp(startX, 50)];
            startX+=200;
            [levelObjects addChild:toAdd];
        }
        levelNum++;

    }
    else if ([currLevel isEqualToString:@"LevelC"])
    {
        
    }
    
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
            [((Enemy *)child).physicsBody setCollisionGroup:groupEnemy];
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
    
    if ([self heroOnObject])
    {
        numJumps = 0;
    }
}

/* player jumping method called when jump button pressed
 * only allows one(now multiple defined by JUMPLIMIT) jump off a jumpable object in the level
 */
-(void)jump
{
    if (numJumps > 0 && numJumps < JUMPLIMIT)
    {
        numJumps++;
        [hero.physicsBody applyForce:ccp(0, 5000)];
    }
    else
    {
        if ([self heroOnObject])
        {
            /* fixes timing bug */
            hero.position = ccp(hero.position.x, hero.position.y + 5);
            numJumps = 1;
            [hero.physicsBody applyForce:ccp(0, 5000)];
        }
    }
}

/* death occurs if hero falls off a ledge or her heatlh reaches zero */
- (void) deathCheck
{
    if (!hero.dead && ([hero position].y < 30 || [hero health] < 0))
    {
        levelNum = 0;
        currLevel = @"LevelA";
        hero.dead = YES;
        [self reportScore];
        score = 0;
        [self performSelector:@selector(loadLevelAfterDeath) withObject:nil afterDelay:1];
    }
}

- (void) loadLevelAfterDeath
{
    if (multiPlayerMode) {
        currLevel = @"LevelC";
        [self loadLevelWithHeroPosition:ccp(630, 50) flipped:YES];
        [self correctOpponentPosition];
        return;
    }
    [self loadLevelWithHeroPosition:ccp(935, 50) flipped:YES];
}

- (void) updateEnemies
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (Enemy* enemy in enemies)
    {
        [enemy update];
        if (!enemy.dead)
        {
            [tempArray addObject:enemy];
        }
    }
    enemies = tempArray;
    
}

/* gets touches from anwhere within our scene which activates the shoot mechanism */
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPos = [touch locationInNode:physicsNodeMS];
    
    CCSprite *bullet = (CCSprite *)[CCBReader load:@"Bullet"];
    [bullet.physicsBody setCollisionGroup:hero];
    
    bullet.position = ccp(hero.position.x + hero.boundingBox.size.width/2, hero.position.y + hero.boundingBox.size.height/2);
    
    

    /* calculate the direction vector */
    CGPoint launchDirection = ccpAdd(ccp(-bullet.position.x,-bullet.position.y), touchPos);
    if (launchDirection.x < 0)
    {
        [hero setFlipX:YES];
        for (CCSprite *child in hero.children)
        {
            [child setFlipX:YES];
            [child setPosition:ccp(44, 76)];
            [child setAnchorPoint:ccp(0.69, 0.79)];
            [child setRotation:-180 * atan(launchDirection.y/launchDirection.x)/M_PI];
        }
    }
    else
    {
        [hero setFlipX:NO];
        for (CCSprite *child in hero.children)
        {
            [child setFlipX:NO];
            [child setPosition:ccp(27, 76)];
            [child setAnchorPoint:ccp(0.38, 0.79)];
            [child setRotation:-180 * atan(launchDirection.y/launchDirection.x)/M_PI];
        }
    }
    
   
    
    [bullet setScale:0.33];
    [bullet setFlipX:!hero.flipX];
    [bullet.physicsBody setMass:0.05];
    [bullet.physicsBody setAffectedByGravity:YES];

    double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
    CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
    CGPoint force = ccpMult(unitDir, 2000);
    float angle = -180 * atan(launchDirection.y/launchDirection.x)/M_PI;
    [bullet setRotation:angle];    
    
    [levelObjects addChild:bullet];
    [bullet.physicsBody applyForce:force];
    [self shootAnim];
    if (multiPlayerMode) {
        [self opponentShootWithLaunchDirection:launchDirection];
    }
}

- (void) shootAnim
{
    // the animation manager of each node is stored in the 'userObject' property
    CCBAnimationManager* animationManager = hero.userObject;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"MainShoot"];}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    /* a bullet hit our hero */
    if (nodeB == hero)
    {
        hero.health-=6;
    }
    /* bullet hit an enemy */
    else if ([nodeB isKindOfClass:Enemy.class])
    {
        if (((Enemy*)(nodeB)).dead != YES)
        {
            ((Enemy*)nodeB).health-=6;
        }
    }
    
    /* if two bullets hit each other don't remove them */
    if (![nodeA isKindOfClass:Bullet.class] || ![nodeB isKindOfClass:Bullet.class])
    {
        [nodeA removeFromParent];
    }
}

- (void) removeBullet:(CCNode *)nodeA
{
    [nodeA removeFromParent];
}


/* anything that needs to be redrawn for every frame like health labels */
- (void) update:(CCTime)delta
{
    [scoreBoard setString:[NSString stringWithFormat:@"%lld", score]];
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
        heroRect.size.height = 1;
        if (CGRectIntersectsRect(groundRect, heroRect))
        {
            return true;
        }
    }
    return false;
}

-(void) updateMovement
{
    if (leftButton.pressed) //&& [self heroOnObject])
    {

        [self startWalking];
        [hero setFlipX:YES];
        for (CCSprite *child in hero.children)
        {
            [child setFlipX:YES];
            [child setPosition:ccp(44, 76)];
            [child setAnchorPoint:ccp(0.69, 0.79)];
        }

        if (hero.physicsBody.velocity.x > -200)
        {
            [[hero physicsBody] setVelocity:ccp(hero.physicsBody.velocity.x - 8, hero.physicsBody.velocity.y)];
        }

    }
    else if (rightButton.pressed)//&& [self heroOnObject])
    {
        [self startWalking];
        [hero setFlipX:NO];
        for (CCSprite *child in hero.children)
        {
            [child setFlipX:NO];
            [child setPosition:ccp(27, 76)];
            [child setAnchorPoint:ccp(0.38, 0.79)];
        }
        if (hero.physicsBody.velocity.x < 200)
        {
            [[hero physicsBody] setVelocity:ccp(hero.physicsBody.velocity.x + 8, hero.physicsBody.velocity.y)];
        }
    }
    else //if ([self heroOnObject])
    {
        if ([[MainScene scene] heroOnObject])
        {
            [self pauseWalking];
            if (hero.physicsBody.velocity.x > 0)
            {
                [[hero physicsBody] setVelocity:ccp(hero.physicsBody.velocity.x - 8, hero.physicsBody.velocity.y)];
            }
            else if (hero.physicsBody.velocity.x < 0)
            {
                [[hero physicsBody] setVelocity:ccp(hero.physicsBody.velocity.x + 8, hero.physicsBody.velocity.y)];
            }
        }
    }
}

-(void)reportScore
{

    GKScore *boardscore = [[GKScore alloc] initWithLeaderboardIdentifier:_appDelegate.leaderboardIdentifier];

    boardscore.value = score;
    
    [GKScore reportScores:@[boardscore] withCompletionHandler:^(NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = _appDelegate.leaderboardIdentifier;
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [[CCDirector sharedDirector] presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAd{
    
    if (adIsShowing) {
        [adView setHidden:true];
        adIsShowing = false;
    }else{
        [adView setHidden:false];
        adIsShowing =true;
    }
}


- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
    [self.appDelegate.mpcHandler advertiseSelf:false];
    if (isHost == true) {
        NSString *message = @"host";
        
        
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        if (![self.appDelegate.mpcHandler.session sendData:data
                                                   toPeers:self.appDelegate.mpcHandler.session.connectedPeers
                                                  withMode:MCSessionSendDataReliable
                                                     error:&error]) {
            NSLog(@"[Error] %@", error);
        }
        Hero *temp = opponent;
        opponent = hero;
        hero = temp;
        [hero setHealth:100];
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.mpcHandler.browser dismissViewControllerAnimated:YES completion:nil];
    [self.appDelegate.mpcHandler advertiseSelf:false];
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification {
    // Get the state of the peer.
    int state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    // We care only for the Connected and the Not Connected states.
    // The Connecting state will be simply ignored.
    if (state != MCSessionStateConnecting) {
        [self addOpponent];
    }
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification {
    NSLog(@"got data");
    // Get the user info dictionary that was received along with the notification.
    NSDictionary *userInfoDict = [notification userInfo];
    
    // Convert the received data into a NSString object.
    NSData *receivedData = [userInfoDict objectForKey:@"data"];
    /*NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:receivedData];
    unarchiver.requiresSecureCoding = NO;
    NSValue *value = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    opponent.position = [value CGPointValue];*/
    
    NSString *message =
    [[NSString alloc] initWithData:receivedData
                          encoding:NSUTF8StringEncoding];
    if ([message isEqualToString:@"1"] || [message isEqualToString:@"0"]) {
        opponent.flipX = [message boolValue];
        for (CCSprite *child in opponent.children)
        {
            [child setFlipX:[message boolValue]];
            if (opponent.flipX) {
                [child setPosition:ccp(44, 76)];
                [child setAnchorPoint:ccp(0.69, 0.79)];
            }else{
                [child setPosition:ccp(27, 76)];
                [child setAnchorPoint:ccp(0.38, 0.79)];
            }
        }
    }else if ([message isEqualToString:@"t"] || [message isEqualToString:@"f"]){
        //NSLog(@"%@", message);
        if ([message boolValue]) {
            CCBAnimationManager* animationManager = opponent.userObject;
            // timelines can be referenced and run by name
            [animationManager runAnimationsForSequenceNamed:@"MainWalking"];
        }else{
            [opponent stopAllActions];
        }
    }else if ([message hasPrefix:@"shoot"]){
        message = [message substringFromIndex:5];
        CCSprite *bullet = (CCSprite *)[CCBReader load:@"Bullet"];
        [bullet.physicsBody setCollisionGroup:opponent];
        
        bullet.position = ccp(opponent.position.x + opponent.boundingBox.size.width/2, opponent.position.y + opponent.boundingBox.size.height/2);
        
        
        
        /* calculate the direction vector */
        CGPoint launchDirection = CGPointFromString(message);
        if (launchDirection.x < 0)
        {
            [opponent setFlipX:YES];
            for (CCSprite *child in opponent.children)
            {
                [child setFlipX:YES];
                [child setPosition:ccp(44, 76)];
                [child setAnchorPoint:ccp(0.69, 0.79)];
                [child setRotation:-180 * atan(launchDirection.y/launchDirection.x)/M_PI];
            }
        }
        else
        {
            [opponent setFlipX:NO];
            for (CCSprite *child in opponent.children)
            {
                [child setFlipX:NO];
                [child setPosition:ccp(27, 76)];
                [child setAnchorPoint:ccp(0.38, 0.79)];
                [child setRotation:-180 * atan(launchDirection.y/launchDirection.x)/M_PI];
            }
        }
        
        
        
        [bullet setScale:0.33];
        [bullet setFlipX:!opponent.flipX];
        [bullet.physicsBody setMass:0.05];
        [bullet.physicsBody setAffectedByGravity:YES];
        
        double length = sqrt(pow(launchDirection.x, 2) + pow(launchDirection.y, 2));
        CGPoint unitDir = ccp(launchDirection.x/length, launchDirection.y/length);
        CGPoint force = ccpMult(unitDir, 2000);
        float angle = -180 * atan(launchDirection.y/launchDirection.x)/M_PI;
        [bullet setRotation:angle];    
        
        [levelObjects addChild:bullet];
        [bullet.physicsBody applyForce:force];
        CCBAnimationManager* animationManager = opponent.userObject;
        // timelines can be referenced and run by name
        [animationManager runAnimationsForSequenceNamed:@"MainShoot"];
        
    }else if([message isEqualToString:@"host"]){
        isHost = false;
    }else if ([message hasPrefix:@"velocity"]){
        opponent.physicsBody.velocity = CGPointFromString(message);
        //NSLog(@"%@", message);
    }else{
        opponent.position = CGPointFromString(message);
    }
    
}

- (void)addOpponent{
    multiPlayerMode = true;
    opponent.position = ccp(330, 50);
    [physicsNodeMS addChild:opponent];
    [opponent setZOrder:1];
    [opponent.physicsBody setMass:1];
    [opponent.physicsBody setAllowsRotation:false];
    [opponent.physicsBody setCollisionGroup:opponent];
    
    
    [self schedule:@selector(sendPositionData) interval:0.1];
    [self schedule:@selector(updateOpponentVelocity) interval:.3];
    //[self schedule:@selector(correctOpponentPosition) interval:.7];
    
}

- (void)sendPositionData{
    /*NSCoder *coder;
    NSValue *value = [NSValue valueWithCGPoint:hero.position];
    [coder encodeObject:value];
    NSLog(@"%@",coder);
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];*/
    NSLog(@"%d",self.walking);
    if (multWalk != self.walking){
        NSString *message3;
        if (self.walking) {
            message3 = @"t";
        }else{
           message3 = @"f";
        }
        
        NSData *data3 = [message3 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error3 = nil;
        if (![self.appDelegate.mpcHandler.session sendData:data3
                                                   toPeers:self.appDelegate.mpcHandler.session.connectedPeers
                                                  withMode:MCSessionSendDataReliable
                                                     error:&error3]) {
            NSLog(@"[Error] %@", error3);
        }
        multWalk = self.walking;
    }
    
    if (oldFlip != hero.flipX){
        NSString *message2 = [NSString stringWithFormat:@"%d", hero.flipX];
        NSData *data2 = [message2 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error2 = nil;
        if (![self.appDelegate.mpcHandler.session sendData:data2
                                                   toPeers:self.appDelegate.mpcHandler.session.connectedPeers
                                                  withMode:MCSessionSendDataReliable
                                                     error:&error2]) {
            NSLog(@"[Error] %@", error2);
        }
        oldFlip = hero.flipX;
    }

    
    
}

- (void) correctOpponentPosition{
    NSString *message = [NSString stringWithFormat:@"%@", NSStringFromCGPoint(hero.position)];
     
     
     NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
     
     NSError *error = nil;
     if (![self.appDelegate.mpcHandler.session sendData:data
     toPeers:self.appDelegate.mpcHandler.session.connectedPeers
     withMode:MCSessionSendDataReliable
     error:&error]) {
     NSLog(@"[Error] %@", error);
     }
}

- (void) updateOpponentVelocity{
    NSString *message = [NSString stringWithFormat:@"velocity%@", NSStringFromCGPoint(hero.physicsBody.velocity)];
    
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    if (![self.appDelegate.mpcHandler.session sendData:data
                                               toPeers:self.appDelegate.mpcHandler.session.connectedPeers
                                              withMode:MCSessionSendDataReliable
                                                 error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}

- (void) opponentShootWithLaunchDirection:(CGPoint )launchDirection{
    
    NSString *message = [NSString stringWithFormat:@"shoot%@", NSStringFromCGPoint(launchDirection)];
    
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    if (![self.appDelegate.mpcHandler.session sendData:data
                                               toPeers:self.appDelegate.mpcHandler.session.connectedPeers
                                              withMode:MCSessionSendDataReliable
                                                 error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}
- (void) startWalking
{
    if (!self.walking)
    {
        self.walking = true;
        // the animation manager of each node is stored in the 'userObject' property
        CCBAnimationManager* animationManager = hero.userObject;
        // timelines can be referenced and run by name
        [animationManager runAnimationsForSequenceNamed:@"MainWalking"];
    }
}

- (void) pauseWalking
{
    [hero stopAllActions];
    self.walking = false;
    
}



@end
