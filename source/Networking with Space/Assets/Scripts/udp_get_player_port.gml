///udp_get_player_port(udpHandle, playerId)
var index = ds_list_find_index(argument0[| CNsUdpPlayerIdList], argument1);
if(index!=-1){
    return ds_list_find_value(argument0[| CNsUdpPortList], index)
}
return noone
