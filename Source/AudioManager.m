//
//  AudioManager.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "AudioManager.h"

#import "AudioManager.h"
#import "OALSimpleAudio.h"

@implementation AudioManager

// Use this method to play a sound effect based on the sound file passed in
- (void)playSoundEffect:(NSString *)soundFile {
    
    [[OALSimpleAudio sharedInstance] playEffect:soundFile];
}

- (void)playButtonClickedSound
{
    [[OALSimpleAudio sharedInstance] playEffect:@"click.wav"];
}

+ (AudioManager *)sharedAudioManager {
    
    // we are using the dispatch once predicate to ensure we use the same object
    // across all scenes
    static dispatch_once_t pred;
    static AudioManager *_sharedInstance;
    
    dispatch_once(&pred, ^{ _sharedInstance = [[self alloc] init]; });
    
    return _sharedInstance;
}

@end
