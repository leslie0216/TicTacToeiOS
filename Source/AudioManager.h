//
//  AudioManager.h
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioManager : NSObject

- (void)playSoundEffect:(NSString *)soundFile;
- (void)playButtonClickedSound;
+ (instancetype)sharedAudioManager;

@end
