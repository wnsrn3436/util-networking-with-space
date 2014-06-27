///ns_get_max_clients(tcpHandle)
if(argument0[| CNsCommonIsServer]){
    return argument0[| CNsServerMaxClients]
}
return false
