///ns_get_is_disconnected(tcpHandle)
if(!argument0[| CNsCommonIsServer])
{
    var buffer = _NsSysBuffer;
    buffer_seek(buffer, buffer_seek_start, 0)
    buffer_write(buffer, buffer_u8, CSendToCommonMsgServerAlive)
    if(network_send_packet(argument0[| CNsCommonSocket], buffer, 1)<=0){
        return true
    }
}
return false
