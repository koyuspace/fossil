public class Fossil.GtkUi.View.Image : Gtk.ScrolledWindow, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Gtk.Image image;
	private Gdk.Pixbuf pixbuf;
	
	public float factor = 1;
	
	public bool autoscale = true;
	
	construct {}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if ((request.status == "success") && request.resource.mimetype.has_prefix("image/")){
			try {
				var input_stream = tab.get_file_content_stream();
				if (input_stream == null) {
					return false;
				}
				pixbuf = new Gdk.Pixbuf.from_stream(input_stream);
				image = new Gtk.Image.from_pixbuf(pixbuf);
				add(image);
				size_allocate.connect(trigger_autoscale);
			} catch (GLib.Error e) {
				print(@"[image] Error while loading image ($(request.uri))\n$(e.message)");
				return false;
			}
		} else {
			return false;
		}
		this.request = request;
		
		set_events(Gdk.EventMask.ALL_EVENTS_MASK);
		
		this.scroll_event.connect((event) => {
			if((event.state & Gdk.ModifierType.CONTROL_MASK) > 0){
				float new_factor = factor-((float) event.delta_y)/10;
				if (new_factor > 0 && new_factor < 1000){
					scale(new_factor);
				}
				autoscale = false;
				return true;
			}
			return false;
		});
		show_all();
		return true;
	}
	
	public void trigger_autoscale(Gtk.Allocation rect){
		if(autoscale){
			scale_to_window(false);			
		}
	}
	
	public void scale_to_window(bool do_not_magnify = true){
		float ph = pixbuf.get_height();
		float pw = pixbuf.get_width();
		float wh = get_allocated_height();
		float ww = get_allocated_width();
		float hr = ph/wh;
		float wr = pw/ww;
		float new_factor = factor;
		if (hr > 1 || wr > 1 || !do_not_magnify){
			new_factor = 1/float.max(hr,wr);
			//print(@"[image] rect.width=$(rect.width) rect.height=$(rect.height)\n");
			//print(@"[image] width: $pw,$ww rat: $wr | height: $ph,$wh rat: $hr\n");
			//print(@"[image] factor: $factor\n");
		}
		scale(new_factor);
	}
	
	public void scale(float factor){
		float off = this.factor/factor;
		this.factor = factor;
		int ph = pixbuf.get_height();
		int pw = pixbuf.get_width();
		//int wh = get_allocated_height();
		//int ww = get_allocated_width();
		int w = (int) (pw*factor);
		int h = (int) (ph*factor);
		if (off > 1.0001 || off < 0.9999){
			var scaled_pixbuf = pixbuf.scale_simple(w, h, Gdk.InterpType.BILINEAR);
			if (scaled_pixbuf != null){
				image.set_from_pixbuf( (owned) scaled_pixbuf);
			}
		}
		image.set_padding(0,0);
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return (request.status == "success") && request.resource.mimetype.has_prefix("image/");
		}
	}
	
	public void cleanup(){
		this.image.clear();
		size_allocate.disconnect(trigger_autoscale);
	}
	
}
