public interface Dragonstone.Interface.Page.Service.Syncronisation : Object {
	
	/*
		This service stores data from widgets, so that it can be used by other widgets or to persist state.
		There are public and private keys, private keys start with a .
		This can for example be used to persist scroll position on view change
		or letting other widgets handle some functionality.
	*/
	
	/*
		Well known public keys are
		
		page_search.query
		page_search.num_results
		page_search.at_result
	*/
	
	// The module_name is used for logging.
	
	//if the key is null it means that all syncronised information should be reloaded
	public signal void on_syncronisation_update(string? key, string? val);
	
	public abstract void syncronisation_write(string key, string? val, string module_name);
	public abstract string? syncronisation_read(string key, string module_name);
	public abstract void foreach_syncronisation_key(Func<string> cb, string module_name);
	
}
