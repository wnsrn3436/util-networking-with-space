///ns_message_receive_in_async()
switch(async_load[? "type"])
{
    case network_type_data:
        var recv_buffer = async_load[? "buffer"], recv_handle;
        buffer_seek(recv_buffer, buffer_seek_start, 0)
        switch(buffer_read(recv_buffer, buffer_u8))
        {
            case CSendToCommonMsgServerMsg:
                recv_handle = _NsServerPortMap[? ds_map_find_value(async_load, "port")]
                if(!is_undefined(recv_handle))
                {
                    if(recv_handle[| CNsCommonRecvIns]!=id){return true}
                    var send_player = buffer_read(recv_buffer, buffer_s16);
                    switch(send_player)
                    {
                        case CSendToServerMsgConnected:
                            if(buffer_read(recv_buffer, buffer_string)==recv_handle[| CNsCommonVersion] and recv_handle[| CNsServerMaxClients]>ds_map_size(recv_handle[| CNsServerClientMap]))
                            {
                                if(recv_handle[| CNsCommonHashLen])
                                {
                                    var sent_player = async_load[? "id"];
                                    if(!is_undefined(_NsWaitKeyPlayerMap[? sent_player]))
                                    {
                                        if(_NsWaitKeyPlayerMap[? sent_player]!=noone)
                                        {
                                            var recv_buffer_pos = buffer_tell(recv_buffer), hash;
                                            buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                            hash = buffer_read(recv_buffer, buffer_string)
                                            buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                            buffer_write(recv_buffer, buffer_string, recv_handle[| CNsCommonKey])
                                            buffer_write(recv_buffer, buffer_u16, _NsWaitKeyPlayerMap[? sent_player]++)
                                            if(hash!=string_copy(buffer_sha1(recv_buffer, 0, buffer_tell(recv_buffer)), 1, recv_handle[| CNsCommonHashLen]))
                                            {
                                                ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                                if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                                break
                                            }
                                            buffer_seek(recv_buffer, buffer_seek_start, recv_buffer_pos)
                                        }
                                        else
                                        {
                                            ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                            if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                            break
                                        }
                                    }
                                    else
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                }
                                var sent_player=async_load[? "id"], buffer=_NsSysBuffer, act_list=recv_handle[| CNsServerActivatedSpace], act_size, list, list_size, i, j;
                                buffer_seek(buffer, buffer_seek_start, 0)
                                buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                buffer_write(buffer, buffer_u8, CSendToClientMsgWaitMsgOldPlayer)
                                buffer_write(buffer, buffer_s16, sent_player)
                                buffer_write(buffer, buffer_u16, recv_handle[| CNsServerWaitMsgKeyCount]++)
                                buffer_write(buffer, buffer_u16, ds_map_size(recv_handle[| CNsServerClientMap]))
                                act_size = ds_list_size(act_list)
                                for(i=0; i<act_size; i++)
                                {
                                    list = act_list[| i]
                                    list_size = ds_list_size(list)
                                    for(j=0; j<list_size; j++)
                                    {
                                        network_send_packet(list[| j], buffer, 6)
                                        buffer_write(buffer, buffer_s16, list[| j])
                                    }
                                }
                                if(recv_handle[| CNsServerWaitMsgKeyCount]>65535){recv_handle[| CNsServerWaitMsgKeyCount] = 0}
                                buffer_write(buffer, buffer_s16, recv_handle[| CNsCommonPlayerId])
                                buffer_poke(buffer, 1, buffer_u8, CSendToClientMsgConnected)
                                network_send_packet(sent_player, buffer, buffer_tell(buffer))
                                _NsMsgId = buffer_read(recv_buffer, buffer_s16)
                                ds_map_add(recv_handle[| CNsServerClientMap], sent_player, _NsMsgId)
                                list = recv_handle+_NsMsgId+1
                                if(recv_handle[| CNsCommonHashLen])
                                {
                                    ds_list_add(list+recv_handle[| CNsServerSpaceNumber], _NsWaitKeyPlayerMap[? sent_player])
                                    ds_map_delete(_NsWaitKeyPlayerMap, sent_player)
                                }
                                ds_list_add(list, sent_player)
                                if(ds_list_size(list)==1){
                                    ds_list_add(act_list, list)
                                }
                                _NsMsgSentSpace = _NsMsgId
                                _NsMsgSentPlayer = sent_player
                                _NsRecvBuffer = recv_buffer
                                _NsMsgRecvHandle = recv_handle
                                _NsMsgType = TypeClientConnected
                                event_user(NsEventServer)
                            }
                            else
                            {
                                var buffer=_NsSysBuffer, sent_player=async_load[? "id"];
                                buffer_seek(buffer, buffer_seek_start, 0)
                                buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                buffer_write(buffer, buffer_u8, CSendToClientMsgConnectionFailed)
                                network_send_packet(sent_player, buffer, 2)
                                if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                            }
                            break
                        case CSendToServerMsgClientKey:
                            var sent_player = async_load[? "id"];
                            if(!is_undefined(_NsWaitKeyPlayerMap[? sent_player]))
                            {
                                if(_NsWaitKeyPlayerMap[? sent_player]==noone)
                                {
                                    var seed=random_get_seed(), buffer=_NsSysBuffer, random_num;
                                    randomize()
                                    random_num = irandom(65530)
                                    _NsWaitKeyPlayerMap[? sent_player] = random_num
                                    buffer_seek(buffer, buffer_seek_start, 0)
                                    buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                    buffer_write(buffer, buffer_u8, CSendToClientMsgClientKey)
                                    buffer_write(buffer, buffer_string, base64_encode(string(random_num)))
                                    network_send_packet(sent_player, buffer, buffer_tell(buffer))
                                    random_set_seed(seed)
                                }
                                else
                                {
                                    ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                    if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                }
                            }
                            else
                            {
                                ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                            }
                            break
                        case CSendToServerMsgSpaceChanged:
                            if(recv_handle[| CNsCommonHashLen])
                            {
                                var recv_buffer_pos=buffer_tell(recv_buffer), sent_player=async_load[? "id"], hash, sent_space, list, index;
                                buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                hash = buffer_read(recv_buffer, buffer_string)
                                sent_space = buffer_read(recv_buffer, buffer_s16)
                                if(sent_space>=0 and recv_handle[| CNsServerSpaceNumber]>sent_space)
                                {
                                    list = recv_handle+sent_space+1
                                    index = ds_list_find_index(list, sent_player)
                                    if(index==-1)
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    list+=recv_handle[| CNsServerSpaceNumber]
                                    buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                    buffer_write(recv_buffer, buffer_string, recv_handle[| CNsCommonKey])
                                    buffer_write(recv_buffer, buffer_u16, list[| index]++)
                                    if(hash!=string_copy(buffer_sha1(recv_buffer, 0, buffer_tell(recv_buffer)), 1, recv_handle[| CNsCommonHashLen]))
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    buffer_seek(recv_buffer, buffer_seek_start, recv_buffer_pos)
                                    if(list[| index]>65535){list[| index] = 0}
                                }
                                else
                                {
                                    ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                    if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                    break
                                }
                            }
                            var sent_player = async_load[? "id"], msg_id, sent_space, list, sent_list;
                            msg_id = buffer_read(recv_buffer, buffer_s16)
                            sent_space = buffer_read(recv_buffer, buffer_s16)
                            list = recv_handle+msg_id+1
                            sent_list = recv_handle+sent_space+1
                            if(list!=sent_list)
                            {
                                if(recv_handle[| CNsCommonHashLen])
                                {
                                    var index = ds_list_find_index(sent_list, sent_player);
                                    ds_list_add(list+recv_handle[| CNsServerSpaceNumber], ds_list_find_value(sent_list+recv_handle[| CNsServerSpaceNumber], index))
                                    ds_list_delete(sent_list+recv_handle[| CNsServerSpaceNumber], index)
                                    ds_list_delete(sent_list, index)
                                }
                                else{
                                    ds_list_delete(sent_list, ds_list_find_index(sent_list, sent_player))
                                }
                                ds_list_add(list, sent_player)
                                if(ds_list_empty(sent_list)){
                                    ds_list_delete(recv_handle[| CNsServerActivatedSpace], ds_list_find_index(recv_handle[| CNsServerActivatedSpace], sent_list))
                                }
                                if(ds_list_size(list)==1){
                                    ds_list_add(recv_handle[| CNsServerActivatedSpace], list)
                                }
                                ds_map_replace(recv_handle[| CNsServerClientMap], sent_player, msg_id)
                            }
                            _NsMsgId = msg_id
                            _NsMsgSentSpace = sent_space
                            _NsMsgSentPlayer = sent_player
                            _NsRecvBuffer = recv_buffer
                            _NsMsgRecvHandle = recv_handle
                            _NsMsgType = TypeClientSpaceChanged
                            event_user(NsEventServer)
                            break
                        case CSendToServerMsgWaitMsgPlayer:
                            if(recv_handle[| CNsCommonHashLen])
                            {
                                var recv_buffer_pos=buffer_tell(recv_buffer), sent_player=async_load[? "id"], hash, sent_space, list, index;
                                buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                hash = buffer_read(recv_buffer, buffer_string)
                                sent_space = buffer_read(recv_buffer, buffer_s16)
                                if(sent_space>=0 and recv_handle[| CNsServerSpaceNumber]>sent_space)
                                {
                                    list = recv_handle+sent_space+1
                                    index = ds_list_find_index(list, sent_player)
                                    if(index==-1)
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    list+=recv_handle[| CNsServerSpaceNumber]
                                    buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                    buffer_write(recv_buffer, buffer_string, recv_handle[| CNsCommonKey])
                                    buffer_write(recv_buffer, buffer_u16, list[| index]++)
                                    if(hash!=string_copy(buffer_sha1(recv_buffer, 0, buffer_tell(recv_buffer)), 1, recv_handle[| CNsCommonHashLen]))
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    buffer_seek(recv_buffer, buffer_seek_start, recv_buffer_pos)
                                    if(list[| index]>65535){list[| index] = 0}
                                }
                                else
                                {
                                    ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                    if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                    break
                                }
                            }
                            var buffer=_NsSysBuffer, new_player=buffer_read(recv_buffer, buffer_s16);
                            if(ds_map_exists(recv_handle[| CNsServerClientMap], new_player))
                            {
                                buffer_seek(buffer, buffer_seek_start, 0)
                                buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                buffer_write(buffer, buffer_u8, CSendToClientMsgWaitMsgNewPlayer)
                                buffer_write(buffer, buffer_u16, buffer_read(recv_buffer, buffer_u16))
                                buffer_write(buffer, buffer_s16, async_load[? "id"])
                                network_send_packet(new_player, buffer, 6)
                            }
                            break
                        default:
                            if(recv_handle[| CNsCommonHashLen])
                            {
                                var recv_buffer_pos=buffer_tell(recv_buffer), sent_player=async_load[? "id"], hash, sent_space, list, index;
                                buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                hash = buffer_read(recv_buffer, buffer_string)
                                sent_space = buffer_read(recv_buffer, buffer_s16)
                                if(sent_space>=0 and recv_handle[| CNsServerSpaceNumber]>sent_space)
                                {
                                    list = recv_handle+sent_space+1
                                    index = ds_list_find_index(list, sent_player)
                                    if(index==-1)
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    list+=recv_handle[| CNsServerSpaceNumber]
                                    buffer_seek(recv_buffer, buffer_seek_end, recv_handle[| CNsCommonHashLen]+3)
                                    buffer_write(recv_buffer, buffer_string, recv_handle[| CNsCommonKey])
                                    buffer_write(recv_buffer, buffer_u16, list[| index]++)
                                    if(hash!=string_copy(buffer_sha1(recv_buffer, 0, buffer_tell(recv_buffer)), 1, recv_handle[| CNsCommonHashLen]))
                                    {
                                        ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                        if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                        break
                                    }
                                    buffer_seek(recv_buffer, buffer_seek_start, recv_buffer_pos)
                                    if(list[| index]>65535){list[| index] = 0}
                                }
                                else
                                {
                                    ns_message_trigger(recv_handle, NsEventServer, TypeServerWasAttacked, ns_get_player_space(recv_handle, sent_player), sent_player, noone, noone)
                                    if(!ns_set_stop_network(recv_handle, sent_player)){ds_map_delete(_NsWaitKeyPlayerMap, sent_player); network_destroy(sent_player)}
                                    break
                                }
                            }
                            var buffer = _NsSysBuffer, to_space, sent_space, sent_player, sent_list, buffer_size;
                            to_space = buffer_read(recv_buffer, buffer_s16)
                            sent_space = buffer_read(recv_buffer, buffer_s16)
                            sent_player = buffer_read(recv_buffer, buffer_s16)
                            sent_list = recv_handle+sent_space+1
                            if(SendToServer>send_player)
                            {
                                buffer_seek(buffer, buffer_seek_start, 0)
                                buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                buffer_write(buffer, buffer_u8, CSendToClientMsgEventMsg)
                                if(!recv_handle[| CNsCommonHashLen]){
                                    buffer_size = async_load[? "size"]-1
                                }
                                else{
                                    buffer_size = async_load[? "size"]-1-recv_handle[| CNsCommonHashLen]-3
                                }
                                buffer_copy(recv_buffer, 3, buffer_size-2, buffer, 2)
                                switch(to_space)
                                {
                                    case ToMySpace:
                                        var sent_list_size=ds_list_size(sent_list), sent_index=ds_list_find_index(sent_list, sent_player), i;
                                        for(i=0; i<sent_index; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                        for(i=sent_index+1; i<sent_list_size; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                        break
                                    case ToEverySpace:
                                        var act_list = recv_handle[| CNsServerActivatedSpace], act_size, list, list_size, i, j;
                                        act_size = ds_list_size(act_list)
                                        for(i=0; i<act_size; i++)
                                        {
                                            list = act_list[| i]
                                            if(list!=sent_list)
                                            {
                                                list_size = ds_list_size(list)
                                                for(j=0; j<list_size; j++){network_send_packet(list[| j], buffer, buffer_size)}
                                            }
                                        }
                                        var sent_list_size=ds_list_size(sent_list), sent_index=ds_list_find_index(sent_list, sent_player);
                                        for(i=0; i<sent_index; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                        for(i=sent_index+1; i<sent_list_size; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                        break
                                    case ToOtherSpace:
                                        var act_list = recv_handle[| CNsServerActivatedSpace], act_size, list, list_size, i, j;
                                        act_size = ds_list_size(act_list)
                                        for(i=0; i<act_size; i++)
                                        {
                                            list = act_list[| i]
                                            if(list!=sent_list)
                                            {
                                                list_size = ds_list_size(list)
                                                for(j=0; j<list_size; j++){network_send_packet(list[| j], buffer, buffer_size)}
                                            }
                                        }
                                        break
                                    default:
                                        var list = recv_handle+to_space+1, list_size, i;
                                        if(list!=sent_list)
                                        {
                                            list_size = ds_list_size(list)
                                            for(i=0; i<list_size; i++){network_send_packet(list[| i], buffer, buffer_size)}
                                        }
                                        else
                                        {
                                            list_size = ds_list_size(sent_list)
                                            var sent_index = ds_list_find_index(sent_list, sent_player);
                                            for(i=0; i<sent_index; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                            for(i=sent_index+1; i<list_size; i++){network_send_packet(sent_list[| i], buffer, buffer_size)}
                                        }
                                }
                                if(SendToAllMe<send_player)
                                {
                                    var join_space = recv_handle[| CNsCommonSpace];
                                    if((to_space<0 and (to_space==ToEverySpace or (to_space==ToMySpace and sent_space==join_space) or (to_space==ToOtherSpace and sent_space!=join_space))) or to_space==join_space)
                                    {
                                        _NsMsgSentSpace = sent_space
                                        _NsMsgSentPlayer = sent_player
                                        _NsMsgId = buffer_read(recv_buffer, buffer_u16)
                                        _NsRecvBuffer = recv_buffer
                                        _NsMsgRecvHandle = recv_handle
                                        event_user(NsEventMsg)
                                    }
                                }
                            }
                            else
                            {
                                if(send_player!=SendToServer and send_player!=recv_handle[| CNsCommonPlayerId])
                                {
                                    buffer_seek(buffer, buffer_seek_start, 0)
                                    buffer_write(buffer, buffer_u8, CSendToCommonMsgClientMsg)
                                    buffer_write(buffer, buffer_u8, CSendToClientMsgEventMsg)
                                    if(!recv_handle[| CNsCommonHashLen]){
                                        buffer_size = async_load[? "size"]-1
                                    }
                                    else{
                                        buffer_size = async_load[? "size"]-1-recv_handle[| CNsCommonHashLen]-3
                                    }
                                    buffer_copy(recv_buffer, 3, buffer_size-2, buffer, 2)
                                    switch(to_space)
                                    {
                                        case ToMySpace: if(ds_list_find_index(sent_list, send_player)!=-1){network_send_packet(send_player, buffer, buffer_size)}; break
                                        case ToEverySpace: if(ds_map_exists(recv_handle[| CNsServerClientMap], send_player)){network_send_packet(send_player, buffer, buffer_size)}; break
                                        case ToOtherSpace:
                                            var send_space = ds_map_find_value(recv_handle[| CNsServerClientMap], send_player);
                                            if(!is_undefined(send_space) and send_space!=sent_space){network_send_packet(send_player, buffer, buffer_size)}
                                            break
                                        default: if(ds_list_find_index(recv_handle+to_space+1, send_player)!=-1){network_send_packet(send_player, buffer, buffer_size)}
                                    }
                                }
                                else
                                {
                                    var join_space = recv_handle[| CNsCommonSpace];
                                    if((to_space<0 and (to_space==ToEverySpace or (to_space==ToMySpace and sent_space==join_space) or (to_space==ToOtherSpace and sent_space!=join_space))) or to_space==join_space)
                                    {
                                        _NsMsgSentSpace = sent_space
                                        _NsMsgSentPlayer = sent_player
                                        _NsMsgId = buffer_read(recv_buffer, buffer_u16)
                                        _NsRecvBuffer = recv_buffer
                                        _NsMsgRecvHandle = recv_handle
                                        event_user(NsEventMsg)
                                    }
                                }
                            }
                    }
                    return true
                }
                break
            case CSendToCommonMsgClientMsg:
                recv_handle = _NsClientSocketMap[? ds_map_find_value(async_load, "id")]
                if(!is_undefined(recv_handle))
                {
                    if(recv_handle[| CNsCommonRecvIns]!=id){return true}
                    switch(buffer_read(recv_buffer, buffer_u8))
                    {
                        case CSendToClientMsgEventMsg:
                            if(recv_handle[| CNsCommonPlayerId]==noone){break}
                            var to_space=buffer_read(recv_buffer, buffer_s16), join_space=recv_handle[| CNsCommonSpace];
                            _NsMsgSentSpace = buffer_read(recv_buffer, buffer_s16)
                            if(recv_handle[| CNsClientWaitMsgPlayer]==noone)
                            {
                                if((to_space<0 and (to_space==ToEverySpace or (to_space==ToMySpace and _NsMsgSentSpace==join_space) or (to_space==ToOtherSpace and _NsMsgSentSpace!=join_space))) or to_space==join_space)
                                {
                                    _NsMsgSentPlayer = buffer_read(recv_buffer, buffer_s16)
                                    _NsMsgId = buffer_read(recv_buffer, buffer_u16)
                                    _NsRecvBuffer = recv_buffer
                                    _NsMsgRecvHandle = recv_handle
                                    event_user(NsEventMsg)
                                }
                            }
                            else
                            {
                                _NsMsgSentPlayer = buffer_read(recv_buffer, buffer_s16)
                                if(ds_list_find_index(recv_handle[| CNsClientWaitMsgPlayer], _NsMsgSentPlayer)==-1)
                                {
                                    if((to_space<0 and (to_space==ToEverySpace or (to_space==ToMySpace and _NsMsgSentSpace==join_space) or (to_space==ToOtherSpace and _NsMsgSentSpace!=join_space))) or to_space==join_space)
                                    {
                                        _NsMsgId = buffer_read(recv_buffer, buffer_u16)
                                        _NsRecvBuffer = recv_buffer
                                        _NsMsgRecvHandle = recv_handle
                                        event_user(NsEventMsg)
                                    }
                                }
                            }
                            break
                        case CSendToClientMsgConnected:
                            recv_handle[| CNsCommonPlayerId] = buffer_read(recv_buffer, buffer_s16)
                            recv_handle[| CNsClientWaitMsgKey] = buffer_read(recv_buffer, buffer_u16)
                            var list = recv_handle[| CNsClientWaitMsgPlayer];
                            repeat(buffer_read(recv_buffer, buffer_u16)){ds_list_add(list, buffer_read(recv_buffer, buffer_s16))}
                            if(ds_list_empty(list))
                            {
                                ds_list_destroy(list)
                                recv_handle[| CNsClientWaitMsgPlayer] = noone
                            }
                            recv_handle[| CNsClientServerId] = buffer_read(recv_buffer, buffer_s16)
                            _NsMsgRecvHandle = recv_handle
                            _NsMsgType = TypeConnected
                            event_user(NsEventClient)
                            break
                        case CSendToClientMsgWaitMsgOldPlayer:
                            var buffer=_NsSysBuffer, sent_player=buffer_read(recv_buffer, buffer_s16);
                            if(recv_handle[| CNsClientWaitMsgPlayer]!=noone)
                            {
                                var list = recv_handle[| CNsClientWaitMsgPlayer], index;
                                index = ds_list_find_index(list, sent_player)
                                if(index!=-1)
                                {
                                    ds_list_delete(list, index)
                                    if(ds_list_empty(list))
                                    {
                                        ds_list_destroy(list)
                                        recv_handle[| CNsClientWaitMsgPlayer] = noone
                                    }
                                }
                            }
                            buffer_seek(buffer, buffer_seek_start, 0)
                            buffer_write(buffer, buffer_u8, CSendToCommonMsgServerMsg)
                            buffer_write(buffer, buffer_s16, CSendToServerMsgWaitMsgPlayer)
                            buffer_write(buffer, buffer_s16, sent_player)
                            buffer_write(buffer, buffer_u16, buffer_read(recv_buffer, buffer_u16))
                            if(!recv_handle[| CNsCommonHashLen]){
                                network_send_packet(recv_handle[| CNsCommonSocket], buffer, 7)
                            }
                            else
                            {
                                var buffer_pos = 7, hash;
                                buffer_write(buffer, buffer_string, recv_handle[| CNsCommonKey])
                                buffer_write(buffer, buffer_u16, recv_handle[| CNsClientKey]++)
                                hash = string_copy(buffer_sha1(buffer, 0, buffer_tell(buffer)), 1, recv_handle[| CNsCommonHashLen])
                                buffer_seek(buffer, buffer_seek_start, buffer_pos)
                                buffer_write(buffer, buffer_string, hash)
                                buffer_write(buffer, buffer_s16, recv_handle[| CNsCommonSpace])
                                network_send_packet(recv_handle[| CNsCommonSocket], buffer, buffer_tell(buffer))
                                if(recv_handle[| CNsClientKey]>65535){recv_handle[| CNsClientKey] = 0}
                            }
                            break
                        case CSendToClientMsgWaitMsgNewPlayer:
                            if(buffer_read(recv_buffer, buffer_u16)==recv_handle[| CNsClientWaitMsgKey])
                            {
                                var list = recv_handle[| CNsClientWaitMsgPlayer];
                                ds_list_delete(list, ds_list_find_index(list, buffer_read(recv_buffer, buffer_s16)))
                                if(ds_list_empty(list))
                                {
                                    ds_list_destroy(list)
                                    recv_handle[| CNsClientWaitMsgPlayer] = noone
                                }
                            }
                            break
                        case CSendToClientMsgClientKey:
                            var key_buffer = recv_handle[| CNsClientKeyBuffer], key_buffer_pos, hash;
                            key_buffer_pos = buffer_tell(key_buffer)
                            recv_handle[| CNsClientKey] = real(base64_decode(buffer_read(recv_buffer, buffer_string)))
                            buffer_write(key_buffer, buffer_string, recv_handle[| CNsCommonKey])
                            buffer_write(key_buffer, buffer_u16, recv_handle[| CNsClientKey]++)
                            hash = string_copy(buffer_sha1(key_buffer, 0, buffer_tell(key_buffer)), 1, recv_handle[| CNsCommonHashLen])
                            buffer_seek(key_buffer, buffer_seek_start, key_buffer_pos)
                            buffer_write(key_buffer, buffer_string, hash)
                            buffer_write(key_buffer, buffer_s16, noone)
                            network_send_packet(recv_handle[| CNsCommonSocket], key_buffer, buffer_tell(key_buffer))
                            buffer_delete(key_buffer)
                            recv_handle[| CNsClientKeyBuffer] = noone
                            break
                        case CSendToClientMsgConnectionFailed:
                            _NsMsgRecvHandle = recv_handle
                            _NsMsgType = TypeConnectionFailed
                            event_user(NsEventClient)
                            break
                    }
                    return true
                }
                break
            case CSendToCommonMsgServerAlive:
                recv_handle = _NsServerPortMap[? ds_map_find_value(async_load, "port")]
                if(!is_undefined(recv_handle)){
                    return true
                }
                break
        }
        buffer_seek(recv_buffer, buffer_seek_start, 0)
        break
    case network_type_disconnect:
        var recv_handle = _NsServerSocketMap[? ds_map_find_value(async_load, "id")];
        if(!is_undefined(recv_handle))
        {
            if(recv_handle[| CNsCommonRecvIns]==id)
            {
                var sent_player = async_load[? "socket"], sent_space, list, index;
                sent_space = ds_map_find_value(recv_handle[| CNsServerClientMap], sent_player)
                if(!is_undefined(sent_space))
                {
                    list = recv_handle+sent_space+1
                    index = ds_list_find_index(list, sent_player)
                    if(recv_handle[| CNsCommonHashLen])
                    {
                        ds_list_delete(list+recv_handle[| CNsServerSpaceNumber], index)
                        ds_map_delete(_NsWaitKeyPlayerMap, sent_player)
                    }
                    ds_list_delete(list, index)
                    if(ds_list_empty(list)){
                        ds_list_delete(recv_handle[| CNsServerActivatedSpace], ds_list_find_index(recv_handle[| CNsServerActivatedSpace], list))
                    }
                    ds_map_delete(recv_handle[| CNsServerClientMap], sent_player)
                    _NsMsgSentSpace = sent_space
                    _NsMsgSentPlayer = sent_player
                    _NsMsgId = sent_space
                    _NsMsgRecvHandle = recv_handle
                    _NsMsgType = TypeClientDisconnected
                    event_user(NsEventServer)
                    return true
                }
                if(recv_handle[| CNsCommonHashLen]){ds_map_delete(_NsWaitKeyPlayerMap, sent_player)}
            }
            return true
        }
        break
    case network_type_connect:
        var recv_handle = _NsServerSocketMap[? ds_map_find_value(async_load, "id")];
        if(!is_undefined(recv_handle))
        {
            if(recv_handle[| CNsCommonRecvIns]==id)
            {
                if(recv_handle[| CNsCommonHashLen]){
                    _NsWaitKeyPlayerMap[? ds_map_find_value(async_load, "socket")] = noone
                }
            }
            return true
        }
        break
}
return false
