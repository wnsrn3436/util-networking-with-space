///ime_net_id_clear(imeHandle)
if(argument0[| CImeNetIdList]!=noone)
{
    if(argument0[| CImeNetIdDataMap]!=noone)
    {
        var list=argument0[| CImeNetIdList], map=argument0[| CImeNetIdDataMap], list_size, key, i;
        list_size = ds_list_size(list)
        for(i=0; i<list_size; i++)
        {
            key = list[| i]
            ds_list_destroy(map[? key])
            ds_map_delete(map, key)
        }
        ds_list_clear(list)
    }
    else{
        ds_list_clear(argument0[| CImeNetIdList])
    }
}
argument0[| CImeNetId] = -1
