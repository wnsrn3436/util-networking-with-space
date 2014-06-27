///udp_message_receive_in_async()
if(async_load[? "type"]==network_type_data)
{
    var recv_buffer = async_load[? "buffer"], recv_handle;
    buffer_seek(recv_buffer, buffer_seek_start, 0)
    if(buffer_read(recv_buffer, buffer_u8)==CSendToCommonMsgUdpMsg)
    {
        recv_handle = _NsUdpSocketMap[? ds_map_find_value(async_load, "id")]
        if(!is_undefined(recv_handle))
        {
            var sent_player = buffer_read(recv_buffer, buffer_s16), index;
            index = ds_list_find_index(recv_handle[| CNsUdpPlayerIdList], sent_player)
            if(index!=-1)
            {
                if(ds_list_find_value(recv_handle[| CNsUdpIpList], index)==async_load[? "ip"] and ds_list_find_value(recv_handle[| CNsUdpPortList], index)==async_load[? "port"])
                {
                    if(ds_list_find_value(recv_handle[| CNsUdpTcpHandle], CNsCommonRecvIns)==id)
                    {
                        _NsMsgSentSpace = buffer_read(recv_buffer, buffer_s16)
                        _NsMsgSentPlayer = sent_player
                        _NsMsgId = buffer_read(recv_buffer, buffer_u16)
                        _NsRecvBuffer = recv_buffer
                        _NsMsgRecvHandle = recv_handle
                        event_user(NsEventMsg)
                    }
                    return true
                }
            }
        }
    }
    buffer_seek(recv_buffer, buffer_seek_start, 0)
}
return false
