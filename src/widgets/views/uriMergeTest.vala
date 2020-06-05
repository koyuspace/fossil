public class Dragonstone.View.UriMergeTest : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	public UriMergeTest(){
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
		this.append_big_headline("Uri Merger Test");
		this.append_widget(baseurientry);
		this.append_widget(relativeurientry);
		this.append_widget(outlabel);
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
		this.append_widget(new Gtk.Label(@"$baseuri + $relativeuri = $joined $res"));
	}

	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		return true;
	}
	
	public bool canHandleCurrentResource(){
		return false;
	}
}
