//
//  JWGameOverScene.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/13/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This scene displays a game over message and shows the winner's game center alias

#import <SpriteKit/SpriteKit.h>

@interface JWGameOverScene : SKScene

-(instancetype)initWithSize:(CGSize)size andAlais:(NSString*)alias;

@end
