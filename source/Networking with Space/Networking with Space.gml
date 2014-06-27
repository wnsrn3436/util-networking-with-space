#define hidden_ns_init
///hidden_ns_init()
globalvar 
    _NsRecvBuffer, 
    _NsSendBuffer, 
    _NsSysBuffer, 
    _NsServerPortMap, 
    _NsServerSocketMap, 
    _NsClientSocketMap, 
    _NsWaitKeyPlayerMap, 
    _NsHandleList, 
    _NsMsgRecvHandle, 
    _NsMsgType, 
    _NsMsgSentSpace, 
    _NsMsgSentPlayer, 
    _NsMsgId
;
_NsRecvBuffer = noone
_NsSendBuffer = buffer_create(256, buffer_grow, 1)
_NsSysBuffer = buffer_create(256, buffer_grow, 1)
_NsServerPortMap = ds_map_create()
_NsServerSocketMap = ds_map_create()
_NsClientSocketMap = ds_map_create()
_NsWaitKeyPlayerMap = ds_map_create()
_NsHandleList = ds_list_create()
_NsMsgRecvHandle = noone
_NsMsgType = noone
_NsMsgSentSpace = noone
_NsMsgSentPlayer = noone
_NsMsgId = noone

#define hidden_ns_final
///hidden_ns_final()
ns_handle_clear()
buffer_delete(_NsSendBuffer)
buffer_delete(_NsSysBuffer)
ds_map_destroy(_NsServerPortMap)
ds_map_destroy(_NsServerSocketMap)
ds_map_destroy(_NsClientSocketMap)
ds_map_destroy(_NsWaitKeyPlayerMap)
ds_list_destroy(_NsHandleList)

#define hidden_NsMsgSentIP
///hidden_NsMsgSentIP()
if(_NsMsgRecvHandle[| CNsCommonPlayerId]!=_NsMsgSentPlayer){
    return async_load[? "ip"]
}
return "127.0.0.1"

#define hidden_NsMsgSentPort
///hidden_NsMsgSentPort()
if(_NsMsgRecvHandle[| CNsCommonPlayerId]!=_NsMsgSentPlayer){
    return async_load[? "port"]
}
return _NsMsgRecvHandle[| CNsCommonPort]

