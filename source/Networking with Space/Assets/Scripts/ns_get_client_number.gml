///ns_get_client_number(tcpHandle)
if(argument0[| CNsCommonIsServer]){
    return ds_map_size(argument0[| CNsServerClientMap])
}
return false
