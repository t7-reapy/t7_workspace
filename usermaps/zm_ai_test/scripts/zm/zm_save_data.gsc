#precache( "eventstring", "set_save_data" );
#precache( "eventstring", "get_save_data" );

#namespace save_data;

/@
"Name: save_data::set_save_data( <index>, <value> )"
"Summary: Saves a value on a specific index."
"Module: save_data"
"CallOn: self : The player"
"MandatoryArg: <index> : The index that the value will be stored on. (0-719)"
"MandatoryArg: <value> : The value we want to store. (0-255)"
"Example: player save_data::set_save_data(3, 30);"
@/
function set_save_data(index, value) {
	if(!isdefined(self)) {
		// SaveData needs player
		return;
	}
	if(!isdefined(index) || !isdefined(value)) {
		// SaveData needs an index and a value
		return;
	}
	if(index < 0 || index > 719){
		// SaveData value only supports indexes 0-719
		return;
	}
	if(value < 0 || value > 255) {
		// SaveData value only supports values 0-255
		return;
	}
	self LUINotifyEvent( &"set_save_data", 2, index, value);
}

/@
"Name: save_data::get_save_data( <index> )"
"Summary: Gets a saved value on a specific index."
"Module: save_data"
"CallOn: self : The player"
"MandatoryArg: <index> : The index that we want the value of. (0-719)"
"Example: player save_data::get_save_data(3);"
@/
function get_save_data(index) {
	if(!isdefined(self)) {
		// SaveData needs player
		return;
	}
	if(!isdefined(index)) {
		// SaveData needs an index
		return;
	}
	if(index < 0 || index > 719){
		// SaveData value only supports indexes 0-719
		return;
	}
	self LUINotifyEvent( &"get_save_data", 1, index);
	while(1) {
		self waittill("menuresponse", menu, response);
		if(Int(GetSubStr(response, 0, (index + "").size)) == index) {
			return Int(GetSubStr(response, (index + "").size + 1));
		}
	}
}