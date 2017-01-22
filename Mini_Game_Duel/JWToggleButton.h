//
//  JWToggleButton.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/10/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, ButtonState){
    kOn = 0,
    kOff
};

@interface JWToggleButton : SKSpriteNode

-(instancetype)initWithImageNamed:(NSString *)name andState:(ButtonState)startingState;
-(void)buttonPressed;

@end
