///ns_set_space(tcpHandle, joinSpace)
if(!argument0[| CNsCommonIsServer])
{
    if(argument0[| CNsCommonPlayerId]==noone){return false}
    var buffer = _NsSysBuffer;
    buffer_seek(buffer, buffer_seek_start, 0)
    buffer_write(buffer, buffer_u8, CSendToCommonMsgServerMsg)
    buffer_write(buffer, buffer_s16, CSendToServerMsgSpaceChanged)
    buffer_write(buffer, buffer_s16, argument1)
    buffer_write(buffer, buffer_s16, argument0[| CNsCommonSpace])
    buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 7)
    if(!argument0[| CNsCommonHashLen]){
        network_send_packet(argument0[| CNsCommonSocket], buffer, 7+buffer_tell(_NsSendBuffer))
    }
    else
    {
        buffer_seek(buffer, buffer_seek_relative, buffer_tell(_NsSendBuffer))
        var buffer_pos = buffer_tell(buffer), hash;
        buffer_write(buffer, buffer_string, argument0[| CNsCommonKey])
        buffer_write(buffer, buffer_u16, argument0[| CNsClientKey]++)
        hash = string_copy(buffer_sha1(buffer, 0, buffer_tell(buffer)), 1, argument0[| CNsCommonHashLen])
        buffer_seek(buffer, buffer_seek_start, buffer_pos)
        buffer_write(buffer, buffer_string, hash)
        buffer_write(buffer, buffer_s16, argument0[| CNsCommonSpace])
        network_send_packet(argument0[| CNsCommonSocket], buffer, buffer_tell(buffer))
        if(argument0[| CNsClientKey]>65535){argument0[| CNsClientKey] = 0}
    }
    argument0[| CNsCommonSpace] = argument1
}
else
{
    var buffer=_NsSysBuffer, sent_space=argument0[| CNsCommonSpace];
    argument0[| CNsCommonSpace] = argument1
    buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 0)
    buffer_seek(buffer, buffer_seek_start, 0)
    ns_message_trigger(argument0, NsEventServer, TypeServerSpaceChanged, sent_space, argument0[| CNsCommonPlayerId], argument0[| CNsCommonSpace], buffer)
}
return true
