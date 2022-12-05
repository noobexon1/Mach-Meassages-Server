/* Description:
 The ServerHandler object is responsible for:
   - Initializing server port as well as checking it in the bootstrap server so that it could be found by clients.
   - Maintain the main server loop which consists of 3 stages: listen->process->react.
   - Use the services provided by the clientsMessagesRegistry object.
*/

#include <servers/bootstrap.h>
#include "ClientsMessagesRegistry.h"

#define MAX_RECEIEVE_SIZE 1024

@interface ServerHandler : NSObject

@property(readonly) mach_port_t serverPort; // Stores local port name.
@property(readwrite) ClientsMessagesRegistry* registry; // A database object that holds clients messages data queues.

- (void) listen; // React to messages received by checking the message type.
- (void) proccess:(Message*) message; // React to messages received by checking the message type.
- (void) save:(Message*) message; // Allocating a new messages data queue for a client (if required) and enqueuing the received message's data
- (void) retrieve:(Message*) message; // Dequeue a message's data from the client's messages data queue.
- (void) sendResponse:(NSNumber*) data message:(Message*) message; // Send clients data in a message back to the requesting client
- (void) cleanup; // Runs on a different thread and cleans up after dead name ports.

@end

