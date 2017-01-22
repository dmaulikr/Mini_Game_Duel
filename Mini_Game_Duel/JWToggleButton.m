//
//  JWToggleButton.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/10/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWToggleButton.h"

@interface JWToggleButton ()

@property ButtonState currentState;

@end

@implementation JWToggleButton

-(instancetype)initWithImageNamed:(NSString *)name andState:(ButtonState)startingState{
    
    if(self = [super initWithImageNamed:name]){
        self.currentState = startingState;
    }
    
    return  self;
}

-(NSString*) updateLabelForCurrentState{
    NSString *buttonName;
    
    if (_currentState == kOn) {
        buttonName = @"start_button.png";
    }
    else if (_currentState == kOff) {
        buttonName = @"start_button_pressed.png";
    }
    
    return buttonName;
}

-(void)buttonPressed{
    if (_currentState == kOff) {
        _currentState = kOn;
    }
    else {
        _currentState = kOff;
    }
    
    NSString *newButtonName = [self updateLabelForCurrentState];
    self.texture = [SKTexture textureWithImageNamed:newButtonName];
}


@end
