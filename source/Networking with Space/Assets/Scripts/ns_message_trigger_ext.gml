///ns_message_trigger_ext(tcpHandle, NsEvent, Type, sentSpace, sentPlayer, msgId, recvBuffer, bufferReposTF)
var temp_handle, temp_type, temp_space, temp_player, temp_msg, temp_buffer;
temp_handle = _NsMsgRecvHandle
temp_type = _NsMsgType
temp_space = _NsMsgSentSpace
temp_player = _NsMsgSentPlayer
temp_msg = _NsMsgId
temp_buffer = _NsRecvBuffer;
_NsMsgRecvHandle = argument0
_NsMsgType = argument2
_NsMsgSentSpace = argument3
_NsMsgSentPlayer = argument4
_NsMsgId = argument5
_NsRecvBuffer = argument6
if(argument6>=0 and argument7)
{
    var buffer_pos = buffer_tell(argument6);
    with(argument0[| CNsCommonRecvIns]){
        event_user(argument1)
    }
    buffer_seek(argument6, buffer_seek_start, buffer_pos)
}
else
{
    with(argument0[| CNsCommonRecvIns]){
        event_user(argument1)
    }
}
_NsMsgRecvHandle = temp_handle
_NsMsgType = temp_type
_NsMsgSentSpace = temp_space
_NsMsgSentPlayer = temp_player
_NsMsgId = temp_msg
_NsRecvBuffer = temp_buffer
