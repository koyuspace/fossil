public class Fossil.Settings.Context.Fallback : Fossil.Interface.Settings.Provider, Object {
	
	private List<Fossil.Interface.Settings.Provider> fallbacks = new List<Fossil.Interface.Settings.Provider>();
	public bool deepwrite = false;
	
	public Fallback() {
		this.submit_client_report.connect(on_submit_client_report);
	}
	
	//first added fallbacks are first used
	public void add_fallback(Fossil.Interface.Settings.Provider provider){
		lock(fallbacks){
			if (fallbacks.index(provider) < 0) {
				fallbacks.append(provider);
				provider.settings_updated.connect(on_settings_updated);
				provider.provider_report.connect(on_provider_report);
				this.settings_updated("");
			}
		}
	}
	
	public void remove_fallback(Fossil.Interface.Settings.Provider provider){
		lock(fallbacks){
			if (fallbacks.index(provider) >= 0) {
				provider.settings_updated.disconnect(on_settings_updated);
				provider.provider_report.disconnect(on_provider_report);
				fallbacks.remove(provider);
				this.settings_updated("");
			}
		}
	}
	
	private void on_settings_updated(string path){
		this.settings_updated(path);
	}
	
	private void on_provider_report(Fossil.Settings.Report report){
		this.provider_report(report);
	}
	
	public void on_submit_client_report(Fossil.Settings.Report report){
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			provider.submit_client_report(report);
		}
	}
	
	  /////////////////////////////////////////////
	 // Fossil.Interface.Settings.Provider //
	/////////////////////////////////////////////
	
	public void request_index(string path_prefix, Func<string> cb){
		GenericSet<string> alredy_seen = new GenericSet<string>(str_hash, str_equal);
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			provider.request_index(path_prefix, (path) => {
				if (!alredy_seen.contains(path)) {
					alredy_seen.add(path);
					cb(path);
				}
			});
		}
	}
	
	public bool has_object(string path){
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			if (provider.has_object(path)) {
				return true;
			}
		}
		return false;
	}
	
	public string? read_object(string path){
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			string? content = provider.read_object(path);
			if (content != null) {
				return content;
			}
		}
		return null;
	}
	
	public bool can_write_object(string path){
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			if (provider.can_write_object(path)) {
				return true;
			}
		}
		return false;
	}
	
	// writing null content will be the equivalent of a delete
	public bool write_object(string path, string? content){
		bool success = false;
		foreach(Fossil.Interface.Settings.Provider provider in fallbacks){
			if (provider.write_object(path, content)) {
				if (deepwrite) {
					return true;
				}
				success = true;
			}
		}
		return success;
	}
}
