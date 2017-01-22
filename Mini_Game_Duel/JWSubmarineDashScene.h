//
//  JWSubmarineDashScene.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This class implements the sub dash game

#import <SpriteKit/SpriteKit.h>
#import "JWGameKitHelper.h"
#import "JWMasterMultiplayerNetworking.h"
#import "JWSubmarineDashMultiplayerNetworking.h"

// Categories used for collision detections
typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategorySub      = 0x1 << 0,
    CollisionCategoryOppSub   = 0x1 << 1,
    CollisionCategoryBarrier  = 0x1 << 2,
    CollisionCategoryEnemy    = 0x1 << 3,
    CollisionCategoryCoin     = 0x1 << 4,
};

@interface JWSubmarineDashScene : SKScene <JWMultiplayerNetworkingSubDashProtocol>

@property BOOL gameOver;
@property (nonatomic, strong) JWSubmarineDashMultiplayerNetworking *networkingEngine;
// This is used as a way to update the winning players current points
@property (nonatomic,strong) JWMasterMultiplayerNetworking *masterNetworkingEngine;


@end
