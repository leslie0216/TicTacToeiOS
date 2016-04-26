//
//  GameManager.h
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface GameManager : NSObject

+ (GameManager *)sharedGameManager;

@property(assign, nonatomic)BOOL isHost;
@property(atomic, strong) Player* localPlayer;
@property(atomic, strong) Player* remotePlayer;
@property(assign, nonatomic)int activePlayerID;

-(void)startNewGame:(NSString *)firstPlayer;

-(void)readyToGameScene;

-(void)sendPlayerInfo;

- (void)processMessage:(NSData*)data;

-(void)sendClientSceneLoadedEvent;

-(void)playerMove:(int)playerId andTileNum:(int)tileNum;


@end
