public interface Fossil.Interface.Page.Service.Metadata : Object {
	
	/*
		This interface is supposed to store page wide metadata
		that is usually inferred from downloaded resources.
		The metadata in this service will be used for eye candy,
		indexing sites and user information.
		The metadata may also come from information derived
		from a previously visited resource, i.e. the label of a link leading to an image.
		It should not be related to user input!
	*/
	
	/*
		Well known metadata keys are:
		title
		icon_uri
		search_uri_template
	*/
	
	// The module_name is used for logging.
	
	public signal void on_page_metadata_change(string key, string? val);
	
	public abstract void set_page_metadata(string key, string? val, string module_name);
	public abstract string? get_page_metadata(string key, string module_name);
	public abstract void foreach_page_metadata_key(Func<string> cb, string module_name);
	
}
