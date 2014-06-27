///ns_get_initial_max_clients(tcpHandle)
if(argument0[| CNsCommonIsServer]){
    return argument0[| CNsServerInitialMaxClients]
}
return false
