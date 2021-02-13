public interface Dragonstone.Interface.Page.Service.ExternalNavigation : Object {
	
	/*
		This interface is for navigation to other pages, the requests will be passed on to the tab 
		or an other appropriate handler
	*/
	
	/*
		Well known target names include:
		this_tab
		new_tab
		new_window
	*/
	
	// The module_name is used for logging.
	
	public abstract void go_to_uri(string uri, string target, string module_name);
	
	public abstract string get_primary_target();
	public abstract string? get_secodary_target();
	
	//Lower numbers mean higher prioritys
	public abstract uint? get_target_priority(string target);
	//Will iterate over all possible targets, higher prioritys first
	public abstract void foreach_target(Func<string> cb);
	// The name you would use in a configuration menu
	public abstract string? get_target_name(string target);
	// What should be displayed in a menu if there is no localized name avaiable
	public abstract string? get_default_target_menu_label(string target);
	
	
}
