//
//  JWSubmarineDashPlayerSprite.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWPlayerSprite.h"

@interface JWSubmarineDashPlayerSprite : JWPlayerSprite

@property NSInteger coinsCollected;
@property BOOL isCurrentlyExploding;

-(void)addPhysicsBody;
-(void)addOneToCollectedCoins;

@end
