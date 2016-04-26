//
//  Board.h
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Board : CCSprite

@property (nonatomic, readonly) NSMutableArray *gridArray;

-(void)setEnabled:(BOOL)enabled;
-(void)resetTiles;
-(void)setTileImage:(int)tileNum image:(NSString *)imagePath;

@end
