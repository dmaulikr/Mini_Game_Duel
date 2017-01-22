//
//  JWButtonRaceMultiplayerNetworking.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/8/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This MN class is responsible for sending necessary data to each player for the Button Race mini-game

#import "JWGameKitHelper.h"

@protocol JWMultiplayerNetworkingButtonRaceProtocol <NSObject>

- (void)miniGameEnded:(BOOL)player1Won; // add coin amt
- (void)setCurrentPlayerIndex:(NSUInteger)index;
- (void)movePlayerAtIndex:(NSUInteger)index distance:(NSInteger)dist;
//- (void)gameOver:(BOOL)player1Won;
- (void)setPlayerAliases:(NSArray*)playerAliases;

@end

@interface JWButtonRaceMultiplayerNetworking : NSObject <GameKitHelperDelegate>

@property (nonatomic, assign) id<JWMultiplayerNetworkingButtonRaceProtocol> multiNetworkingButtonRaceDelegate;
@property NSMutableArray *orderOfPlayers;
@property BOOL startCountDown;

+(instancetype)sharedMultiNetworking;
- (void)sendMove:(NSInteger)moveDistance;
- (void)sendGameEnd:(BOOL)player1Won;

@end
