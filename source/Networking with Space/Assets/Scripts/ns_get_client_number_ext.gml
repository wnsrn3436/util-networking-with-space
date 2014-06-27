///ns_get_client_number_ext(tcpHandle, space)
if(argument0[| CNsCommonIsServer]){
    return ds_list_size(argument0+argument1+1)
}
return false
