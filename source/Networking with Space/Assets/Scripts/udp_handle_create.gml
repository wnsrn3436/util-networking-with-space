///udp_handle_create(tcpHandle, udpSocket, socketIP, socketPort)
var list = ds_list_create();
list[| CNsUdpSocket] = argument1
list[| CNsUdpTcpHandle] = argument0
list[| CNsUdpPlayerIdList] = ds_list_create()
list[| CNsUdpIpList] = ds_list_create()
list[| CNsUdpPortList] = ds_list_create()
list[| CNsUdpIp] = argument2
list[| CNsUdpPort] = argument3
_NsUdpSocketMap[? argument1] = list
ds_list_add(_NsUdpHandleList, list)
return list
