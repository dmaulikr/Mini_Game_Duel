//
//  JWGameOverScene.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 12/13/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWGameOverScene.h"

static const int kFontSizeGameOver = 40;
static const int kFontSizeAlias = 30;
static const int kPaddingGameOver = 100;

@interface JWGameOverScene ()

@property NSString *winnerAlias;
@property SKLabelNode *winnerAliasLabel;
@property SKLabelNode *gameOverLabel;

@end

@implementation JWGameOverScene

-(instancetype)initWithSize:(CGSize)size andAlais:(NSString*)alias{
    
    if (self = [super initWithSize:size]) {

        _winnerAlias = alias;
        [self setupBackground];
        [self addLabels];
        
    }
    
    return self;
}


-(void)setupBackground{
    
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"plain3.png"];
        bg.anchorPoint = CGPointZero;
        bg.position = CGPointMake(0, 0);
        bg.zPosition = -2;
        [self addChild:bg];
    
}

-(void)addLabels{
    
    _gameOverLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    _gameOverLabel.fontSize = kFontSizeGameOver;
    _gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-kPaddingGameOver);
    _gameOverLabel.text = [NSString stringWithFormat:@"Game Over!!!"];
    [self addChild:_gameOverLabel];
    
    _winnerAliasLabel = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    _winnerAliasLabel.fontSize = kFontSizeAlias;
    _winnerAliasLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _winnerAliasLabel.text = [NSString stringWithFormat:@"%@ Won!!", _winnerAlias];
    [self addChild:_winnerAliasLabel];
    
}


@end
