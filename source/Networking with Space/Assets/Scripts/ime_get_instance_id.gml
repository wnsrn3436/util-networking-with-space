///ime_get_instance_id(imeHandle, netId)
var ins_id = ds_map_find_value(argument0[| CImeInsMap], argument1);
if(!is_undefined(ins_id)){
    return ins_id
}
return noone
