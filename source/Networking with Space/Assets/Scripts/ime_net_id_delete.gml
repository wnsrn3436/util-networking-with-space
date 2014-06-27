///ime_net_id_delete(imeHandle, netId)
if(argument0[| CImeNetIdList]!=noone)
{
    var index = ds_list_find_index(argument0[| CImeNetIdList], argument1);
    if(index!=-1)
    {
        ds_list_delete(argument0[| CImeNetIdList], index)
        if(argument0[| CImeNetIdDataMap]!=noone)
        {
            var map = argument0[| CImeNetIdDataMap];
            ds_list_destroy(map[? argument1])
            ds_map_delete(map, argument1)
        }
    }
}
