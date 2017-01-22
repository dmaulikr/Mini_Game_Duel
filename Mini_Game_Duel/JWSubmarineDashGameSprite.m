//
//  JWSubmarineDashGameSprite.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWSubmarineDashScene.h"
#import "JWSubmarineDashGameSprite.h"

NSString *const kSpriteName = @"gameSprite"; // Name given to every sprite object besides the submarine

@implementation JWSubmarineDashGameSprite

-(instancetype)initWithTexture:(SKTexture*)texture withScale:(CGFloat)scale ofCategory:(uint32_t)category{
    
    self = [self initWithTexture:texture];
    self.texture = texture;
    self.name = kSpriteName;
    [self setScale:scale];
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask = category;
    
    return self;
    
}

@end
