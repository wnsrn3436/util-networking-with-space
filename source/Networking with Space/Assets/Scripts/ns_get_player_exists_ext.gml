///ns_get_player_exists_ext(tcpHandle, space, playerId)
if(argument0[| CNsCommonIsServer])
{
    if(argument0[| CNsCommonPlayerId]==argument2){
        return argument0[| CNsCommonSpace]==argument1
    }
    return ds_list_find_index(argument0+argument1+1, argument2)!=-1
}
return false
