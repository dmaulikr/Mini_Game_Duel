//
//  JWSubmarineDashGameSprite.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/11/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern NSString *const kSpriteName;

@interface JWSubmarineDashGameSprite : SKSpriteNode

@property (nonatomic) SKTexture *texture;

-(instancetype)initWithTexture:(SKTexture*)texture withScale:(CGFloat)scale ofCategory:(uint32_t)category;

@end
