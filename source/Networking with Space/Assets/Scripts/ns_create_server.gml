///ns_create_server(port, maxClients, spaceNumber, joinSpace, recvInstance, version, hashLen, key)
argument7 = string(argument7)
if(string_byte_length(argument7)<=argument6)
{
    var socket = network_create_server(network_socket_tcp, argument0, argument1), list;
    if(socket>=0)
    {
        var stack=ds_stack_create(), ds_count=0, ds_max=2+argument2+(argument2*(argument6>0)), temp_list, temp_list2;
        temp_list = ds_list_create()
        while(++ds_count!=ds_max)
        {
            temp_list2 = ds_list_create()
            if(temp_list+1!=temp_list2){
                ds_count = 0
            }
            ds_stack_push(stack, temp_list)
            temp_list = temp_list2
        }
        ds_stack_push(stack, temp_list)
        repeat(argument2+(argument2*(argument6>0))){
            ds_stack_pop(stack)
        }
        list = ds_stack_pop(stack)
        ds_stack_pop(stack)
        
        list[| CNsCommonSocket] = socket
        list[| CNsCommonPort] = argument0
        list[| CNsCommonSpace] = argument3
        list[| CNsCommonPlayerId] = socket
        list[| CNsCommonIsServer] = true
        list[| CNsCommonRecvIns] = argument4
        list[| CNsCommonVersion] = string(argument5)
        list[| CNsCommonHashLen] = argument6
        list[| CNsCommonKey] = argument7
        list[| CNsServerWaitMsgKeyCount] = 0
        list[| CNsServerInitialMaxClients] = argument1
        list[| CNsServerMaxClients] = argument1
        list[| CNsServerClientMap] = ds_map_create()
        list[| CNsServerActivatedSpace] = list-1
        list[| CNsServerSpaceNumber] = argument2
        _NsServerPortMap[? argument0] = list
        _NsServerSocketMap[? socket] = list
        ds_list_add(_NsHandleList, list)
        buffer_copy(_NsSendBuffer, 0, buffer_tell(_NsSendBuffer), _NsSysBuffer, 0)
        buffer_seek(_NsSysBuffer, buffer_seek_start, 0)
        ns_message_trigger(list, NsEventServer, TypeServerCreated, argument3, socket, argument3, _NsSysBuffer)
        
        while(!ds_stack_empty(stack)){
            ds_list_destroy(ds_stack_pop(stack))
        }
        ds_stack_destroy(stack)
        
        return list
    }
}
return false
