public class Dragonstone.View.Loading : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.ProgressBar progressbar = new Gtk.ProgressBar();
	
	construct {
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		progressbar.halign = Gtk.Align.CENTER;
		progressbar.valign = Gtk.Align.CENTER;
		progressbar.set_pulse_step(0.001);
		var icon = new Gtk.Image.from_icon_name("content-loading-symbolic",Gtk.IconSize.DND);
		icon.icon_size=6;
		centerBox.set_center_widget(icon);
		centerBox.pack_end(progressbar);
		outerBox.set_center_widget(centerBox);
		var empty1 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_start(empty1);
		var empty2 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty2);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "loading" || request.status == "connecting" || request.status == "routing")) {return false;}
		this.request = request;
		this.request.notify["substatus"].connect(loadUpdatedTimeoutHack);
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "loading" || request.status == "connecting" || request.status == "routing";
		}
	}
	
	public void loadUpdatedTimeoutHack(){
		Timeout.add(0,() => {
			loadUpdated();
			return false;
		},Priority.HIGH);
	}
	
	public void loadUpdated(){
		progressbar.pulse();
		float kb = int64.parse(request.substatus,16)/1000;
		progressbar.set_text(@"$kb KB");
		progressbar.set_show_text(true);
	}
	
	public void cleanup(){
		this.request.notify["substatus"].disconnect(loadUpdatedTimeoutHack);
	}
	
}
