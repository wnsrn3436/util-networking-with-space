///ns_handle_clear()
repeat(ds_list_size(_NsHandleList)){
    ns_handle_destroy(_NsHandleList[| 0])
}
