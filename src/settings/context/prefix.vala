public class Dragonstone.Settings.Context.Prefix : Dragonstone.Interface.Settings.Provider, Object {
	
	private Dragonstone.Interface.Settings.Provider provider;
	private string add_prefix;
	private string remove_prefix;
	
	public Prefix(Dragonstone.Interface.Settings.Provider provider, string add_prefix, string remove_prefix = ""){
		this.provider = provider;
		this.add_prefix = add_prefix;
		this.remove_prefix = remove_prefix;
		this.provider.settings_updated.connect(on_settings_updated);
		this.provider.provider_report.connect(on_provider_report);
		this.submit_client_report.connect(on_submit_client_report);
	}
	
	public string? translate_to_provider_path(string path){
		if (path.has_prefix(remove_prefix)) {
			return add_prefix+path.substring(remove_prefix.length);
		} else {
			return null;
		}
	}
	
	public string? translate_from_provider_path(string path){
		if (path.has_prefix(add_prefix)){
			return remove_prefix+path.substring(add_prefix.length);
		} else {
			return null;
		}
	}
	
	private void on_settings_updated(string path){
		string translated_path = translate_from_provider_path(path);
		if (translated_path != null) {
			this.settings_updated(translated_path);
		}
	}
	
	private void on_provider_report(Dragonstone.Settings.Report report){
		string translated_path = translate_from_provider_path(report.path);
		if (translated_path != null) {
			this.provider_report(new Dragonstone.Settings.Report.with_updated_path(report, translated_path));
		}
	}
	
	public void on_submit_client_report(Dragonstone.Settings.Report report){
		string translated_path = translate_to_provider_path(report.path);
		if (translated_path != null) {
			provider.submit_client_report(new Dragonstone.Settings.Report.with_updated_path(report, translated_path));
		}
	}
	
	  /////////////////////////////////////////////
	 // Dragonstone.Interface.Settings.Provider //
	/////////////////////////////////////////////
	
	public void request_index(string path_prefix, Func<string> cb){
		string translated_path_provider = translate_to_provider_path(path_prefix);
		if (translated_path_provider != null) {
			provider.request_index(translate_to_provider_path(path_prefix), (path) => {
				string? translated_path = translate_from_provider_path(path);
				if (translated_path != null) {
					cb(translated_path);
				}
			});
		}
	}
	
	public bool has_object(string path){
		string translated_path_provider = translate_to_provider_path(path);
		if (translated_path_provider != null) {
			return provider.has_object(translated_path_provider);
		} else {
			return false;
		}
	}
	
	public string? read_object(string path){
		string translated_path_provider = translate_to_provider_path(path);
		if (translated_path_provider != null) {
			return provider.read_object(translated_path_provider);
		} else {
			return null;
		}
	}
	
	public bool can_write_object(string path){
		string translated_path_provider = translate_to_provider_path(path);
		if (translated_path_provider != null) {
			return provider.can_write_object(translated_path_provider);
		} else {
			return false;
		}
	}
	
	// writing null content will be the equivalent of a delete
	public bool write_object(string path, string? content){
		string translated_path_provider = translate_to_provider_path(path);
		if (translated_path_provider != null) {
			return provider.write_object(translated_path_provider, content);
		} else {
			return false;
		}
	}
	
}
