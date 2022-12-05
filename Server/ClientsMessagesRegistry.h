/* Description:
 The ClientsMessageRegistry object is responsible for:
   - Handeling clients registration and allocating a data queue for each one of them
   - Store and Deposit data for registered clients
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mach/message.h>

#import <Foundation/Foundation.h>
#import "MessageTypeMaker.h"

@interface ClientsMessagesRegistry : NSObject

@property(readwrite) NSMutableDictionary* clients; // A mapping from a client to its saved messages.

- (void) registerNewClient:(NSNumber*) client; // Create a new data queue for a new client.
- (BOOL) isRegistered:(NSNumber*) client; // Check if a client already has a data queue.
- (NSNumber*) dequeueData:(NSNumber*) client; // Dequeue data from a client's queue.
- (BOOL) isEmptyQueue:(NSNumber*) client; // Check if a data queue is empty
- (void) removeQueue:(NSNumber*) client; // Delete a client's queue if its empty or if the client's port is dead.
- (void) enqueueData:(Message*) message; // Enqueue data to a client's queue.

@end
