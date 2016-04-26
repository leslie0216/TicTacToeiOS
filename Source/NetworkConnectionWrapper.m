//
//  NetworkConnectionWrapper.m
//  NetworkTest
//
//  Created by Chengzhao Li on 2016-03-29.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "NetworkConnectionWrapper.h"
#import "NetworkConnectionHandler.h"
#import "BluetoothHandler.h"

@implementation NetworkConnectionWrapper
{
    NetworkConnectionHandler *handler;
}

@synthesize isHost;

// singleton
static NetworkConnectionWrapper *_sharedWrapper = nil;

+ (NetworkConnectionWrapper *)sharedWrapper
{
    if (!_sharedWrapper) {
        _sharedWrapper = [[self alloc] init];
    }
    
    return _sharedWrapper;
}

+(id)alloc
{
    NSAssert(_sharedWrapper == nil, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

// Force creation of a new singleton, useful to prevent state leaking during tests.
+ (void) resetSingleton
{
    _sharedWrapper = nil;
}

//

-(void)setupNetwork
{
    handler = [[BluetoothHandler alloc]init];
    
    [handler setupNetwork];
}

-(void)startConnection
{
    if (isHost) {
        [handler startHost];
    } else {
        [handler startClient];
    }
}

-(void)sendDataToAll : (NSData*)data reliableFlag:(BOOL)isReliable
{
    [handler sendDataToAll:data reliableFlag:isReliable];
}

-(void)sendDataToHost : (NSData*)data reliableFlag:(BOOL)isReliable
{
    [handler sendDataToHost:data reliableFlag:isReliable];
}

-(void)sendData : (NSData*)data toPeer:(id)peerName reliableFlag:(BOOL)isReliable
{
    [handler sendData:data toPeer:peerName reliableFlag:isReliable];
}

-(int)currentConnectionCount
{
    return [handler connectionCount];
}

-(void)finishConnectionSetup
{
    if (isHost) {
        [handler stopSearch];
    } else {
        [handler stopAdvertise];
    }
}

-(void)disconnect
{
    [handler disconnect];
    handler = nil;
}

-(void)startToConnectTo:(NSString *)UUID
{
    [handler startToConnectTo:UUID];
}

-(void)setLocalName:(NSString *)n
{
    [handler setLocalName:n];
}

@end
