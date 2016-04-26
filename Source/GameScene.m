//
//  GameScene.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "GameScene.h"
#import "Board.h"
#import "AudioManager.h"
#import "NetworkConnectionWrapper.h"
#import "GameManager.h"

@implementation GameScene
{
    CCLabelTTF* lbTurnMsg;
    Board* board;
    
    NetworkConnectionWrapper* networkWrapper;
}

-(void)didLoadFromCCB
{
    networkWrapper = [NetworkConnectionWrapper sharedWrapper];

    [board setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerChangedStateWithNotification:)                                                 name:CONNECTION_STATE_CHANGED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReceivedDataWithNotification:)
                                                 name:RECEIVED_DATA_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerReadyToNewGameWithNotification:)
                                                 name:GAMEMANAGER_READY_TO_NEW_GAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerStartNewGameWithNotification:)
                                                 name:GAMEMANAGER_START_NEW_GAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerPlayerMoveWithNotification:)
                                                 name:GAMEMANAGER_PLAYER_MOVE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerGameFinishedWithNotification:)
                                                 name:GAMEMANAGER_GAME_FINISHED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerGameDrawWithNotification:)
                                                 name:GAMEMANAGER_GAME_DRAW
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameManagerSwitchPlayerWithNotification:)
                                                 name:GAMEMANAGER_SWITCH_PLAYER
                                               object:nil];
    
    if (![[GameManager sharedGameManager] isHost]) {
        [[GameManager sharedGameManager] sendClientSceneLoadedEvent];
    }
}

-(void)onBtnBackClicked
{
    CCLOG(@"onBtnBackClicked");
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Quit" message:@"Do you want to quit the game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alertView.tag = 1;
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
            CCLOG(@"GameScene: User quit the game");
            [self disconnectAndBack];
        }
    } else if (alertView.tag == 2) {
        // disconnect
        CCLOG(@"GameScene: Connection break");
        [self disconnectAndBack];
    } else if (alertView.tag == 3) {
        if ([alertView cancelButtonIndex] == buttonIndex) {
            // local player first
            [[GameManager sharedGameManager] startNewGame:[[[GameManager sharedGameManager] localPlayer] playerName]];
            
        } else {
            // remote player first
            [[GameManager sharedGameManager] startNewGame:[[[GameManager sharedGameManager] remotePlayer] playerName]];
        }
    } else if (alertView.tag == 4) {
        if ([alertView cancelButtonIndex] == buttonIndex) {
            // do nothing
            
        } else {
            // start a new game
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"New Game" message:@"Choose the first player" delegate:self cancelButtonTitle:[[[GameManager sharedGameManager] localPlayer] playerName] otherButtonTitles:[[[GameManager sharedGameManager] remotePlayer] playerName], nil];
            alertView.tag = 3;
            
            [alertView show];
        }
    }
}

-(void)disconnectAndBack
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [networkWrapper disconnect];
    
    CCScene *serverClientScene = [CCBReader loadAsScene:@"ServerClientScene"];
    [[CCDirector sharedDirector] replaceScene:serverClientScene];
}

- (void)peerChangedStateWithNotification:(NSNotification *)notification
{
    if ([networkWrapper currentConnectionCount] == 0)
    {
        NSString* msg = [[notification userInfo] objectForKey:@"connectionInfo"];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error." message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 2;
        
        [alertView show];
    }
}

- (void)handleReceivedDataWithNotification:(NSNotification *)notification
{
    NSData* msg = [[notification userInfo] objectForKey:@"data"];
    [[GameManager sharedGameManager] processMessage:msg];
}

-(void)gameManagerReadyToNewGameWithNotification:(NSNotification *)notification
{
    if ([[GameManager sharedGameManager] isHost]) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"New Game" message:@"Choose the first player" delegate:self cancelButtonTitle:[[[GameManager sharedGameManager] localPlayer] playerName] otherButtonTitles:[[[GameManager sharedGameManager] remotePlayer] playerName], nil];
        alertView.tag = 3;
        
        [alertView show];
    }
}

-(void)gameManagerStartNewGameWithNotification:(NSNotification *)notification
{
    // reset tiles
    [board resetTiles];
    
    if ([[GameManager sharedGameManager]activePlayerID] == [[[GameManager sharedGameManager]localPlayer]playerID]) {
        [board setEnabled:YES];
        lbTurnMsg.string = @"Your turn";
    } else {
        [board setEnabled:NO];
        lbTurnMsg.string = @"Waiting...";
    }
}

-(void)gameManagerPlayerMoveWithNotification:(NSNotification *)notification
{
    NSNumber* tileNum = [[notification userInfo] objectForKey:@"tileNum"];
    NSNumber* playerId = [[notification userInfo] objectForKey:@"playerId"];
    if ([playerId intValue] == [[[GameManager sharedGameManager]localPlayer]playerID])
    {
        [board setTileImage:[tileNum intValue] image:[[[GameManager sharedGameManager]localPlayer]imageName]];
    } else {
        [board setTileImage:[tileNum intValue] image:[[[GameManager sharedGameManager]remotePlayer]imageName]];
    }
}

-(void)gameManagerGameFinishedWithNotification:(NSNotification *)notification
{
    [board setEnabled:NO];
    NSNumber* playerId = [[notification userInfo] objectForKey:@"winnerId"];
    if ([[[GameManager sharedGameManager]localPlayer]playerID] == [playerId intValue]) {
        lbTurnMsg.string = @"You Win";
    } else {
        lbTurnMsg.string = @"You Lose";
    }
    
    [self newGameAlert];
}

-(void)gameManagerGameDrawWithNotification:(NSNotification *)notification
{
    [board setEnabled:NO];
    lbTurnMsg.string = @"Draw!!!";
    
    [self newGameAlert];
}

-(void)gameManagerSwitchPlayerWithNotification:(NSNotification *)notification
{
    if ([[GameManager sharedGameManager]activePlayerID] == [[[GameManager sharedGameManager]localPlayer]playerID]) {
        [board setEnabled:YES];
        lbTurnMsg.string = @"Your turn";
    } else {
        [board setEnabled:NO];
        lbTurnMsg.string = @"Waiting...";
    }
}

-(void)newGameAlert
{
    if ([[GameManager sharedGameManager]isHost]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:lbTurnMsg.string message:@"Start a new game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        alertView.tag = 4;
        
        [alertView show];
    }
}

@end
