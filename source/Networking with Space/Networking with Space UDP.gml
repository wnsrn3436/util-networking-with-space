#define hidden_udp_init
///hidden_udp_init()
globalvar 
    _NsUdpSocketMap, 
    _NsUdpHandleList
;
_NsUdpSocketMap = ds_map_create()
_NsUdpHandleList = ds_list_create()

#define hidden_udp_final
///hidden_udp_final()
udp_handle_clear(true)
ds_map_destroy(_NsUdpSocketMap)
ds_list_destroy(_NsUdpHandleList)

