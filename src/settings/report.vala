public class Fossil.Settings.Report : Object {
	public string module_name { get; private set; }
	public string path { get; private set; }
	public string? error { get; private set; }
	public string? warning { get; private set; }
	public string? info { get; private set; }
	public string? debug { get; private set; }
	public int64? timestamp; //number of milliseconds since 1970-01-01 UTC
	
	public Report(string module_name, string path, string? error = null, string? warning = null, string? info = null, string? debug = null){
		this.module_name = module_name;
		this.path = path;
		this.error = error;
		this.warning = warning;
		this.info = info;
		this.debug = debug;
		this.timestamp = (GLib.get_real_time()/1000);
	}
	
	public Report.with_updated_path(Fossil.Settings.Report report, string new_path, string module_name_prefix = ""){
		this.module_name = module_name_prefix+report.module_name;
		this.path = new_path;
		this.error = report.error;
		this.warning = report.warning;
		this.info = report.info;
		this.debug = report.debug;
		this.timestamp = report.timestamp;
	}
	
	public string to_string(){
		string message = @"[$timestamp][$module_name]($path)";
		if (error != null){
			message += @" [ERROR] $error";
		}
		if (warning != null){
			message += @" [WARNING] $warning";
		}
		if (info != null){
			message += @" [INFO] $info";
		}
		if (debug != null){
			message += @" [DEBUG] $debug";
		}
		return message;
	}
}
