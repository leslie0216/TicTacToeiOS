//
//  Tile.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Tile.h"
#import "AudioManager.h"
#import "GameManager.h"
#import "CCTextureCache.h"

@implementation Tile
{
    CCButton* tileBtn;
}

-(void)onMove
{
    if ([[GameManager sharedGameManager]activePlayerID] == [[[GameManager sharedGameManager]localPlayer]playerID]) {
        CCLOG(@"tile %d clicked", self.tileNum);
        [[AudioManager sharedAudioManager] playButtonClickedSound];
        
        [[GameManager sharedGameManager] playerMove:[[[GameManager sharedGameManager]localPlayer]playerID] andTileNum:self.tileNum];
    }
}

-(void)setEnabled:(BOOL)enabled
{
    tileBtn.enabled = enabled;
}

-(void)setImage:(NSString *)imangePath
{
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:imangePath];
    [self.tileImage setTexture:texture];

    CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:imangePath];
    [tileBtn setBackgroundSpriteFrame:frame forState:CCControlStateNormal];
    [tileBtn setBackgroundSpriteFrame:frame forState:CCControlStateHighlighted];
    [tileBtn setBackgroundSpriteFrame:frame forState:CCControlStateDisabled];
    [tileBtn setBackgroundSpriteFrame:frame forState:CCControlStateSelected];
}


@end
