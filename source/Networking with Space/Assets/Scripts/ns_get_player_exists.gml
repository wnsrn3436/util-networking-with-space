///ns_get_player_exists(tcpHandle, playerId)
if(argument0[| CNsCommonIsServer])
{
    if(argument0[| CNsCommonPlayerId]==argument1){return true}
    return ds_map_exists(argument0[| CNsServerClientMap], argument1)
}
return false
