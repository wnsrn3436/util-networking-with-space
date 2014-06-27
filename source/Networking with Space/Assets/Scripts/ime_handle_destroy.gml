///ime_handle_destroy(imeHandle)
var index = ds_list_find_index(_ImeHandleList, argument0);
if(index!=-1)
{
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
            ds_map_destroy(map)
            ds_list_destroy(list)
        }
        else{
            ds_list_destroy(argument0[| CImeNetIdList])
        }
    }
    if(argument0[| CImeInsMap]!=noone){
        ds_map_destroy(argument0[| CImeInsMap])
    }
    ds_list_destroy(argument0)
    ds_list_delete(_ImeHandleList, index)
    return true
}
return false
