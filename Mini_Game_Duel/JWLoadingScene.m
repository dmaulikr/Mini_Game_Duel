//
//  JWLoadingScene.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/26/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWLoadingScene.h"
#import "JWGameSelectionScene.h"
#import "JWGameKitHelper.h"


static const int kLoadingLabelFontSize = 30;
static const int kLoadingLabelPadding = 100;
static const int kTransitionAnimation = 1;


@interface JWLoadingScene ()

@property SKLabelNode *loadingLabel;

@end

@implementation JWLoadingScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self initializeScene];        
    }
    return self;
    
}

-(void) initializeScene{
    
    [self setupBackground];
    [self setupLoadingLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transitionToSelectionScene)
                                                 name:MatchDidStart object:nil];
    
}


-(void)setupBackground{

    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"wolfe_launch.png"];
    background.size = CGSizeMake(320, 480); // weird...
    background.anchorPoint = CGPointZero;
    background.position = CGPointMake(0, 0);
    background.zPosition = -2;
    [self addChild:background];
    
}
 

-(void)setupLoadingLabel{
    
    self.loadingLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.loadingLabel.fontSize = kLoadingLabelFontSize;
    self.loadingLabel.position = CGPointMake(CGRectGetMidX(self.frame), kLoadingLabelPadding);
    self.loadingLabel.text = @"I'm Loading :D";
    [self addChild:self.loadingLabel];
    
}

// Stay on this scene until match is found, then present the game selection scene
-(void)transitionToSelectionScene{
    
    SKScene *gameSelectionScene = [JWGameSelectionScene sceneWithSize:self.view.bounds.size];
    gameSelectionScene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *selectionSceneTransition = [SKTransition doorwayWithDuration:kTransitionAnimation];
    [self.view presentScene:gameSelectionScene transition:selectionSceneTransition];
    
}

@end
