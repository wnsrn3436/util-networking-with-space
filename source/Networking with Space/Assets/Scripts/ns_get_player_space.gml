///ns_get_player_space(tcpHandle, playerId)
if(argument0[| CNsCommonIsServer])
{
    if(argument0[| CNsCommonPlayerId]==argument1){return argument0[| CNsCommonSpace]}
    var player_space = ds_map_find_value(argument0[| CNsServerClientMap], argument1);
    if(!is_undefined(player_space)){
        return player_space
    }
}
return noone
