///ns_handle_destroy(tcpHandle)
var index = ds_list_find_index(_NsHandleList, argument0);
if(index!=-1)
{
    if(argument0[| CNsCommonIsServer])
    {
        var list = argument0, list_size, i;
        if(!argument0[| CNsCommonHashLen])
        {
            repeat(argument0[| CNsServerSpaceNumber])
            {
                list_size = ds_list_size(++list)
                for(i=0; i<list_size; i++){
                    network_destroy(list[| i])
                }
                ds_list_destroy(list)
            }
        }
        else
        {
            var list2 = argument0+argument0[| CNsServerSpaceNumber];
            repeat(argument0[| CNsServerSpaceNumber])
            {
                list_size = ds_list_size(++list)
                for(i=0; i<list_size; i++){
                    network_destroy(list[| i])
                }
                ds_list_destroy(list)
                ds_list_destroy(++list2)
            }
        }
        ds_map_destroy(argument0[| CNsServerClientMap])
        ds_list_destroy(argument0[| CNsServerActivatedSpace])
        ds_map_delete(_NsServerPortMap, argument0[| CNsCommonPort])
        ds_map_delete(_NsServerSocketMap, argument0[| CNsCommonSocket])
    }
    else
    {
        if(argument0[| CNsClientKeyBuffer]!=noone){
            buffer_delete(argument0[| CNsClientKeyBuffer])
        }
        if(argument0[| CNsClientWaitMsgPlayer]!=noone){
            ds_list_destroy(argument0[| CNsClientWaitMsgPlayer])
        }
        ds_map_delete(_NsClientSocketMap, argument0[| CNsCommonSocket])
    }
    network_destroy(argument0[| CNsCommonSocket])
    ds_list_destroy(argument0)
    ds_list_delete(_NsHandleList, index)
    return true
}
return false
