#import "LoginScene.h"
#import "Parameters.h"
#import "AudioManager.h"
#import "Player.h"
#import "GameManager.h"

@implementation LoginScene
{
    CCButton* btnStart;
    CCTextField* tfUserName;
    CCLabelTTF* lbWarninng;
}

-(void)didLoadFromCCB
{
    btnStart.enabled = NO;
    lbWarninng.string = [NSString stringWithFormat:@"The length of user name must be\nbetween %d and %d letters", MIN_USERNAME_LENGTH, MAX_USERNAME_LENGTH];
    lbWarninng.visible = NO;
}

-(void)onBtnStartClicked
{
    CCLOG(@"name = %@", tfUserName.string);
    [[AudioManager sharedAudioManager] playButtonClickedSound];
    
    // init local player with random id
    Player* localPlayer = [[Player alloc] initWithID:arc4random_uniform(10000) andName:tfUserName.string];
    [[GameManager sharedGameManager]setLocalPlayer:localPlayer];
    
    CCScene *serverClientScene = [CCBReader loadAsScene:@"ServerClientScene"];
    [[CCDirector sharedDirector] replaceScene:serverClientScene];
}

-(void)onUserNameEntered:(id)sender
{
    if (tfUserName.string.length >= MIN_USERNAME_LENGTH && tfUserName.string.length <= MAX_USERNAME_LENGTH) {
        btnStart.enabled = YES;
        lbWarninng.visible = NO;
    } else {
        btnStart.enabled = NO;
        lbWarninng.visible = YES;
    }
}

@end
