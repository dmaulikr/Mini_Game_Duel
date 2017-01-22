//
//  JWSubmarineDashMultiplayerNetworking.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/12/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//


#import "JWSubmarineDashMultiplayerNetworking.h"

#define playerIdKey @"PlayerId"

static const int kFirstPlayer = 0;
static const int kSecondPlayer = 1;

static const int kGameLatencyFix = 1;

// Defines the possible game states -- used to ensure the games are sychronous
typedef NS_ENUM(NSUInteger, GameState) {
    kGameStateWaitingForStart = 0,
    kGameStateActive,
    kGameStateDone
};

// Defines the types of messages that will be sent and recieved - will be used to indentify message types later on
typedef NS_ENUM(NSUInteger, MessageType) {
    kMessageTypeGameBegin = 0,
    kMessageTypeMove,
    kMessageTypeExplode,
    kMessageTypeCollectedCoin,
    kMessageTypeGameOver
};

// Structs for each type of message that can be sent and recieved
typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
} MessageExplode;

typedef struct {
    Message message;
} MessageCollectedCoin;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

@interface JWSubmarineDashMultiplayerNetworking ()

@property (nonatomic,strong) JWGameKitHelper *gameKitHelper;
@property GameState gameState;
@property BOOL isPlayer1;

@end


@implementation JWSubmarineDashMultiplayerNetworking

- (id)init{
    
    self = [super init];
    if (self) {
        _gameState = kGameStateWaitingForStart;
        _gameKitHelper = [JWGameKitHelper sharedGameKitHelper];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSubDash) name:SubDashIsReady object:nil];
        _startUpdatingGame = NO;
        
    }
    return self;
    
}

// Creating and return a "thread safe" singleton object
+(instancetype)sharedMultiNetworking{
    
    static JWSubmarineDashMultiplayerNetworking *sharedMultiNetworking = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMultiNetworking = [[JWSubmarineDashMultiplayerNetworking alloc] init];
    });
    
    return sharedMultiNetworking;
    
}


-(void)startSubDash{
    
    _gameState = kGameStateWaitingForStart;
    [self performSelector:@selector(tryStartGame) withObject:self afterDelay:kGameLatencyFix];
    
}

- (void)tryStartGame {
    
    _isPlayer1 = [self isLocalPlayerPlayer1];
    
    if (_isPlayer1 && _gameState == kGameStateWaitingForStart){
        _gameState = kGameStateActive;
        [self sendGameBegin];
        [self processPlayerAliases];
        
        //set this player's index in the button race game
        [self.multiNetworkingSubDashDelegate setCurrentPlayerIndex:kFirstPlayer];
        _startUpdatingGame = YES;
    }
    
}

// Reliably sends data to all players of the match as long as both players stay network connected
// If there is a network problem, the match ends
- (void)sendData:(NSData*)data{
    
    NSError *error;
    
    BOOL success = [_gameKitHelper.match
                    sendDataToAllPlayers:data
                    withDataMode:GKMatchSendDataReliable
                    error:&error];
    
    if (!success) {
        NSLog(@"Error sending data:%@", error.localizedDescription);
        //[self matchEnded]; TODO
    }
    
}

#pragma mark - GameKitHelperDelegate Methods

-(void)matchStarted{
    // Do nothing...
}

- (void)match:(GKMatch *)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID {
    
    Message *message = (Message*)[data bytes];
    if (message->messageType == kMessageTypeGameBegin) {
        NSLog(@"Begin game message received");
        _gameState = kGameStateActive;
        [self.multiNetworkingSubDashDelegate setCurrentPlayerIndex:kSecondPlayer];
        _startUpdatingGame = YES;
        [self processPlayerAliases];
    }
    else if (message->messageType == kMessageTypeMove) {
        NSLog(@"Move message received");
        [self.multiNetworkingSubDashDelegate movePlayerAtIndex:[self indexForPlayerWithId:playerID]];
    }
    else if (message->messageType == kMessageTypeExplode){
        NSLog(@"Explode message received");
        [self.multiNetworkingSubDashDelegate explodePlayerAtIndex:[self indexForPlayerWithId:playerID]];
    }
    else if (message->messageType == kMessageTypeCollectedCoin){
        NSLog(@"Collected coin message received");
        [self.multiNetworkingSubDashDelegate sendCollectedCoinAtIndex:[self indexForPlayerWithId:playerID]];
    }
    else if(message->messageType == kMessageTypeGameOver) {
        NSLog(@"Game over message received");
        MessageGameOver* messageGameOver = (MessageGameOver*) [data bytes];
        [self.multiNetworkingSubDashDelegate miniGameEnded:messageGameOver->player1Won];
    }
    
}

// Called when match should be ended completely
- (void)matchEnded{
    
    // end game
    
}

// Sends a game begin message to all players notifying them that local player is ready to begin
- (void)sendGameBegin {
    
    MessageGameBegin beginGameMessage;
    beginGameMessage.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&beginGameMessage length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
}

// Sends a move message to all players notiying them how far to move the opponent
-(void)sendMove{

    MessageMove messageMove;
    messageMove.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&messageMove length:sizeof(MessageMove)];
    [self sendData:data];
    
}

// Sends a explode message to all players tell them to explode my sub on their screen
-(void)sendExplode{
    
    MessageExplode messageExplode;
    messageExplode.message.messageType = kMessageTypeExplode;
    NSData *data = [NSData dataWithBytes:&messageExplode length:sizeof(messageExplode)];
    [self sendData:data];
    
}

// Sends a message to other player telling them I collected a coin
-(void)sendCollectedCoin{
    
    MessageCollectedCoin messageCollectedCoin;
    messageCollectedCoin.message.messageType = kMessageTypeCollectedCoin;
    NSData *data = [NSData dataWithBytes:&messageCollectedCoin length:sizeof(messageCollectedCoin)];
    [self sendData:data];
    
}


// Sends a game over message to all players notifying them if player 1 won
- (void)sendGameEnd:(BOOL)player1Won {
    
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
    [self sendData:data];
    
}

- (NSUInteger)indexForPlayerWithId:(NSString*)playerId{
    
    __block NSUInteger index = -1;
    [_orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop){
        NSString *pId = obj[playerIdKey];
        if ([pId isEqualToString:playerId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
    
}

// Helper method that returns true if local player should be player 1
- (BOOL)isLocalPlayerPlayer1 {
    
    BOOL isPlayer1 = NO;
    NSDictionary *dictionary = _orderOfPlayers[0];
    
    if ([dictionary[playerIdKey] isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        NSLog(@"I'm player 1");
        isPlayer1 = YES;
    }
    
    return isPlayer1;
}

- (void)processPlayerAliases {
    
    NSMutableArray *playerAliases = [NSMutableArray arrayWithCapacity:_orderOfPlayers.count];
    for (NSDictionary *playerDetails in _orderOfPlayers) {
        NSString *playerId = playerDetails[playerIdKey];
        [playerAliases addObject:((GKPlayer*)[JWGameKitHelper sharedGameKitHelper].playersDict[playerId]).alias];
    }
    if (playerAliases.count > 0) {
        [self.multiNetworkingSubDashDelegate setPlayerAliases:playerAliases];
    }
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
