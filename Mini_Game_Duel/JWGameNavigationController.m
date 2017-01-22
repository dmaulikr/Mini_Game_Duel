//
//  JWGameNavigationController.m
//  Mini_Game_Duel
//
//  Created by MTSS User on 11/25/14.
//  Copyright (c) 2014 Joe Wolfe. All rights reserved.
//

#import "JWGameKitHelper.h"
#import "JWGameNavigationController.h"

@interface JWGameNavigationController ()

@property (nonatomic,strong) JWGameKitHelper *gameKitHelper;

@end

@implementation JWGameNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Reference to JWGameKitHelper singleton
        _gameKitHelper = [JWGameKitHelper sharedGameKitHelper];
    }
    return self;
}

// Register for the notification to present the game kit view controller for sign in and authenticate the local player
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [_gameKitHelper authenticateLocalPlayer];
}

// Show the game kit view controller when the notification is recieved
- (void)showAuthenticationViewController {
    
    [self.topViewController presentViewController: _gameKitHelper.authenticationViewController animated:YES completion:nil];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
