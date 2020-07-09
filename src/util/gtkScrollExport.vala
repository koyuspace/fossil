public class Dragonstone.Util.GtkScrollExport {
	
	public static bool import(Gtk.ScrolledWindow sw, string data){
		var kv = new Dragonstone.Util.Kv();
		kv.import(data);
		if (kv.get_value("type") != "dragonstone.gtk_scroll_export.0"){
			return false;
		}
		string? val = kv.get_value("vscroll");
		if (val != null){
			uint64 vscroll;
			if (Dragonstone.Util.Intparser.try_parse_unsigned(val,out vscroll)){
				Timeout.add(100,() => {
					sw.vadjustment.set_value(vscroll);
					return false;
				},Priority.HIGH);
			}
		}
		val = kv.get_value("hscroll");
		if (val != null){
			uint64 hscroll;
			if (Dragonstone.Util.Intparser.try_parse_unsigned(val,out hscroll)){
				Timeout.add(100,() => {
					sw.hadjustment.set_value(hscroll);
					return false;
				},Priority.HIGH);
			}
		}
		return true;
	}
	
	public static string export(Gtk.ScrolledWindow sw){
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("type","dragonstone.gtk_scroll_export.0");
		kv.set_value("vscroll",@"$(sw.vadjustment.get_value())");
		kv.set_value("hscroll",@"$(sw.hadjustment.get_value())");
		return kv.export();
	}
}
