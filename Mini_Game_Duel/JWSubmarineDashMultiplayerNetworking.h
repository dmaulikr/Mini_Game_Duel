//
//  JWSubmarineDashMultiplayerNetworking.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/12/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This MN class is responsible for sending necessary data to each player for the SubmarineDash mini-game

#import "JWGameKitHelper.h"

@protocol JWMultiplayerNetworkingSubDashProtocol <NSObject>

-(void)miniGameEnded:(BOOL)player1Won;
-(void)setCurrentPlayerIndex:(NSInteger)index;
-(void)movePlayerAtIndex:(NSUInteger)index;
-(void)explodePlayerAtIndex:(NSUInteger)index;
-(void)sendCollectedCoinAtIndex:(NSUInteger)index;
-(void)setPlayerAliases:(NSArray*)playerAliases;

@end

@interface JWSubmarineDashMultiplayerNetworking : NSObject <GameKitHelperDelegate>

@property (nonatomic,assign) id<JWMultiplayerNetworkingSubDashProtocol> multiNetworkingSubDashDelegate;
@property NSMutableArray *orderOfPlayers;
@property BOOL startUpdatingGame;

+(instancetype)sharedMultiNetworking;
-(void)sendMove;
-(void)sendExplode;
-(void)sendCollectedCoin;
-(void)sendGameEnd:(BOOL)player1Won;

@end
