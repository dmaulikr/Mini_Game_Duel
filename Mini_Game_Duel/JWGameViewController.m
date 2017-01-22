//
//  JWViewController.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/22/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWGameViewController.h"
#import "JWGameKitHelper.h"
#import "JWMasterMultiplayerNetworking.h"

#import "JWLoadingScene.h"
#import "JWButtonRaceScene.h"
#import "JWGameSelectionScene.h"
#import "JWGameOverScene.h"

#define playerIdKey @"PlayerId"

static const int kMinPlayers = 2;
static const int kMaxPlayers = 2;
static const int kMaxPoints = 60;

@interface JWGameViewController ()

@property (nonatomic,strong) JWGameKitHelper *gameKitHelper;
@property (nonatomic,strong) JWMasterMultiplayerNetworking *networkingEngine;

@end

@implementation JWGameViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Reference to JWGameKitHelper singleton
        _gameKitHelper = [JWGameKitHelper sharedGameKitHelper];
        
        // Listen for a notification sent when a mini-game ends
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transitionToNextScene)
                                                     name:MiniGameEnded object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView *skView = (SKView*)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene *scene = [JWLoadingScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
                                                 name:LocalPlayerIsAuthenticated object:nil];
}

// Calls GameKitHelper method to find a match for this game
- (void)playerAuthenticated {
    
    _networkingEngine = [JWMasterMultiplayerNetworking sharedMultiNetworking];

    // Sets the JWGameKitHelper's delegate to be networkingEngine (JWMultiplayerNetworking class instance)
    [_gameKitHelper findMatchWithMinPlayers:kMinPlayers maxPlayers:kMaxPlayers viewController:self delegate:_networkingEngine];
    
}

// When mini-game ends, check if any of the players reached the max score.
// If so, end game and show winner. Otherwise, transition back to selection scene to continue
-(void)transitionToNextScene{
    
    SKView *skView = (SKView*)self.view;
    [skView.scene removeFromParent];
    
    // reset the gameKitHelper delegate
    _gameKitHelper.delegate = [JWMasterMultiplayerNetworking sharedMultiNetworking];
    
    // Check if a player won by reaching the max points
    NSString *winnerAlias;
    BOOL somePlayerWon = NO;
    for(int i = 0; i<kMaxPlayers; i++){
        NSNumber *pts = [_networkingEngine.pointsOfPlayers objectAtIndex:i];
        if([pts intValue] >= kMaxPoints){
            somePlayerWon = YES;
            // get the winning player's alias
            for (NSDictionary *playerDetails in _networkingEngine.orderOfPlayers) {
                NSString *playerId = playerDetails[playerIdKey];
                winnerAlias =((GKPlayer*)[JWGameKitHelper sharedGameKitHelper].playersDict[playerId]).alias;
            }
        }
    }
    
    if(somePlayerWon){
        
        // transition to game over scene
        JWGameOverScene *scene = [[JWGameOverScene alloc] initWithSize:skView.bounds.size andAlais:winnerAlias];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        SKTransition *selectionSceneTransition = [SKTransition flipHorizontalWithDuration:1.0];
        [skView presentScene:scene transition:selectionSceneTransition];
        
    }else{
    
    JWGameSelectionScene *scene = [JWGameSelectionScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    SKTransition *selectionSceneTransition = [SKTransition flipHorizontalWithDuration:1.0];
    [skView presentScene:scene transition:selectionSceneTransition];
    
    // Notify MasterMultiplayerNetworking that we are ready for new mini-game points
    [self performSelector:@selector(notify) withObject:nil afterDelay:2.0];
        
    }

}

-(void)notify{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReadyForNewMiniGamePoints object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // All games portrait mode?? Or force some to have landscape??
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
