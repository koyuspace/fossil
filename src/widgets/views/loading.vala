public class Dragonstone.View.Loading : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
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
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (!(resource.resourcetype == Dragonstone.ResourceType.LOADING)) {return false;}
		this.resource = resource;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return resource.resourcetype == Dragonstone.ResourceType.LOADING;
		}
	}
	
}
