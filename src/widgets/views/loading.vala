public class Dragonstone.View.Loading : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.ProgressBar progressbar = new Gtk.ProgressBar();
	private Gtk.Spinner spinner = new Gtk.Spinner();
	
	construct {
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		progressbar.halign = Gtk.Align.CENTER;
		spinner.halign = Gtk.Align.CENTER;
		spinner.start();
		var icon = new Gtk.Image.from_icon_name("content-loading-symbolic",Gtk.IconSize.DND);
		icon.icon_size=6;
		centerBox.set_center_widget(icon);
		centerBox.pack_end(spinner);
		outerBox.set_center_widget(centerBox);
		var empty1 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_start(empty1);
		var empty2 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty2);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "loading" || request.status == "connecting")) {return false;}
		this.request = request;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "loading" || request.status == "connecting";
		}
	}
	
}
