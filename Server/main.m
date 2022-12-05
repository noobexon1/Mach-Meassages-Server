#include "ServerHandler.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("[SERVER]: Initializing...\n");
        ServerHandler* server = [[ServerHandler alloc] init];
        printf("[SERVER]: Activating garbage collector service...\n");
        [server performSelectorInBackground:@selector(cleanup) withObject:nil];
        
        while (1) {
            [server listen];
        }
    }
    return 0;
}
