public class Dragonstone.GtkUi.LegacyWidget.TextContent : Gtk.ScrolledWindow {
	public Gtk.TextView textview = null;
	
	construct {
		textview = new Gtk.TextView();
		textview.editable = false;
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		add(textview);
	}
	
	public void append_text(string text){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		textview.buffer.insert(ref end_iter,text,text.length);
	}
	
	public void append_widget(Gtk.Widget widget){
		append_widget_inline(widget);
		append_text("\n");
	}
	
	public void append_widget_inline(Gtk.Widget widget){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		var anchor = textview.buffer.create_child_anchor(end_iter);
		textview.add_child_at_anchor(widget,anchor);
	}
	
}
