//
//  Player.h
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

- (id)initWithID:(int)playerNum andName:(NSString*)playerName;

@property (nonatomic, assign) int playerID;
@property (nonatomic, strong) NSString *playerName;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSMutableSet *tileNumsPlayed;

@end
