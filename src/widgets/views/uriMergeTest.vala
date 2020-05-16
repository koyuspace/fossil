public class Dragonstone.View.UriMergeTest : Gtk.Box, Dragonstone.IView {
	
	public UriMergeTest(){
		this.orientation = Gtk.Orientation.VERTICAL;
		var outlabel = new Gtk.Label("");
		var baseurientry = new Gtk.Entry();
		baseurientry.placeholder_text = "Base Uri";
		var relativeurientry = new Gtk.Entry();
		relativeurientry.placeholder_text = "Relative Uri";
		baseurientry.activate.connect(() => {
			outlabel.label = Dragonstone.Util.Uri.join(baseurientry.text,relativeurientry.text);
		});
		relativeurientry.activate.connect(() => {
			outlabel.label = Dragonstone.Util.Uri.join(baseurientry.text,relativeurientry.text);
		});
		pack_start(baseurientry);
		pack_start(relativeurientry);
		pack_start(outlabel);
		add_test("file:///","/","file:///");
		add_test("file:","","file:");
		show_all();
	}
	
	private void add_test(string baseuri,string relativeuri,string result){
		var joined =  Dragonstone.Util.Uri.join(baseuri,relativeuri);
		var res = "[passed]";
		if(joined != result){
			res = "[failed] "+result;
		}
		pack_start(new Gtk.Label(@"$baseuri + $relativeuri = $joined $res"));
	}

	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		return true;
	}
	
	public bool canHandleCurrentResource(){
		return false;
	}
}
