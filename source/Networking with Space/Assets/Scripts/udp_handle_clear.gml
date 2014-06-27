///udp_handle_clear(udpSocketDestroyTF)
repeat(ds_list_size(_NsUdpHandleList)){
    udp_handle_destroy(_NsUdpHandleList[| 0], argument0)
}
