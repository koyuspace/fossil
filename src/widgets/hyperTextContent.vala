public class Dragonstone.Widget.HyperTextContent : Dragonstone.Widget.TextContent {
	
	public HashTable<string,string> uris = new HashTable<string,string>(str_hash,str_equal);
	
	protected Gtk.TextTag link_tag;
	
	public HyperTextContent(){
		var buffer = textview.buffer;
		link_tag = buffer.create_tag("link");
		link_tag.underline = Pango.Underline.SINGLE;
		link_tag.event.connect(on_link_tag_event);
		//textview.set_tooltip_text("TEST!");
		textview.has_tooltip = true;
		textview.query_tooltip.connect(on_tooltip_query);
	}

	public void append_link(string text, string uri){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		string index = @"$(end_iter.get_line())/$(end_iter.get_line_offset())";
		uris.set(index,uri);
		textview.buffer.insert_with_tags(ref end_iter, text, text.length, link_tag);
	}
	
	private bool on_tooltip_query(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip){
		//print(@"tooltip $x $y $keyboard_tooltip\n");
		int? buffer_x, buffer_y;
		textview.window_to_buffer_coords(Gtk.TextWindowType.TEXT, x, y, out buffer_x, out buffer_y);
		if (buffer_x != null && buffer_y != null){
			Gtk.TextIter iter;
			if (textview.get_iter_at_location(out iter,buffer_x,buffer_y)){
				string? uri = get_link_uri(iter);
				if (uri != null){
					tooltip.set_text(uri);
					//print(@"TOOLTIP: $buffer_y/$buffer_x $uri\n");
					return true;
				} else {
					tooltip.set_text("");
				}
			}
		}
		return false;
	}
	
	private bool on_link_tag_event(Object event_object, Gdk.Event event, Gtk.TextIter iter){
		uint button;
		if (event.get_button(out button) && event.get_event_type() == Gdk.EventType.BUTTON_RELEASE){
			if (button == 1){
				//link clicked
				string? uri = get_link_uri(iter);
				if (uri == null){
					print("[hypertextcontent][error] on_link_tag_event() no uri found\n");
					return true;
				}
				print(@"Clicked on $uri\n");
				return true;
			}
		}
		return false;
	}
	
	private string? get_link_uri(Gtk.TextIter iter){
		iter.backward_to_tag_toggle(link_tag);
		string index = @"$(iter.get_line())/$(iter.get_line_offset())";
		return uris.get(index);
	}
	
}
