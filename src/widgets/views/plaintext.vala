public class Dragonstone.View.Plaintext : Gtk.ScrolledWindow, Dragonstone.IView {
	
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
		if (kv.get_value("view_type") != "dragonstone.gemini_text.0"){
			return false;
		}
		string? val = kv.get_value("vscroll");
		if (val != null){
			uint64 vscroll;
			if (Dragonstone.Util.Intparser.try_parse_unsigned(val,out vscroll)){
				Timeout.add(100,() => {
					this.vadjustment.set_value(vscroll);
					return false;
				},Priority.HIGH);
			}
		}
		val = kv.get_value("hscroll");
		if (val != null){
			uint64 hscroll;
			if (Dragonstone.Util.Intparser.try_parse_unsigned(val,out hscroll)){
				Timeout.add(100,() => {
					this.hadjustment.set_value(hscroll);
					return false;
				},Priority.HIGH);
			}
		}
		return true;
	}
	
	public string? export(){
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("view_type","dragonstone.gemini_text.0");
		kv.set_value("vscroll",@"$(this.vadjustment.get_value())");
		kv.set_value("hscroll",@"$(this.hadjustment.get_value())");
		return kv.export();
	}
	
}
