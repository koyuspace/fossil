public class Dragonstone.GtkUi.Widget.HyperTextContent : Dragonstone.GtkUi.Widget.TextContent, Dragonstone.Interface.Document.TokenRenderer {
	
	public HashTable<string,string> uris = new HashTable<string,string>(str_hash,str_equal);
	public signal void go(string uri, bool alt); //alt is true if the link was ctrl-clicked or middleclicked

	protected Dragonstone.GtkUi.Widget.LinkPopover? link_popover = null;
	protected Gtk.TextTag default_tag;	
	protected Gtk.TextTag link_tag;
	protected Gtk.TextTag link_hover_tag;
	protected Gtk.TextTag preformatted_tag;
	protected Gtk.TextTag link_icon_tag;
	
	private Gtk.GestureLongPress long_press_gesture;
	private bool long_press = false;
	
	public HashTable<string,Gtk.TextTag> text_tag_cache = new HashTable<string,Gtk.TextTag>(str_hash,str_equal);
	
	private Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? theme = null;
	
	public HyperTextContent(Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? _theme = null, Dragonstone.GtkUi.Widget.LinkPopover? link_popover = null){
		this.theme = _theme;
		this.link_popover = link_popover;
		/*
		try {
			Json.Parser parser = new Json.Parser();
			parser.load_from_data(temporary_style_json);
			var root_node = parser.get_root();
			if (root_node != null){
				if (root_node.get_node_type() == OBJECT) {
					var theme_object = root_node.get_object();
					theme = Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextViewTheme.hyper_text_view_theme_from_json(theme_object);
				}
			}
		} catch (Error e) {
			print("[hypertextcontent] Error while parsing theme json: "+e.message+"\n");
		}
		*/
		
		if(theme == null){ //fall back to an empty theme
			theme = new Dragonstone.GtkUi.Theming.HyperTextViewTheme();
		}
		
		//Register a custom style provider
		
		var default_tag_theme = theme.get_text_tag_theme("*");
		if (default_tag_theme != null) {
			if (default_tag_theme.paragraph_background_color != null || default_tag_theme.foreground_color != null){
				try {
					//print("[hypertextcontent] Adding style provider\n");
					var style_provider = new Gtk.CssProvider();
					string css = ".hypertext text {\n";
					if (default_tag_theme.foreground_color != null) {
						css += @"color: $(default_tag_theme.foreground_color);\n";
					}
					if (default_tag_theme.paragraph_background_color != null) {
						css += @"background-color: $(default_tag_theme.paragraph_background_color);\n";
					}
					css += "}";
					//print(@"$css\n");
					style_provider.load_from_data(css);
					textview.get_style_context().add_class("hypertext");
					textview.get_style_context().add_provider(style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
				} catch (Error e) {
					print("[hypertextcontent] Error while applying custom css: "+e.message+"\n");
				}
			}
		}
		
		default_tag = get_themed_tag("*");
		link_tag = get_themed_tag("*:link");
		link_hover_tag = get_themed_tag("link :hover");
		preformatted_tag = get_themed_tag("*:preformatted");
		link_icon_tag = get_themed_tag("link_icon");
		
		link_tag.event.connect(on_link_tag_event);
		
		/* Old styling, only kept for debugging
		link_hover_tag.underline = Pango.Underline.SINGLE;
		link_tag.underline = Pango.Underline.NONE;
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
		error_color.parse("#FB3934"); //Pretty sure nobody is using a red background anytime soon
		error_tag.foreground_rgba = error_color;
		parser_error_tag.foreground_rgba = error_color; 
		parser_error_tag.style = Pango.Style.ITALIC;
		*/
		
		if (default_tag.wrap_mode_set){
			textview.wrap_mode = default_tag.wrap_mode;
		} else {
			textview.wrap_mode = Gtk.WrapMode.WORD_CHAR;
		}
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
	
	 // Theme integration
	/////////////////////////////
	
	public Gtk.TextTag get_themed_tag_by_name(string tag_name, string? tag_table_name){
		string? _tag_table_name = tag_table_name;
		if (_tag_table_name == null) { _tag_table_name = tag_name; }
		Gtk.TextTag? tag = null;
		tag = textview.buffer.tag_table.lookup(_tag_table_name);
		if (tag == null) {
			tag = textview.buffer.create_tag(_tag_table_name);
			var tag_theme = theme.get_text_tag_theme(tag_name);
			if (tag_theme != null) {
				tag_theme.apply_theme(tag);
			}
		}
		return tag;
	}
	
	public Gtk.TextTag get_themed_tag(string cache_key){
		Gtk.TextTag? tag = text_tag_cache.get(cache_key);
		if (tag == null) {
			string tag_name = theme.get_best_matching_text_tag_theme_name(cache_key.split(" "));
			//print(@"[hypertextcontent] TAG $cache_key >>> $tag_name \n");
			tag = get_themed_tag_by_name(tag_name, (cache_key=="*:link"?cache_key:null));
			text_tag_cache.set(cache_key, tag);
		}
		return tag;
	}
	
	public void append_styled_text(string text, string class_name, bool preformatted, bool inlined, uint level, string? uri = null){
		if (text == "") { return; }
		string preformatted_variant = preformatted?":preformatted":":not_preformatted";
		string inline_variant = inlined?":inline":":paragraph";
		string theme_cache_key = @"$class_name $preformatted_variant $inline_variant +$level";
		string prefix_theme_cache_key = @"$theme_cache_key :prefix";
		string? prefix = null;
		if (inlined) {
			prefix = theme.get_prefix(@"$class_name :inline +$level");
			if (prefix == null) {
				prefix = theme.get_prefix(@"$class_name :inline");
			}
		}
		if (prefix == null) {
			prefix = theme.get_prefix(@"$class_name +$level");
		}
		if (prefix == null) {
			prefix = theme.get_prefix(class_name);
		}
		if (prefix == "{{{link_icon}}}") {
			if (uri != null){
				append_link_icon(uri);
			} else {
				append_link_icon(""); //dhould fail all tests and just display an arrow
			}
		} else if (prefix != null && prefix != ""){
			var prefix_tag = get_themed_tag(prefix_theme_cache_key);
			append_with_tag(prefix, prefix_tag, preformatted);
		}
		var text_tag = get_themed_tag(theme_cache_key);
		append_with_tag(text, text_tag, preformatted, uri);
	}
	
	  //////////////////////////////////////////////////
	 // Dragonstone.Interface.Document.TokenRenderer //
	//////////////////////////////////////////////////
	
	private bool last_had_newline = true;
	
	public void end_last_paragraph(){
		if (!last_had_newline) {
			append_text("\n");
			last_had_newline = true;
		}
	}
	
	public void append_token(Dragonstone.Ui.Document.Token token){
		if (!token.text.validate(token.text.length)) {
			append_styled_text("", "invalid_utf_8", token.preformatted, token.inlined, token.level);
		}
		bool inlined = token.inlined;
		bool preformatted = token.preformatted;
		string text = token.text;
		string class_name = "*";
		bool use_styled_text = true;
		switch(token.token_type){
			case EMPTY_LINE:
				text = "\n";
				class_name = "empty_line";
				inlined = false;
				preformatted = false;
				break;
			case LINK:
				if (token.uri == null) {
					use_styled_text = false;
					append_styled_text(token.text, "link_without_uri", true, false, token.level);
				} else {
					class_name = "link";
				}
				break;
			case SEARCH:
				use_styled_text = false;
				end_last_paragraph();
				if (token.uri != null) {
					var searchfield = new Dragonstone.GtkUi.Widget.InlineSearch(token.text, token.uri);
					searchfield.go.connect((s,uri) => {
						go(uri, false);
					});
					append_widget(searchfield);
				} else {
					append_styled_text(token.text, "link_without_uri", true, false, token.level);
				}
				break;
			case PARAGRAPH:
				class_name = "paragraph";
				break;
			case DESCRIPTION:
				class_name = "description";
				break;
			case ERROR:
				class_name = "error";
				break;
			case TITLE:
				class_name = "title";
				inlined = false;
				break;
			case LIST_ITEM:
				class_name = "list_item";
				inlined = false;
				break;
			case QUOTE:
				class_name = "quote";
				break;
			case PARSER_ERROR:
				class_name = "parser_error";
				preformatted = true;
				break;
			default:
				break;
		}
		if (use_styled_text) {
			if (!inlined) { end_last_paragraph(); }
			append_styled_text(text, class_name, preformatted, inlined, token.level, token.uri);
		}
		switch (token.token_type) {
			case LINK:
				if (!token.inlined) { append_text("\n"); }
				last_had_newline = (!token.inlined) || token.text.has_suffix("\n");
				break;
			case SEARCH:
			case EMPTY_LINE:
				last_had_newline = true;
				break;
			case LIST_ITEM:
			case QUOTE:
			case TITLE:
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
	
	protected void append_with_tag(string text, Gtk.TextTag tag, bool preformatted, string? uri = null){
		Gtk.TextIter start_iter;
		textview.buffer.get_end_iter(out start_iter);
		textview.buffer.insert_with_tags(ref start_iter, text, text.length, tag);
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		start_iter.backward_chars(text.char_count());
		if (preformatted) {
			textview.buffer.apply_tag(preformatted_tag, start_iter, end_iter);
		} else {
			textview.buffer.apply_tag(default_tag, start_iter, end_iter);
		}
		if (uri != null){
			textview.buffer.apply_tag(link_tag, start_iter, end_iter);
			//register uri
			string index = @"$(start_iter.get_line())/$(start_iter.get_line_offset())";
			//print(@"Adding link: $index $uri $text\n");
			uris.set(index,uri);
		}
	}
	
	public void append_link_icon(string uri){
		Gtk.TextIter end_iter;
		var icon_name = Dragonstone.GtkUi.Util.DefaultGtkLinkIconLoader.guess_icon_name_for_uri(uri);
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
					textview.buffer.apply_tag(link_icon_tag, pb_start_iter, pb_end_iter);
				}
			} catch(Error e){
				print(@"[hypertextcontent][error] error while loading icon $icon_name: $(e.message)\n");
			}
		}
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
	
	//TODO: Fix a small bug where when a link follows an empty line and starts at the beginning of the line the coordineates are off by one line
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
