public class Dragonstone.Page.Page : Object, Dragonstone.Interface.Page.Page {
	
	protected Dragonstone.Interface.Settings.Provider? persistant_settings = null;
	protected Dragonstone.Settings.RamProvider local_settings = new Dragonstone.Settings.RamProvider();
	protected Dragonstone.Settings.Context.Fallback settings_context = new Dragonstone.Settings.Context.Fallback();
	protected Dragonstone.Interface.Page.Service.Metadata metadata;
	protected Dragonstone.Interface.Page.Service.Syncronisation syncronisation = new Dragonstone.Page.Service.Syncronisation();
	protected Dragonstone.Interface.Page.Service.InternalNavigation internal_navigation;
	protected Dragonstone.Interface.Page.Service.ExternalNavigation external_navigation;
	protected Dragonstone.Interface.Page.Service.LinearHistory? linear_history = null;
	
	public Dragonstone.GtkUi.LegacyWidget.Tab? legacy_tab = null;
	public Dragonstone.Request? legacy_request = null;
	
	public Page(Dragonstone.Interface.Page.Service.InternalNavigation internal_navigation, Dragonstone.Interface.Page.Service.ExternalNavigation external_navigation, Dragonstone.Interface.Settings.Provider? persistant_settings = null, Dragonstone.Interface.Page.Service.LinearHistory? linear_history = null, Dragonstone.Interface.Page.Service.Metadata? metadata = null){
		this.internal_navigation = internal_navigation;
		this.external_navigation = external_navigation;
		this.persistant_settings = persistant_settings;
		this.linear_history = linear_history;
		if (metadata != null){
			this.metadata = metadata;
		} else {
			this.metadata = new Dragonstone.Page.Service.Metadata();
		}
		this.settings_context.add_fallback(local_settings);
		if (persistant_settings != null) {
			this.settings_context.add_fallback(persistant_settings);
		}
	}
	
	  /////////////////////////////////////
	 // Dragonstone.Interface.Page.Page //
	/////////////////////////////////////
	
	public virtual Dragonstone.Interface.Settings.Provider get_page_settings_provider(){
		return settings_context;
	}
	
	public virtual Dragonstone.Interface.Settings.Provider? get_persistant_page_settings_provider(){
		return persistant_settings;
	}
	
	//Core services
	public virtual Dragonstone.Interface.Page.Service.Metadata get_metadata_service(){
		return metadata;
	}
	
	public virtual Dragonstone.Interface.Page.Service.Syncronisation get_syncronisation_service(){
		return syncronisation;
	}
	
	public virtual Dragonstone.Interface.Page.Service.InternalNavigation get_internal_navigation_service(){
		return internal_navigation;
	}
	
	public virtual Dragonstone.Interface.Page.Service.ExternalNavigation get_external_navigation_service(){
		return external_navigation;
	}
	
	//optinal services
	public virtual Dragonstone.Interface.Page.Service.LinearHistory? get_linear_history_service(){
		return linear_history;
	}
	
	// Temporary legacy services to make it easier to migrate to the new ones
	// All of the blow functionality is DEPRECATED
	
	public virtual FileInputStream? get_content_stream(){
		if (legacy_tab == null) {
			return null;
		} else {
			return legacy_tab.get_file_content_stream();
		}
	}
	
	public virtual string get_content_mimetype(){
		if (legacy_request != null){
			if (legacy_request.resource != null){
				return legacy_request.resource.mimetype;
			}
		}
		return "";
	}
	
	public virtual string? get_legacy_status(){
		if (legacy_request != null){
			return legacy_request.status;
		}
		return null;
	}
	
	public virtual Dragonstone.GtkUi.LegacyWidget.Tab? get_legacy_tab(){ return legacy_tab; }
	public virtual Dragonstone.Request? get_legacy_request(){ return legacy_request; }
}
