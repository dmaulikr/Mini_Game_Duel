//
//  JWButtonRaceScene.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/24/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This class contains the code for button race scene

#import <SpriteKit/SpriteKit.h>
#import "JWMasterMultiplayerNetworking.h"
#import "JWButtonRaceMultiplayerNetworking.h"

@interface JWButtonRaceScene : SKScene <JWMultiplayerNetworkingButtonRaceProtocol>

// This is used as a way to update the winning players current points
@property (nonatomic,strong) JWMasterMultiplayerNetworking *masterNetworkingEngine;
@property (nonatomic, strong) JWButtonRaceMultiplayerNetworking *networkingEngine;

@end
