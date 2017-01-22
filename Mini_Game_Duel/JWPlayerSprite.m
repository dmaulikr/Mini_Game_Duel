//
//  JWPlayerSprite.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/8/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWPlayerSprite.h"

@interface JWPlayerSprite ()

@property players playerType;

@end

@implementation JWPlayerSprite

// Init player with specified type, color, and size
-(instancetype)initWithType:(players)playerType color:(UIColor *)color size:(CGSize)size{
    
    self = [self initWithColor:color size:size];
    self.playerType = playerType;
    
    return self;
}

-(instancetype)initWithType:(players)playerType image:(NSString*)imageName{
    
    self = [self initWithImageNamed:imageName];
    self.playerType = playerType;
    return self;
    
}


@end
