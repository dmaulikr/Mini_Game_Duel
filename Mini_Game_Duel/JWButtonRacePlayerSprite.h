//
//  JWButtonRacePlayerSprite.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/24/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>



@interface JWButtonRacePlayerSprite : JWPlayerSprite

@property BOOL finishedMoving;

-(instancetype)initWithType:(players)playerType color:(UIColor *)color size:(CGSize)size;
-(instancetype)initWithType:(players)playerType image:(NSString*)imageName;

-(void)moveForward;
-(void)moveForward:(NSInteger)distance;
-(void)addOneToTapCount;
-(NSInteger)currentTapCount;

- (void)setPlayerAliasText:(NSString*)playerAlias;

@end
