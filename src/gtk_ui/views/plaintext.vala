public class Dragonstone.GtkUi.View.Plaintext : Gtk.ScrolledWindow, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request request = null;
	private Gtk.TextView textview;
	
	construct {
		textview = new Gtk.TextView();
		textview.editable = false;
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		add(textview);
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if ((request.status == "success") && request.resource.mimetype.has_prefix("text/")){
			string text = "";
			var file = File.new_for_path (request.resource.filepath);
			if (!file.query_exists ()) {
				text = "ERROR: Cache file does not exist!\nReloading should help,\nif it doesn't please contact the developer!";
			}
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				while ((line = dis.read_line (null)) != null) {
					text = text+line+"\n";
				}
			} catch (GLib.Error e) {
			    text = "ERROR WHILE READING FILE:\n"+e.message;
			}
			textview.buffer.text = text;
			
		} else {
			return false;
		}
		this.request = request;
		show_all();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return (request.status == "success") && request.resource.mimetype.has_prefix("text/");
		}
	}
	
	public bool import(string data){
		var kv = new Dragonstone.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "dragonstone.plain_text.0"){
			return false;
		}
		string? val = kv.get_value("scroll");
		if (val != null){
			Dragonstone.GtkUi.Util.GtkScrollExport.import(this,val);
		}
		return true;
	}
	
	public string? export(){
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("view_type","dragonstone.plain_text.0");
		kv.set_value("scroll",Dragonstone.GtkUi.Util.GtkScrollExport.export(this));
		return kv.export();
	}
	
}
