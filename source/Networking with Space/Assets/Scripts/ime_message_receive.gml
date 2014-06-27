///ime_message_receive(imeHandle, netId)
var temp_handle = _NsMsgRecvHandle;
_NsMsgRecvHandle = argument0
with(ime_get_instance_id(argument0, argument1)){
    event_user(ImeEventMsg)
}
_NsMsgRecvHandle = temp_handle
