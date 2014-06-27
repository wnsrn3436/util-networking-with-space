///ime_net_id_create(imeHandle)
var net_id = ++argument0[| CImeNetId];
if(argument0[| CImeNetIdList]!=noone)
{
    ds_list_add(argument0[| CImeNetIdList], net_id)
    if(argument0[| CImeNetIdDataMap]!=noone){
        ds_map_add(argument0[| CImeNetIdDataMap], net_id, ds_list_create())
    }
}
return net_id
