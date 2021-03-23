public interface Fossil.Interface.Settings.Provider : Object {
	
	public signal void settings_updated(string path_prefix);
	
	public abstract void request_index(string path_prefix, Func<string> cb);
	
	public abstract bool has_object(string path);
	public abstract string? read_object(string path);
	
	public abstract bool can_write_object(string path);
	// writing null content will be the equivalent of a delete
	public abstract bool write_object(string path, string? content);
	
	//those who use this settings provider can use this one to publish their
	//reports when something settings related happend
	public signal void submit_client_report(Fossil.Settings.Report report);
	
	// this signal is where reports from settings porivders are supposed to be propagated upwards
	public signal void provider_report(Fossil.Settings.Report report);
	
}
