# 함수 설명

게임메이커: 스튜디오의 `network_*` 함수 위에서 동작하는 네트워크 확장이며 세 묶음이 들어 있다. TCP 로 서버와 클라이언트를 잇는 Networking with Space(`ns_`)와 클라이언트끼리 UDP 로 직접 주고받는 Networking with Space UDP(`udp_`)가 있고 Instance Message(`ime_`)는 인스턴스에 네트워크 id 를 붙여 메시지를 나눠 준다.

## 공통 사항

- 핸들은 `ds_list` 다. `ns_create_server` 와 `ns_create_client_async` 가 돌려주는 것을 TCP 핸들, `udp_handle_create` 가 돌려주는 것을 UDP 핸들, `ime_handle_create` 가 돌려주는 것을 IME 핸들이라고 부른다.
- 플레이어 id 는 서버에서 그 플레이어의 소켓 번호다. 서버 자신의 id 는 서버 소켓 번호다.
- 공간 번호는 0 부터 `spaceNumber - 1` 까지다. 메시지는 받을 공간을 정해서 보내고 그 공간에 있는 플레이어만 받는다.
- 보낼 값은 `NsSendBuffer` 에 쓰고 받은 값은 `NsRecvBuffer` 에서 읽는다. 보내기 전에 `buffer_seek(NsSendBuffer, buffer_seek_start, 0)` 으로 쓰는 위치를 처음으로 돌려야 한다. 보내는 함수는 `NsSendBuffer` 의 처음부터 지금 위치까지를 보낸다.
- 메시지 id 는 게임에서 정하는 0 부터 65535 사이의 정수다.
- 서버와 클라이언트는 `version`, `hashLen`, `key` 가 같아야 한다. `version` 이 다르면 접속이 거절된다.
- `hashLen` 이 0 이면 해시를 쓰지 않는다. 1 부터 40 이면 클라이언트가 보내는 패킷마다 그 길이로 자른 SHA-1 해시를 붙인다. 서버가 맞지 않는 패킷을 받으면 `TypeServerWasAttacked` 이벤트를 띄운 뒤 그 클라이언트를 끊는다. `key` 가 `hashLen` 바이트보다 길면 핸들을 만들지 못하므로, 해시를 쓰지 않을 때는 `key` 를 빈 문자열로 둬야 한다.

받을 사람 상수

| 상수 | 뜻 |
|---|---|
| `SendToServer` | 서버에게 |
| `SendToAllServerMe` | 서버와 나와 다른 플레이어 모두에게 |
| `SendToAllServer` | 서버와 다른 플레이어 모두에게. 서버가 보내면 서버 자신도 받는다 |
| `SendToAllMe` | 나를 포함한 플레이어 모두에게. 클라이언트가 보내면 서버는 빠진다 |
| `SendToAll` | 나를 뺀 플레이어 모두에게. 클라이언트가 보내면 서버는 빠진다 |
| `SendToOther` | 나를 뺀 모두에게. 클라이언트가 보내면 서버도 받는다 |
| 플레이어 id | 그 플레이어에게 |

받을 공간 상수

| 상수 | 뜻 |
|---|---|
| `ToMySpace` | 보내는 쪽이 있는 공간에 |
| `ToEverySpace` | 모든 공간에 |
| `ToOtherSpace` | 보내는 쪽이 있는 공간을 뺀 모든 공간에 |
| 공간 번호 | 그 공간에 |

서버에게도 자기 공간이 있다. 클라이언트가 `SendToServer` 로 보낸 메시지도 받을 공간에 서버의 공간이 들어 있어야 서버에 이벤트가 뜬다. 공간과 관계없이 서버에 보내려면 `ToEverySpace` 를 쓴다.

## 이벤트

받는 인스턴스(`recvInstance`)는 TCP 핸들을 만들 때 정하고, 받은 메시지는 그 인스턴스의 User Defined 이벤트로 온다. 받는 인스턴스의 Asynchronous Networking 이벤트에서 `ns_message_receive_in_async()` 를 호출해야 한다.

| 이벤트 | 상수 | 언제 |
|---|---|---|
| User Defined 0 | `NsEventMsg` | 메시지가 왔을 때 |
| User Defined 1 | `NsEventServer` | 서버에서 생긴 일. `NsMsgType` 으로 종류를 나눈다 |
| User Defined 2 | `NsEventClient` | 클라이언트에서 생긴 일. `NsMsgType` 으로 종류를 나눈다 |
| User Defined 3 | `ImeEventMsg` | `ime_message_receive` 가 그 인스턴스에 메시지를 넘겼을 때 |

이벤트 안에서 읽는 값

| 이름 | 내용 |
|---|---|
| `NsMsgRecvHandle` | 메시지를 받은 핸들 |
| `NsMsgType` | User Defined 1, 2 의 종류 |
| `NsMsgSentPlayer` | 보낸 플레이어 id |
| `NsMsgSentSpace` | 보낸 플레이어의 공간 |
| `NsMsgId` | 메시지 id |
| `NsMsgSentIP`, `NsMsgSentPort` | 보낸 쪽의 IP 와 포트. 서버 자신이 보낸 것이면 `"127.0.0.1"` 과 서버 포트 |
| `NsRecvBuffer` | 받은 값이 든 버퍼 |

`NsMsgType` 의 종류

| 상수 | 이벤트 | 언제 | 값 |
|---|---|---|---|
| `TypeServerCreated` | User Defined 1 | `ns_create_server` 로 서버를 열었을 때 | `NsMsgSentSpace` 와 `NsMsgId` 는 서버의 공간. `NsRecvBuffer` 에 서버를 열 때 `NsSendBuffer` 에 쓴 값이 있다 |
| `TypeServerSpaceChanged` | User Defined 1 | 서버가 `ns_set_space` 로 공간을 옮겼을 때 | `NsMsgSentSpace` 는 이전 공간, `NsMsgId` 는 새 공간 |
| `TypeServerWasAttacked` | User Defined 1 | 해시가 맞지 않는 패킷을 받았을 때. 이 이벤트 뒤에 그 클라이언트를 끊는다 | `NsMsgSentPlayer` 는 그 클라이언트 |
| `TypeClientConnected` | User Defined 1 | 클라이언트가 들어왔을 때 | `NsMsgSentPlayer` 는 새 플레이어, `NsMsgSentSpace` 와 `NsMsgId` 는 그 플레이어의 공간. `NsRecvBuffer` 에 접속하며 보낸 값이 있다 |
| `TypeClientDisconnected` | User Defined 1 | 클라이언트가 나갔을 때 | `NsMsgSentPlayer` 는 나간 플레이어, `NsMsgSentSpace` 와 `NsMsgId` 는 그 플레이어의 공간 |
| `TypeClientSpaceChanged` | User Defined 1 | 클라이언트가 공간을 옮겼을 때 | `NsMsgSentSpace` 는 이전 공간, `NsMsgId` 는 새 공간. `NsRecvBuffer` 에 옮기며 보낸 값이 있다 |
| `TypeConnected` | User Defined 2 | 서버가 접속을 받아 플레이어 id 를 줬을 때 | |
| `TypeConnectionFailed` | User Defined 2 | 서버가 가득 찼거나 `version` 이 달라 접속이 거절됐을 때 | |

## Networking with Space

핸들

- `ns_create_server(port, maxClients, spaceNumber, joinSpace, recvInstance, version, hashLen, key)` : 서버를 열고 TCP 핸들을 돌려준다. `maxClients` 는 받을 클라이언트 수의 상한, `spaceNumber` 는 공간 개수, `joinSpace` 는 서버 자신이 들어갈 공간이다. 실패하면 `false` 를 돌려준다. 열자마자 `TypeServerCreated` 이벤트가 뜬다.
- `ns_create_client_async(ip, port, joinSpace, recvInstance, version, hashLen, key)` : 서버에 접속하고 TCP 핸들을 돌려준다. 실패하면 `false` 를 돌려준다. `NsSendBuffer` 에 써 둔 값을 접속 요청과 함께 보내므로 이름 같은 값을 처음부터 넘길 수 있다. 플레이어 id 는 `TypeConnected` 이벤트가 뜰 때 정해지고 그 전에는 메시지를 보낼 수 없다.
- `ns_handle_destroy(tcpHandle)` : 핸들을 없애고 연결을 끊는다. 서버 핸들이면 모든 클라이언트의 소켓도 닫는다. 없는 핸들이면 `false` 를 돌려준다.
- `ns_handle_clear()` : 모든 TCP 핸들을 없앤다.
- `ns_get_handle_list()` : TCP 핸들이 담긴 ds_list 를 돌려준다.
- `ns_get_handle_number()` : TCP 핸들 개수를 돌려준다.
- `ns_get_handle_exists(tcpHandle)` : 그 핸들이 있으면 `true` 를 돌려준다.

메시지

- `ns_message_receive_in_async()` : 받은 패킷을 처리하고 해당하는 User Defined 이벤트를 띄운다. 받는 인스턴스의 Asynchronous Networking 이벤트에서 호출해야 한다. 이 확장의 패킷이면 `true`, 아니면 `false` 를 돌려주므로 다른 네트워크 코드와 함께 쓸 수 있다. 서버에서는 중계도 여기서 한다.
- `ns_message_send(tcpHandle, ToSpace, SendToPlayer, msgId)` : `NsSendBuffer` 의 내용을 메시지 id `msgId` 로 보낸다. 클라이언트가 보낸 메시지는 서버가 중계한다. 받는 사람에 나 자신이 들어 있으면 나에게 갈 메시지는 네트워크를 거치지 않고 곧바로 이벤트로 뜬다. 클라이언트가 아직 플레이어 id 를 받지 못했으면 `false` 를 돌려준다.
- `ns_message_trigger(tcpHandle, NsEvent, Type, sentSpace, sentPlayer, msgId, recvBuffer)` : 받는 인스턴스에 이벤트를 직접 띄운다. 이벤트 안의 값은 인자로 준 것이 되고 끝나면 원래 값으로 돌아온다. 공간을 옮긴 클라이언트를 나간 것과 들어온 것으로 처리하는 것처럼 이벤트 처리를 다시 쓸 때 호출한다.
- `ns_message_trigger_ext(tcpHandle, NsEvent, Type, sentSpace, sentPlayer, msgId, recvBuffer, bufferReposTF)` : `ns_message_trigger` 와 같은데 `bufferReposTF` 가 `true` 면 이벤트가 끝난 뒤 `recvBuffer` 의 읽는 위치를 이벤트 전으로 되돌린다.
- `ns_set_receive_instance(tcpHandle, instanceId)` : 받는 인스턴스를 바꾼다.
- `ns_get_receive_instance(tcpHandle)` : 받는 인스턴스를 돌려준다.

플레이어

- `ns_get_player_id(tcpHandle)` : 내 플레이어 id 를 돌려준다. 접속 중인 클라이언트는 `noone` 이다.
- `ns_get_space(tcpHandle)` : 내 공간을 돌려준다.
- `ns_set_space(tcpHandle, joinSpace)` : 내 공간을 옮긴다. 클라이언트가 옮기면 `NsSendBuffer` 의 값을 함께 보내고 서버에 `TypeClientSpaceChanged` 가 뜬다. 서버가 옮기면 서버에 `TypeServerSpaceChanged` 가 뜬다. 클라이언트가 아직 플레이어 id 를 받지 못했으면 `false` 를 돌려준다.
- `ns_get_is_server(tcpHandle)` : 서버 핸들이면 `true` 를 돌려준다.
- `ns_get_socket(tcpHandle)` : 핸들의 소켓을 돌려준다.
- `ns_get_version(tcpHandle)`, `ns_get_hash_length(tcpHandle)`, `ns_get_key(tcpHandle)` : 핸들을 만들 때 준 `version`, `hashLen`, `key` 를 돌려준다.

서버에서만 사용할 수 있는 함수

- `ns_get_initial_max_clients(tcpHandle)` : 서버를 열 때 정한 `maxClients` 를 돌려준다.
- `ns_get_max_clients(tcpHandle)` : 지금 받을 클라이언트 수의 상한을 돌려준다.
- `ns_set_max_clients(tcpHandle, maxClients)` : 받을 클라이언트 수의 상한을 바꾼다. 서버를 열 때 정한 값보다 크게 할 수는 없다.
- `ns_set_stop_network(tcpHandle, clientId)` : 그 클라이언트를 끊고 `TypeClientDisconnected` 이벤트를 띄운다. 없는 플레이어면 `false` 를 돌려준다.
- `ns_get_client_number(tcpHandle)` : 들어온 클라이언트 수를 돌려준다. 서버 자신은 세지 않는다.
- `ns_get_client_number_ext(tcpHandle, space)` : 그 공간에 있는 클라이언트 수를 돌려준다.
- `ns_get_space_number(tcpHandle)` : 공간 개수를 돌려준다.
- `ns_get_space_exists(tcpHandle, space)` : 그 공간 번호가 있으면 `true` 를 돌려준다.
- `ns_get_player_exists(tcpHandle, playerId)` : 그 플레이어가 있으면 `true` 를 돌려준다.
- `ns_get_player_exists_ext(tcpHandle, space, playerId)` : 그 플레이어가 그 공간에 있으면 `true` 를 돌려준다.
- `ns_get_player_space(tcpHandle, playerId)` : 그 플레이어의 공간을 돌려준다. 없는 플레이어면 `noone` 이다.
- `ns_get_space_to_list(tcpHandle, space)` : 그 공간의 플레이어 id 가 담긴 ds_list 를 돌려준다. 읽기만 해야 한다.
- `ns_get_list_to_space(tcpHandle, spaceDSList)` : `ns_get_space_to_list` 의 반대로, ds_list 에서 공간 번호를 돌려준다.
- `ns_get_activated_spaces(tcpHandle)` : 클라이언트가 한 명 이상 있는 공간의 ds_list 들을 담은 ds_list 를 돌려준다. 읽기만 해야 한다.

클라이언트에서만 사용할 수 있는 함수

- `ns_get_is_connecting(tcpHandle)` : 아직 플레이어 id 를 받지 못했으면 `true` 를 돌려준다.
- `ns_get_is_disconnected(tcpHandle)` : 서버에 1바이트 패킷을 보내 보고, 보내지 못하면 `true` 를 돌려준다. 서버가 닫혔는지 알고 싶을 때 주기적으로 호출한다.
- `ns_get_server_id(tcpHandle)` : 서버의 플레이어 id 를 돌려준다. 서버 핸들이면 자기 id 다.
- `ns_get_server_ip(tcpHandle)` : 접속할 때 준 IP 를 돌려준다. 서버 핸들이면 `"127.0.0.1"` 이다.
- `ns_get_server_port(tcpHandle)` : 포트를 돌려준다.

## Networking with Space UDP

UDP 소켓은 게임에서 `network_create_socket_ext(network_socket_udp, port)` 로 직접 만들고 다른 플레이어의 IP 와 포트는 TCP 메시지로 주고받아 등록해야 한다. 등록한 플레이어에게만 보내고 등록한 플레이어의 IP 와 포트에서 온 패킷만 받는다.

- `udp_handle_create(tcpHandle, udpSocket, socketIP, socketPort)` : UDP 핸들을 만든다. 플레이어 id 와 공간, 받는 인스턴스는 `tcpHandle` 로 준 TCP 핸들에서 빌려 온다. `socketIP`, `socketPort` 는 내 UDP 주소로, 다른 플레이어에게 알려 줄 값을 보관해 두는 자리다.
- `udp_handle_destroy(udpHandle, udpSocketDestroyTF)` : UDP 핸들을 없앤다. `udpSocketDestroyTF` 가 `true` 면 UDP 소켓도 닫는다.
- `udp_handle_clear(udpSocketDestroyTF)` : 모든 UDP 핸들을 없앤다.
- `udp_get_handle_list()`, `udp_get_handle_number()`, `udp_get_handle_exists(udpHandle)` : UDP 핸들 목록, 개수, 있는지를 돌려준다.
- `udp_get_tcp_handle(udpHandle)`, `udp_get_socket(udpHandle)`, `udp_get_ip(udpHandle)`, `udp_get_port(udpHandle)` : 만들 때 준 값을 돌려준다.
- `udp_player_add(udpHandle, playerId, playerIP, playerPort)` : 메시지를 주고받을 플레이어를 등록한다.
- `udp_player_delete(udpHandle, playerId)` : 등록한 플레이어를 지운다. 없는 플레이어면 `false` 를 돌려준다.
- `udp_player_clear(udpHandle)` : 등록한 플레이어를 모두 지운다. 공간을 옮길 때 호출한다.
- `udp_get_player_number(udpHandle)`, `udp_get_player_exists(udpHandle, playerId)` : 등록한 플레이어 수와 등록됐는지를 돌려준다.
- `udp_get_player_ip(udpHandle, playerId)`, `udp_get_player_port(udpHandle, playerId)` : 등록한 플레이어의 IP 와 포트를 돌려준다. 없는 플레이어면 `""` 와 `noone` 이다.
- `udp_message_send(udpHandle, msgId)` : `NsSendBuffer` 의 내용을 등록한 플레이어 모두에게 보낸다.
- `udp_message_receive_in_async()` : 받은 UDP 패킷을 처리하고 TCP 핸들의 받는 인스턴스에 User Defined 0 을 띄운다. 이때 `NsMsgRecvHandle` 은 UDP 핸들이다. Asynchronous Networking 이벤트에서 `ns_message_receive_in_async()` 가 `false` 를 돌려줬을 때 호출하면 된다.

## Instance Message

인스턴스마다 네트워크 id 를 붙이고 메시지에 든 네트워크 id 로 그 인스턴스에 이벤트를 넘긴다. 서버는 네트워크 id 를 만들어 나눠 주고 클라이언트는 받은 네트워크 id 와 자기 인스턴스를 짝지어 둔다.

- `ime_handle_create(useNetIdListTF, useNetIdListDataTF, useImeInstanceTF)` : IME 핸들을 만든다. `useNetIdListTF` 는 만든 네트워크 id 목록을 둘지, `useNetIdListDataTF` 는 네트워크 id 마다 ds_list 하나를 붙일지, `useImeInstanceTF` 는 네트워크 id 와 인스턴스의 짝을 둘지 정한다. 보통 서버는 앞의 것을, 클라이언트는 뒤의 것을 켠다.
- `ime_handle_destroy(imeHandle)`, `ime_handle_clear()` : IME 핸들 하나, 또는 모두를 없앤다.
- `ime_get_handle_list()`, `ime_get_handle_number()`, `ime_get_handle_exists(imeHandle)` : IME 핸들 목록, 개수, 있는지를 돌려준다.
- `ime_net_id_create(imeHandle)` : 새 네트워크 id 를 만들어 돌려준다. 0 부터 하나씩 늘어난다.
- `ime_net_id_delete(imeHandle, netId)` : 네트워크 id 를 목록에서 지운다.
- `ime_net_id_clear(imeHandle)` : 네트워크 id 를 모두 지우고 번호를 0 부터 다시 매긴다.
- `ime_get_net_id_list(imeHandle)`, `ime_get_net_id_number(imeHandle)`, `ime_get_net_id_exists(imeHandle, netId)` : 네트워크 id 목록, 개수, 있는지를 돌려준다.
- `ime_get_net_id_data_list(imeHandle, netId)` : 그 네트워크 id 에 붙은 ds_list 를 돌려준다. 없으면 `noone` 이다.
- `ime_instance_add(imeHandle, netId, instanceId)` : 네트워크 id 와 인스턴스를 짝짓는다.
- `ime_instance_delete(imeHandle, netId)`, `ime_instance_clear(imeHandle)` : 짝을 하나, 또는 모두 지운다.
- `ime_get_instance_id(imeHandle, netId)` : 그 네트워크 id 의 인스턴스를 돌려준다. 없으면 `noone` 이다.
- `ime_get_instance_map(imeHandle)`, `ime_get_instance_number(imeHandle)`, `ime_get_instance_exists(imeHandle, netId)` : 짝이 담긴 ds_map, 개수, 있는지를 돌려준다.
- `ime_message_receive(imeHandle, netId)` : 그 네트워크 id 의 인스턴스에 User Defined 3 을 띄운다. 이벤트 안에서 `NsRecvBuffer` 의 나머지를 읽을 수 있고 `NsMsgRecvHandle` 은 IME 핸들이다. User Defined 0 에서 메시지 앞에 쓴 네트워크 id 를 읽고 호출한다.
