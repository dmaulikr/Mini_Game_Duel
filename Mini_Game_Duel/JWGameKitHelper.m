//
//  JWGameKitHelper.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/25/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//



#import "JWGameKitHelper.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";
NSString *const RandomNumberReady = @"random_number_ready";
NSString *const MatchDidStart = @"match_started";
NSString *const ButtonRaceIsReady = @"button_race_is_ready";
NSString *const SubDashIsReady = @"sub_dash_is_ready";
NSString *const MiniGameEnded = @"mini_game_ended";
NSString *const ReadyForNewSelectionNumber = @"ready_for_new_selection_number";
NSString *const ReadyForNewMiniGamePoints = @"ready_for_new_mini_game_points";

@interface JWGameKitHelper ()

@property BOOL enableGameCenter; // Keeps track of whether or not to enable GC features
@property BOOL matchStarted;

@end

@implementation JWGameKitHelper

- (id)init{
    
    self = [super init];
    if (self) {
        self.enableGameCenter = YES;
    }
    return self;
    
}

// Creating and return a "thread safe" singleton object
+ (instancetype)sharedGameKitHelper{
    
    static JWGameKitHelper *sharedGameKitHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[JWGameKitHelper alloc] init];
    });
    
    return sharedGameKitHelper;
    
}

#pragma mark - Game Center Authentication

// Creates a local player instance and sets the player's authenticateHandler which determines whether
// or not player is logged into Game Center already
- (void)authenticateLocalPlayer{

    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer.isAuthenticated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        return;
    }
    
    // If player is not logged into GC, GK passes AuthenticateHandler a VC to log the player into GC
    localPlayer.authenticateHandler  = ^(UIViewController *viewController, NSError *error) {
        
        [self setLastError:error];
        
        if(viewController != nil) {
            [self setAuthenticationViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            _enableGameCenter = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        } else {
            _enableGameCenter = NO;
        }
    };
}


// Called when the match is ready. It stores each player into the player dict for future reference
// and notifies the delegate that the match can start
- (void)lookupPlayers {
    
    NSLog(@"Looking up %lu players...", (unsigned long)_match.playerIDs.count);
    
    [GKPlayer loadPlayersForIdentifiers:_match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            _matchStarted = NO;
            [_delegate matchEnded];
        } else {
            
            // Populate players dict
            _playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [_playersDict setObject:player forKey:player.playerID];
            }
            [_playersDict setObject:[GKLocalPlayer localPlayer] forKey:[GKLocalPlayer localPlayer].playerID];
            
            // Notify delegate match can begin
            _matchStarted = YES;
            [_delegate matchStarted];
        }
    }];
}

// Store the VC passed by GK and save it. Send the notification that VC needs to be displayed
- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController{
    
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
    
}

// Save last error and log it
- (void)setLastError:(NSError *)error{
    
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[self.lastError userInfo] description]);
    }
    
}

#pragma mark - Match Making

// Called to find a match -- Does nothing if game center is not enabled
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate {
    
    if (self.enableGameCenter){
        
        self.matchStarted = NO;
        self.match = nil;
        _delegate = delegate;
        [viewController dismissViewControllerAnimated:NO completion:nil];
        
        // Configure match - my case will have min and max always be 2
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        request.minPlayers = minPlayers;
        request.maxPlayers = maxPlayers;
        
        // Shows the matchmaker view controller which allows the user to search for a random player and start the game
        GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
        mmvc.matchmakerDelegate = self;
        [viewController presentViewController:mmvc animated:YES completion:nil];
        
    }
    
}

#pragma mark - GKMatchmakerViewControllerDelegate

// Called when the user cancelled matchmaking. It dismisses the matchmaking view controller.
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {

    [viewController dismissViewControllerAnimated:YES completion:nil];
}


// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);

}

// A match has been found and game can start. Sets the match's delegate to be this GameKitHelper class so it is notified of
// incoming data and connection changes
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.match = match;
    match.delegate = self;
    
    // Check to see if the match has not already started and that all players are ready
    if (!_matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
    
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (_match != match) return;
    
    [_delegate match:match didReceiveData:data fromPlayer:playerID];
    
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (_match != match) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            
            if (!_matchStarted && match.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            _matchStarted = NO;
            [_delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [_delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [_delegate matchEnded];
}


@end
