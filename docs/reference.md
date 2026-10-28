# Function reference

This is a networking extension built on the `network_*` functions of GameMaker: Studio. It has three groups: Networking with Space (`ns_`), which connects a server and clients over TCP, Networking with Space UDP (`udp_`), which sends directly between clients over UDP, and Instance Message (`ime_`), which gives instances network ids and hands messages out to them.

## General

- A handle is a `ds_list`. The one returned by `ns_create_server` and `ns_create_client_async` is called a TCP handle, the one returned by `udp_handle_create` a UDP handle, and the one returned by `ime_handle_create` an IME handle.
- A player id is that player's socket number on the server. The server's own id is the server socket number.
- Space numbers run from 0 to `spaceNumber - 1`. Each message is sent to a chosen space, and only players in that space receive it.
- Values to send are written into `NsSendBuffer`, and received values are read from `NsRecvBuffer`. Before sending, the write position must be moved back to the start with `buffer_seek(NsSendBuffer, buffer_seek_start, 0)`. The send functions send `NsSendBuffer` from the start up to the current position.
- A message id is an integer from 0 to 65535 chosen by the game.
- The server and clients must use the same `version`, `hashLen`, and `key`. A connection with a different `version` is refused.
- A `hashLen` of 0 turns hashing off. From 1 to 40, every packet a client sends carries a SHA-1 hash truncated to that length. When the server receives a packet that does not match, it fires `TypeServerWasAttacked` and then disconnects that client. A handle cannot be created when `key` is longer than `hashLen` bytes, so `key` must be an empty string when hashing is off.

Receiver constants

| Constant | Meaning |
|---|---|
| `SendToServer` | To the server |
| `SendToAllServerMe` | To the server, me, and every other player |
| `SendToAllServer` | To the server and every other player. When the server sends it, the server receives it too |
| `SendToAllMe` | To every player including me. When a client sends it, the server is left out |
| `SendToAll` | To every player except me. When a client sends it, the server is left out |
| `SendToOther` | To everyone except me. When a client sends it, the server receives it too |
| Player id | To that player |

Receiving space constants

| Constant | Meaning |
|---|---|
| `ToMySpace` | To the sender's space |
| `ToEverySpace` | To every space |
| `ToOtherSpace` | To every space except the sender's |
| Space number | To that space |

The server has a space of its own as well. Even a message a client sends with `SendToServer` fires an event on the server only if the receiving space includes the server's space. Use `ToEverySpace` to reach the server regardless of space.

## Events

The receiving instance (`recvInstance`) is set when the TCP handle is created, and received messages arrive as User Defined events of that instance. `ns_message_receive_in_async()` must be called in the Asynchronous Networking event of the receiving instance.

| Event | Constant | When |
|---|---|---|
| User Defined 0 | `NsEventMsg` | A message arrived |
| User Defined 1 | `NsEventServer` | Something happened on the server. `NsMsgType` tells which |
| User Defined 2 | `NsEventClient` | Something happened on a client. `NsMsgType` tells which |
| User Defined 3 | `ImeEventMsg` | `ime_message_receive` handed a message to that instance |

Values read inside an event

| Name | Content |
|---|---|
| `NsMsgRecvHandle` | The handle that received the message |
| `NsMsgType` | The kind of User Defined 1 or 2 event |
| `NsMsgSentPlayer` | The sender's player id |
| `NsMsgSentSpace` | The sender's space |
| `NsMsgId` | The message id |
| `NsMsgSentIP`, `NsMsgSentPort` | The sender's IP and port. `"127.0.0.1"` and the server port when the server sent it itself |
| `NsRecvBuffer` | The buffer holding the received values |

Kinds of `NsMsgType`

| Constant | Event | When | Values |
|---|---|---|---|
| `TypeServerCreated` | User Defined 1 | A server was opened with `ns_create_server` | `NsMsgSentSpace` and `NsMsgId` are the server's space. `NsRecvBuffer` holds what was written into `NsSendBuffer` when opening the server |
| `TypeServerSpaceChanged` | User Defined 1 | The server moved to another space with `ns_set_space` | `NsMsgSentSpace` is the previous space and `NsMsgId` the new one |
| `TypeServerWasAttacked` | User Defined 1 | A packet with a mismatched hash arrived. The client is disconnected after this event | `NsMsgSentPlayer` is that client |
| `TypeClientConnected` | User Defined 1 | A client joined | `NsMsgSentPlayer` is the new player, and `NsMsgSentSpace` and `NsMsgId` are its space. `NsRecvBuffer` holds what it sent while connecting |
| `TypeClientDisconnected` | User Defined 1 | A client left | `NsMsgSentPlayer` is the player who left, and `NsMsgSentSpace` and `NsMsgId` are its space |
| `TypeClientSpaceChanged` | User Defined 1 | A client moved to another space | `NsMsgSentSpace` is the previous space and `NsMsgId` the new one. `NsRecvBuffer` holds what it sent while moving |
| `TypeConnected` | User Defined 2 | The server accepted the connection and gave a player id | |
| `TypeConnectionFailed` | User Defined 2 | The connection was refused because the server is full or `version` differs | |

## Networking with Space

Handles

- `ns_create_server(port, maxClients, spaceNumber, joinSpace, recvInstance, version, hashLen, key)` : Opens a server and returns a TCP handle. `maxClients` is the maximum number of clients it accepts, `spaceNumber` the number of spaces, and `joinSpace` the space the server itself joins. Returns `false` on failure. `TypeServerCreated` fires as soon as it opens.
- `ns_create_client_async(ip, port, joinSpace, recvInstance, version, hashLen, key)` : Connects to a server and returns a TCP handle. Returns `false` on failure. Whatever is in `NsSendBuffer` goes along with the connection request, so a value such as a name can be handed over from the start. The player id is set when `TypeConnected` fires, and messages cannot be sent before that.
- `ns_handle_destroy(tcpHandle)` : Destroys the handle and closes the connection. For a server handle, every client socket is closed too. Returns `false` for a handle that does not exist.
- `ns_handle_clear()` : Destroys every TCP handle.
- `ns_get_handle_list()` : Returns the ds_list of TCP handles.
- `ns_get_handle_number()` : Returns the number of TCP handles.
- `ns_get_handle_exists(tcpHandle)` : Returns `true` if the handle exists.

Messages

- `ns_message_receive_in_async()` : Processes a received packet and fires the matching User Defined event. Must be called in the Asynchronous Networking event of the receiving instance. Returns `true` for a packet of this extension and `false` otherwise, so it can be used together with other network code. On the server, this function also relays messages.
- `ns_message_send(tcpHandle, ToSpace, SendToPlayer, msgId)` : Sends the contents of `NsSendBuffer` with message id `msgId`. Messages from a client are relayed by the server. When the receivers include the sender, the sender's copy fires as an event right away without going over the network. Returns `false` if a client has not received its player id yet.
- `ns_message_trigger(tcpHandle, NsEvent, Type, sentSpace, sentPlayer, msgId, recvBuffer)` : Fires an event on the receiving instance directly. The event values become the given arguments and are restored afterwards. Call it to reuse event handling, for example treating a client that changed spaces as one that left and one that joined.
- `ns_message_trigger_ext(tcpHandle, NsEvent, Type, sentSpace, sentPlayer, msgId, recvBuffer, bufferReposTF)` : Same as `ns_message_trigger`, and when `bufferReposTF` is `true`, puts the read position of `recvBuffer` back where it was before the event.
- `ns_set_receive_instance(tcpHandle, instanceId)` : Changes the receiving instance.
- `ns_get_receive_instance(tcpHandle)` : Returns the receiving instance.

Players

- `ns_get_player_id(tcpHandle)` : Returns my player id. It is `noone` for a client still connecting.
- `ns_get_space(tcpHandle)` : Returns my space.
- `ns_set_space(tcpHandle, joinSpace)` : Moves me to another space. When a client moves, the contents of `NsSendBuffer` go along and `TypeClientSpaceChanged` fires on the server. When the server moves, `TypeServerSpaceChanged` fires on the server. Returns `false` if a client has not received its player id yet.
- `ns_get_is_server(tcpHandle)` : Returns `true` for a server handle.
- `ns_get_socket(tcpHandle)` : Returns the handle's socket.
- `ns_get_version(tcpHandle)`, `ns_get_hash_length(tcpHandle)`, `ns_get_key(tcpHandle)` : Return the `version`, `hashLen`, and `key` given when the handle was created.

Server-only functions

- `ns_get_initial_max_clients(tcpHandle)` : Returns the `maxClients` set when the server was opened.
- `ns_get_max_clients(tcpHandle)` : Returns the current limit on accepted clients.
- `ns_set_max_clients(tcpHandle, maxClients)` : Changes the limit on accepted clients. It cannot go above the value set when the server was opened.
- `ns_set_stop_network(tcpHandle, clientId)` : Disconnects that client and fires `TypeClientDisconnected`. Returns `false` for a player that does not exist.
- `ns_get_client_number(tcpHandle)` : Returns the number of connected clients. The server itself is not counted.
- `ns_get_client_number_ext(tcpHandle, space)` : Returns the number of clients in that space.
- `ns_get_space_number(tcpHandle)` : Returns the number of spaces.
- `ns_get_space_exists(tcpHandle, space)` : Returns `true` if that space number exists.
- `ns_get_player_exists(tcpHandle, playerId)` : Returns `true` if that player exists.
- `ns_get_player_exists_ext(tcpHandle, space, playerId)` : Returns `true` if that player is in that space.
- `ns_get_player_space(tcpHandle, playerId)` : Returns that player's space, or `noone` for a player that does not exist.
- `ns_get_space_to_list(tcpHandle, space)` : Returns the ds_list of player ids in that space. It must be treated as read-only.
- `ns_get_list_to_space(tcpHandle, spaceDSList)` : The reverse of `ns_get_space_to_list`, returns the space number of a ds_list.
- `ns_get_activated_spaces(tcpHandle)` : Returns a ds_list holding the ds_lists of spaces with at least one client. It must be treated as read-only.

Client-only functions

- `ns_get_is_connecting(tcpHandle)` : Returns `true` if the player id has not been received yet.
- `ns_get_is_disconnected(tcpHandle)` : Tries sending a 1-byte packet to the server and returns `true` if it cannot be sent. Call it periodically to find out whether the server has closed.
- `ns_get_server_id(tcpHandle)` : Returns the server's player id. For a server handle it is its own id.
- `ns_get_server_ip(tcpHandle)` : Returns the IP given when connecting. For a server handle it is `"127.0.0.1"`.
- `ns_get_server_port(tcpHandle)` : Returns the port.

## Networking with Space UDP

The game creates the UDP socket itself with `network_create_socket_ext(network_socket_udp, port)`, and the IPs and ports of the other players must be exchanged over TCP messages and registered. Packets go only to registered players, and only packets from a registered player's IP and port are accepted.

- `udp_handle_create(tcpHandle, udpSocket, socketIP, socketPort)` : Creates a UDP handle. The player id, space, and receiving instance are borrowed from the TCP handle given as `tcpHandle`. `socketIP` and `socketPort` are my UDP address, stored in the handle so they can be passed on to other players.
- `udp_handle_destroy(udpHandle, udpSocketDestroyTF)` : Destroys the UDP handle. When `udpSocketDestroyTF` is `true`, the UDP socket is closed too.
- `udp_handle_clear(udpSocketDestroyTF)` : Destroys every UDP handle.
- `udp_get_handle_list()`, `udp_get_handle_number()`, `udp_get_handle_exists(udpHandle)` : Return the list of UDP handles, their number, and whether one exists.
- `udp_get_tcp_handle(udpHandle)`, `udp_get_socket(udpHandle)`, `udp_get_ip(udpHandle)`, `udp_get_port(udpHandle)` : Return the values given at creation.
- `udp_player_add(udpHandle, playerId, playerIP, playerPort)` : Registers a player to exchange messages with.
- `udp_player_delete(udpHandle, playerId)` : Removes a registered player. Returns `false` for a player that does not exist.
- `udp_player_clear(udpHandle)` : Removes every registered player. Call it when changing spaces.
- `udp_get_player_number(udpHandle)`, `udp_get_player_exists(udpHandle, playerId)` : Return the number of registered players and whether one is registered.
- `udp_get_player_ip(udpHandle, playerId)`, `udp_get_player_port(udpHandle, playerId)` : Return a registered player's IP and port, or `""` and `noone` for a player that does not exist.
- `udp_message_send(udpHandle, msgId)` : Sends the contents of `NsSendBuffer` to every registered player.
- `udp_message_receive_in_async()` : Processes a received UDP packet and fires User Defined 0 on the receiving instance of the TCP handle. `NsMsgRecvHandle` is then the UDP handle. Call it in the Asynchronous Networking event when `ns_message_receive_in_async()` returned `false`.

## Instance Message

Each instance gets a network id, and the network id inside a message decides which instance the event goes to. The server creates network ids and hands them out, and a client pairs the network ids it receives with its own instances.

- `ime_handle_create(useNetIdListTF, useNetIdListDataTF, useImeInstanceTF)` : Creates an IME handle. `useNetIdListTF` decides whether to keep a list of created network ids, `useNetIdListDataTF` whether to attach a ds_list to each network id, and `useImeInstanceTF` whether to keep pairs of network ids and instances. A server usually turns on the first two, and a client the last one.
- `ime_handle_destroy(imeHandle)`, `ime_handle_clear()` : Destroy one IME handle, or all of them.
- `ime_get_handle_list()`, `ime_get_handle_number()`, `ime_get_handle_exists(imeHandle)` : Return the list of IME handles, their number, and whether one exists.
- `ime_net_id_create(imeHandle)` : Creates and returns a new network id. Ids count up by one from 0.
- `ime_net_id_delete(imeHandle, netId)` : Removes a network id from the list.
- `ime_net_id_clear(imeHandle)` : Removes every network id and starts numbering from 0 again.
- `ime_get_net_id_list(imeHandle)`, `ime_get_net_id_number(imeHandle)`, `ime_get_net_id_exists(imeHandle, netId)` : Return the list of network ids, their number, and whether one exists.
- `ime_get_net_id_data_list(imeHandle, netId)` : Returns the ds_list attached to that network id, or `noone` if there is none.
- `ime_instance_add(imeHandle, netId, instanceId)` : Pairs a network id with an instance.
- `ime_instance_delete(imeHandle, netId)`, `ime_instance_clear(imeHandle)` : Remove one pair, or all of them.
- `ime_get_instance_id(imeHandle, netId)` : Returns the instance of that network id, or `noone` if there is none.
- `ime_get_instance_map(imeHandle)`, `ime_get_instance_number(imeHandle)`, `ime_get_instance_exists(imeHandle, netId)` : Return the ds_map of pairs, their number, and whether one exists.
- `ime_message_receive(imeHandle, netId)` : Fires User Defined 3 on the instance of that network id. Inside the event, the rest of `NsRecvBuffer` can be read, and `NsMsgRecvHandle` is the IME handle. Call it from User Defined 0 after reading the network id written at the start of the message.
