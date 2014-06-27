///ns_set_stop_network(tcpHandle, clientId)
if(argument0[| CNsCommonIsServer] and argument0[| CNsCommonPlayerId]!=argument1)
{
    var sent_space, list, index;
    sent_space = ds_map_find_value(argument0[| CNsServerClientMap], argument1)
    if(!is_undefined(sent_space))
    {
        list = argument0+sent_space+1
        index = ds_list_find_index(list, argument1)
        if(argument0[| CNsCommonHashLen])
        {
            ds_list_delete(list+argument0[| CNsServerSpaceNumber], index)
            ds_map_delete(_NsWaitKeyPlayerMap, argument1)
        }
        ds_list_delete(list, index)
        if(ds_list_empty(list)){
            ds_list_delete(argument0[| CNsServerActivatedSpace], ds_list_find_index(argument0[| CNsServerActivatedSpace], list))
        }
        ds_map_delete(argument0[| CNsServerClientMap], argument1)
        network_destroy(argument1)
        ns_message_trigger(argument0, NsEventServer, TypeClientDisconnected, sent_space, argument1, sent_space, noone)
        return true
    }
}
return false
