public class Dragonstone.Widget.HyperTextContent : Dragonstone.Widget.TextContent {
	
	public HashTable<string,string> uris = new HashTable<string,string>(str_hash,str_equal);
	public signal void go(string uri, bool alt); //alt is true if the link was ctrl-clicked or middleclicked

	protected Dragonstone.Widget.LinkPopover? link_popover = null;	
	protected Gtk.TextTag link_tag;
	
	private Gtk.GestureLongPress long_press_gesture;
	private bool long_press = false;
	
	public HyperTextContent(){
		var buffer = textview.buffer;
		link_tag = buffer.create_tag("link");
		//link_tag.underline = Pango.Underline.SINGLE;
		link_tag.event.connect(on_link_tag_event);
		link_tag.scale = 1.1;
		link_tag.style = Pango.Style.ITALIC;
		/*link_tag.pixels_above_lines = 5;
		link_tag.pixels_above_lines_set = true;
		link_tag.pixels_below_lines = 5;
		link_tag.pixels_below_lines_set = true;*/
		textview.has_tooltip = true;
		textview.query_tooltip.connect(on_tooltip_query);
		textview.button_press_event.connect(on_textview_button);
		textview.touch_event.connect(on_textview_touch);
		long_press_gesture = new Gtk.GestureLongPress(textview);
		long_press_gesture.set_propagation_phase(Gtk.PropagationPhase.TARGET);
		long_press_gesture.pressed.connect((x,y) => {
			string? uri = get_link_uri_at_window_location((int) x,(int) y);
			if (uri != null){
				long_press = true;
				print(@"Long pressed on $uri\n");
				show_popover((int) x, (int) y, uri);
			}
		});
	}

	public void append_link(string text, string uri, bool with_icon = true){
		Gtk.TextIter end_iter;
		//Insert Icon
		if (with_icon){
			var icon_name = Dragonstone.Util.DefaultGtkLinkIconLoader.guess_icon_name_for_uri(uri);
			/*// Old Icon code, can only show icons at caracter size
			var icon_theme = Gtk.IconTheme.get_for_screen(get_screen());
			if (icon_theme.has_icon(icon_name)){
				try{
					var icon_pixbuf = icon_theme.load_icon(icon_name, (int) Gtk.IconSize.LARGE_TOOLBAR, 0);
					if (icon_pixbuf != null){
						textview.buffer.get_end_iter(out end_iter);
						textview.buffer.insert_pixbuf(end_iter,icon_pixbuf);
						append_text(" ");
					}
				} catch(Error e){
					print(@"[hypertextcontent][error] error while loading icon $icon_name: $(e.message)\n");
				}
			}*/
			var image = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
			append_widget_inline(image);
			append_text(" ");
		}
		textview.buffer.get_end_iter(out end_iter);
		//register uri
		string index = @"$(end_iter.get_line())/$(end_iter.get_line_offset())";
		uris.set(index,uri);
		//insert link
		textview.buffer.insert_with_tags(ref end_iter, text, text.length, link_tag);
	}
	
	private void show_popover(int x, int y, string uri){
		if (link_popover != null){
			link_popover.use_uri(uri);
			link_popover.set_relative_to(textview);
			var rect = Gdk.Rectangle() {
				x = x,
				y = y,
				width = 1,
				height = 1
			};
			link_popover.pointing_to = rect;
			link_popover.popup();
			link_popover.show_all();
		}
	}
	
	private bool on_tooltip_query(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip){
		//print(@"tooltip $x $y $keyboard_tooltip\n");
		string? uri = get_link_uri_at_window_location(x,y);
		if (uri != null){
			tooltip.set_text(uri);
			//print(@"TOOLTIP: $buffer_y/$buffer_x $uri\n");
			return true;
		} else {
			tooltip.set_text("");
		}
		return false;
	}
	
	private bool on_textview_button(Gdk.EventButton event){
		//print(@"BUTTON: $(event.button)\n");
		if (event.button == 3){
			string? uri = get_link_uri_at_window_location((int) event.x, (int) event.y);
			if (uri != null){
				print(@"Open menu for $uri\n");
				show_popover((int) event.x, (int) event.y, uri);
				return true;
			}
		}
		return false;
	}
	
	
	private int max_distance_for_touch_squared = 50;
	private bool last_touch_event_in_progress = false;
	private int last_touch_event_start_x = 0;
	private int last_touch_event_start_y = 0;
	
	
	private bool on_textview_touch(Gdk.Event event){
		if (event.get_event_type() == Gdk.EventType.TOUCH_BEGIN){
			last_touch_event_start_x = (int) event.touch.x;
			last_touch_event_start_y = (int) event.touch.y;
			last_touch_event_in_progress = true;
		}
		if (event.get_event_type() == Gdk.EventType.TOUCH_END){
			if (long_press) {
				long_press = false;
				return true;
			}
			if (last_touch_event_in_progress){
				last_touch_event_in_progress = false;
				double dx = event.touch.x-last_touch_event_start_x;
				double dy = event.touch.y-last_touch_event_start_y;
				int distance_squared = (int) ((dx*dx)+(dy*dy));
				print(@"D: $distance_squared\n");
				if(distance_squared <= max_distance_for_touch_squared){
					string? uri = get_link_uri_at_window_location((int) event.touch.x, (int) event.touch.y);
					if (uri == null){
						print("[hypertextcontent][error] on_link_tag_event() no uri found\n");
						return true;
					}
					go(uri,false);
				}
			}
		}
		return false;
	}
	
	private bool on_link_tag_event(Object event_object, Gdk.Event event, Gtk.TextIter iter){
		uint button;
		if (event.get_button(out button) && event.get_event_type() == Gdk.EventType.BUTTON_RELEASE){
			if (long_press) {
				long_press = false;
				return true;
			}
			//print(@"BUTTON: $button\n");
			if (button == 1 || button == 2){
				//link clicked
				string? uri = get_link_uri(iter);
				if (uri == null){
					print("[hypertextcontent][error] on_link_tag_event() no uri found\n");
					return true;
				}
				bool alt = (button == 2) || ((event.button.state & Gdk.ModifierType.CONTROL_MASK) != 0);
				print(@"Clicked on $uri $alt\n");
				go(uri,alt);
				return true;
			}
		}
		return false;
	}
	
	protected string? get_link_uri_at_window_location(int x, int y){
		int? buffer_x, buffer_y;
		textview.window_to_buffer_coords(Gtk.TextWindowType.TEXT, x, y, out buffer_x, out buffer_y);
		if (buffer_x != null && buffer_y != null){
			Gtk.TextIter iter;
			if (textview.get_iter_at_location(out iter,buffer_x,buffer_y)){
				return get_link_uri(iter);
			}
		}
		return null;
	}
	
	protected string? get_link_uri(Gtk.TextIter iter){
		if (!iter.starts_tag(link_tag)){
			iter.backward_to_tag_toggle(link_tag);
		}
		if (iter.starts_tag(link_tag)){
			string index = @"$(iter.get_line())/$(iter.get_line_offset())";
			return uris.get(index);
		}
		return null;
	}
	
}
