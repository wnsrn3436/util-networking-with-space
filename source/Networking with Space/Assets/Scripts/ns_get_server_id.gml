///ns_get_server_id(tcpHandle)
if(!argument0[| CNsCommonIsServer]){
    return argument0[| CNsClientServerId]
}
return argument0[| CNsCommonPlayerId]
