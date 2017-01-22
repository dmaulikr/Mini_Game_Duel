//
//  JWButtonRaceScene.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/24/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//


// Notes -
// May want to make it "scroll" so tht if person moves off screen, screen moves with them...future use

#import "JWGameKitHelper.h"
#import "JWPlayerSprite.h"
#import "JWButtonRaceScene.h"
#import "JWToggleButton.h"
#import "JWButtonRacePlayerSprite.h"

static const int kFontSize = 25;
static const int kDirectionsLabelFontSize = 20;
static const int kTitlePadding = 25;

static const float kGameCountDownTime = 8;
static const int kGameCountDownXPadding = 25;
static const int kGameCountDownYPadding = 40;
static const int kDirectionsLabelPadding = 75;

static const int kNumOfPlayers = 2;
static const int kNoPlayer = -1;

static const int kPlayerOneStartingX = 100;
static const int kPlayerTwoStartingX = 200;

static const int kPlayerOneStartingY = 25;
static const int kPlayerTwoStartingY = 25;

static const int kBackgroundSpeed = 1;
static NSString *kBackgroundName = @"kBackground";

@interface JWButtonRaceScene ()

@property (nonatomic,strong) NSMutableArray *playersArray;
@property NSInteger currentPlayer;

@property JWToggleButton *toggleButton;
@property SKLabelNode *gameCountDownLabel;
@property SKLabelNode *directionsLabel;

@property CFTimeInterval startTime;
@property CFTimeInterval elapsedTime;

@property BOOL countDownInProgress;
@property BOOL first;
@property BOOL notificationSent;
@property BOOL moveBackground;

@property SKTexture *explosion1;
@property SKTexture *explosion2;
@property SKTexture *explosion3;

@end

@implementation JWButtonRaceScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self initializeScene];
        [self startGame];
        _networkingEngine = [JWButtonRaceMultiplayerNetworking sharedMultiNetworking];
        _networkingEngine.multiNetworkingButtonRaceDelegate = self;
        
        _masterNetworkingEngine = [JWMasterMultiplayerNetworking sharedMultiNetworking];
        
        // Alert MutliplayerNetworking that ButtonRace is ready
        [[NSNotificationCenter defaultCenter] postNotificationName:ButtonRaceIsReady object:nil];

    }
    return self;
    
}

-(void) initializeScene{
    
    self.view.userInteractionEnabled = YES;
    [self createTitleLabel];
    [self setupBackground];
    [self createPlayers];
    [self createPlayButton];
    [self createGameCountDownLabel];
    [self createDirectionsLabel];
    
    self.explosion1 = [SKTexture textureWithImageNamed:@"explosion1.png"];
    self.explosion2 = [SKTexture textureWithImageNamed:@"explosion2.png"];
    self.explosion3 = [SKTexture textureWithImageNamed:@"explosion3.png"];
    
    self.explosion1.filteringMode = SKTextureFilteringNearest;
    self.explosion2.filteringMode = SKTextureFilteringNearest;
    self.explosion3.filteringMode = SKTextureFilteringNearest;
}

-(void)setupBackground{
    
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"sky2.png"];
    bg.anchorPoint = CGPointZero;
    bg.position = CGPointMake(0, 0);
    bg.name = kBackgroundName;
    bg.zPosition = -2;
    [self addChild:bg];
    
    _moveBackground = NO;
    
}

-(void) startGame{
    
    self.currentPlayer = kNoPlayer;
    self.countDownInProgress = YES;
    self.first = YES;
    self.notificationSent = NO;

}


# pragma mark - Create Nodes For Initial Display

- (void)createTitleLabel {
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    title.text = @"Space Race!";
    title.fontSize = kFontSize;
    title.position = CGPointMake(CGRectGetMidX(self.frame),
                                 self.frame.size.height-(title.frame.size.height + kTitlePadding));
    
    [self addChild:title];
}

-(void)createPlayers{
    
    self.playersArray = [NSMutableArray arrayWithCapacity:kNumOfPlayers];
    
    JWButtonRacePlayerSprite *playerOne = [[JWButtonRacePlayerSprite alloc] initWithType:kPlayerOne image:@"rocket.png"];
    JWButtonRacePlayerSprite *playerTwo = [[JWButtonRacePlayerSprite alloc] initWithType:kPlayerTwo image:@"rocket.png"];
    
    playerOne.position = CGPointMake(kPlayerOneStartingX, kPlayerOneStartingY);
    playerTwo.position = CGPointMake(kPlayerTwoStartingX, kPlayerTwoStartingY);
    
    [self.playersArray addObject:playerOne];
    [self.playersArray addObject:playerTwo];
    
    [self addChild:playerOne];
    [self addChild:playerTwo];
    
}

-(void)createPlayButton{
    
    self.toggleButton = [JWToggleButton new];
    self.toggleButton = [[JWToggleButton alloc] initWithImageNamed:@"start_button.png" andState:kOn];
    self.toggleButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-self.toggleButton.size.height/2-self.toggleButton.size.height/4);
    [self addChild:self.toggleButton];
}

-(void)createGameCountDownLabel{
    
    self.gameCountDownLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    self.gameCountDownLabel.position = CGPointMake(CGRectGetMidX(self.frame)-kGameCountDownXPadding, CGRectGetMidY(self.frame)+kGameCountDownYPadding);
    self.gameCountDownLabel.fontSize = kFontSize;
    self.gameCountDownLabel.text = [NSString stringWithFormat:@"%.02f", kGameCountDownTime];
    [self.gameCountDownLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [self addChild:self.gameCountDownLabel];
    
}

-(void)createDirectionsLabel{
    
    self.directionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.directionsLabel.fontSize = kDirectionsLabelFontSize;
    self.directionsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+kDirectionsLabelPadding);
    self.directionsLabel.text = @"Tap the Button!!";
    [self addChild:self.directionsLabel];
    
}

#pragma mark - Handle game touches

// If game button is pressed while the countdown is in progress, add one to that player's tap count
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_currentPlayer != kNoPlayer && _networkingEngine.startCountDown) {
        
        if(self.countDownInProgress){
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInNode:self];
            SKNode *node = [self nodeAtPoint:location];
            
            if ([node isKindOfClass:[JWToggleButton class]]) {
                JWToggleButton *button = (JWToggleButton*) node;
                [button buttonPressed];
                [[self.playersArray objectAtIndex:self.currentPlayer] addOneToTapCount];
            }
        }
    }
}

#pragma mark - Update the scene

// Updates the count down until it reaches 0.00
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if(_currentPlayer != kNoPlayer && _networkingEngine.startCountDown){
        
        if(_first){
            self.startTime = CACurrentMediaTime();
            self.first = NO;
        }
        
        if(_countDownInProgress){
            [self updateCountDownLabel];
        }
        
        if(_moveBackground){
            [self enumerateChildNodesWithName:kBackgroundName usingBlock: ^(SKNode *node, BOOL *stop) {
                SKSpriteNode *bg = (SKSpriteNode*) node;
                bg.position = CGPointMake(bg.position.x, bg.position.y - kBackgroundSpeed);
            }];
        }
        
        // If both players finished moving and we are currently player 1, end the game
        BOOL player1FinishedMoving = [[self.playersArray objectAtIndex:kPlayerOne] finishedMoving];
        BOOL player2FinishedMoving = [[self.playersArray objectAtIndex:kPlayerTwo] finishedMoving];
        BOOL isPlayer1 = (_currentPlayer == 0);
        if(isPlayer1 && player1FinishedMoving && player2FinishedMoving && !_notificationSent){
            BOOL didWin = NO;
            _moveBackground = NO;
            if([[self.playersArray objectAtIndex:kPlayerOne] position].y >= [[self.playersArray objectAtIndex:kPlayerTwo] position].y){
                didWin = YES;
            }
            [_networkingEngine sendGameEnd:didWin];
            [self blowUpLoser:didWin];
            _notificationSent = YES;
            //if(self.miniGameOverBlock){
            //  self.miniGameOverBlock(player1Won);
            //}
            
        } // current player 1
    }
}

-(void) updateCountDownLabel{
    
    _elapsedTime = CACurrentMediaTime() - self.startTime;
    CFTimeInterval remainingTime = kGameCountDownTime - self.elapsedTime;
    
    if (remainingTime < 0){
        _countDownInProgress = NO;
        _moveBackground = YES;

        [_gameCountDownLabel runAction:[SKAction fadeAlphaTo:0.0 duration:0.2] completion:^{
            
            // Update scene
            [_gameCountDownLabel removeFromParent];
            [_toggleButton removeFromParent];
            _directionsLabel.text = @"WHO WON??!";
            
            // Move the players
            JWButtonRacePlayerSprite *curPlayer = [self.playersArray objectAtIndex:self.currentPlayer];
            [curPlayer moveForward];
            [_networkingEngine sendMove:[curPlayer currentTapCount]];
            
            
            NSLog(@"Game Button Pressed %li times", (long)[[self.playersArray objectAtIndex:self.currentPlayer] currentTapCount]);
        }];
        
    }else{
        NSString *time = [NSString stringWithFormat:@"%.02f", remainingTime];
        [_gameCountDownLabel setText:time];
    }
}

-(void)addPointsToWinner:(BOOL)localPlayerWon{
    
    // Add the game points to the winning players index
    NSInteger otherPlayerIndex = (self.currentPlayer == kPlayerOne) ? kPlayerTwo : kPlayerOne;
    NSNumber *pointsToAdd = _masterNetworkingEngine.selectedPointWorthOfMiniGame;
    NSLog(@"ButtonRace - selectedPointsWorth= %li", (long)[_masterNetworkingEngine.selectedPointWorthOfMiniGame integerValue]);
    if(localPlayerWon){
        NSNumber *currentPts = [_masterNetworkingEngine.pointsOfPlayers objectAtIndex:self.currentPlayer];
        NSInteger totalPts = [pointsToAdd integerValue] + [currentPts integerValue];
        [_masterNetworkingEngine.pointsOfPlayers setObject:[NSNumber numberWithInteger:totalPts] atIndexedSubscript:self.currentPlayer];
    }else{
        NSNumber *currentPts = [_masterNetworkingEngine.pointsOfPlayers objectAtIndex:otherPlayerIndex];
        NSInteger totalPts = [pointsToAdd integerValue] + [currentPts integerValue];
        [_masterNetworkingEngine.pointsOfPlayers setObject:[NSNumber numberWithInteger:totalPts] atIndexedSubscript:otherPlayerIndex];
    }
    
}

-(void)blowUpLoser:(BOOL)localPlayerWon{
    
    [self addPointsToWinner:localPlayerWon];
    
    // Blow up the loser
    SKAction *explode = [SKAction repeatAction:[SKAction animateWithTextures:@[_explosion1, _explosion2, _explosion3] timePerFrame:0.1] count:5];
    
    NSInteger otherPlayerIndex = (self.currentPlayer == kPlayerOne) ? kPlayerTwo : kPlayerOne;

    JWButtonRacePlayerSprite *playerWhoLost;
    if(localPlayerWon){
        playerWhoLost = [self.playersArray objectAtIndex:otherPlayerIndex];
    }else{
        playerWhoLost = [self.playersArray objectAtIndex:self.currentPlayer];
    }

    SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:_explosion1];
    explosion.position = CGPointMake(playerWhoLost.position.x, playerWhoLost.position.y);
    explosion.zPosition = 10;
    [self addChild:explosion];
    playerWhoLost.hidden = YES;
    
    [explosion runAction:explode completion:^{
        [explosion removeFromParent];
        [[NSNotificationCenter defaultCenter] postNotificationName:MiniGameEnded object:nil];
    }];
    
}

#pragma mark MultiNetworkingButtonRaceProtocol

-(void) miniGameEnded:(BOOL)player1Won{
    
    BOOL didLocalPlayerWin = YES;
    if (player1Won) {
        didLocalPlayerWin = NO;
    }
    
    [self blowUpLoser:didLocalPlayerWin];
    
    // May have to delay this action so explosion shows
    //[[NSNotificationCenter defaultCenter] postNotificationName:MiniGameEnded object:nil];
    
    //if (self.miniGameOverBlock) {
      //  self.miniGameOverBlock(didLocalPlayerWin);
    //}
    
}

- (void)setCurrentPlayerIndex:(NSUInteger)index {
    _currentPlayer = index;
    NSLog(@"ButtonDash - My current player index is %lu", (unsigned long)index);
}

-(void)movePlayerAtIndex:(NSUInteger)index distance:(NSInteger)dist{
    [_playersArray[index] moveForward:dist];
}

- (void)setPlayerAliases:(NSArray*)playerAliases {
    [playerAliases enumerateObjectsUsingBlock:^(NSString *playerAlias, NSUInteger idx, BOOL *stop) {
        [_playersArray[idx] setPlayerAliasText:playerAlias];
    }];
}

// Sequence Example
/*
 SKAction *wait = [SKAction waitForDuration:0.5];
 SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.2];
 
 SKAction *sequence = [SKAction sequence:@[wait, fadeOut]];
 
 [self.gameCountDownLabel runAction: sequence completion:^{
 [self.gameCountDownLabel removeFromParent];
 }];
 */

@end


