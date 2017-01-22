//
//  JWSubmarineDashPlayerSprite.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWSubmarineDashPlayerSprite.h"

@interface JWSubmarineDashPlayerSprite ()

@property NSString *imageName;

@end

@implementation JWSubmarineDashPlayerSprite

// Race until first player finish line

// cool idea -
// Could do a power up that makes the other person's seaweed take up the whole screen?? auto death ha

-(void)addPhysicsBody{
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.height/2];
    self.physicsBody.dynamic = YES;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
}

-(void)addOneToCollectedCoins{
    _coinsCollected++;
}

@end
