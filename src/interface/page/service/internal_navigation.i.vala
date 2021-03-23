public interface Fossil.Interface.Page.Service.InternalNavigation : Object {
	
	/*
		This interface is for navigating withing a page,
		that is all navigation that can be done without creating a second page.
	*/
	
	// The module_name is used for logging.
	
	// Where we are now
	public signal void current_uri_changed(string uri);
	public abstract string get_current_uri();
	
	// redirecting
	public abstract void redirect(string uri, string module_name);
	public abstract uint get_redirect_counter();
	public abstract bool may_autoredirect_to(string uri);
	
	// reloading
	public abstract void reload();
	
}
