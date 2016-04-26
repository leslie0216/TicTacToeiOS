//
//  Tile.h
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Tile : CCNode

@property (nonatomic, assign) int tileNum;
@property (nonatomic, strong) CCSprite *tileImage;

-(void)setEnabled:(BOOL)enabled;

@end
