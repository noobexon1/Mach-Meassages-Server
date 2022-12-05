# Server

*How to run*

1) Clone server.
2) Clone client (https://github.com/noobexon1/Client).
3) Build both.
4) Run server first.
5) run as many clients as you want.

*How to use*

The Server is simply responding to clients.

The clients have basic ui with 3 commands:

1) "send" -> You will be promted to provide input data -> Data will then be sent to be stored on the server.
2) "retrieve" -> Data will be received from the server by queue behavier (first message sent to the server will be received first).
3) "quit" -> Exit the client (This is not really neccasery. The server will persist and respond correctly no matter what happens to the client).

After every action taken by clients, log messages will appear on both client an server screens to describe what is going on at each and every step.

*Approaches in implementation requiring special attention*

1) The server is not listening to clients directly, but rather to its port name on launchd. 
The clients send their messages to that port name and although the server's retrieve method is blocking,
it is blocked by launchd, from which all of the clients messages are coming anyway. This is equivelent to the reactor design pattern.

2) To check that the data hasn't been tempered with after storing it on the server, the client creates an encrypted data signature
using SHA256. this signature is only stored on the clients side, and upon retrievel, the "fresh" data signature is compared with the 
one stored on the client.

3) There is no in-line data passed between the clients and the server or any buffers used. 
Instead, the processes exchange virtual memory pages addresses. This allows faster transaction of data and more modularity. 

*Answers to bonus questions*

-(Q)-
When a process dies, what happens to the data stored in server? can we somehow remove it without messaging the server explicitly?

-(A)- 
Absolutly. In my implementation i choose to use a dedicated thread that would check on the registered clients ports every 1 second.
The thread is checking for dead ports by queuering the type of right that the client's port has.
When it finds one - it is deallocating the vm addresses residing in the client's queue inside the server and deleteing the queue. 

-(Q)-
What happens when two 'save' messages are sent, how does the server handle it?	 

-(A)- 
The server is not listening to a specific client, but rather to its registered port name at the bootstrap server.
Therefore, incoming messages are stored at the server's port queue by the order in which they arrived from the bootstrap server.
So, if two 'save' requests are sent, the server will handle the first message to arrive in its port queue from the bootstrap server and then
handle the second message when its done. 
Efficency could probably be enhanced by having a thread pool of "workers" to which the server could tell what to do  
with each incoming request, allowing it to focus only on fetching messages and as a result shorten the clients waiting time.
This is only critical if the amount of waiting clients is large enough.

-(Q)- If many processes send the same data, can we optimize it?

-(A)-
Yes. This could be done by virtual memory page allocation. 
In my implementation, when a client sends the server "data", it actually just sends the data's virtual memory page address.
It is only when the data is actually referenced by the server that is it copied to the server's memory. 
This behavier is much like sending an e-mail with an attachment. It is only when the mail receiver open/download the attachment that 
the attachments actual data is copied to the receivers memory.
In my implementation, this optimization allowes clients to send big chunks of similar data, but the server could still probably handle it,
because it stores just the data's addresses, which are just unsigned longs... 

