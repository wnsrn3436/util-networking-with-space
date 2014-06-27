///udp_handle_destroy(udpHandle, udpSocketDestroyTF)
var index = ds_list_find_index(_NsUdpHandleList, argument0);
if(index!=-1)
{
    ds_list_destroy(argument0[| CNsUdpPlayerIdList])
    ds_list_destroy(argument0[| CNsUdpIpList])
    ds_list_destroy(argument0[| CNsUdpPortList])
    ds_map_delete(_NsUdpSocketMap, argument0[| CNsUdpSocket])
    if(argument1){
        network_destroy(argument0[| CNsUdpSocket])
    }
    ds_list_destroy(argument0)
    ds_list_delete(_NsUdpHandleList, index)
    return true
}
return false
