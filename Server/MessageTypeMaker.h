/* Description:
 The MessageTypeMaker object is responsible for:
   - Defining the different message types
   - Providing setup service for messages
*/

#import <Foundation/Foundation.h>

// clients messages codes:
#define SEND 1
#define RETRIEVE 2

// Structures of messages being exchanged.
typedef struct {
    mach_msg_header_t header;
    mach_msg_size_t msgh_descriptors_count;
    mach_msg_port_descriptor_t port_descriptor;
    mach_msg_ool_descriptor_t ool_descriptor;
} Response;

typedef struct {
    mach_msg_header_t header;
    mach_msg_size_t msgh_descriptors_count;
    mach_msg_port_descriptor_t port_descriptor;
    mach_msg_ool_descriptor_t ool_descriptor;
    mach_msg_trailer_t trailer;
} Message;

@interface MessageTypeMaker : NSObject

+ (void) setupResponseMessge:(NSNumber*) data response:(Response*) response remotePort:(mach_port_t) remotePort; // Sets up all of the message metadata for a response operation.

@end
