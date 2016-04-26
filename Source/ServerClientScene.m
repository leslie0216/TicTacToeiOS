//
//  ServerClientScene.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "ServerClientScene.h"
#import "AudioManager.h"
#import "GameManager.h"
#import "Parameters.h"

@implementation ServerClientScene

-(void)onServer
{
    CCLOG(@"onServer");
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    [[GameManager sharedGameManager]localPlayer].imageName = X_IMAGE;
    [[GameManager sharedGameManager] setIsHost:YES];
    
    CCScene *lobbyScene = [CCBReader loadAsScene:@"LobbyScene"];
    [[CCDirector sharedDirector] replaceScene:lobbyScene];
}

-(void)onClient
{
    CCLOG(@"onClient");
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    [[GameManager sharedGameManager]localPlayer].imageName = O_IMAGE;
    [[GameManager sharedGameManager] setIsHost:NO];

    CCScene *lobbyScene = [CCBReader loadAsScene:@"LobbyScene"];
    [[CCDirector sharedDirector] replaceScene:lobbyScene];
}

-(void)onBtnBackClicked
{
    CCLOG(@"onBtnBackClicked");
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    CCScene *loginScene = [CCBReader loadAsScene:@"LoginScene"];
    [[CCDirector sharedDirector] replaceScene:loginScene];
}

@end
