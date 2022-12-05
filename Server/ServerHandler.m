#import "ServerHandler.h"

@implementation ServerHandler

- (id) init {
    self = [super init];
    if (self) {
        // Allocate a new local port in the server's namespace with RECEIVE right.
        kern_return_t result = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &_serverPort);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Local port \"RECEIVE\" right allocation failed with exit code 0x%x\n", result);
            exit(1);
        }
        printf("[SERVER]: Local port allocated at server's namespace with a \"RECEIVE\" right. name: %u.\n", _serverPort);
        
        // Add a SEND right to the local port created above. This right will be supplied to the bootstrap server to be copied to requesting clients.
        result = mach_port_insert_right(mach_task_self(), _serverPort, _serverPort, MACH_MSG_TYPE_MAKE_SEND);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Local port %u was not granted SEND right. exit code 0x%x\n", _serverPort, result);
            exit(1);
        }
        printf("[SERVER]: Local port %u was granted \"SEND\" right.\n", _serverPort);
        
        // Check in the server's port name at the bootstrap server (probably launchd) so it can be looked up.
        result = bootstrap_check_in(bootstrap_port, "ima.good.mach.com", &_serverPort);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Unable to register server at the bootstrap server. exit code 0x%x\n", result);
            exit(1);
        }
        printf("[SERVER]: Successfuly registered server port on the bootstrap server.\n");
        
        _registry = [[ClientsMessagesRegistry alloc] init];
    }
    return self;
}

- (void) listen {
    Message message = {0};
    
    mach_msg_return_t result = mach_msg(
            &message.header,                            // msg;
            MACH_RCV_MSG,                               // option;
            0,                                          // send_size;
            MAX_RECEIEVE_SIZE,                          // receive_limit;
            _serverPort,                                // receive_name;
            MACH_MSG_TIMEOUT_NONE,                      // timeout;
            MACH_PORT_NULL                              // notify;
        );
    
    if (result != KERN_SUCCESS) {
        printf("\n[ERROR]: There was a problem while listening to clients requests. error 0x%x\n", result);
        exit(1);
    }
    printf("\n[SERVER]: Received a new message from %u.\n", message.port_descriptor.name);
        
    [self proccess:&message];
}

- (void) proccess:(Message*) message {
    if (message->header.msgh_id == SEND) {
        [self save:message];
    } else if (message->header.msgh_id == RETRIEVE) {
        [self retrieve:message];
    } else {
        printf("[ERROR]: Unrecognized message type... Ignoring.");
    }
}

- (void) save:(Message*) message {
    NSNumber* client = [NSNumber numberWithUnsignedInt:message->port_descriptor.name];
    if (![_registry isRegistered:client]) {
        [_registry registerNewClient:client];
    }
    [_registry enqueueData:message];
}

- (void) retrieve:(Message*) message {
    NSNumber* client = [NSNumber numberWithUnsignedInt:message->port_descriptor.name];
    if (![_registry isRegistered:client]) {
        printf("[SERVER]: Ignoring... Retrieve request is from a non-registered entity\n");
    } else {
        NSNumber* data = [_registry dequeueData:client];
        printf("[SERVER]: Data Retrieved succesfuly.\n");
        [self sendResponse:data message:message];
    }
}

- (void) sendResponse:(NSNumber*) data message:(Message*) message {
    printf("[SERVER]: Responding to %u with requested data...\n", message->port_descriptor.name);
    
    Response response = {0};
    [MessageTypeMaker setupResponseMessge:data response:&response remotePort:message->header.msgh_remote_port];
    
    mach_msg_return_t result = mach_msg(
            &response.header,                       // msg;
            MACH_SEND_MSG,                          // option;
            sizeof(response),                       // send_size;
            0,                                      // receive_limit;
            MACH_PORT_NULL,                         // receive_name;
            MACH_MSG_TIMEOUT_NONE,                  // timeout;
            MACH_PORT_NULL                          // notify;
        );
    
    if (result != KERN_SUCCESS) {
        printf("\n[ERROR]: Response sending failed with error 0x%x\n", result);
        exit(1);
    }
        
    printf("[SERVER]: Responded succesfuly to: %u.\n", message->port_descriptor.name);
}

- (void) cleanup {
    while (1) {
        sleep(1);
        NSArray* clients = [[_registry clients] allKeys];
        if ([clients count] != 0) {
            [clients enumerateObjectsUsingBlock:^(id  _Nonnull client, NSUInteger i, BOOL * _Nonnull stop) {
                mach_port_type_t type;
                mach_port_type(mach_task_self(), [client unsignedIntValue], &type);
                if (type == MACH_PORT_TYPE_DEAD_NAME) {
                    printf("\n[SERVER]: Client %d is no longer reachable. Removing virtual memory pages...\n", [client unsignedIntValue]);
                    NSMutableArray* dataQueue = [[_registry clients] objectForKey:client];
                    [dataQueue enumerateObjectsUsingBlock:^(id  _Nonnull vm_address, NSUInteger j, BOOL * _Nonnull _stop) {
                        vm_deallocate(mach_task_self(), [vm_address unsignedLongValue], vm_page_size);
                    }];
                    printf("[SERVER]: %d Virtual memory pages removed.\n", [client unsignedIntValue]);
                    [_registry removeQueue:client];
                }
            }];
        }
    }
}

@end






