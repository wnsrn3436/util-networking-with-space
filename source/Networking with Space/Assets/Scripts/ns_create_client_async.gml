///ns_create_client_async(ip, port, joinSpace, recvInstance, version, hashLen, key)
argument6 = string(argument6)
if(string_byte_length(argument6)<=argument5)
{
    var socket = network_create_socket(network_socket_tcp);
    if(socket>=0)
    {
        if(network_connect(socket, argument0, argument1)>=0)
        {
            var list=ds_list_create(), buffer=_NsSysBuffer;
            argument4 = string(argument4)
            list[| CNsCommonSocket] = socket
            list[| CNsCommonPort] = argument1
            list[| CNsCommonSpace] = argument2
            list[| CNsCommonPlayerId] = noone
            list[| CNsCommonIsServer] = false
            list[| CNsCommonRecvIns] = argument3
            list[| CNsCommonVersion] = argument4
            list[| CNsCommonHashLen] = argument5
            list[| CNsCommonKey] = argument6
            list[| CNsClientIp] = argument0
            list[| CNsClientKey] = noone
            list[| CNsClientKeyBuffer] = noone
            list[| CNsClientWaitMsgPlayer] = ds_list_create()
            list[| CNsClientWaitMsgKey] = noone
            list[| CNsClientServerId] = noone
            _NsClientSocketMap[? socket] = list
            ds_list_add(_NsHandleList, list)
            if(!argument5)
            {
                buffer_seek(buffer, buffer_seek_start, 0)
                buffer_write(buffer, buffer_u8, CSendToCommonMsgServerMsg)
                buffer_write(buffer, buffer_s16, CSendToServerMsgConnected)
                buffer_write(buffer, buffer_string, argument4)
                buffer_write(buffer, buffer_s16, argument2)
                buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, buffer_tell(buffer))
                network_send_packet(socket, buffer, buffer_tell(buffer)+buffer_tell(_NsSendBuffer))
            }
            else
            {
                var key_buffer = buffer_create(256, buffer_grow, 1);
                buffer_write(key_buffer, buffer_u8, CSendToCommonMsgServerMsg)
                buffer_write(key_buffer, buffer_s16, CSendToServerMsgConnected)
                buffer_write(key_buffer, buffer_string, argument4)
                buffer_write(key_buffer, buffer_s16, argument2)
                buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), key_buffer, buffer_tell(key_buffer))
                buffer_seek(key_buffer, buffer_seek_relative, buffer_tell(_NsSendBuffer))
                list[| CNsClientKeyBuffer] = key_buffer
                buffer_seek(buffer, buffer_seek_start, 0)
                buffer_write(buffer, buffer_u8, CSendToCommonMsgServerMsg)
                buffer_write(buffer, buffer_s16, CSendToServerMsgClientKey)
                network_send_packet(socket, buffer, 3)
            }
            return list
        }
        network_destroy(socket)
    }
}
return false
