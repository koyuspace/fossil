public class Fossil.GtkUi.View.Loading : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Gtk.ProgressBar progressbar = new Gtk.ProgressBar();
	
	private Gtk.Image default_icon;
	private Gtk.Image connecting_icon;
	private Gtk.Image download_icon;
	private Gtk.Image upload_icon;
	
	private Gtk.Label headline;
	
	private string headline_default = "- LOADING -";	
	private string headline_connecting = "- CONNECTING -";
	private string headline_download = "- DOWNLOADING -";
	private string headline_upload = "- UPLOADING -";

	private bool status_dirty = true;
	private string? last_status = "...";
	private string last_substatus = "";
	private bool still_going = true;
	
	construct {
		default_icon = this.append_big_icon("content-loading-symbolic");
		connecting_icon = this.append_big_icon("network-idle-symbolic");
		download_icon = this.append_big_icon("network-receive-symbolic");
		upload_icon = this.append_big_icon("network-transmit-symbolic");
		connecting_icon.hide();
		download_icon.hide();
		upload_icon.hide();
		headline = append_big_headline(headline_default);
		progressbar.halign = Gtk.Align.CENTER;
		progressbar.valign = Gtk.Align.CENTER;
		progressbar.set_pulse_step(0.01);
		progressbar.expand = true;
		progressbar.halign = Gtk.Align.FILL;
		append_widget(progressbar);
		Timeout.add(100,() => {
			update_display();
			return still_going;
		});
	}
	
	private void update_status(string status){
		default_icon.hide();
		connecting_icon.hide();
		download_icon.hide();
		upload_icon.hide();
		if (status == "connecting"){
			headline.label = headline_connecting;
			connecting_icon.show();
			progressbar.hide();
		} else if (status == "loading"){
			headline.label = headline_download;
			download_icon.show();
			progressbar.show();
		} else if (status == "uploading"){
			headline.label = headline_upload;
			upload_icon.show();
			progressbar.show();
		} else {
			headline.label = headline_default;
			default_icon.show();
			progressbar.hide();
		}
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status == "loading" || request.status == "uploading" || request.status == "connecting" || request.status == "routing")) {return false;}
		this.request = request;
		this.request.notify["substatus"].connect(on_load_updated);
		this.headline_default = tab.translation.localize("view.loading.headline_default");
		this.headline_connecting = tab.translation.localize("view.loading.headline_connecting");
		this.headline_download = tab.translation.localize("view.loading.headline_download");
		this.headline_upload = tab.translation.localize("view.loading.headline_upload");
		show_all();
		update_display();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "loading" || request.status == "uploading" || request.status == "connecting" || request.status == "routing";
		}
	}
	
	public void on_load_updated(){
		if (request.status != last_status) {
			last_status = request.status;
			status_dirty = true;
		}
		last_substatus = request.substatus;
		
	}
	
	public void update_display(){
		if (status_dirty) {
			status_dirty = false;
			update_status(last_status);
		}

		progressbar.pulse();
		uint64 bytes = 0;
		Fossil.Util.Intparser.try_parse_base_16_unsigned(request.substatus,out bytes);
		float kb = bytes/1000;
		//float kb = int64.parse(request.substatus,16)/1000;
		progressbar.set_text(@"$kb KB");
		progressbar.set_show_text(true);
	}
	
	public void cleanup(){
		this.request.notify["substatus"].disconnect(on_load_updated);
		still_going = false;
	}
	
}
