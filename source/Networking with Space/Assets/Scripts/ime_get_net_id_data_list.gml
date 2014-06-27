///ime_get_net_id_data_list(imeHandle, netId)
var list = ds_map_find_value(argument0[| CImeNetIdDataMap], argument1);
if(!is_undefined(list)){
    return list
}
return noone
