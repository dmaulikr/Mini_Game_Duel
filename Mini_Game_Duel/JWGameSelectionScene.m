//
//  JWGameSelectionScene.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/22/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWMasterMultiplayerNetworking.h"
#import "JWGameSelectionScene.h"
#import "JWSubmarineDashScene.h"
#import "JWButtonRaceScene.h"

static const int kFontSize = 25;
static const int kFontSizeAlias = 20;

static const int kTitlePadding = 25;
static const int kArrowPadding = 95;
static const int kInBetweenGamePadding = 55;
static const int kInitialGamePadding = 100;
static const int kCurrentScorePadding = 40;
static const int kAliasPadding = 10;

static const int kPointsPaddingX = 30;
static const int kPointsPaddingY = 5;

static const int kPlayerOne = 0;
static const int kPlayerTwo = 1;
static const int kMiniGameStartingPts = 0;

static const float kMoveArrowAction = 0.05;
static const float kWaitBeforeGameTransition = 1.0;
static const float kTransitionAnimation = 1.0;

typedef NS_ENUM(NSUInteger, ArrowPositions){
    kMiniGameOne,
    kMiniGameTwo,
    kMiniGameThree
};

// While waiting for selection, have players (submarines, rockets) move around at the button of the screen. Do something to the ones
// that get selected

@interface JWGameSelectionScene ()

// Coordinates specify where to place the mini game titles on the view
@property CGFloat miniGameXCoord;
@property CGFloat miniGameOneYCoord;
@property CGFloat miniGameTwoYCoord;
@property CGFloat miniGameThreeYCoord;
@property CGFloat selectionArrowXCoord;

@property (nonatomic,strong) SKSpriteNode *miniGameOne;
@property (nonatomic,strong) SKSpriteNode *miniGameTwo;
@property (nonatomic,strong) SKSpriteNode *miniGameThree;

@property (nonatomic,strong) SKLabelNode *miniGameOnePointsLabel;
@property (nonatomic,strong) SKLabelNode *miniGameTwoPointsLabel;
@property (nonatomic,strong) SKLabelNode *miniGameThreePointsLabel;

@property (nonatomic,strong) NSNumber *miniGameOnePointValue;
@property (nonatomic,strong) NSNumber *miniGameTwoPointValue;
@property (nonatomic,strong) NSNumber *miniGameThreePointValue;

@property (nonatomic,strong) SKLabelNode *aliasPlayer1;
@property (nonatomic,strong) SKLabelNode *aliasPlayer2;

@property (nonatomic,strong) SKLabelNode *currentPointsPlayer1;
@property (nonatomic,strong) SKLabelNode *currentPointsPlayer2;

@property (nonatomic,strong) SKSpriteNode *selectionArrow;

@property ArrowPositions arrowPosition;

@property (nonatomic,strong) NSMutableArray *arrowActionsArray;

@end

@implementation JWGameSelectionScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.view.userInteractionEnabled = YES;
        [self setupBackground];
        [self setupButtonLocations];
        [self setupAliasLabels];
        [self setupCurrentPointLabels];
        [self createTitleLabel];
        [self createMiniGameButtons];
        [self setupMiniGamePointsLabels];
        [self createSelectionArrow];
        
        self.arrowActionsArray = [[NSMutableArray alloc] init];
        
        _networkingEngine = [JWMasterMultiplayerNetworking sharedMultiNetworking];
        _networkingEngine.multiNetworkSelectionDelegate = self;
        
        _gameKitHelper = [JWGameKitHelper sharedGameKitHelper];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectMiniGame:)
                                                     name:RandomNumberReady object:nil];
        
    }
    
    return self;
}


 -(void)setupBackground{
 
     SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"plain3.png"];
     bg.anchorPoint = CGPointZero;
     bg.position = CGPointMake(0, 0);
     bg.zPosition = -2;
     [self addChild:bg];
 
 }


// Sets the properties specifing correct locations of buttons based on screen size
-(void)setupButtonLocations{
    
    self.miniGameXCoord = CGRectGetMidX(self.frame);
    
    self.miniGameOneYCoord = self.frame.size.height-kInitialGamePadding;
    self.miniGameTwoYCoord = self.miniGameOneYCoord - kInBetweenGamePadding;
    self.miniGameThreeYCoord = self.miniGameOneYCoord - kInBetweenGamePadding*2;
    
    self.selectionArrowXCoord =  CGRectGetMidX(self.frame) - kArrowPadding;
    
}

-(void)setupMiniGamePointsLabels{
    
    self.miniGameOnePointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.miniGameOnePointsLabel.fontSize = kFontSizeAlias;
    self.miniGameOnePointsLabel.position = CGPointMake(self.miniGameOne.position.x+self.miniGameOne.frame.size.width-kPointsPaddingX,self.miniGameOne.position.y-kPointsPaddingY);
    self.miniGameOnePointsLabel.text = [NSString stringWithFormat:@"%d", kMiniGameStartingPts];
    [self addChild:_miniGameOnePointsLabel];
    
    self.miniGameTwoPointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.miniGameTwoPointsLabel.fontSize = kFontSizeAlias;
    self.miniGameTwoPointsLabel.position = CGPointMake(self.miniGameTwo.position.x+self.miniGameTwo.frame.size.width-kPointsPaddingX,self.miniGameTwo.position.y-kPointsPaddingY);
    self.miniGameTwoPointsLabel.text = [NSString stringWithFormat:@"%d", kMiniGameStartingPts];
    [self addChild:_miniGameTwoPointsLabel];
    
    self.miniGameThreePointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.miniGameThreePointsLabel.fontSize = kFontSizeAlias;
    self.miniGameThreePointsLabel.position = CGPointMake(self.miniGameThree.position.x+self.miniGameThree.frame.size.width-kPointsPaddingX,self.miniGameThree.position.y-kPointsPaddingY);
    self.miniGameThreePointsLabel.text = [NSString stringWithFormat:@"%d", kMiniGameStartingPts];
    [self addChild:_miniGameThreePointsLabel];
    
}

// Updates the label so that it appears to be counting from old value to new value
-(void)updateLabel:(SKLabelNode*)label fromInt:(int)startNum toInt:(int)endNum{
    
    for(int i=startNum; i<=endNum; i++){
        label.text = [NSString stringWithFormat:@"%d", i];
    }
    
}

-(void)setupAliasLabels{
    
    self.aliasPlayer1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.aliasPlayer1.fontSize = kFontSizeAlias;
    self.aliasPlayer1.position = CGPointMake(10, CGRectGetMidY(self.frame));
    
    self.aliasPlayer2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.aliasPlayer2.fontSize = kFontSizeAlias;
}

// Update position and text somewhere else later
-(void)setupCurrentPointLabels{
    
    self.currentPointsPlayer1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.currentPointsPlayer1.fontSize = kFontSizeAlias;
    
    self.currentPointsPlayer2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.currentPointsPlayer2.fontSize = kFontSizeAlias;

}

# pragma mark - Create Sprites For Initial Display

-(void)createTitleLabel{
    
    //self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    title.text = @"Mini-Game Selection";
    title.fontSize = kFontSize;
    title.position = CGPointMake(CGRectGetMidX(self.frame),
                                 self.frame.size.height-(title.frame.size.height + kTitlePadding));
    
    [self addChild:title];
}

-(void)createMiniGameButtons{
    
    self.miniGameOne = [SKSpriteNode spriteNodeWithImageNamed:@"ButtonRaceButton2.png"];
    self.miniGameOne.name = @"MiniGameOne";
    self.miniGameOne.position = CGPointMake(self.miniGameXCoord, self.miniGameOneYCoord);
    self.miniGameOne.zPosition = 1.0;
    self.miniGameOne.userInteractionEnabled = YES;
    [self addChild:self.miniGameOne];
    
    self.miniGameTwo = [SKSpriteNode spriteNodeWithImageNamed:@"SubDashButton2.png"];
    self.miniGameTwo.name = @"MiniGameTwo";
    self.miniGameTwo.position = CGPointMake(self.miniGameXCoord, self.miniGameTwoYCoord);
    self.miniGameTwo.zPosition = 1.0;
    self.miniGameTwo.userInteractionEnabled = YES;
    [self addChild:self.miniGameTwo];
    
    self.miniGameThree = [SKSpriteNode spriteNodeWithImageNamed:@"SubDashButton2.png"];
    self.miniGameThree.name = @"MiniGameThree";
    self.miniGameThree.position = CGPointMake(self.miniGameXCoord, self.miniGameThreeYCoord);
    self.miniGameThree.zPosition = 1.0;
    self.miniGameThree.userInteractionEnabled = YES;
    [self addChild:self.miniGameThree];
    
}

// Creates the arrow and sets it to point at the first minigame option
-(void)createSelectionArrow{
    
    self.selectionArrow = [SKSpriteNode spriteNodeWithImageNamed:@"selectionArrow.png"];
    
    self.selectionArrow.position = CGPointMake(self.selectionArrowXCoord, self.miniGameOneYCoord);
    self.arrowPosition = kMiniGameOne;
    
    [self addChild:self.selectionArrow];
    
}

-(void)showMiniGamePointValues{
    
    NSLog(@"%@", _networkingEngine.pointsForMiniGames);
    
    _miniGameOnePointValue = [_networkingEngine.pointsForMiniGames objectAtIndex:0];
    _miniGameTwoPointValue= [_networkingEngine.pointsForMiniGames objectAtIndex:1];
    _miniGameThreePointValue = [_networkingEngine.pointsForMiniGames objectAtIndex:2];

    [self updateLabel:_miniGameOnePointsLabel fromInt:kMiniGameStartingPts toInt:[_miniGameOnePointValue intValue]];
    [self updateLabel:_miniGameTwoPointsLabel fromInt:kMiniGameStartingPts toInt:[_miniGameTwoPointValue intValue]];
    [self updateLabel:_miniGameThreePointsLabel fromInt:kMiniGameStartingPts toInt:[_miniGameThreePointValue intValue]];
    
}

#pragma mark - Simulate Selecting a Mini Game

// Simulates arrow movement for some time and "selects" the minigame that the arrow points to when it stops moving
-(void)selectMiniGame:(NSNotification*)notification{
    
    // Show the mini game points next to each mini game
    [self showMiniGamePointValues];
    
    NSNumber *randomNumber = [notification object];
    NSInteger timesToMoveArrow = [randomNumber integerValue];
    NSLog(@"In selection Scene - num %ld", (long)timesToMoveArrow);
    
    for (int i = 0; i < timesToMoveArrow; i++) {
        [self moveArrow];
    }
    
    SKAction *wait = [SKAction waitForDuration:kWaitBeforeGameTransition];
    [self.arrowActionsArray addObject:wait];
    
    [self performSelector:@selector(simulateArrowMovement) withObject:nil afterDelay:1.0];
    
}

// Adds a move action to the arrowActionsArray. The move action changes the arrows position to the next minigame button
-(void)moveArrow{
    
    SKAction *moveArrow;
    switch (self.arrowPosition) {
        case kMiniGameOne:
            moveArrow = [SKAction moveToY:self.miniGameTwoYCoord duration:kMoveArrowAction];
            self.arrowPosition = kMiniGameTwo;
            break;
        case kMiniGameTwo:
            moveArrow = [SKAction moveToY:self.miniGameThreeYCoord duration:kMoveArrowAction];
            self.arrowPosition = kMiniGameThree;
            break;
        case kMiniGameThree:
            moveArrow = [SKAction moveToY:self.miniGameOneYCoord duration:kMoveArrowAction];
            self.arrowPosition = kMiniGameOne;
            break;
        default:
            break;
    }
    
    // Add the action into actions array to be called later
    [self.arrowActionsArray addObject:moveArrow];
    
}

// Runs all the move actions contained in the arrowActionsArray on the selection arrow to simulate its movement
-(void)simulateArrowMovement{
    
    SKAction *sequence = [SKAction sequence:self.arrowActionsArray];
    [self.selectionArrow runAction:sequence completion:^{
        [self performSelector:@selector(transitionToSelectedMiniGame) withObject:nil afterDelay:2];
    }];
    
}

// Creates the new scene for the selected MiniGame and transitions to it
-(void) transitionToSelectedMiniGame{
    
    SKScene *nextMiniGameScene;
    switch (self.arrowPosition) {
        case kMiniGameOne:
            nextMiniGameScene = [[JWButtonRaceScene alloc] initWithSize:self.size];
            //nextMiniGameScene = [[JWSubmarineDashScene alloc] initWithSize:self.size];
            _networkingEngine.selectedPointWorthOfMiniGame = _miniGameOnePointValue;
            NSLog(@"GameSelection- MiniGame point worth - %li", (long)[_miniGameOnePointValue integerValue]);
            break;
        case kMiniGameTwo:
            //nextMiniGameScene = [[JWButtonRaceScene alloc] initWithSize:self.size];
            nextMiniGameScene = [[JWSubmarineDashScene alloc] initWithSize:self.size];
            _networkingEngine.selectedPointWorthOfMiniGame = _miniGameTwoPointValue;
            NSLog(@"GameSelection- MiniGame point worth - %li", (long)[_miniGameTwoPointValue integerValue]);
            break;
        case kMiniGameThree:
            //nextMiniGameScene = [[JWButtonRaceScene alloc] initWithSize:self.size];
            nextMiniGameScene = [[JWSubmarineDashScene alloc] initWithSize:self.size];
            _networkingEngine.selectedPointWorthOfMiniGame = _miniGameThreePointValue;
            NSLog(@"GameSelection- MiniGame point worth - %li", (long)[_miniGameThreePointValue integerValue]);
            break;
        default:
            break;
    }
    
    // Update GameKitHelper's delegate so that it now sends the update messages to the button race multiplayer networking class
    if([nextMiniGameScene isMemberOfClass:[JWButtonRaceScene class]]){
        JWButtonRaceMultiplayerNetworking *multiNetwork = [JWButtonRaceMultiplayerNetworking sharedMultiNetworking];
        _gameKitHelper.delegate = multiNetwork;
        multiNetwork.orderOfPlayers = _networkingEngine.orderOfPlayers;
    }else if([nextMiniGameScene isMemberOfClass:[JWSubmarineDashScene class]]){
        JWSubmarineDashMultiplayerNetworking *multiNetwork = [JWSubmarineDashMultiplayerNetworking sharedMultiNetworking];
        _gameKitHelper.delegate = multiNetwork;
        multiNetwork.orderOfPlayers = _networkingEngine.orderOfPlayers;
    }

    // Remove this scene so it gets dealloced
    SKView* skView = (SKView*)self.view;
    SKScene* oldScene = (skView.scene);
    [oldScene removeFromParent];
    
    // Transition to the next game
    nextMiniGameScene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *miniGameTransition = [SKTransition flipVerticalWithDuration:kTransitionAnimation];
    [self.view presentScene:nextMiniGameScene transition:miniGameTransition];
}

-(void)dealloc{
    NSLog(@"Dealloc was called in selection scene");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showPlayerPoints{
    
    NSNumber *player1Points = [[_networkingEngine pointsOfPlayers] objectAtIndex:kPlayerOne];
    self.currentPointsPlayer1.text = [NSString stringWithFormat:@"%d", [player1Points intValue]];
    self.currentPointsPlayer1.position = CGPointMake(_aliasPlayer1.position.x, _aliasPlayer1.position.y/2);
    [self addChild:self.currentPointsPlayer1];
    
    NSNumber *player2Points = [[_networkingEngine pointsOfPlayers] objectAtIndex:kPlayerTwo];
    self.currentPointsPlayer2.text = [NSString stringWithFormat:@"%d", [player2Points intValue]];
    self.currentPointsPlayer2.position = CGPointMake(_aliasPlayer2.position.x, _aliasPlayer2.position.y/2);
    [self addChild:self.currentPointsPlayer2];
    
}

#pragma mark MultiNetworkingSelectionProtocol

-(void)setPlayerAliases:(NSArray*)playerAliases{
    
    NSLog(@"Game Selection - Set Player Alias");
    // Get each player alias and show them on the selection scene with each players current points underneath
    [playerAliases enumerateObjectsUsingBlock:^(NSString *playerAlias, NSUInteger idx, BOOL *stop) {
        if(idx == kPlayerOne){
            _aliasPlayer1.text = playerAlias;
            self.aliasPlayer1.position = CGPointMake(_aliasPlayer1.frame.size.width/2 + kAliasPadding, CGRectGetMidY(self.frame)-kCurrentScorePadding);
            [self addChild:self.aliasPlayer1];
        }else{
            _aliasPlayer2.text = playerAlias;
            self.aliasPlayer2.position = CGPointMake(CGRectGetWidth(self.frame)-_aliasPlayer2.frame.size.width/2-kAliasPadding, CGRectGetMidY(self.frame)-kCurrentScorePadding);
            [self addChild:self.aliasPlayer2];
        }
    }];
    [self showPlayerPoints];
}

-(void) matchOver:(BOOL)player1Won{
    
}



@end
