//
//  LobbyScene.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "LobbyScene.h"
#import "AudioManager.h"
#import "GameManager.h"
#import "Parameters.h"
#import "T3ConnectAlertView.h"
#import "NetworkConnectionWrapper.h"

@implementation LobbyScene
{
    CCLabelTTF* lbRole;
    CCLabelTTF* lbMsg;
    CCLabelTTF* lbPlayer1;
    CCLabelTTF* lbPlayer2;
    CCNode* iconPlayer1;
    CCNode* iconPlayer2;
    CCButton* btnStartGame;
    CCButton* btnBack;
    
    NetworkConnectionWrapper* networkWrapper;
}

-(void)didLoadFromCCB
{
    if ([[GameManager sharedGameManager] isHost]) {
        lbRole.string = @"Server";
        lbMsg.string = @"Waiting for player...";
        lbPlayer1.color = [CCColor whiteColor];
        lbPlayer1.string = [[GameManager sharedGameManager] localPlayer].playerName;
        lbPlayer2.color = [CCColor darkGrayColor];
        lbPlayer2.string = @"--empty--";
        btnStartGame.enabled = NO;
        btnBack.enabled = YES;
    } else {
        lbRole.string = @"Client";
        lbMsg.string = @"Searching for game...";
        lbPlayer1.color = [CCColor darkGrayColor];
        lbPlayer1.string = @"--empty--";
        lbPlayer2.color = [CCColor whiteColor];
        lbPlayer2.string = [[GameManager sharedGameManager] localPlayer].playerName;
        btnStartGame.enabled = NO;
        btnStartGame.visible = NO;
        btnBack.position = ccp(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.195);
    }
    
    networkWrapper = [NetworkConnectionWrapper sharedWrapper];
    [networkWrapper setIsHost:[[GameManager sharedGameManager] isHost]];
    [networkWrapper setupNetwork];
    [networkWrapper setLocalName:[[GameManager sharedGameManager] localPlayer].playerName];
    [networkWrapper startConnection];
    
    if ([[GameManager sharedGameManager] isHost]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foundPeerWithNotification:)
                                                     name:SERVER_DID_FOUND_CLIENT_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverClientConnectionDoneNotification:)                                                 name:SERVER_CLIENT_CONNECTION_DONE_NOTIFICATION
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foundServerWithNotification:)
                                                     name:CLINET_DID_FOUND_SERVER_NOTIFICATION
                                                   object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startConnectionFailedNotification:)                                                 name:SERVER_CLIENT_DID_NOT_START_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)                                                 name:CONNECTION_STATE_CHANGED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:RECEIVED_DATA_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remoteInfoUpToDateWithNotification:)
                                                 name:REMOTE_INFO_UP_TO_DATE
                                               object:nil];
}

-(void)onBtnStartGameClicked
{
    CCLOG(@"onBtnStartGameClicked");
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[GameManager sharedGameManager] readyToGameScene];
}

-(void)onBtnBackClicked
{
    CCLOG(@"onBtnBackClicked");
    [[AudioManager sharedAudioManager] playButtonClickedSound];

    [self disconnectAndBack];
}

-(void)disconnectAndBack
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [networkWrapper disconnect];
    
    CCScene *serverClientScene = [CCBReader loadAsScene:@"ServerClientScene"];
    [[CCDirector sharedDirector] replaceScene:serverClientScene];
}

- (void)foundPeerWithNotification:(NSNotification *)notification
{
    NSString* remoteName = [[notification userInfo] objectForKey:@"peerName"];
    NSString* UUID = [[notification userInfo] objectForKey:@"peerUUID"];
    if ([[GameManager sharedGameManager]isHost]) {
        NSString* msg = [NSString stringWithFormat:@"%@ would like to join your game, do you accept?", remoteName];
        
        T3ConnectAlertView *alert = [[T3ConnectAlertView alloc] initWithTitle:@"Player Request" message:msg delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
        
        alert.target = UUID;
        alert.tag = 1;
        
        [alert show];
    }
    
}

-(void)foundServerWithNotification:(NSNotification *)notification
{
    NSString* remoteName = [[notification userInfo] objectForKey:@"serverName"];
    if (![[GameManager sharedGameManager]isHost]) {
        NSString* msg = [NSString stringWithFormat:@"The game %@ was found,. Would you like to connect?", remoteName];
        
        T3ConnectAlertView *alert = [[T3ConnectAlertView alloc] initWithTitle:@"Game Found" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
        
        alert.target = remoteName;
        alert.tag = 2;
        
        [alert show];
    }
}

- (void)startConnectionFailedNotification:(NSNotification *)notification
{
    NSError* error = [[notification userInfo] objectForKey:@"error"];
    NSString* msg = [NSString stringWithFormat:@"\nstart connection failed : %@",error];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error." message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    

    [alertView show];
}

- (void)serverClientConnectionDoneNotification:(NSNotification *)notification
{
    // if host, send server info to client
    if ([networkWrapper isHost]) {
        [[GameManager sharedGameManager] sendPlayerInfo];
    }
    
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification
{
    if ([networkWrapper currentConnectionCount] == 0)
    {
        NSString* msg = [[notification userInfo] objectForKey:@"connectionInfo"];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error." message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 3;
        
        [alertView show];
    }
}

-(void)remoteInfoUpToDateWithNotification:(NSNotification *)notification
{
    if ([networkWrapper isHost]) {
        if ([networkWrapper currentConnectionCount] > 0) {
            btnStartGame.enabled = YES;
        } else {
            btnStartGame.enabled = NO;
        }
        lbMsg.string = @"Ready to game";
        lbPlayer2.color = [CCColor whiteColor];
        lbPlayer2.string = [[GameManager sharedGameManager] remotePlayer].playerName;
    } else {
        lbMsg.string = @"Ready to game";
        lbPlayer1.color = [CCColor whiteColor];
        lbPlayer1.string = [[GameManager sharedGameManager] remotePlayer].playerName;
    }
    
    [networkWrapper finishConnectionSetup];
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification
{
    NSData* msg = [[notification userInfo] objectForKey:@"data"];
    [[GameManager sharedGameManager] processMessage:msg];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept"]) {
            T3ConnectAlertView* alertV = (T3ConnectAlertView*)alertView;
            [networkWrapper startToConnectTo:alertV.target];
        }
    } else if (alertView.tag == 2) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            [networkWrapper disconnect];
        } else {
            [self remoteInfoUpToDateWithNotification:nil];

            // send client info to server
            [[GameManager sharedGameManager]sendPlayerInfo];
        }
    } else if (alertView.tag == 3) {
        // disconnect
        [self disconnectAndBack];
    }
}

@end
