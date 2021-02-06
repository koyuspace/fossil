public class Dragonstone.Settings.FileProvider : Dragonstone.Interface.Settings.Provider, Object {
	
	//the id, stripped of its prefix will be directly appendd to this
	//this is done to make it possible to enforce filenames starting with a fixed prefix
	private string basepath;
	public string module_name;
	private string path_prefix;
	private bool writable;
	private FileMonitor? file_monitor = null;
	
	public FileProvider(string basepath, string module_name, string path_prefix = "", bool writable = true){
		this.path_prefix = path_prefix;
		this.module_name = module_name;
		this.basepath = basepath;
		this.writable = writable;
		try {
			var directory = File.new_for_path(basepath);
			file_monitor = directory.monitor_directory(NONE);
			file_monitor.changed.connect(on_file_changed);
		} catch (Error e){
			print("[settings.fileprovider] Error while setting up directory monitor: "+e.message);
		}
	}
	
	~FileProvider(){
		if (file_monitor != null){
			file_monitor.cancel();
			file_monitor.changed.disconnect(on_file_changed);
		}
	}
	
	private void on_file_changed(File file, File? other_file, FileMonitorEvent event_type){
		string? basename = file.get_basename();
		if (basename != null) {
			if (!basename.has_prefix(".")){
				if (event_type != CHANGES_DONE_HINT) {
					print(@"[settings][updated] $(path_prefix+basename.replace("/","."))\n");
					this.settings_updated(path_prefix+basename.replace("/","."));
				}
			}
		}
	}
	
	public string? get_name(string path){
		if (path.has_prefix(path_prefix)){
			return path.substring(path_prefix.length).replace("/",".");
		}
		return null;
	}
	
	private void report(string path, string? error, string? warning, string? info, string? debug){
		this.provider_report(new Dragonstone.Settings.Report(module_name, path, error, warning, info, debug));
	}
	  /////////////////////////////////////////////
	 // Dragonstone.Interface.Settings.Provider //
	/////////////////////////////////////////////
	
	public void request_index(string path_prefix, Func<string> cb){
		if (path_prefix.length >= this.path_prefix.length) {
			if (!path_prefix.has_prefix(this.path_prefix)) {
				return;
			}
		} else if (this.path_prefix.length < path_prefix.length){
			if (!this.path_prefix.has_prefix(path_prefix)) {
				return;
			}
		}
		try {
			var directory = File.new_for_path(basepath);
			var enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);
			FileInfo file_info;
			while ((file_info = enumerator.next_file()) != null) {
				string path = this.path_prefix+file_info.get_name();
				if (path.has_prefix(path_prefix)){
					cb(path);
				}
			}
		//currently does nothing
		} catch (GLib.Error e) {
			report(path_prefix, e.message, null, "request_index()", basepath);
		}
	}
	
	public bool has_object(string path){
		var name = get_name(path);
		if(name != null){
			var file = File.new_for_path(basepath+name);
			return file.query_exists();
		} else {
			return false;
		}
	}
	public string? read_object(string path){
		var name = get_name(path);
		if(name != null){
			var file = File.new_for_path(basepath+name);
			try{
				var data_input_stream = new DataInputStream(file.read());
				string output = "";
				string line;
				while ((line = data_input_stream.read_line_utf8(null)) != null) {
					output = output+line+"\n";
				}
				report(path, null, null, "successfully read file", basepath+name);
				return output;
			} catch (GLib.Error e) {
				report(path, e.message, null, null, basepath+name);
				return null;
			}
		} else {
			return null;
		}
	}
	
	public bool can_write_object(string path){
		return writable;
	}
	public bool write_object(string path, string? content){
		if (writable) {
			var name = get_name(path);
			if(name != null){
				bool updated = false;
				try{
					//print(@"[settings][file settings provider] exporting $path to $basepath$name\n");
					var file = File.new_for_path(basepath+name);
					if (file.query_exists()) {
						file.delete();
						report(path, null, null, "successfully deleted file", basepath+name);
						updated = true;
					}
					if (content != null) {
						var file_output_stream = file.create(FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION);
						var data_output_stream = new DataOutputStream(file_output_stream);
						data_output_stream.put_string(content);
						data_output_stream.close();
						//print(@"[settings][file settings provider] exported $path\n");
						report(path, null, null, "successfully written to file", basepath+name);
						updated = true;
					}
				}catch (GLib.Error e) {
					//print(@"[settings][file settings provider][error] $(e.message)\n");
					report(path, e.message, null, null, basepath+name);
					return false;
				}
				if (updated) {
					settings_updated(path);
				}
			} else {
				return false;
			}
		}
		return writable;
	}
}
