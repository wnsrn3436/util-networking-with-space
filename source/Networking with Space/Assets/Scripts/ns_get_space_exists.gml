///ns_get_space_exists(tcpHandle, space)
if(argument0[| CNsCommonIsServer]){
    return (argument1>=0 and argument0[| CNsServerSpaceNumber]>argument1)
}
return false
