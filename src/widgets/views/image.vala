public class Dragonstone.View.Image : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Image image;
	private Gdk.Pixbuf pixbuf;
	
	public float factor = 1;
	
	construct {}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if ((request.status == "success") && request.resource.mimetype.has_prefix("image/")){
			try {
				pixbuf = new Gdk.Pixbuf.from_file(request.resource.filepath);
				image = new Gtk.Image.from_pixbuf(pixbuf);
				add(image);
				size_allocate.connect(scaleToWindow);
			} catch (GLib.Error e) {
				print(@"[image] Error while loading image ($(request.uri))\n$(e.message)");
				return false;
			}
		} else {
			return false;
		}
		this.request = request;
		return true;
	}
	
	public void scaleToWindow(Gtk.Allocation rect){
		float ph = pixbuf.get_height();
		float pw = pixbuf.get_width();
		float wh = get_allocated_height();
		float ww = get_allocated_width();
		float hr = ph/wh;
		float wr = pw/ww;
		float new_factor = 1;
		if (hr > 1 || wr > 1){
			new_factor = 1/float.max(hr,wr);
		}
		print(@"[image] rect.width=$(rect.width) rect.height=$(rect.height)\n");
		print(@"[image] width: $pw,$ww rat: $wr | height: $ph,$wh rat: $hr\n");
		print(@"[image] factor: $factor\n");
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
				image.set_from_pixbuf(scaled_pixbuf);
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
		size_allocate.disconnect(scaleToWindow);
	}
	
}
