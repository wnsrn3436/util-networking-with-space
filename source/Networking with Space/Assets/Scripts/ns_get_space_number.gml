///ns_get_space_number(tcpHandle)
if(argument0[| CNsCommonIsServer]){
    return argument0[| CNsServerSpaceNumber]
}
return false
