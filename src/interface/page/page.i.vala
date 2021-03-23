public interface Fossil.Interface.Page.Page : Object {

	// Returns a settings provider, that contains the persistant configuration for pages, overlayed with local changes
	// Writing will only make local changes that won't be saved
	public abstract Fossil.Interface.Settings.Provider get_page_settings_provider();
	
	// Returns the persistant configuration for pages wich will be used for all pages in the same configuration space
	// Use this to implement settings pages otherwise don't use it
	public abstract Fossil.Interface.Settings.Provider? get_persistant_page_settings_provider();
	
	//Core services
	public abstract Fossil.Interface.Page.Service.Metadata get_metadata_service();
	public abstract Fossil.Interface.Page.Service.Syncronisation get_syncronisation_service();
	public abstract Fossil.Interface.Page.Service.InternalNavigation get_internal_navigation_service();
	public abstract Fossil.Interface.Page.Service.ExternalNavigation get_external_navigation_service();
	
	//optinal services
	public abstract Fossil.Interface.Page.Service.LinearHistory? get_linear_history_service();
	
	// Temporary legacy services to make it easier to migrate to the new ones
	// All of the blow functionality is DEPRECATED
	
	public virtual FileInputStream? get_content_stream(){ return null; }
	public virtual string get_content_mimetype(){ return ""; }
	public virtual string? get_legacy_status(){ return null; }

}
