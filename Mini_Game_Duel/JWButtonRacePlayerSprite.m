//
//  JWButtonRacePlayerSprite.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/24/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWPlayerSprite.h"
#import "JWButtonRacePlayerSprite.h"

#define kPlayerAliasLabelName @"player_alias"

@interface JWButtonRacePlayerSprite()

//@property players playerType;
@property NSInteger numberOfTaps;

@end

@implementation JWButtonRacePlayerSprite

// Init player with specified type, color, and size
-(instancetype)initWithType:(players)playerType color:(UIColor *)color size:(CGSize)size{
    
    self = [super initWithType:playerType color:color size:size];
    self.numberOfTaps = 0;
    self.finishedMoving = NO;
    
    SKLabelNode *playerAlias = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
    playerAlias.fontSize = 20;
    playerAlias.fontColor = [SKColor redColor];
    playerAlias.position = CGPointMake(0, 40);
    playerAlias.name = kPlayerAliasLabelName;
    [self addChild:playerAlias];
    
    return self;
}

-(instancetype)initWithType:(players)playerType image:(NSString*)imageName{
    
    self = [super initWithType:playerType image:imageName];
    
    self.numberOfTaps = 0;
    self.finishedMoving = NO;
    
    SKLabelNode *playerAlias = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
    playerAlias.fontSize = 20;
    playerAlias.fontColor = [SKColor redColor];
    playerAlias.position = CGPointMake(0, 40);
    playerAlias.name = kPlayerAliasLabelName;
    [self addChild:playerAlias];
    
    return self;
    
}


// Move player forward a calculated distance based on player's number of taps
- (void)moveForward{
    
    CGPoint moveTo = CGPointMake(self.position.x, self.position.y+(self.numberOfTaps*2));
    SKAction *movePlayer = [SKAction moveTo:moveTo duration:4];
    //[self runAction:movePlayer];
    [self runAction:movePlayer completion:^{
        self.finishedMoving = YES;
    }];
    
}

-(void)moveForward:(NSInteger)distance{
    CGPoint moveTo = CGPointMake(self.position.x, self.position.y+(distance*2));
    SKAction *movePlayer = [SKAction moveTo:moveTo duration:4];
    [self runAction:movePlayer completion:^{
        self.finishedMoving = YES;
    }];
}

-(void)addOneToTapCount{
    self.numberOfTaps++;
}

// TODO REMOVE THIS FUNCTION -- UNNEEDED

-(NSInteger)currentTapCount{
    return self.numberOfTaps;
}

- (void)setPlayerAliasText:(NSString*)playerAlias; {
    SKLabelNode *playerAliasLabel = (SKLabelNode*)[self childNodeWithName:kPlayerAliasLabelName];
    playerAliasLabel.text = playerAlias;
}

@end
