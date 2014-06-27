///udp_message_send(udpHandle, msgId)
var buffer=_NsSysBuffer, tcphandle=argument0[| CNsUdpTcpHandle], udpsocket=argument0[| CNsUdpSocket], iplist=argument0[| CNsUdpIpList], portlist=argument0[| CNsUdpPortList], buffer_size=buffer_tell(_NsSendBuffer), list_size, i;
buffer_seek(buffer, buffer_seek_start, 0)
buffer_write(buffer, buffer_u8, CSendToCommonMsgUdpMsg)
buffer_write(buffer, buffer_s16, tcphandle[| CNsCommonPlayerId])
buffer_write(buffer, buffer_s16, tcphandle[| CNsCommonSpace])
buffer_write(buffer, buffer_u16, argument1)
buffer_copy(_NsSendBuffer, 0, buffer_size, buffer, 7)
buffer_size += 7
list_size = ds_list_size(iplist)
for(i=0; i<list_size; i++){
    network_send_udp(udpsocket, iplist[| i], portlist[| i], buffer, buffer_size)
}
