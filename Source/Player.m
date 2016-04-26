//
//  Player.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithID:(int)playerID andName:(NSString*)playerName
{
    self = [super init];
    
    self.playerID = playerID;
    self.playerName = playerName;
    self.imageName = @"";
    self.tileNumsPlayed = [NSMutableSet set];
    
    return self;
}

@end
