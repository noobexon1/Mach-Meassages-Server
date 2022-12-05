#import "MessageTypeMaker.h"

@implementation MessageTypeMaker

+ (void) setupResponseMessge:(NSNumber*) data response:(Response*) response remotePort:(mach_port_t) remotePort {
    // Header:
    response->header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND, 0, MACH_MSGH_BITS_COMPLEX);
    response->header.msgh_remote_port = remotePort;
    
    response->msgh_descriptors_count = 2;
    
    // Port descriptor:
    response->port_descriptor.name = MACH_PORT_NULL;
    response->port_descriptor.type = MACH_MSG_PORT_DESCRIPTOR;
    response->port_descriptor.disposition = MACH_MSG_TYPE_MAKE_SEND;
    
    // OOL descriptor:
    response->ool_descriptor.address = [data pointerValue];
    response->ool_descriptor.size = (mach_msg_size_t) vm_page_size;
    response->ool_descriptor.copy = MACH_MSG_VIRTUAL_COPY;
    response->ool_descriptor.deallocate = true;
    response->ool_descriptor.type = MACH_MSG_OOL_DESCRIPTOR;
}

@end
