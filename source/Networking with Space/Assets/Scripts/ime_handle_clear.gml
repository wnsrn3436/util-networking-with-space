///ime_handle_clear()
repeat(ds_list_size(_ImeHandleList)){
    ime_handle_destroy(_ImeHandleList[| 0])
}
