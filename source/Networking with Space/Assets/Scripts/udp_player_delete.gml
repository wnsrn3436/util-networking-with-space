///udp_player_delete(udpHandle, playerId)
var index = ds_list_find_index(argument0[| CNsUdpPlayerIdList], argument1);
if(index!=-1)
{
    ds_list_delete(argument0[| CNsUdpPlayerIdList], index)
    ds_list_delete(argument0[| CNsUdpIpList], index)
    ds_list_delete(argument0[| CNsUdpPortList], index)
    return true
}
return false
