//
//  JWMasterMultiplayerNetworking.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/8/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This MN class is responsible for the following:
    // Assigning each player as either player one or player two based on the random player numbers they send each other
    // Determining and sending out the current mini-game point values to be displayed and played for
    // Determining and sending a random selection number that controls how many times the selection arrow moves

// Thus, it will be a singleton and will be called in each of the following cases:
    // To start the match stuff (random player).
    // Every time selection scene needs a new number.

#import "JWGameKitHelper.h"

@protocol JWMultiplayerNetworkingSelectionProtocol <NSObject>

-(void)setPlayerAliases:(NSArray*)playerAliases;
-(void) matchOver:(BOOL)player1Won;

@end

@interface JWMasterMultiplayerNetworking : NSObject <GameKitHelperDelegate>

+(instancetype)sharedMultiNetworking;

@property NSMutableArray *orderOfPlayers;
@property NSMutableArray *pointsOfPlayers;
@property NSMutableArray *pointsForMiniGames;

@property (nonatomic,strong) NSNumber *selectedPointWorthOfMiniGame;

@property (nonatomic, assign) id<JWMultiplayerNetworkingSelectionProtocol> multiNetworkSelectionDelegate;


@end
