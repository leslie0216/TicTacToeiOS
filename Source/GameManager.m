//
//  GameManager.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "GameManager.h"
#import "NetworkConnectionWrapper.h"
#import "Messages.pbobjc.h"
#import "LobbyScene.h"

@implementation GameManager
{
    NetworkConnectionWrapper* networkWrapper;
    
    NSArray* winnerCombo;
    int numBoardSpots;
    int numFilledBoardSpots;
}

@synthesize isHost;

static GameManager *_sharedGameManager = nil;

+ (GameManager *)sharedGameManager {
    
    @synchronized(self) {
        
        if (_sharedGameManager == nil) {
            _sharedGameManager = [[GameManager alloc] init];
        }
    }
    
    return _sharedGameManager;
}

#pragma mark -
#pragma mark Init/Alloc Methods

+ (id)alloc {
    
    @synchronized([GameManager class]) {
        
        NSAssert(
                 _sharedGameManager == nil,
                 @"Attempted to allocate a second instance of the GameManager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

- (id)init {
    
    if (self = [super init]) {
    }
    
    CCLOG(@"GameManager init");
    networkWrapper = [NetworkConnectionWrapper sharedWrapper];
    
    winnerCombo = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@0,@1,@2,nil], [NSArray arrayWithObjects:@0,@3,@6,nil], [NSArray arrayWithObjects:@0,@4,@8,nil], [NSArray arrayWithObjects:@1,@4,@7,nil], [NSArray arrayWithObjects:@2,@4,@6,nil], [NSArray arrayWithObjects:@2,@5,@8,nil], [NSArray arrayWithObjects:@3,@4,@5,nil], [NSArray arrayWithObjects:@6,@7,@8,nil], nil];
    
    numBoardSpots = GRID_SIZE * GRID_SIZE;
    numFilledBoardSpots = 0;
    
    return self;
}

- (void)dealloc {
    
    CCLOG(@"GameManager dealloc");
}

-(void)readyToGameScene
{
    [networkWrapper finishConnectionSetup];
    
    //broadcast to remote
    if (isHost) {
        NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_GO_TO_GAME andMessage:nil];
        [self sendMessage:data];
    }
    
    CCScene *gameScene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:gameScene];
}

-(void)sendPlayerInfo
{
    //send local player info
    T3PlayerDataMessage *msg = [[T3PlayerDataMessage alloc]init];
    msg.playerName = self.localPlayer.playerName;
    msg.playerId = self.localPlayer.playerID;
    
    NSData *data = [self packMessageWithType:MSG_PLAYER_DATA andMessage:msg];
    [self sendMessage:data];
}

-(void)sendClientSceneLoadedEvent
{
    if (!isHost)
    {
        NSData *data = [self packMessageWithType:MSG_CLIENT_SERVER_SCENE_LOADED andMessage:nil];
        [self sendMessage:data];
    }
}

-(void)startNewGame:(NSString *)firstPlayer;
{
    self.activePlayerID = [self.localPlayer.playerName isEqualToString:firstPlayer] ? self.localPlayer.playerID : self.remotePlayer.playerID;
    
    if (isHost) {
        T3StartNewGameMessage *msg = [[T3StartNewGameMessage alloc]init];
        msg.initPlayerId = self.activePlayerID;
        NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_START_NEW_GAME andMessage:msg];
        [self sendMessage:data];
    }
    
    if (self.localPlayer.tileNumsPlayed == nil)
    {
        self.localPlayer.tileNumsPlayed = [NSMutableSet set];
    } else {
        [self.localPlayer.tileNumsPlayed removeAllObjects];
    }
    
    if (self.remotePlayer.tileNumsPlayed == nil)
    {
        self.remotePlayer.tileNumsPlayed = [NSMutableSet set];
    } else {
        [self.remotePlayer.tileNumsPlayed removeAllObjects];
    }
    
    numFilledBoardSpots = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_START_NEW_GAME
                                                            object:nil
                                                          userInfo:nil];
    });
}

-(void)playerMove:(int)playerId andTileNum:(int)tileNum
{
    if (isHost) {
        numFilledBoardSpots++;
        if (self.localPlayer.playerID == playerId) {
            [self.localPlayer.tileNumsPlayed addObject:@(tileNum)];
        } else {
            [self.remotePlayer.tileNumsPlayed addObject:@(tileNum)];
        }
        
        // broadcast to client
        T3PlayerMoveMessage *msg = [[T3PlayerMoveMessage alloc]init];
        msg.playerId = self.activePlayerID;
        msg.tileNum = tileNum;
        NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_PLAYER_MOVE andMessage:msg];
        [self sendMessage:data];
        
        // change tile imange
        NSNumber *player = [NSNumber numberWithInt:playerId];
        NSNumber *num = [NSNumber numberWithInt:tileNum];
        NSDictionary *userInfo = @{ @"playerId": player,
                                    @"tileNum": num};
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_PLAYER_MOVE
                                                                object:nil
                                                              userInfo:userInfo];
        });
        
        [self updateGame];
    } else {
        // send move msg to server
        T3PlayerMoveMessage *msg = [[T3PlayerMoveMessage alloc]init];
        msg.playerId = self.localPlayer.playerID;
        msg.tileNum = tileNum;
        NSData *data = [self packMessageWithType:MSG_CLIENT_SERVER_MOVE_ACTION andMessage:msg];
        [self sendMessage:data];
    }
}

-(void)updateGame
{
    // check winner
    Player* currentPlayer = self.activePlayerID == self.localPlayer.playerID ? self.localPlayer : self.remotePlayer;
    if ([self isPlayerWin:currentPlayer]) {
        NSNumber *player = [NSNumber numberWithInt:self.activePlayerID];
        NSDictionary *userInfo = @{ @"winnerId": player};
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_GAME_FINISHED
                                                                object:nil
                                                              userInfo:userInfo];
        });
        
        // send msg to client
        T3GameFinishedMessage* msg = [[T3GameFinishedMessage alloc]init];
        msg.winnerId = self.activePlayerID;
        NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_GAME_FINISHED andMessage:msg];
        [self sendMessage:data];
        
        return;
    }
    
    // check if draw
    if (numBoardSpots == numFilledBoardSpots) {
        // send msg to client
        NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_GAME_DRAW andMessage:nil];
        [self sendMessage:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_GAME_DRAW
                                                                object:nil
                                                              userInfo:nil];
        });
        
        return;
    }
    
    // swith player
    self.activePlayerID = self.activePlayerID == self.localPlayer.playerID ? self.remotePlayer.playerID : self.localPlayer.playerID;
    
    // send msg to client
    T3SwitchPlayerMessage *msg = [[T3SwitchPlayerMessage alloc]init];
    msg.activePlayerId = self.activePlayerID;
    NSData *data = [self packMessageWithType:MSG_SERVER_CLIENT_SWITCH_PLAYER andMessage:msg];
    [self sendMessage:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_SWITCH_PLAYER
                                                            object:nil
                                                          userInfo:nil];
    });
}

-(BOOL)isPlayerWin:(Player *)player
{
    if([player.tileNumsPlayed count] < 3) { return NO; }
    
    int index = 0;
    
    // check winning combos until a winning one is found
    int numWinningCombos = [winnerCombo count];
    
    while (index < numWinningCombos)
    {
        NSArray *winningComboToTest = winnerCombo[index];
        NSMutableSet *playersTileNums = player.tileNumsPlayed;
        
        if([playersTileNums containsObject:winningComboToTest[0]] & [playersTileNums containsObject:winningComboToTest[1]] & [playersTileNums containsObject:winningComboToTest[2]])
        {
            return YES;
        }
        
        index++;
    }
    
    return NO;
}

-(NSData*)packMessageWithType:(char)msgType andMessage:(GPBMessage*)msg{
    char* target = msgBuffer;
    msgBuffer[0] = msgType;
    target++;
    
    if(msg == nil) {
        // this message has no content
        return [NSData dataWithBytesNoCopy:msgBuffer length:1 freeWhenDone:NO];
    }
    
    NSData* msgData = msg.data;
    NSUInteger len = [msgData length];
    memcpy(target, [msgData bytes], len);
    
    return [NSData dataWithBytesNoCopy:msgBuffer length:len+1 freeWhenDone:NO];
}

-(void)sendMessage:(NSData*)data
{
    if (isHost) {
        [networkWrapper sendDataToAll:data reliableFlag:YES];
    } else {
        [networkWrapper sendDataToHost:data reliableFlag:YES];
    }
}

- (void)processMessage:(NSData*)data
{
    char* msgPointer = (char*)[data bytes];
    int msgLength = [data length];
    int msgType = (int)msgPointer[0];
    msgPointer++;
    
    NSData* msgData;
    msgData = [NSData dataWithBytes:msgPointer length:msgLength-1];
    switch (msgType) {
        case MSG_PLAYER_DATA:
        {
            T3PlayerDataMessage* recvMsg;
            recvMsg = [T3PlayerDataMessage parseFromData:msgData error:nil];
            if (self.remotePlayer == nil) {
                self.remotePlayer = [[Player alloc]init];
                if (isHost) {
                    self.remotePlayer.imageName = O_IMAGE;
                } else {
                    self.remotePlayer.imageName = X_IMAGE;
                }
            }
            
            self.remotePlayer.playerName = recvMsg.playerName;
            self.remotePlayer.playerID = recvMsg.playerId;
            
            if (!isHost) {
                NSDictionary *userInfo = @{ @"serverName": recvMsg.playerName};
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:CLINET_DID_FOUND_SERVER_NOTIFICATION
                                                                        object:nil
                                                                      userInfo:userInfo];
                });
            } else {                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:REMOTE_INFO_UP_TO_DATE
                                                                        object:nil
                                                                      userInfo:nil];
                }); 
            }

            break;
        }
        case MSG_SERVER_CLIENT_GO_TO_GAME:
        {
            [networkWrapper finishConnectionSetup];
            
            CCScene* scene = [[CCDirector sharedDirector] runningScene];
            if ([scene isKindOfClass:[LobbyScene class]]) {
                LobbyScene *ls = (LobbyScene *)scene;
                [[NSNotificationCenter defaultCenter] removeObserver:ls];
            }
            
            CCScene *gameScene = [CCBReader loadAsScene:@"GameScene"];
            [[CCDirector sharedDirector] replaceScene:gameScene];
            break;
        }
        case MSG_CLIENT_SERVER_SCENE_LOADED:{
            if (isHost) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_READY_TO_NEW_GAME
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            break;
        }
        case MSG_SERVER_CLIENT_START_NEW_GAME:
        {
            T3StartNewGameMessage* recvMsg;
            recvMsg = [T3StartNewGameMessage parseFromData:msgData error:nil];
            [self startNewGame:(recvMsg.initPlayerId == self.localPlayer.playerID) ? self.localPlayer.playerName : self.remotePlayer.playerName];
            break;
        }
        case MSG_SERVER_CLIENT_PLAYER_MOVE:
        {
            if (!isHost) {
                T3PlayerMoveMessage* msg = [T3PlayerMoveMessage parseFromData:msgData error:nil];
                numFilledBoardSpots++;
                if (self.localPlayer.playerID == msg.playerId) {
                    [self.localPlayer.tileNumsPlayed addObject:@(msg.tileNum)];
                } else {
                    [self.remotePlayer.tileNumsPlayed addObject:@(msg.tileNum)];
                }
                
                NSNumber *playerId = [NSNumber numberWithInt:msg.playerId];
                NSNumber *num = [NSNumber numberWithInt:msg.tileNum];
                NSDictionary *userInfo = @{ @"playerId": playerId,
                                            @"tileNum": num};
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_PLAYER_MOVE
                                                                        object:nil
                                                                      userInfo:userInfo];
                });
            }
            break;
        }
        case MSG_CLIENT_SERVER_MOVE_ACTION:
        {
            if (isHost) {
                T3PlayerMoveMessage* msg = [T3PlayerMoveMessage parseFromData:msgData error:nil];
                [self playerMove:msg.playerId andTileNum:msg.tileNum];
            }
            break;
        }
        case MSG_SERVER_CLIENT_GAME_FINISHED:
        {
            if (!isHost) {
                T3GameFinishedMessage* msg = [T3GameFinishedMessage parseFromData:msgData error:nil];
                NSNumber *player = [NSNumber numberWithInt:msg.winnerId];
                NSDictionary *userInfo = @{ @"winnerId": player};
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_GAME_FINISHED
                                                                        object:nil
                                                                      userInfo:userInfo];
                });
            }
        }
        case MSG_SERVER_CLIENT_GAME_DRAW:
        {
            if (!isHost) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_GAME_DRAW
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            break;
        }
        case MSG_SERVER_CLIENT_SWITCH_PLAYER:
        {
            if (!isHost)
            {
                T3SwitchPlayerMessage *msg = [T3SwitchPlayerMessage parseFromData:msgData error:nil];
                self.activePlayerID = msg.activePlayerId;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GAMEMANAGER_SWITCH_PLAYER
                                                                        object:nil
                                                                      userInfo:nil];
                });
            }
            break;
        }
    }

}

@end
