///udp_get_player_ip(udpHandle, playerId)
var index = ds_list_find_index(argument0[| CNsUdpPlayerIdList], argument1);
if(index!=-1){
    return ds_list_find_value(argument0[| CNsUdpIpList], index)
}
return ""
