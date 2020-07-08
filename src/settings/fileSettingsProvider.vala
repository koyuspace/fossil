public class Dragonstone.Settings.FileProvider : Dragonstone.Settings.Provider, Object {
	
	//the id, stripped of its prefix will be directly appendd to this
	//this is done to make it possible to enforce filenames starting with a fixed prefix
	private string basepath;
	private string id_prefix;
	private bool writable;
	
	public FileProvider(string basepath, string id_prefix = "", bool writable = true){
		this.id_prefix = id_prefix;
		this.basepath = basepath;
		this.writable = writable;
	}
	
	public string? get_name(string id){
		if (id.has_prefix(id_prefix)){
			return id.substring(id_prefix.length).replace("/",".");
		}
		return null;
	}
	
	public bool has_object(string id){
		var name = get_name(id);
		if(name != null){
			var file = File.new_for_path(basepath+name);
			return file.query_exists();
		} else {
			return false;
		}
	}
	public Dragonstone.Settings.Rom? get_object(string id){
		var name = get_name(id);
		if(name != null){
			var file = File.new_for_path(basepath+name);
			try{
				var data_input_stream = new DataInputStream(file.read());
				string output = "";
				string line;
				while ((line = data_input_stream.read_line_utf8(null)) != null) {
					output = output+line+"\n";
				}
				//TODO use a file rom provider here, that can monitor the filesystem and automatically update
				var rom_provider = new Dragonstone.Settings.RomProvider(output);
				var rom = new Dragonstone.Settings.Rom(rom_provider);
				return rom;
			}catch (GLib.Error e) {
				return null;
			}
		} else {
			return null;
		}
	}
	
	public bool can_upload_object(string id){
		return writable;
	}
	public bool upload_object(string id, string content){
		if (writable) {
			var name = get_name(id);
			if(name != null){
				try{
					print(@"[settings][file settings provider] exporting $id to $basepath$name\n");
					var file = File.new_for_path(basepath+name);
					try {
						file.delete();
					} catch {}
					var file_output_stream = file.create(FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION);
					var data_output_stream = new DataOutputStream(file_output_stream);
					data_output_stream.put_string(content);
					print(@"[settings][file settings provider] exported $id\n");
				}catch (GLib.Error e) {
					print(@"[settings][file settings provider][error] $(e.message)\n");
					return false;
				}
			} else {
				return false;
			}
		}
		return writable;
	}
}
