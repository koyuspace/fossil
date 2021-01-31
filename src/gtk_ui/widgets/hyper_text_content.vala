public class Dragonstone.GtkUi.Widget.HyperTextContent : Dragonstone.GtkUi.Widget.TextContent, Dragonstone.Interface.Document.TokenRenderer {
	
	public HashTable<string,string> uris = new HashTable<string,string>(str_hash,str_equal);
	public signal void go(string uri, bool alt); //alt is true if the link was ctrl-clicked or middleclicked

	protected Dragonstone.GtkUi.Widget.LinkPopover? link_popover = null;	
	protected Gtk.TextTag link_tag;
	protected Gtk.TextTag link_hover_tag;
	protected Gtk.TextTag h1_tag;
	protected Gtk.TextTag h2_tag;
	protected Gtk.TextTag h3_tag;
	protected Gtk.TextTag quote_tag;
	protected Gtk.TextTag list_item_tag;
	protected Gtk.TextTag description_tag;
	protected Gtk.TextTag preformatted_paragraph_tag;
	protected Gtk.TextTag preformatted_tag;
	protected Gtk.TextTag parser_error_tag;
	protected Gtk.TextTag error_tag;
	
	private Gtk.GestureLongPress long_press_gesture;
	private bool long_press = false;
	
	public HyperTextContent(){
		var buffer = textview.buffer;
		link_tag = buffer.create_tag("link");
		link_hover_tag = buffer.create_tag("link_hover");
		h1_tag = buffer.create_tag("h1");
		h2_tag = buffer.create_tag("h2");
		h3_tag = buffer.create_tag("h3");
		quote_tag = buffer.create_tag("quote");
		list_item_tag = buffer.create_tag("list_item");
		description_tag = buffer.create_tag("description");
		preformatted_paragraph_tag = buffer.create_tag("preformatted_paragraph");
		preformatted_tag = buffer.create_tag("preformatted");
		parser_error_tag = buffer.create_tag("parser_error");
		error_tag = buffer.create_tag("error");
		link_hover_tag.underline = Pango.Underline.SINGLE;
		link_tag.underline = Pango.Underline.NONE;
		link_tag.event.connect(on_link_tag_event);
		link_tag.scale = 1.1;
		link_tag.style = Pango.Style.ITALIC;
		h1_tag.scale = 1.7;
		h2_tag.scale = 1.5;
		h3_tag.scale = 1.2;
		quote_tag.style = Pango.Style.OBLIQUE;
		description_tag.scale = 0.9;
		description_tag.style = Pango.Style.ITALIC;
		preformatted_paragraph_tag.wrap_mode = Gtk.WrapMode.NONE;
		var error_color = Gdk.RGBA();
		error_color.parse("#FB3934"); //Pretty sure sobody is using a red background anytime soon
		error_tag.foreground_rgba = error_color;
		parser_error_tag.foreground_rgba = error_color; 
		parser_error_tag.style = Pango.Style.ITALIC;
		textview.wrap_mode = Gtk.WrapMode.WORD_CHAR;
		textview.right_margin = 8;
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
	
	//TODO: implement theming and get rid of this
	protected void highlight_preformatted_paragraphs(){
		preformatted_paragraph_tag.paragraph_background = "#191919";
		preformatted_paragraph_tag.foreground = "#D3D7CF";
	}
	
	  //////////////////////////////////////////////////
	 // Dragonstone.Interface.Document.TokenRenderer //
	//////////////////////////////////////////////////
	
	private bool last_had_newline = true;
	
	public void start_new_paragraph(){
		if (!last_had_newline) {
			append_text("\n");
		}
	}
	
	public void append_token(Dragonstone.Ui.Document.Token token){
		switch(token.token_type){
			case PARAGRAPH:
				if (!token.inlined) { start_new_paragraph(); }
				if (token.preformatted) {
					append_with_tag(token.text, preformatted_paragraph_tag, true);
				} else {
					append_text(token.text);
				}
				break;
			case DESCRIPTION:
				if (!token.inlined) { start_new_paragraph(); }
				append_with_tag(token.text, description_tag, token.preformatted);
				break;
			case EMPTY_LINE:
				if (!token.inlined) { start_new_paragraph(); }
				append_text("\n");
				break;
			case LINK:
				if (token.uri != null) {
					if (token.inlined) {
						append_link(token.text,token.uri, false);
					} else {
						start_new_paragraph();
						append_link(token.text,token.uri);
						append_text("\n");
					}
				} else {
					append_with_tag("[PARSER MISTAKE] Link without uri: "+token.text, parser_error_tag, true);
				}
				break;
			case ERROR:
				if (!token.inlined) { start_new_paragraph(); }
				append_with_tag(token.text, error_tag, token.preformatted);
				break;
			case TITLE:
				start_new_paragraph();
				switch (token.level) {
					case 0:
						append_h1(token.text+"\n");
						break;
					case 1:
						append_h2(token.text+"\n");
						break;
					default:
						append_h3(token.text+"\n");
						break;
				}
				break;
			case SEARCH:
				start_new_paragraph();
				if (token.uri != null) {
					var searchfield = new Dragonstone.GtkUi.Widget.InlineSearch(token.text, token.uri);
					searchfield.go.connect((s,uri) => {
						go(uri, false);
					});
					append_widget(searchfield);
				} else {
					append_with_tag("[PARSER MISTAKE] Search field without uri\n"+token.text+"\n", parser_error_tag, true);
				}
				break;
			case LIST_ITEM:
				start_new_paragraph();
				append_with_tag("▶ "+token.text+"\n", list_item_tag, token.preformatted);
				break;
			case QUOTE:
				if (!token.inlined) { start_new_paragraph(); }
				append_with_tag(token.text, quote_tag, token.preformatted);
				break;
			case PARSER_ERROR:
				append_with_tag("[PARSER ERROR] "+token.text, parser_error_tag, true);
				break;
			default:
				break;
		}
		switch (token.token_type) {
			case LINK:
				last_had_newline = (!token.inlined) || token.text.has_suffix("\n");
				break;
			case TITLE:
			case QUOTE:
			case LIST_ITEM:
			case SEARCH:
			case EMPTY_LINE:
				last_had_newline = true;
				break;
			default:
				last_had_newline = token.text.has_suffix("\n");
				break;
		}
	}
	
	public void reset_renderer(){
		this.textview.buffer.text = "";
	}
	
	  ///////////////////////////////////////////////
	 // Dragonstone.GtkUi.Widget.HyperTextContent //
	///////////////////////////////////////////////
	
	protected void append_with_tag(string text, Gtk.TextTag tag, bool preformatted = false){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		if (preformatted) {
			textview.buffer.insert_with_tags(ref end_iter, text, text.length, tag);
		} else {
			textview.buffer.insert_with_tags(ref end_iter, text, text.length, preformatted_tag, tag);
		}
	}
	
	public void append_h1(string text){
		append_with_tag(text,h1_tag);
	}
	
	public void append_h2(string text){
		append_with_tag(text,h2_tag);
	}
	
	public void append_h3(string text){
		append_with_tag(text,h3_tag);
	}
	
	public void append_link(string text, string uri, bool with_icon = true){
		Gtk.TextIter end_iter;
		//Insert Icon
		if (with_icon){
			var icon_name = Dragonstone.GtkUi.Util.DefaultGtkLinkIconLoader.guess_icon_name_for_uri(uri);
			// Old Icon code, can only show icons at caracter size
			var icon_theme = Gtk.IconTheme.get_for_screen(get_screen());
			if (!icon_theme.has_icon(icon_name)) {
				icon_name = "go-jump-symbolic";
			}
			if (icon_theme.has_icon(icon_name)){
				try{
					var icon_pixbuf = icon_theme.load_icon(icon_name, 20*this.scale_factor, Gtk.IconLookupFlags.FORCE_SYMBOLIC);
					if (icon_pixbuf != null){
						append_text(" ");
						textview.buffer.get_end_iter(out end_iter);
						textview.buffer.insert_pixbuf(end_iter,icon_pixbuf);
						append_text(" ");
						Gtk.TextIter pb_start_iter;
						textview.buffer.get_end_iter(out pb_start_iter);
						pb_start_iter.backward_chars(2);
						Gtk.TextIter pb_end_iter;
						textview.buffer.get_end_iter(out pb_end_iter);
						textview.buffer.apply_tag(h2_tag,pb_start_iter,pb_end_iter);
					}
				} catch(Error e){
					print(@"[hypertextcontent][error] error while loading icon $icon_name: $(e.message)\n");
				}
			}
			//var image = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
			//append_widget_inline(image);
			//append_text(" ");
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
	
	private string? last_tooltip_uri = null;
	private Gtk.TextIter? last_link_hover_start_iter = null;
	private Gtk.TextIter? last_link_hover_end_iter = null;
	
	private bool on_tooltip_query(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip){
		//print(@"tooltip $x $y $keyboard_tooltip\n");
		Gtk.TextIter? start_iter;
		Gtk.TextIter? end_iter;
		if (get_link_iters_at_window_location(x,y,out start_iter,out end_iter)){
			string? uri = get_link_uri(start_iter);
			//will break,when there are two links to the same uri above each other, but tis is for now acceptable
			//break means, it won't chane the highlighted uri
			bool update = false;
			if (uri != last_tooltip_uri){
				last_tooltip_uri = uri;
				update = true;
			}
			if (uri != null){
				if(update){
					clear_last_hover();
					textview.buffer.apply_tag(link_hover_tag,start_iter,end_iter);
					last_link_hover_start_iter = start_iter;
					last_link_hover_end_iter = end_iter;
				} else {
					tooltip.set_text(uri);
				}
				//print(@"TOOLTIP: $buffer_y/$buffer_x $uri\n");
				//link_tag.underline = Pango.Underline.SINGLE;
				return !update;
			}
		}
		clear_last_hover();
		last_tooltip_uri = null;
		//link_tag.underline = Pango.Underline.NONE;
		return false;
	}
	
	private void clear_last_hover(){
		if (last_link_hover_start_iter != null && last_link_hover_end_iter != null){
			textview.buffer.remove_tag(link_hover_tag,last_link_hover_start_iter,last_link_hover_end_iter);
		}
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
				last_touch_event_in_progress = false;
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
						print("[hypertextcontent][error] on_textview_touch() no uri found\n");
						return true;
					}
					go(uri,false);
				}
			}
		}
		return false;
	}
	
	private int max_distance_for_button_squared = 50;
	private bool last_button_event_in_progress = false;
	private int last_button_event_start_x = 0;
	private int last_button_event_start_y = 0;
	
	private bool on_link_tag_event(Object event_object, Gdk.Event event, Gtk.TextIter iter){
		if (event.get_event_type() == Gdk.EventType.BUTTON_PRESS){
			last_button_event_start_x = (int) event.button.x;
			last_button_event_start_y = (int) event.button.y;
			last_button_event_in_progress = true;
		}
		uint button;
		if (event.get_button(out button) && event.get_event_type() == Gdk.EventType.BUTTON_RELEASE){
			if (long_press) {
				long_press = false;
				last_button_event_in_progress = false;
				return true;
			}
			//print(@"BUTTON: $button\n");
			if (last_button_event_in_progress && (button == 1 || button == 2)){
				last_button_event_in_progress = false;
				double dx = event.button.x-last_button_event_start_x;
				double dy = event.button.y-last_button_event_start_y;
				int distance_squared = (int) ((dx*dx)+(dy*dy));
				print(@"D_button: $distance_squared ($dx,$dx)\n");
				if(distance_squared <= max_distance_for_button_squared){
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
		}
		return false;
	}
	
	//both iters are guaranteed to be non null if this returns true
	protected bool get_link_iters_at_window_location(int x, int y, out Gtk.TextIter? start_iter, out Gtk.TextIter? end_iter){
		start_iter = null;
		end_iter = null;
		int? buffer_x, buffer_y;
		textview.window_to_buffer_coords(Gtk.TextWindowType.TEXT, x, y, out buffer_x, out buffer_y);
		if (buffer_x != null && buffer_y != null){
			if (textview.get_iter_at_location(out start_iter,buffer_x,buffer_y)){
				if (!start_iter.starts_tag(link_tag)){
					start_iter.backward_to_tag_toggle(link_tag);
				}
				if (start_iter.starts_tag(link_tag)){
					end_iter = Gtk.TextIter();
					end_iter.assign(start_iter);
					end_iter.forward_to_tag_toggle(link_tag);
					return true;
				}
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
