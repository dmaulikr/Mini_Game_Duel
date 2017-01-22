//
//  JWMasterMultiplayerNetworking.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/8/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWMasterMultiplayerNetworking.h"

#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"
#define randomSelectionNumberKey @"selectionNumber"

static const int kFirstPlayer = 0;

static const int kMaxRandomPlayerNum = 100;
static const int kMinRandomPlayerNum = 1;

static const int kMaxRandomNumber = 80;
static const int kMinRandomNumber = 40;

// Defines the possible game states -- Game states are used to ensure the games are sychronous
typedef NS_ENUM(NSUInteger, GameState) {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomPlayerNumber,
    kGameStateSendPointValuesForMiniGames,
    kGameStateWaitingForRandomSelectionNumber,
    kGameStateStartSelection,
    kGameStateActive,
    KGameStateMatchEnded
};

// Defines the message types this "game" can send
typedef NS_ENUM(NSUInteger, MessageType) {
    kMessageTypeRandomPlayerNumber = 0,
    kMessageTypeRandomSelectionNumber,
    kMessageTypePointValuesForMiniGames,
    kMessageTypeStartSelection,
    kMessageTypeMatchEnded
};

typedef struct {
    MessageType messageType;
}Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
}MessageRandomPlayerNumber;

typedef struct{
    Message message;
    uint32_t selectionNumber;
}MessageRandomSelectionNumber;

typedef struct{
    Message message;
    uint32_t pointsForGame1;
    uint32_t pointsForGame2;
    uint32_t pointsForGame3;
}MessagePointValuesForMiniGames;

typedef struct {
    Message message;
} MessageStartSelection;

typedef struct{
    Message message;
    BOOL player1Won;
}MessageMatchEnded;


@interface JWMasterMultiplayerNetworking ()

@property (nonatomic,strong) JWGameKitHelper *gameKitHelper;
@property GameState gameState;
@property BOOL isPlayer1;

@property NSMutableArray *orderOfSelectionNumbers;

@property BOOL receivedAllRandomNumbers;
@property BOOL receivedAllSelectionNumbers;

@property uint32_t ourRandomNumber;
@property uint32_t ourSelectionNumber;

@property NSArray *optionsForGamePoints;

@end

@implementation JWMasterMultiplayerNetworking

- (id)init{
    
    self = [super init];
    if (self) {
        _ourRandomNumber = kMinRandomPlayerNum + arc4random() % (kMaxRandomPlayerNum - kMinRandomPlayerNum);
        _ourSelectionNumber = kMinRandomNumber + arc4random() % (kMaxRandomNumber - kMinRandomNumber);
        _gameState = kGameStateWaitingForMatch;
        
        _orderOfPlayers = [NSMutableArray array];
        [_orderOfPlayers addObject:@{playerIdKey : [GKLocalPlayer localPlayer].playerID,
                                     randomNumberKey : @(_ourRandomNumber)}];
        
        _orderOfSelectionNumbers = [NSMutableArray array];
        [_orderOfSelectionNumbers addObject:@{playerIdKey: [GKLocalPlayer localPlayer].playerID,
                                              randomSelectionNumberKey : @(_ourSelectionNumber)}];
        
        // Setup this array to hold each player's points. Each player starts with 0 points. Player one is first index.
        _pointsOfPlayers = [NSMutableArray array];
        NSNumber *num = [NSNumber numberWithInt:0];
        [_pointsOfPlayers addObject:num];
        [_pointsOfPlayers addObject:num];
        
        _pointsForMiniGames = [NSMutableArray array];
        [_pointsForMiniGames addObject:[NSNumber numberWithInt:0]];
        [_pointsForMiniGames addObject:[NSNumber numberWithInt:0]];
        [_pointsForMiniGames addObject:[NSNumber numberWithInt:0]];

        _optionsForGamePoints = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:15], [NSNumber numberWithInt:25], [NSNumber numberWithInt:35], nil];
        
        _selectedPointWorthOfMiniGame = [[NSNumber alloc] initWithInteger:0];

        _gameKitHelper = [JWGameKitHelper sharedGameKitHelper];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(readyForNewMiniGamePoints)
                                                     name:ReadyForNewMiniGamePoints object:nil];
        
    }
    return self;
    
}

// Creating and return a "thread safe" singleton object
+(instancetype)sharedMultiNetworking{
    
    static JWMasterMultiplayerNetworking *sharedMultiNetworking = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMultiNetworking = [[JWMasterMultiplayerNetworking alloc] init];
    });
    
    return sharedMultiNetworking;
    
}

-(void)readyForNewMiniGamePoints{
    
    _gameState = kGameStateSendPointValuesForMiniGames;
    _isPlayer1 = [self isPlayer1];
    [self processPlayerAliases];
    if(_isPlayer1){
        [self determinePointsForMiniGames];
    }
}

// Reset state back to waiting for selection numbers
-(void)readyForNewSelectionNumber{
    
    _ourSelectionNumber = kMinRandomNumber + arc4random() % (kMaxRandomNumber - kMinRandomNumber);
    [_orderOfSelectionNumbers removeAllObjects];
    [_orderOfSelectionNumbers addObject:@{playerIdKey: [GKLocalPlayer localPlayer].playerID,
                                          randomSelectionNumberKey : @(_ourSelectionNumber)}];
    [self sendSelectionNumber];

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
        [self matchEnded];
    }
    
}


-(void) notifySelectionSceneOfRandomNumber{
    
    NSDictionary *dict = _orderOfSelectionNumbers[kFirstPlayer];
    NSNumber *randNum = dict[randomSelectionNumberKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:RandomNumberReady object:randNum];
    
}

// Packages up the locally generated random number in a MessageRandomNumber struc and sends to all players
- (void)sendRandomNumber{
    
    MessageRandomPlayerNumber randomNumMessage;
    randomNumMessage.message.messageType = kMessageTypeRandomPlayerNumber;
    randomNumMessage.randomNumber = _ourRandomNumber;
    NSData *data = [NSData dataWithBytes:&randomNumMessage length:sizeof(MessageRandomPlayerNumber)];
    [self sendData:data];
    
}

// Packages up the locally generated selection number and sends to all players
- (void)sendSelectionNumber{
    
    MessageRandomSelectionNumber selectionNumMessage;
    selectionNumMessage.message.messageType = kMessageTypeRandomSelectionNumber;
    selectionNumMessage.selectionNumber = _ourSelectionNumber;
    NSData *data = [NSData dataWithBytes:&selectionNumMessage length:sizeof(MessageRandomSelectionNumber)];
    [self sendData:data];
    
}

-(void)sendPointsForMiniGames:(uint32_t)game1Points pt2:(uint32_t)game2Points pt3:(uint32_t)game3Points{

    MessagePointValuesForMiniGames pointsMessage;
    pointsMessage.message.messageType = kMessageTypePointValuesForMiniGames;
    pointsMessage.pointsForGame1 = game1Points;
    pointsMessage.pointsForGame2 = game2Points;
    pointsMessage.pointsForGame3 = game3Points;
    NSData *data = [NSData dataWithBytes:&pointsMessage length:sizeof(MessagePointValuesForMiniGames)];
    [self sendData:data];

}

// Sends a game begin message to all players notifying them that local player is ready to begin
- (void)sendStartSelection {
    
    MessageStartSelection startSelectionMessage;
    startSelectionMessage.message.messageType = kMessageTypeStartSelection;
    NSData *data = [NSData dataWithBytes:&startSelectionMessage length:sizeof(MessageStartSelection)];
    [self sendData:data];
    
}

#pragma mark - GameKitHelperDelegate Methods

// Called when two players are found and game center correctly creates a match between them
- (void)matchStarted{
    
    // Notify loading scene that it should display selection scene
    NSLog(@"Match has started successfully - Now Display Selection Scene");
    
    // Notify Loading Scene that the match started and it should display selection scene
    [[NSNotificationCenter defaultCenter] postNotificationName:MatchDidStart object:nil];
    
    // Determine the next state to enter if I already received the other's random number
    if (_receivedAllRandomNumbers) {
        _gameState = kGameStateSendPointValuesForMiniGames;
        [self processPlayerAliases];
        [self determinePointsForMiniGames];
    } else {
        _gameState = kGameStateWaitingForRandomPlayerNumber;
    }
    
    [self sendRandomNumber];
    
}

// Called when match should be ended completely
- (void)matchEnded{
    
    // end game
    
}

// Called when the GKMatchDelegate match:didReceiveDate:fromPlayer is called
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    
    Message *message = (Message*)[data bytes];
    if (message->messageType == kMessageTypeRandomPlayerNumber) {
        
        MessageRandomPlayerNumber *messageRandomPlayerNumber = (MessageRandomPlayerNumber*)[data bytes];
        NSLog(@"Received random number:%d", messageRandomPlayerNumber->randomNumber);
        // If we have a tie, resend numbers; otherwise, add entry into dictionary and process the received random number
        BOOL tie = NO;
        if (messageRandomPlayerNumber->randomNumber == _ourRandomNumber) {
            NSLog(@"Tie");
            tie = YES;
            _ourRandomNumber = kMinRandomPlayerNum + arc4random() % (kMaxRandomPlayerNum - kMinRandomPlayerNum);
            [self sendRandomNumber];
        } else {
            NSDictionary *dictionary = @{playerIdKey : playerID,
                                         randomNumberKey : @(messageRandomPlayerNumber->randomNumber)};
            [self processReceivedRandomNumber:dictionary];
        }
        
        if (_receivedAllRandomNumbers) {
            _isPlayer1 = [self isLocalPlayerPlayer1];
        }
        
        if (!tie && _receivedAllRandomNumbers) {
            if (_gameState == kGameStateWaitingForRandomPlayerNumber) {
                _gameState = kGameStateSendPointValuesForMiniGames;
                [self processPlayerAliases];
                [self determinePointsForMiniGames];
            }
        }
    }else if (message->messageType == kMessageTypePointValuesForMiniGames){
        MessagePointValuesForMiniGames *messagePoints = (MessagePointValuesForMiniGames*)[data bytes];
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:messagePoints->pointsForGame1] atIndexedSubscript:0];
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:messagePoints->pointsForGame2] atIndexedSubscript:1];
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:messagePoints->pointsForGame3] atIndexedSubscript:2];
        
        NSLog(@"In receicedData - points %u, %u, %u", messagePoints->pointsForGame1, messagePoints->pointsForGame2, messagePoints->pointsForGame3);
        _gameState = kGameStateWaitingForRandomSelectionNumber;
        [self readyForNewSelectionNumber];
    }
    else if (message->messageType == kMessageTypeRandomSelectionNumber){
        // process random selection number!
        MessageRandomSelectionNumber *messageSelectionNum = (MessageRandomSelectionNumber*)[data bytes];
        NSLog(@"Received selection number:%d", messageSelectionNum->selectionNumber);
        NSDictionary *dict = @{playerID: playerID, randomSelectionNumberKey: @(messageSelectionNum->selectionNumber)};
        [self processReceivedSelectionNumber:dict];
        if(_receivedAllSelectionNumbers){
            if(_gameState == kGameStateWaitingForRandomSelectionNumber){
                _gameState = kGameStateStartSelection;
                [self tryStartGame];
            }
        }
    }
    else if (message->messageType == kMessageTypeStartSelection) {
        NSLog(@"Start Selection message received");
        _gameState = kGameStateActive;
        [self notifySelectionSceneOfRandomNumber];
        
    } else if(message->messageType == kMessageTypeMatchEnded) {
        NSLog(@"Game over message received");
        MessageMatchEnded *messageMatchOver = (MessageMatchEnded*)[data bytes];
        [self.multiNetworkSelectionDelegate matchOver:messageMatchOver->player1Won];
    }

}

- (void)tryStartGame {
    
    if (_isPlayer1 && _gameState == kGameStateStartSelection){
        
        _gameState = kGameStateActive;
        [self sendStartSelection];
        [self performSelector:@selector(notifySelectionSceneOfRandomNumber) withObject:nil afterDelay:0.6]; //.2
        //[self notifySelectionSceneOfRandomNumber];
    }
}

-(void)determinePointsForMiniGames{
    
    if(_isPlayer1 && _gameState == kGameStateSendPointValuesForMiniGames){
        
        // Make 3 point values, save them locally, and send them to other player
        int game1 = arc4random() % 3;
        int game2 = arc4random() % 3;
        int game3 = arc4random() % 3;
        
        NSNumber *pt1 = [_optionsForGamePoints objectAtIndex:game1];
        NSNumber *pt2 = [_optionsForGamePoints objectAtIndex:game2];
        NSNumber *pt3 = [_optionsForGamePoints objectAtIndex:game3];
        
        uint32_t ptsGame1 = [pt1 intValue];
        uint32_t ptsGame2 = [pt2 intValue];
        uint32_t ptsGame3 = [pt3 intValue];

        NSLog(@"In determine points -- %u, %u, %u,", ptsGame1, ptsGame2, ptsGame3);
        
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:ptsGame1] atIndexedSubscript:0];
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:ptsGame2] atIndexedSubscript:1];
        [_pointsForMiniGames setObject:[NSNumber numberWithUnsignedInt:ptsGame3] atIndexedSubscript:2];

        // Send them to the other player so they can save them and change their state
        [self sendPointsForMiniGames:ptsGame1 pt2:ptsGame2 pt3:ptsGame3];
        
        // Change game state to wait for selection number
        _gameState = kGameStateWaitingForRandomSelectionNumber;
        
        // Send selection number to other guy
        //[self performSelector:@selector(readyForNewSelectionNumber) withObject:nil afterDelay:.2];
        [self readyForNewSelectionNumber];
        
    }
}

#pragma mark - Handle Recieving Messages

// Recieves random number sent from the other player, makes sure it is unique, and sorts orderOfPlayers so that the first
// element (player one) has the larger random number
-(void)processReceivedRandomNumber:(NSDictionary*)randomNumberDetails {
    
    // Make sure it's not already in the array
    if([_orderOfPlayers containsObject:randomNumberDetails]) {
        [_orderOfPlayers removeObjectAtIndex:[_orderOfPlayers indexOfObject:randomNumberDetails]];
    }
    
    [_orderOfPlayers addObject:randomNumberDetails];
    
    NSSortDescriptor *sortByRandomNumber = [NSSortDescriptor sortDescriptorWithKey:randomNumberKey ascending:NO];
    NSArray *sortDescriptors = @[sortByRandomNumber];
    [_orderOfPlayers sortUsingDescriptors:sortDescriptors];
    
    if ([self allRandomNumbersAreReceived]) {
        _receivedAllRandomNumbers = YES;
        //[self sendSelectionNumber];
    }
    
}

-(void)processReceivedSelectionNumber:(NSDictionary*)randomNumber{
    
    [_orderOfSelectionNumbers addObject:randomNumber];
    NSSortDescriptor *sortBySelectionNum = [NSSortDescriptor sortDescriptorWithKey:randomSelectionNumberKey ascending:NO];
    NSArray *sortDescriptors = @[sortBySelectionNum];
    [_orderOfSelectionNumbers sortUsingDescriptors:sortDescriptors];
    
    if([self allSelectionNumbersReceived]){
        _receivedAllSelectionNumbers = YES;
    }
    
}

// Helper method to return true when all random numbers have been recieved and are unique
- (BOOL)allRandomNumbersAreReceived {
    
    BOOL allRandomNumbersReceived = NO;
    NSMutableArray *receivedRandomNumbers = [NSMutableArray array];
    
    for (NSDictionary *dict in _orderOfPlayers) {
        [receivedRandomNumbers addObject:dict[randomNumberKey]];
    }
    
    NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
    
    if (arrayOfUniqueRandomNumbers.count == _gameKitHelper.match.playerIDs.count + 1) {
        allRandomNumbersReceived = YES;
    }
    
    return allRandomNumbersReceived;
    
}

-(BOOL)allSelectionNumbersReceived{
    
    BOOL allReceived = NO;
    NSMutableArray *receivedSelectionNumbers = [NSMutableArray array];
    
    for(NSDictionary *dict in _orderOfSelectionNumbers){
        [receivedSelectionNumbers addObject:dict[randomSelectionNumberKey]];
    }
    
    if (receivedSelectionNumbers.count == _gameKitHelper.match.playerIDs.count + 1) {
        allReceived = YES;
    }
    
    return allReceived;
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

// Find and return the index of the local player based of their player id
- (NSUInteger)indexForLocalPlayer{
    
    NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    return [self indexForPlayerWithId:playerId];
    
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

- (void)processPlayerAliases {
    
    if ([self allRandomNumbersAreReceived]) {
        NSMutableArray *playerAliases = [NSMutableArray arrayWithCapacity:_orderOfPlayers.count];
        for (NSDictionary *playerDetails in _orderOfPlayers) {
            NSString *playerId = playerDetails[playerIdKey];
            [playerAliases addObject:((GKPlayer*)[JWGameKitHelper sharedGameKitHelper].playersDict[playerId]).alias];
        }
        if (playerAliases.count > 0) {
            [self.multiNetworkSelectionDelegate setPlayerAliases:playerAliases];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
