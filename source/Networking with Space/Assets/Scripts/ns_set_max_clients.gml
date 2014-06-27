///ns_set_max_clients(tcpHandle, maxClients)
if(argument0[| CNsCommonIsServer])
{
    argument0[| CNsServerMaxClients] = min(argument1, argument0[| CNsServerInitialMaxClients])
    return true
}
return false
