# Server

* PLEASE NOTE - THIS WILL NOT RUN ON ANYTHING OTHER THEN MacOS! *
* YOU WILL EITHER NEED A REAL MACHIN OR A VM!!! *

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
2) "retrieve" -> Data will be received from the server in a queue manner (first message sent to the server will be received first).
3) "quit" -> Exit the client (This is not really neccasery. The server will persist and respond correctly even if the client crashs or interrupted).

After every action taken by clients, log messages will appear on both client and server screens to describe what is going on at each and every step.

*Approaches in implementation requiring special attention*

1) The server is not listening to clients directly, but rather to its port name on launchd. 
The clients send their messages to that port name and although the server's retrieve method is blocking,
it is blocked by launchd, from which all of the clients messages are coming anyway. This is an attempt to follow the reactor design pattern.

2) To check that the data hasn't been tempered with after storing it on the server, the client creates an encrypted data signature
using SHA256. this signature is only stored on the clients side, and upon retrievel, the "fresh" data signature is compared with the 
one stored on the client.

3) There is no in-line data passed between the clients and the server or any buffers used. 
Instead, the processes exchange virtual memory pages addresses. This allows faster transaction of data and more modularity. 
