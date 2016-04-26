//
//  Board.m
//  T3
//
//  Created by Chengzhao Li on 2016-04-22.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "Board.h"
#import "Parameters.h"
#import "Tile.h"
#import "CCTextureCache.h"

@implementation Board
{
    CGFloat m_columnWidth;
    CGFloat m_columnHeight;
    CGFloat m_tileMarginVertical;
    CGFloat m_tileMarginHorizontal;
}


- (void)didLoadFromCCB
{
    // initialize 2-D grid array with Tiles
    _gridArray = [NSMutableArray array];
    
    int counter = 0;
    
    // set up 2-D grid array
    for (int col = 0; col < GRID_SIZE; col++)
    {
        _gridArray[col] = [NSMutableArray array];
        
        for (int row = 0; row < GRID_SIZE; row++)
        {
            Tile *tile = (Tile*) [CCBReader load:@"Tile"];
            tile.position = [self positionForColumn:col row:row];
            tile.tileNum = counter;
            
            _gridArray[col][row] = tile;
            
            [self addChild:tile];
            
            counter++;
        }
    }
    
    // lay out background neatly
    [self setupBackground];
}

- (CGPoint)positionForColumn:(NSInteger)column row:(NSInteger)row
{
    NSInteger x = m_tileMarginHorizontal + column * (m_tileMarginHorizontal + m_columnWidth);
    NSInteger y = m_tileMarginVertical + row * (m_tileMarginVertical + m_columnHeight);
    
    return CGPointMake(x,y);
}

- (void)setupBackground
{
    // get Tile dimensions
    Tile *tempTile = (Tile *)[CCBReader load:@"Tile"];
    m_columnWidth = tempTile.contentSize.width;
    m_columnHeight = tempTile.contentSize.height;
    
    // calculate the margin by subtracting the tile sizes from the grid size
    m_tileMarginHorizontal = (self.contentSize.width - (GRID_SIZE * m_columnWidth)) / (GRID_SIZE+1);
    m_tileMarginVertical = (self.contentSize.height - (GRID_SIZE * m_columnWidth)) / (GRID_SIZE+1);
    
    // set up initial x and y positions
    float x = m_tileMarginHorizontal;
    float y = m_tileMarginVertical;
    
    for (int col = 0; col < GRID_SIZE; col++)
    {
        // iterate through each row
        x = m_tileMarginHorizontal;
        
        for (int row = 0; row < GRID_SIZE; row++)
        {
            //  iterate through each column in the current row and set Tile position
            Tile *tile = _gridArray[col][row];
            tile.position = ccp(x, y);
            
            x += m_columnWidth + m_tileMarginHorizontal;
        }
        
        y += m_columnHeight + m_tileMarginVertical;
    }
}

-(void)setEnabled:(BOOL)enabled
{
    for (int col = 0; col < GRID_SIZE; col++)
    {
        for (int row = 0; row < GRID_SIZE; row++)
        {
            Tile *tile = _gridArray[col][row];
            [tile setEnabled:enabled];
        }
    }
}

-(void)resetTiles
{
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:EMPTY_IMAGE];
    for(int col = 0; col < GRID_SIZE; col++)
    {
        for(int row = 0; row < GRID_SIZE; row++)
        {
            Tile *tile = _gridArray[col][row];
            [tile.tileImage setTexture: texture];
        }
    }
}

-(void)setTileImage:(int)tileNum image:(NSString *)imagePath
{
    CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:imagePath];
    for(int col = 0; col < GRID_SIZE; col++)
    {
        for(int row = 0; row < GRID_SIZE; row++)
        {
            Tile *tile = _gridArray[col][row];
            if (tile.tileNum == tileNum) {
                [tile.tileImage setTexture:texture];
                return;
            }
        }
    }
}

@end
