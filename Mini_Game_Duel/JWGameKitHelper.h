//
//  JWGameKitHelper.h
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/25/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

// This class "wraps up" all Game Center code so it's in one place.
// It also defines a protocol/delegate that's followed by each Multiplayer Networking class. It's how they
// are notified of game center data (i.e. match started, etc.)

// It also defines a list of externs that are used to categorize/name notifications throughout this project

@import GameKit;

// Protocol defined to help notify other objects when the match starts, when it recieves data, and when it ends
@protocol GameKitHelperDelegate
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end

extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;
extern NSString *const RandomNumberReady;
extern NSString *const ReadyForNewSelectionNumber;
extern NSString *const ReadyForNewMiniGamePoints;
extern NSString *const MatchDidStart;
extern NSString *const ButtonRaceIsReady;
extern NSString *const SubDashIsReady;
extern NSString *const MiniGameEnded;

@interface JWGameKitHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>

// This delegate property gets reassigned throughout this app so that it also points to
// the current mini-game's multiplayer network class
@property (nonatomic, assign) id <GameKitHelperDelegate> delegate;

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, strong) NSMutableDictionary *playersDict;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, strong) GKMatch *match;

+(instancetype)sharedGameKitHelper;
-(void)authenticateLocalPlayer;
-(void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate;

@end
