//
//  JWGameSelectionScene.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/22/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This class is responsible for showing the random selection of mini-games, transitioning to those mini-game scenes,
// and showing each player's current score 

#import <SpriteKit/SpriteKit.h>
#import "JWMasterMultiplayerNetworking.h"
#import "JWGameKitHelper.h"

@interface JWGameSelectionScene : SKScene <JWMultiplayerNetworkingSelectionProtocol>

@property (nonatomic,strong) JWMasterMultiplayerNetworking *networkingEngine;
@property (nonatomic,strong) JWGameKitHelper *gameKitHelper;

@end
