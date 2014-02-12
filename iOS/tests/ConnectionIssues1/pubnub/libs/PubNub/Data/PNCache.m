/**

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNCache.h"


#pragma mark Private interface declaration

@interface PNCache ()

#pragma mark - Properties

/**
 Unified storage for cached data across all channels which is in use by client and developer.
 */
@property (nonatomic, strong) NSMutableDictionary *stateCache;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNCache


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.stateCache = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Metadata management method

- (NSDictionary *)state {

    return ([self.stateCache count] ? [self.stateCache copy] : nil);
}

- (void)storeClientState:(NSDictionary *)clientState forChannel:(PNChannel *)channel {

    if (clientState) {

        if (channel) {
            
            if ([self.stateCache valueForKey:channel.name]) {
                
                NSMutableDictionary *oldState = [[self.stateCache valueForKey:channel.name] mutableCopy];
                [oldState addEntriesFromDictionary:clientState];
                
                clientState = oldState;
            }

            [self.stateCache setValue:clientState forKey:channel.name];
        }
    }
    else {

        [self purgeStateForChannel:channel];
    }
}

- (void)storeClientState:(NSDictionary *)clientState forChannels:(NSArray *)channels {
    
    if (clientState) {
        
        [channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
            
            if ([clientState valueForKey:channel.name] != nil || [self.stateCache valueForKey:channel.name]) {
                
                NSDictionary *state = [clientState valueForKey:channel.name];
                
                if ([self.stateCache valueForKey:channel.name]) {
                    
                    NSMutableDictionary *oldState = [[self.stateCache valueForKey:channel.name] mutableCopy];
                    if (state) {
                        
                        [oldState addEntriesFromDictionary:state];
                    }
                    
                    state = oldState;
                }
                [self.stateCache setValue:state forKey:channel.name];
            }
        }];
    }
    else {
        
        [self purgeStateForChannels:channels];
    }
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {

    return (channel ? [self.stateCache valueForKey:channel.name] : nil);
}

- (NSDictionary *)stateForChannels:(NSArray *)channels {

    NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
    [channelsSet intersectSet:[NSSet setWithArray:[self.stateCache allKeys]]];


    return ([channelsSet count] ? [self.stateCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
}

- (void)purgeStateForChannel:(PNChannel *)channel {

    if (channel) {

        [self.stateCache removeObjectForKey:channel.name];
    }
}

- (void)purgeStateForChannels:(NSArray *)channels {

    if (channels) {

        [self.stateCache removeObjectsForKeys:[channels valueForKey:@"name"]];
    }
}

- (void)purgeAllState {

    [self.stateCache removeAllObjects];
}

#pragma mark -


@end