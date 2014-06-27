///ns_get_activated_spaces(tcpHandle)
if(argument0[| CNsCommonIsServer]){
    return argument0[| CNsServerActivatedSpace]
}
return noone
