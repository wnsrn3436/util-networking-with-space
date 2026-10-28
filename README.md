# Networking with Space

[한국어](README.ko.md)

A networking extension (`.gmez`) for building multiplayer and online games in GameMaker: Studio. It wraps server creation, connecting, player ids, and message sending and receiving in scripts built on GameMaker: Studio's `network_*` functions. Connected players are divided into spaces so a message travels only within the spaces it is sent to. It can also attach SHA-1 hashes to the packets clients send and reject tampered ones. It also comes with Networking with Space UDP, which lets clients send to each other directly over UDP, and Instance Message, which gives each instance a network id and routes messages by that id. It was distributed on the YoYo Games Marketplace.

<p>
  <img src="docs/screenshots/screenshot-1.png" width="480" alt="Six example clients connected across space 1 and space 2">
</p>


## How to use

The Releases download contains the extension (`.gmez`), example projects, and a function reference. Importing the extension into the Extensions of a GameMaker: Studio project brings in the scripts along with example objects and rooms that show a server, a client, and moving between spaces. The IME and UDP example projects (`.gmz`) also need the extension imported to run.

The server gets a TCP handle with `ns_create_server` and a client with `ns_create_client_async`. These calls also set the number of spaces, the space to join, the instance that receives messages, a version string, and the hash length and key.

```gml
var port, maxclients, spacenumber, joinspace, recvinstance, version, hashlen, key;
port = 12567 //1~65535
maxclients = 6 //1~1000. This is fixed maximum. You can't exceed this init value by ns_set_max_clients()
spacenumber = 4 //1~32767
joinspace = 0 //0~(spacenumber-1)
recvinstance = id //Message receive instance
version = "The Particles"
hashlen = 10 //Hash size(1~40), zero means do not use security
key = "MyKey" //Hash key(it can't exceed hashlen size)

buffer_seek(NsSendBuffer, buffer_seek_start, 0) //Server can read this buffer in the TypeServerCreated by NsRecvBuffer
tcp_handle = ns_create_server(port, maxclients, spacenumber, joinspace, recvinstance, version, hashlen, key)
```

To send values, write them into `NsSendBuffer`, then send them with a receiving space, a receiver, and a message id. In the code below, the example client sends its coordinates to the other players in its space every step.

```gml
buffer_seek(NsSendBuffer, buffer_seek_start, 0)
buffer_write(NsSendBuffer, buffer_u16, x)
buffer_write(NsSendBuffer, buffer_u16, y)
ns_message_send(obj_network.tcp_handle, ToMySpace, SendToAll, NS.CLIENT_POSITION)
```

The receiving space is `ToMySpace`, `ToEverySpace`, `ToOtherSpace`, or a space number, and the receiver is `SendToServer`, `SendToAllServerMe`, `SendToAllServer`, `SendToAllMe`, `SendToAll`, `SendToOther`, or a player id.

When the receiving instance calls `ns_message_receive_in_async()` in its Asynchronous Networking event, messages arrive as User Defined 0, things that happen on the server (server created, client joined or left, space changed, hash mismatch) as User Defined 1, and things that happen on the client (connection succeeded or failed) as User Defined 2. Inside the event, `NsMsgId`, `NsMsgSentPlayer`, `NsMsgSentSpace`, and `NsMsgType` tell what happened, and the values are read from `NsRecvBuffer`.

```gml
///Message Event
switch(NsMsgId)
{
    ...
    case NS.CLIENT_POSITION:
        with(obj_client)
        {
            if(control==NsMsgSentPlayer)
            {
                x = buffer_read(NsRecvBuffer, buffer_u16)
                y = buffer_read(NsRecvBuffer, buffer_u16)
                break
            }
        }
        break
    ...
}
```

When a player moves to another space with `ns_set_space`, `TypeClientSpaceChanged` fires in User Defined 1 on the server. The arguments of every function and the event values are described in [docs/reference.md](docs/reference.md).

There are five examples. In the one inside the extension, you open a server or connect to one and move your own dot with the arrow keys. Touching the arrow in the lower right cycles through spaces 1, 2, and 3, and only the players in the same space appear on screen. The other four are separate downloads in Releases. IME Basic Example and IME with Enemy Example have the server hand out network ids and synchronize players and server-spawned enemies by those ids. UDP Example sends coordinates directly to the other clients over UDP instead of TCP. In Find Server in the Wi-Fi, clients collect and show the IPs and ports that servers announce by broadcast.


## How it works

**The ds_list numbers next to the handle are used as space lists.** A server handle is a single `ds_list`, but when it is created, more lists with consecutive numbers are reserved, one per space. If the numbering breaks, the count starts over, and lists left out of the consecutive run are destroyed at the end. So the player list of space `s` is always `handle + s + 1`, and the number right before it, `handle - 1`, is the list of spaces that hold at least one client. With hashing on, one more list per space follows, holding the hash counter of each player. When relaying a message, the server finds the list from the space number with a single addition.

```gml
var stack=ds_stack_create(), ds_count=0, ds_max=2+argument2+(argument2*(argument6>0)), temp_list, temp_list2;
temp_list = ds_list_create()
while(++ds_count!=ds_max)
{
    temp_list2 = ds_list_create()
    if(temp_list+1!=temp_list2){
        ds_count = 0
    }
    ds_stack_push(stack, temp_list)
    temp_list = temp_list2
}
```

**The server relays, and the receiver filters by space once more.** A message from a client starts with the receiver, receiving space, sender's space, sender, and message id. The server walks the player lists of the receiving spaces and copies the packet to everyone except the sender. When the receiver is a player id, the packet goes out only if that player is in the receiving space. The receiving client compares its own space with the receiving space again and fires the event only on a match, so messages for the previous space that arrive while a player is changing spaces are filtered out here. When the receivers include the sender itself, that copy is not sent over the network and goes straight to the sender's own event.

**The hash is computed with a key and a counter, then written over the key.** With hashing on, the server sends a random number in base64 on connect, and the client and server both use it as a counter that goes up by one per packet. The client appends the key string and the counter to the packet, computes SHA-1, cuts it to the chosen length, writes it over the key's position, and sends the packet. The network carries the hash instead of the key, and if the same packet is sent again, the counter has changed and the hash no longer matches. The server checks with the same calculation, and on a mismatch fires the `TypeServerWasAttacked` event and disconnects that client.

```gml
buffer_seek(buffer, buffer_seek_relative, buffer_tell(_NsSendBuffer))
var buffer_pos = buffer_tell(buffer), hash;
buffer_write(buffer, buffer_string, argument0[| CNsCommonKey])
buffer_write(buffer, buffer_u16, argument0[| CNsClientKey]++)
hash = string_copy(buffer_sha1(buffer, 0, buffer_tell(buffer)), 1, argument0[| CNsCommonHashLen])
buffer_seek(buffer, buffer_seek_start, buffer_pos)
buffer_write(buffer, buffer_string, hash)
```

**A new player starts receiving from each existing player once that player knows about it.** The server gives the new client the list of existing players and sends every existing client a packet saying a new player joined. When an existing client answers, the server passes the answer to the new client, which removes that player from its waiting list. Messages from players still on the waiting list are dropped. This filters out messages an existing player sent before it knew about the new one.

**UDP and Instance Message borrow the TCP handle.** A UDP handle uses the player id, space, and receiving instance of its TCP handle, and runs `network_send_udp` over a list of registered players' IPs and ports. On receive, only packets from a registered player's IP and port are passed on as User Defined 0. Instance Message is a `ds_map` pairing network ids with instances, and fires User Defined 3 on the instance whose network id is in the message.


## Files

| Path | Content |
|---|---|
| `source/Networking with Space.extension.gmx` | Extension definition (functions, constants, included resources) |
| `source/Networking with Space/*.gml` | Init scripts that create and free the global variables |
| `source/Networking with Space/Assets/Scripts/` | `ns_`, `udp_`, and `ime_` scripts |
| `source/Networking with Space/Assets/Objects/`, `Rooms/`, `Sprites/` | Example included in the extension |
| `docs/reference.md` | Function reference |
| `docs/screenshots/` | Screenshots |
| Releases | Extension, example projects, and function reference |


## License

zlib. See [LICENSE](LICENSE).
