#import "ClientsMessagesRegistry.h"

@implementation ClientsMessagesRegistry

- (id) init {
    self = [super init];
    if (self) {
        _clients = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) registerNewClient:(NSNumber*) client{
    printf("[SERVER]: Allocating a new message queue...\n");
    [_clients setObject:[[NSMutableArray alloc] init] forKey:client];
    printf("[SERVER]: New message queue for %u allocated succesfuly.\n", [client unsignedIntValue]);
}

- (BOOL) isRegistered:(NSNumber*) client {
    BOOL exist = [_clients objectForKey:client] != nil;
    if (exist) {
        printf("[SERVER]: Found exisitng message queue for %u.\n", [client unsignedIntValue]);
    } else {
        printf("[SERVER]: %u is not a recognized client.\n", [client unsignedIntValue]);
    }
    return exist;
}

- (NSNumber*) dequeueData:(NSNumber*) client {
    printf("[SERVER]: Dequeuing data from client's: %u data queue.\n", [client unsignedIntValue]);
    NSNumber* data = [[_clients objectForKey:client] firstObject];
    [[_clients objectForKey:client] removeObjectAtIndex:0];
    if ([self isEmptyQueue:client]) {
        [self removeQueue:client];
    }
    return data;
}

- (BOOL) isEmptyQueue:(NSNumber*) client {
    return [[_clients objectForKey:client] count] == 0;
}

- (void) removeQueue:(NSNumber*) client{
    printf("[SERVER]: Removing data queue for: %d.\n", [client unsignedIntValue]);
    [_clients removeObjectForKey:(client)];
    printf("[SERVER]: Data queue for %d has been removed.\n", [client unsignedIntValue]);
}

- (void) enqueueData:(Message*) message {
    printf("[SERVER]: Enqueuing new message's data...\n");
    NSNumber* client = [NSNumber numberWithUnsignedInt:message->port_descriptor.name];
    NSNumber* address = [NSNumber numberWithUnsignedLong:(unsigned long)message->ool_descriptor.address];
    [[_clients objectForKey:client] addObject:address];
    printf("[SERVER]: Message's data has been enqueued.\n");
}

@end
