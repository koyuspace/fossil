public class Fossil.GtkUi.View.UriMergeInternal : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	public UriMergeInternal(){
		var outlabel = new Gtk.Label("");
		var baseurientry = new Gtk.Entry();
		baseurientry.placeholder_text = "Base Uri";
		var relativeurientry = new Gtk.Entry();
		relativeurientry.placeholder_text = "Relative Uri";
		baseurientry.activate.connect(() => {
			outlabel.label = Fossil.Util.Uri.join(baseurientry.text,relativeurientry.text);
		});
		relativeurientry.activate.connect(() => {
			outlabel.label = Fossil.Util.Uri.join(baseurientry.text,relativeurientry.text);
		});
		this.append_big_headline("Uri Merger Internal");
		this.append_widget(baseurientry);
		this.append_widget(relativeurientry);
		this.append_widget(outlabel);
		add_fossil("file:///","/","file:///");
		add_fossil("file:","","file:");
		show_all();
	}
	
	private void add_fossil(string baseuri,string relativeuri,string result){
		var joined =  Fossil.Util.Uri.join(baseuri,relativeuri);
		var res = "[passed]";
		if(joined != result){
			res = "[failed] "+result;
		}
		this.append_widget(new Gtk.Label(@"$baseuri + $relativeuri = $joined $res"));
	}

	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		return true;
	}
	
	public bool canHandleCurrentResource(){
		return false;
	}
}
