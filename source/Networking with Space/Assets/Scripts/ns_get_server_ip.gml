///ns_get_server_ip(tcpHandle)
if(!argument0[| CNsCommonIsServer]){
    return argument0[| CNsClientIp]
}
return "127.0.0.1"
