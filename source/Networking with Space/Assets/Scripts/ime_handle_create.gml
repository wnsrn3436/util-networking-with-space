///ime_handle_create(useNetIdListTF, useNetIdListDataTF, useImeInstanceTF)
var list = ds_list_create();
if(argument0)
{
    list[| CImeNetIdList] = ds_list_create()
    if(argument1)
        list[| CImeNetIdDataMap] = ds_map_create();
    else
        list[| CImeNetIdDataMap] = noone;
}
else
{
    list[| CImeNetIdList] = noone
    list[| CImeNetIdDataMap] = noone
}

list[| CImeNetId] = -1

if(argument2)
    list[| CImeInsMap] = ds_map_create();
else
    list[| CImeInsMap] = noone;

ds_list_add(_ImeHandleList, list)
return list
