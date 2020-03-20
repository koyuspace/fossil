public class Dragonstone.Widget.TextContent : Gtk.ScrolledWindow {
	public Gtk.TextView textview = null;
	
	construct {
		textview = new Gtk.TextView();
		textview.editable = false;
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		add(textview);
	}
	
	public void appendText(string text){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		textview.buffer.insert(ref end_iter,text,text.length);
	}
	
	public void appendWidget(Gtk.Widget widget){
		appendWidgetInline(widget);
		appendText("\n");
	}
	
	public void appendWidgetInline(Gtk.Widget widget){
		Gtk.TextIter end_iter;
		textview.buffer.get_end_iter(out end_iter);
		var anchor = textview.buffer.create_child_anchor(end_iter);
		textview.add_child_at_anchor(widget,anchor);
	}
	
}
