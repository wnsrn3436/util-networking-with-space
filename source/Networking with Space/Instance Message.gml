#define hidden_ime_init
///hidden_ime_init()
globalvar 
    _ImeHandleList
;
_ImeHandleList = ds_list_create()

#define hidden_ime_final
///hidden_ime_final()
ime_handle_clear()
ds_list_destroy(_ImeHandleList)

