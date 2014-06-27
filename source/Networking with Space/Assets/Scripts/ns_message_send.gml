///ns_message_send(tcpHandle, ToSpace, SendToPlayer, msgId)
if(argument0[| CNsCommonIsServer])
{
    if(SendToServer>argument2)
    {
        var buffer = _NsSysBuffer;
        buffer_seek(buffer, buffer_seek_start, 0)
        buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
        buffer_write(buffer, buffer_u8, CSendToClientMsgEventMsg)
        buffer_write(buffer, buffer_s16, argument1)
        buffer_write(buffer, buffer_s16, argument0[| CNsCommonSpace])
        buffer_write(buffer, buffer_s16, argument0[| CNsCommonPlayerId])
        buffer_write(buffer, buffer_u16, argument3)
        buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 10)
        switch(argument1)
        {
            case ToMySpace:
                var list=argument0+argument0[| CNsCommonSpace]+1, list_size, buffer_size=10+buffer_tell(_NsSendBuffer), i;
                list_size = ds_list_size(list)
                for(i=0; i<list_size; i++){network_send_packet(list[| i], buffer, buffer_size)}
                break
            case ToEverySpace:
                var act_list=argument0[| CNsServerActivatedSpace], act_size, list, list_size, buffer_size=10+buffer_tell(_NsSendBuffer), i, j;
                act_size = ds_list_size(act_list)
                for(i=0; i<act_size; i++)
                {
                    list = act_list[| i]
                    list_size = ds_list_size(list)
                    for(j=0; j<list_size; j++){network_send_packet(list[| j], buffer, buffer_size)}
                }
                break
            case ToOtherSpace:
                var act_list=argument0[| CNsServerActivatedSpace], act_size, list, list_size, send_list=argument0+argument0[| CNsCommonSpace]+1, buffer_size=10+buffer_tell(_NsSendBuffer), i, j;
                act_size = ds_list_size(act_list)
                for(i=0; i<act_size; i++)
                {
                    list = act_list[| i]
                    if(list!=send_list)
                    {
                        list_size = ds_list_size(list)
                        for(j=0; j<list_size; j++){network_send_packet(list[| j], buffer, buffer_size)}
                    }
                }
                break
            default:
                var list=argument0+argument1+1, list_size, buffer_size=10+buffer_tell(_NsSendBuffer), i;
                list_size = ds_list_size(list)
                for(i=0; i<list_size; i++){network_send_packet(list[| i], buffer, buffer_size)}
        }
        if(argument2>SendToAll)
        {
            if(argument1<ToOtherSpace or argument0[| CNsCommonSpace]==argument1)
            {
                buffer_seek(buffer, buffer_seek_start, 10)
                ns_message_trigger(argument0, NsEventMsg, noone, argument0[| CNsCommonSpace], argument0[| CNsCommonPlayerId], argument3, buffer)
            }
        }
    }
    else
    {
        var buffer = _NsSysBuffer;
        if(argument2!=SendToServer and argument2!=argument0[| CNsCommonPlayerId])
        {
            buffer_seek(buffer, buffer_seek_start, 0)
            buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
            buffer_write(buffer, buffer_u8, CSendToClientMsgEventMsg)
            buffer_write(buffer, buffer_s16, argument1)
            buffer_write(buffer, buffer_s16, argument0[| CNsCommonSpace])
            buffer_write(buffer, buffer_s16, argument0[| CNsCommonPlayerId])
            buffer_write(buffer, buffer_u16, argument3)
            buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 10)
            switch(argument1)
            {
                case ToMySpace: if(ds_list_find_index(argument0+argument0[| CNsCommonSpace]+1, argument2)!=-1){network_send_packet(argument2, buffer, 10+buffer_tell(_NsSendBuffer))}; break
                case ToEverySpace: if(ds_map_exists(argument0[| CNsServerClientMap], argument2)){network_send_packet(argument2, buffer, 10+buffer_tell(_NsSendBuffer))}; break
                case ToOtherSpace:
                    var send_space = ds_map_find_value(argument0[| CNsServerClientMap], argument2);
                    if(!is_undefined(send_space) and send_space!=argument0[| CNsCommonSpace]){network_send_packet(argument2, buffer, 10+buffer_tell(_NsSendBuffer))}
                    break
                default: if(ds_list_find_index(argument0+argument1+1, argument2)!=-1){network_send_packet(argument2, buffer, 10+buffer_tell(_NsSendBuffer))}
            }
        }
        else
        {
            if(argument1<ToOtherSpace or argument0[| CNsCommonSpace]==argument1)
            {
                buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 0)
                buffer_seek(buffer, buffer_seek_start, 0)
                ns_message_trigger(argument0, NsEventMsg, noone, argument0[| CNsCommonSpace], argument0[| CNsCommonPlayerId], argument3, buffer)
            }
        }
    }
}
else
{
    if(argument0[| CNsCommonPlayerId]==noone){return false}
    var buffer = _NsSysBuffer;
    if(argument2!=argument0[| CNsCommonPlayerId])
    {
        buffer_seek(buffer, buffer_seek_start, 0)
        buffer_write(buffer, buffer_u8, CSendToCommonMsgServerMsg)
        if(argument2!=SendToOther){buffer_write(buffer, buffer_s16, argument2)}else{buffer_write(buffer, buffer_s16, SendToAllServer)}
        buffer_write(buffer, buffer_s16, argument1)
        buffer_write(buffer, buffer_s16, argument0[| CNsCommonSpace])
        buffer_write(buffer, buffer_s16, argument0[| CNsCommonPlayerId])
        buffer_write(buffer, buffer_u16, argument3)
        buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 11)
        if(!argument0[| CNsCommonHashLen]){
            network_send_packet(argument0[| CNsCommonSocket], buffer, 11+buffer_tell(_NsSendBuffer))
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
        if(argument2==SendToAllServerMe or argument2==SendToAllMe)
        {
            if(argument1<ToOtherSpace or argument0[| CNsCommonSpace]==argument1)
            {
                buffer_seek(buffer, buffer_seek_start, 11)
                ns_message_trigger(argument0, NsEventMsg, noone, argument0[| CNsCommonSpace], argument0[| CNsCommonPlayerId], argument3, buffer)
            }
        }
    }
    else
    {
        if(argument1<ToOtherSpace or argument0[| CNsCommonSpace]==argument1)
        {
            buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), buffer, 0)
            buffer_seek(buffer, buffer_seek_start, 0)
            ns_message_trigger(argument0, NsEventMsg, noone, argument0[| CNsCommonSpace], argument0[| CNsCommonPlayerId], argument3, buffer)
        }
    }
}
return true
