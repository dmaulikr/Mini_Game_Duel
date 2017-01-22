//
//  JWSubmarineDashScene.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWSubmarineDashScene.h"
#import "JWSubmarineDashPlayerSprite.h"
#import "JWSubmarineDashGameSprite.h"

static const int kNumOfPlayers = 2;
static const int kNoPlayer = -1;
static const int kAliasPadding = 10;
static const int kScorePadding = 20;
static const int kFontSizeAlias = 15;
static const int kFontSizeScore = 25;

static const int kMaxCoins = 10;

static const int kTitleFontSize = 25;
static const int kTitlePadding = 25;

static const int kDirectionsFontSize = 20;
static const int kDirectionsPadding = 65;
static const int kDirectionsLimit = 2;
static const float kDirectionsFade = 0.5;

static const int kGroundHeight = 2;
static const int kMiddleBarrierHeight = 15;
static const int kDeletionPadding = 300;

static const float kGravityX = 0.0;
static const float kGravityY = -6.0;

static const float kImpulseX = 0.0;
static const float kImpulseY = 2.5;

static NSString *kBackgroundName = @"underwater2.png";
static const int kBackGroundSpeed = 4;
static const int kBackGroundZ = -2;

@interface JWSubmarineDashScene () <SKPhysicsContactDelegate>

@property NSMutableArray *playersArray;
@property (nonatomic)  NSInteger currentPlayerIndex;
@property JWSubmarineDashPlayerSprite *currentPlayerSprite;
@property JWSubmarineDashPlayerSprite *oppPlayerSprite;

@property SKLabelNode *title;
@property SKLabelNode *directions;
@property SKLabelNode *aliasPlayer1;
@property SKLabelNode *aliasPlayer2;
@property SKLabelNode *currentScorePlayer1;
@property SKLabelNode *currentScorePlayer2;

@property CGFloat middleOfScene;
@property BOOL directionsFaded;

@property SKAction *moveAndRemoveSprite;
@property SKAction *moveUpThenDownForever;
@property SKAction *moveAndRemoveSeaweed;

@property SKTexture *seaweedT1;
@property SKTexture *seaweedT2;
@property SKTexture *seaweedT1Flipped;
@property SKTexture *seaweedT2Flipped;
@property SKTexture *enemy1;
@property SKTexture *coin;
@property SKTexture *coin2;
@property SKTexture *explosion1;
@property SKTexture *explosion2;
@property SKTexture *explosion3;

@property CGPoint enemy1TopStartingPoint;
@property CGPoint enemy1BottomStartingPoint;
@property CGPoint coinTopPosition;
@property CGPoint coinBottomPosition;
@property CGPoint coin2TopPosition;
@property CGPoint coin2BottomPosition;

@property NSInteger seaweedT1PositionY;
@property NSInteger seaweedT2PositionY;
@property NSInteger seaweedT1FlippedPositionY;
@property NSInteger seaweedT2FlippedPositionY;

@end

@implementation JWSubmarineDashScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self initializeScene];
        [self startGame];
        
        _networkingEngine = [JWSubmarineDashMultiplayerNetworking sharedMultiNetworking];
        _networkingEngine.multiNetworkingSubDashDelegate = self;
        
        _masterNetworkingEngine = [JWMasterMultiplayerNetworking sharedMultiNetworking];
        
        // Alert MutliplayerNetworking that SubDash is ready
        [[NSNotificationCenter defaultCenter] postNotificationName:SubDashIsReady object:nil];

    }
    return self;
}

-(void) initializeScene{
    
    [self setupInitialConstraints];
    [self createPlayers];
    [self createOceanBackground];
    [self createBarriers];
    [self createTitleLabel];
    [self createDirectionsLabel];
    [self setupAliasLabels];
    [self setupCurrentScoreLabels];
    [self initializeMoveAndRemoveGameSpriteAction];
    [self initializeAnimateSpriteAction];
    [self startSpawningGameSpriteWithTexture:_enemy1 ofCategory:CollisionCategoryEnemy withDelay:3.0];
    [self startSpawningGameSpriteWithTexture:_coin ofCategory:CollisionCategoryCoin withDelay:1.3];
    [self startSpawningGameSpriteWithTexture:_coin2 ofCategory:CollisionCategoryCoin withDelay:3.3];
    [self startSpawningGameSpriteWithTexture:_seaweedT1 ofCategory:CollisionCategoryEnemy withDelay:3.3];
    [self startSpawningGameSpriteWithTexture:_seaweedT2 ofCategory:CollisionCategoryEnemy withDelay:3.3];
    [self startSpawningGameSpriteWithTexture:_seaweedT1Flipped ofCategory:CollisionCategoryEnemy withDelay:5.3];
    [self startSpawningGameSpriteWithTexture:_seaweedT2Flipped ofCategory:CollisionCategoryEnemy withDelay:5.3];
    
}

-(void)setupInitialConstraints{
    
    self.seaweedT1 = [SKTexture textureWithImageNamed:@"seaweedCorrect.png"];
    self.seaweedT2 = [SKTexture textureWithImageNamed:@"seaweedCorrect.png"];
    self.seaweedT1Flipped = [SKTexture textureWithImageNamed:@"seaweedFlippedCorrect.png"];
    self.seaweedT2Flipped = [SKTexture textureWithImageNamed:@"seaweedFlippedCorrect.png"];
    
    self.enemy1 = [SKTexture textureWithImageNamed:@"seahorse2.png"];
    self.coin = [SKTexture textureWithImageNamed:@"coin1.png"];
    self.coin2 = [SKTexture textureWithImageNamed:@"coin1.png"];
    
    self.explosion1 = [SKTexture textureWithImageNamed:@"explosion1.png"];
    self.explosion2 = [SKTexture textureWithImageNamed:@"explosion2.png"];
    self.explosion3 = [SKTexture textureWithImageNamed:@"explosion3.png"];
    
    self.seaweedT1.filteringMode = SKTextureFilteringNearest;
    self.seaweedT2.filteringMode = SKTextureFilteringNearest;
    self.seaweedT1Flipped.filteringMode = SKTextureFilteringNearest;
    self.seaweedT2Flipped.filteringMode = SKTextureFilteringNearest;
    
    self.enemy1.filteringMode = SKTextureFilteringNearest;
    self.coin.filteringMode = SKTextureFilteringNearest;
    self.coin2.filteringMode = SKTextureFilteringNearest;
    
    self.explosion1.filteringMode = SKTextureFilteringNearest;
    self.explosion2.filteringMode = SKTextureFilteringNearest;
    self.explosion3.filteringMode = SKTextureFilteringNearest;
    
    self.physicsWorld.gravity = CGVectorMake(kGravityX, kGravityY);
    self.physicsWorld.contactDelegate = self;
    
    self.view.userInteractionEnabled = YES;
    self.middleOfScene = CGRectGetMidY(self.frame);
    self.directionsFaded = NO;
    
    self.enemy1TopStartingPoint = CGPointMake(self.frame.size.width, _middleOfScene+_middleOfScene/2);
    self.enemy1BottomStartingPoint = CGPointMake(self.frame.size.width, _middleOfScene-_middleOfScene/2);
    
    self.coinTopPosition = CGPointMake(self.frame.size.width, _middleOfScene+_middleOfScene/1.5);
    self.coinBottomPosition = CGPointMake(self.frame.size.width, _middleOfScene-_middleOfScene/1.5);
    
    self.coin2TopPosition = CGPointMake(self.frame.size.width, _middleOfScene+_middleOfScene/2.5);
    self.coin2BottomPosition = CGPointMake(self.frame.size.width, _middleOfScene-_middleOfScene/2.5);
    
    self.seaweedT1PositionY =  _middleOfScene + kMiddleBarrierHeight/2;
    self.seaweedT2PositionY =  kGroundHeight;
    
    self.seaweedT1FlippedPositionY = self.frame.size.height;
    self.seaweedT2FlippedPositionY =  _middleOfScene - kMiddleBarrierHeight/2;
}

-(void)startGame{
    
    self.gameOver = NO;
    
}

#pragma mark - Create and Remove the Labels

-(void)createTitleLabel {
    
    _title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    _title.text = @"SUBMARINE DASH!";
    _title.fontSize = kTitleFontSize;
    _title.position = CGPointMake(CGRectGetMidX(self.frame),
                                  self.frame.size.height-(_title.frame.size.height + kTitlePadding));
    
    [self addChild:_title];
}

-(void)createDirectionsLabel{
    
    _directions = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    _directions.text = @"Collect 10 coins to Win!!";
    _directions.fontSize = kDirectionsFontSize;
    _directions.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height-(_directions.frame.size.height + kDirectionsPadding));
    
    [self addChild:_directions];
    
    [self performSelector:@selector(fadeDirections) withObject:nil afterDelay:kDirectionsLimit];
    
}

-(void)setupAliasLabels{
    
    self.aliasPlayer1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.aliasPlayer1.fontSize = kFontSizeAlias;
    self.aliasPlayer1.zPosition = 2;
    
    self.aliasPlayer2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.aliasPlayer2.fontSize = kFontSizeAlias;
    self.aliasPlayer2.zPosition = 2;

}

-(void)setupCurrentScoreLabels{
    
    _currentScorePlayer1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _currentScorePlayer1.fontSize = kFontSizeScore;
    _currentScorePlayer1.zPosition = 2;
    _currentScorePlayer1.position = CGPointMake(self.frame.size.width-kScorePadding, self.frame.size.height-kScorePadding*2);
    _currentScorePlayer1.text = [NSString stringWithFormat:@"%d", 0];
    [self addChild:_currentScorePlayer1];
    
    _currentScorePlayer2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _currentScorePlayer2.fontSize = kFontSizeScore;
    _currentScorePlayer2.zPosition = 2;
    _currentScorePlayer2.position = CGPointMake(self.frame.size.width-kScorePadding, _middleOfScene-kMiddleBarrierHeight-kScorePadding);
    _currentScorePlayer2.text = [NSString stringWithFormat:@"%d", 0];
    [self addChild:_currentScorePlayer2];

}


-(void)fadeDirections{
    
    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration:kDirectionsFade];
    [_title runAction:fade];
    [_directions runAction:fade completion:^{
        _directionsFaded = YES;
        
        // Physics body and collisions and collision detection
        [_currentPlayerSprite addPhysicsBody];
        [self addMasksToSub:_currentPlayerSprite];

        // Physics body so it looks like other player and also barrier detection -- nothing else
        [_oppPlayerSprite addPhysicsBody];
        [self addMasksToSub:_oppPlayerSprite];

    }];
}

-(void)addMasksToSub:(JWSubmarineDashPlayerSprite*)player{
    
    if(player == _currentPlayerSprite){
        player.physicsBody.categoryBitMask = CollisionCategorySub;
        player.physicsBody.collisionBitMask = CollisionCategoryBarrier;
        player.physicsBody.contactTestBitMask = CollisionCategoryEnemy | CollisionCategoryCoin;
    }
    else{
        player.physicsBody.categoryBitMask = CollisionCategoryOppSub;
        player.physicsBody.collisionBitMask = CollisionCategoryBarrier;
        player.physicsBody.contactTestBitMask = CollisionCategoryCoin;
    }
    
}

#pragma mark - Create Players and Background

-(void)createPlayers{
    
    self.playersArray = [NSMutableArray arrayWithCapacity:kNumOfPlayers];
    
    CGFloat playersStartingX = self.frame.size.width/4;
    
    CGFloat playerOneStartingY = _middleOfScene + kMiddleBarrierHeight + 15;
    CGFloat playerTwoStartingY = kGroundHeight + 15;
    
    CGPoint playerOnePosition = CGPointMake(playersStartingX, playerOneStartingY);
    CGPoint playerTwoPosition = CGPointMake(playersStartingX, playerTwoStartingY);
    
    [self setupPlayer:kPlayerOne withImage:@"submarine3.png" atPosition:playerOnePosition];
    [self setupPlayer:kPlayerTwo withImage:@"submarine3.png" atPosition:playerTwoPosition];
    
}

-(void)setupPlayer:(NSInteger)playerType withImage:(NSString*)imageName atPosition:(CGPoint)playerPosition{
    
    JWSubmarineDashPlayerSprite *player = [[JWSubmarineDashPlayerSprite alloc] initWithType:playerType image:imageName];
    player.position = playerPosition;
    [self.playersArray addObject:player];
    [self addChild:player];
    
}

-(void)createOceanBackground{
    
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:kBackgroundName];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.name = kBackgroundName;
        bg.zPosition = kBackGroundZ;
        [self addChild:bg];
    }
}

#pragma mark - Create Barriers for Sky, Middle, Ground

-(void)createBarriers{
    
    CGSize groundBarrierSize = CGSizeMake(self.frame.size.width, kGroundHeight * 2);
    CGSize skyBarrierSize = CGSizeMake(self.frame.size.width, kGroundHeight * 2);
    CGSize middleBarrierSize = CGSizeMake(self.frame.size.width, kMiddleBarrierHeight);
    
    CGPoint groundPosition = CGPointMake(self.frame.size.width/2, kGroundHeight);
    CGPoint skyPosition = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    CGPoint middlePosition = CGPointMake(self.frame.size.width/2, _middleOfScene);
    
    [self createBarrierOfSize:groundBarrierSize atPosition:groundPosition];
    [self createBarrierOfSize:skyBarrierSize atPosition:skyPosition];
    [self createBarrierOfSize:middleBarrierSize atPosition:middlePosition];
    
}

// Creates a rectangular empty sprite to act as the boundaries for the game (i.e. for collisions)
-(void)createBarrierOfSize:(CGSize)size atPosition:(CGPoint)position{
    
    SKSpriteNode *barrier = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:size];
    barrier.position = position;
    barrier.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    barrier.physicsBody.dynamic = NO;
    barrier.physicsBody.categoryBitMask = CollisionCategoryBarrier;
    [self addChild:barrier];
    
}

#pragma mark - Create, Setup, Spawn Game Sprites

-(void)startSpawningGameSpriteWithTexture:(SKTexture*)texture ofCategory:(uint32_t)category withDelay:(CGFloat)delayTime{
    
    SKAction *spawn = [SKAction runBlock:^{
        [self setupGameSpriteForSpawning:texture ofCategory:category];
    }];
    
    SKAction *delay = [SKAction waitForDuration:delayTime];
    SKAction *delayThenSpawn = [SKAction sequence:@[delay, spawn]];
    SKAction *delayThenSpawnForever = [SKAction repeatActionForever:delayThenSpawn];
    [self runAction:delayThenSpawnForever];
    
}

-(void)setupGameSpriteForSpawning:(SKTexture*)texture ofCategory:(uint32_t)category{
    
    float scale = 1.0;
    
    // Determines where we should spawn
    BOOL spawnTop = YES;
    BOOL spawnBottom = YES;
    if(_currentPlayerSprite.isCurrentlyExploding || !_networkingEngine.startUpdatingGame){
        if(self.currentPlayerIndex == kPlayerOne){
            spawnTop = NO;
        }else{
            spawnBottom = NO;
        }
    }
    
    if(_oppPlayerSprite.isCurrentlyExploding || !_networkingEngine.startUpdatingGame){
        if (self.currentPlayerIndex == kPlayerOne) {
            spawnBottom = NO;
        }else{
            spawnTop = NO;
        }
    }
    
    JWSubmarineDashGameSprite *sprite1, *sprite2;
    if(spawnTop){
        sprite1 = [[JWSubmarineDashGameSprite alloc] initWithTexture:texture withScale:scale ofCategory:category];
        if(sprite1.texture == _enemy1){
            sprite1.position = _enemy1TopStartingPoint;
        } else if(sprite1.texture == _coin){
            sprite1.position = _coinTopPosition;
        }else if(sprite1.texture == _seaweedT1){
            sprite1.position = CGPointMake(self.frame.size.width, _seaweedT1PositionY + sprite1.size.height/2);
        }else if(sprite1.texture == _seaweedT1Flipped){
            sprite1.position = CGPointMake(self.frame.size.width, _seaweedT1FlippedPositionY - sprite1.size.height/2);
        }else if(sprite1.texture == _coin2){
            sprite1.position = _coin2TopPosition;
        }
        [self spawnGameSprite:sprite1];
    }
    if(spawnBottom){
        sprite2 = [[JWSubmarineDashGameSprite alloc] initWithTexture:texture withScale:scale ofCategory:category];
        if(sprite2.texture == _enemy1){
            sprite2.position = _enemy1BottomStartingPoint;
        }else if(sprite2.texture == _coin){
            sprite2.position = _coinBottomPosition;
        }else if(sprite2.texture == _seaweedT2){
            sprite2.position = CGPointMake(self.frame.size.width, _seaweedT2PositionY+sprite2.size.height/2);
        }else if(sprite2.texture == _seaweedT2Flipped){
            sprite2.position = CGPointMake(self.frame.size.width, _seaweedT2FlippedPositionY-sprite2.size.height/2);
        }else if(sprite2.texture == _coin2){
            sprite2.position = _coin2BottomPosition;
            
        }
        [self spawnGameSprite:sprite2];
    }
}

-(void)spawnGameSprite:(JWSubmarineDashGameSprite*)sprite {
    
    [sprite runAction:_moveAndRemoveSprite];
    if(sprite.texture == _enemy1){
        [sprite runAction:_moveUpThenDownForever];
    }
    [self addChild:sprite];
    
}

#pragma mark - Define actions

-(void)initializeAnimateSpriteAction{
    
    SKAction *moveUp = [SKAction moveByX:0 y:10 duration:0.2];
    SKAction *delay = [SKAction waitForDuration:0.1];
    SKAction *moveDown = [SKAction moveByX:0 y:-10 duration:0.2];
    _moveUpThenDownForever = [SKAction repeatActionForever:[SKAction sequence:@[moveUp, delay, moveDown]]];
    
}

-(void)initializeMoveAndRemoveGameSpriteAction{
    
    CGFloat distanceToMove = self.frame.size.width + kDeletionPadding;
    SKAction *moveSprite = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
    SKAction *removeSprite = [SKAction removeFromParent];
    _moveAndRemoveSprite = [SKAction sequence:@[moveSprite, removeSprite]];
    
}

#pragma mark - SKPhysicsContactDelegate

-(void)didBeginContact:(SKPhysicsContact*)contact{
    
    // Determine which body belongs to a sub and which belongs to a collision object
    SKNode *subSprite = (contact.bodyA.node == _currentPlayerSprite || contact.bodyA.node == _oppPlayerSprite)
                                                ? contact.bodyA.node : contact.bodyB.node;
    
    SKNode *otherSprite = (contact.bodyA.node != _currentPlayerSprite) ? contact.bodyA.node : contact.bodyB.node;
    
    // If current player hit a coin, remove it and add one to collected coins
    if((otherSprite.physicsBody.categoryBitMask == CollisionCategoryCoin) &&
                                                (subSprite.physicsBody.categoryBitMask == CollisionCategorySub)){
        [otherSprite removeFromParent];
        [_networkingEngine sendCollectedCoin];
        [_currentPlayerSprite addOneToCollectedCoins];
        [self updateScoreLabelsWithIndex:_currentPlayerIndex];
        NSLog(@"Collected %ld coins", (long)[_currentPlayerSprite coinsCollected]);

        if(_currentPlayerSprite.coinsCollected == kMaxCoins){
            self.gameOver = YES;
        }
        
    // If other player on my screen hit a coin, remove it - this way I don't need to send a message to remove it
    }else if ((otherSprite.physicsBody.categoryBitMask == CollisionCategoryCoin) &&
                                                (subSprite.physicsBody.categoryBitMask == CollisionCategoryOppSub)){
        [otherSprite removeFromParent];
    }
    else if(subSprite.physicsBody.categoryBitMask == CollisionCategorySub){
        [_networkingEngine sendExplode];
        [self clearPlayersScreen:_currentPlayerSprite];
        [self showExplosionOnPlayer:_currentPlayerSprite];
    }
}

// Simulates the sub exploding when it hits an enemy and updates scene accordingly
-(void)showExplosionOnPlayer:(JWSubmarineDashPlayerSprite*)player{
    
    SKAction *explode = [SKAction repeatAction:[SKAction animateWithTextures:@[_explosion1, _explosion2, _explosion3] timePerFrame:0.2] count:3];
    
    SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:_explosion1];
    explosion.position = CGPointMake(player.position.x, player.position.y);
    explosion.zPosition = 10;
    [self addChild:explosion];
    
    player.hidden = YES;
    player.physicsBody = nil;
    
    // Turn off enemy spawning for the current player until the explosion is over
    player.isCurrentlyExploding = YES;
    
    [explosion runAction:explode completion:^{
        [explosion removeFromParent];
        player.hidden = NO;
        [player addPhysicsBody];
        [self addMasksToSub:player];
        player.isCurrentlyExploding = NO;
    }];
}

// Clears the current player's screen when they hit an enemy so they can't accumulate coins for a brief period
-(void)clearPlayersScreen:(JWSubmarineDashPlayerSprite*)player{
    
    NSArray *nodes = [self children];
    
    if(player.position.y > _middleOfScene){
        for (SKNode *node in nodes) {
            if(node.position.y > _middleOfScene){
                if([node.name  isEqual: kSpriteName]){
                    [node removeFromParent];
                }
            }
        }
    }else{
        for (SKNode *node in nodes) {
            if(node.position.y < _middleOfScene){
                if([node.name  isEqual: kSpriteName]){
                    [node removeFromParent];
                }
            }
        }
    }
}

-(void)addPointsToWinner:(BOOL)localPlayerWon{
    
    // Add the game points to the winning players index and blow up the loser
    NSInteger otherPlayerIndex = (self.currentPlayerIndex == kPlayerOne) ? kPlayerTwo : kPlayerOne;
    NSNumber *pointsToAdd = _masterNetworkingEngine.selectedPointWorthOfMiniGame;
    NSLog(@"Sub Dash - selectedPointsWorth= %li", (long)[_masterNetworkingEngine.selectedPointWorthOfMiniGame integerValue]);
    if(localPlayerWon){
        NSNumber *currentPts = [_masterNetworkingEngine.pointsOfPlayers objectAtIndex:_currentPlayerIndex];
        NSInteger totalPts = [pointsToAdd integerValue] + [currentPts integerValue];
        [_masterNetworkingEngine.pointsOfPlayers setObject:[NSNumber numberWithInteger:totalPts] atIndexedSubscript:self.currentPlayerIndex];
        [self showExplosionOnPlayer:[_playersArray objectAtIndex:otherPlayerIndex]];
    }else{
        NSNumber *currentPts = [_masterNetworkingEngine.pointsOfPlayers objectAtIndex:otherPlayerIndex];
        NSInteger totalPts = [pointsToAdd integerValue] + [currentPts integerValue];
        [_masterNetworkingEngine.pointsOfPlayers setObject:[NSNumber numberWithInteger:totalPts] atIndexedSubscript:otherPlayerIndex];
        [self showExplosionOnPlayer:[_playersArray objectAtIndex:_currentPlayerIndex]];
    }
    
}

#pragma mark - Handle Touches and Update Scene

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if(_currentPlayerIndex != kNoPlayer && _networkingEngine.startUpdatingGame){

        if(_directionsFaded && !_gameOver){
            // Reset sub's velocity so impulses don't accumulate
            CGVector velocity = CGVectorMake(0.0, 0.0);
            CGVector impulse = CGVectorMake(kImpulseX, kImpulseY);
            
            [[self.currentPlayerSprite physicsBody] setVelocity:velocity];
            [[self.currentPlayerSprite physicsBody] applyImpulse:impulse];
            
            [_networkingEngine sendMove];
        }
    }
    
    if(_gameOver){
        // End the game and show the winner...
    }
    
}

// Clamps the value to be within {min-max}
CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if(_currentPlayerIndex != kNoPlayer){
    
        if(_networkingEngine.startUpdatingGame){
        
            // Adjust each player's rotation to make it look like its tilted upwards on a tap and downwards when falling
            self.currentPlayerSprite.zRotation = clamp(-2, 2, self.currentPlayerSprite.physicsBody.velocity.dy * (self.currentPlayerSprite.physicsBody.velocity.dy < 0 ? 0.003 : 0.003));
            self.oppPlayerSprite.zRotation = clamp(-2, 2, self.oppPlayerSprite.physicsBody.velocity.dy * (self.oppPlayerSprite.physicsBody.velocity.dy < 0 ? 0.003 : 0.003));
            
            // Constantly move the background
            [self enumerateChildNodesWithName:kBackgroundName usingBlock: ^(SKNode *node, BOOL *stop) {
                SKSpriteNode *bg = (SKSpriteNode*) node;
                bg.position = CGPointMake(bg.position.x - kBackGroundSpeed, bg.position.y);
                if (bg.position.x <= -bg.size.width) {
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y);
                }
            }];
        }
        
        // Have player 1 check if the game is over and send game over message if it is
        if (_currentPlayerIndex == 0 && _networkingEngine.startUpdatingGame) {
            [_playersArray enumerateObjectsUsingBlock:^(JWSubmarineDashPlayerSprite *player, NSUInteger idx, BOOL *stop) {
                if(player.coinsCollected >= kMaxCoins) {
                    BOOL didWin = NO;
                    if (idx == _currentPlayerIndex) {
                        NSLog(@"Won Sub Dash");
                        didWin = YES;
                    } else {
                        NSLog(@"Lost Sub Dash");
                    }
                    
                    _networkingEngine.startUpdatingGame = NO;
                    [_networkingEngine sendGameEnd:didWin];
                    [self addPointsToWinner:didWin];
                    [self performSelector:@selector(sendMiniGameEndedNot) withObject:nil afterDelay:3.0];
                }
            }];
        }
    }
    
}

#pragma mark MultiNetworkingButtonRaceProtocol

-(void)setCurrentPlayerIndex:(NSInteger)index {
    
    _currentPlayerIndex = index;
    NSLog(@"SubDash - My current player index is %lu", (unsigned long)index);
    self.currentPlayerSprite = [self.playersArray objectAtIndex:self.currentPlayerIndex];
    self.currentPlayerSprite.isCurrentlyExploding = NO;

    NSInteger oppIndex = (index == 0) ? 1 : 0;
    NSLog(@"SubDash - My opp player index is %lu", (unsigned long)oppIndex);
    self.oppPlayerSprite = [self.playersArray objectAtIndex:oppIndex];
}

-(void)movePlayerAtIndex:(NSUInteger)index{
    
    CGVector velocity = CGVectorMake(0.0, 0.0);
    CGVector impulse = CGVectorMake(kImpulseX, kImpulseY);
    
    [[_playersArray[index] physicsBody] setVelocity:velocity];
    [[_playersArray[index] physicsBody] applyImpulse:impulse];

}

-(void)explodePlayerAtIndex:(NSUInteger)index{
    
    [self showExplosionOnPlayer:[_playersArray objectAtIndex:index]];
    [self clearPlayersScreen:[_playersArray objectAtIndex:index]];

}

-(void)updateScoreLabelsWithIndex:(NSInteger)index{
    
    if(index == 0 && _currentPlayerIndex == 0){
        _currentScorePlayer1.text = [NSString stringWithFormat:@"%ld", (long)_currentPlayerSprite.coinsCollected];
    }else if(index == 0 && _currentPlayerIndex == 1){
        _currentScorePlayer1.text = [NSString stringWithFormat:@"%ld", (long)_oppPlayerSprite.coinsCollected];
    }else if(index == 1 && _currentPlayerIndex == 0){
        _currentScorePlayer2.text = [NSString stringWithFormat:@"%ld", (long)_oppPlayerSprite.coinsCollected];
    }else{
        _currentScorePlayer2.text = [NSString stringWithFormat:@"%ld", (long)_currentPlayerSprite.coinsCollected];
    }

}

-(void)sendCollectedCoinAtIndex:(NSUInteger)index{
    
    [[_playersArray objectAtIndex:index] addOneToCollectedCoins];
    [self updateScoreLabelsWithIndex:index];
    
}

-(void)setPlayerAliases:(NSArray*)playerAliases{
    // Get each player alias and show them on the selection scene with each players current points underneath
    [playerAliases enumerateObjectsUsingBlock:^(NSString *playerAlias, NSUInteger idx, BOOL *stop) {
        if(idx == kPlayerOne){
            _aliasPlayer1.text = playerAlias;
            self.aliasPlayer1.position = CGPointMake(kAliasPadding+_aliasPlayer1.frame.size.width/2, self.frame.size.height-kAliasPadding*3);
            [self addChild:self.aliasPlayer1];
        }else{
            _aliasPlayer2.text = playerAlias;
            self.aliasPlayer2.position = CGPointMake(kAliasPadding+_aliasPlayer2.frame.size.width/2, _middleOfScene-kMiddleBarrierHeight-kAliasPadding);
            [self addChild:self.aliasPlayer2];
        }
    }];
}


-(void)miniGameEnded:(BOOL)player1Won{

    BOOL didLocalPlayerWin = YES;
    if (player1Won) {
        didLocalPlayerWin = NO;
    }
    
    [self addPointsToWinner:didLocalPlayerWin];
    [self performSelector:@selector(sendMiniGameEndedNot) withObject:nil afterDelay:2.5];
}

-(void)sendMiniGameEndedNot{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MiniGameEnded object:nil];

}

@end

