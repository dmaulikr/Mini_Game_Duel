//
//  JWPlayerSprite.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/8/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum players {
    kPlayerOne,
    kPlayerTwo
} players;

@interface JWPlayerSprite : SKSpriteNode

@property (nonatomic, readonly) players playerType;

-(instancetype)initWithType:(players)playerType color:(UIColor *)color size:(CGSize)size;
-(instancetype)initWithType:(players)playerType image:(NSString*)imageName;

@end