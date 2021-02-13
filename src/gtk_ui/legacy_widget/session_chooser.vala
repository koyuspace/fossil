public class Dragonstone.GtkUi.LegacyWidget.SessionChooser : Gtk.ComboBoxText {
	private Dragonstone.GtkUi.LegacyWidget.Tab? tab = null;
	private bool tab_changing = false;
	
	public SessionChooser(){
		this.sensitive = false;
		this.changed.connect(on_change);
	}
	
	public void use_tab(Dragonstone.GtkUi.LegacyWidget.Tab? tab){
		tab_changing = true;
		if (this.tab != null){
			this.tab.on_session_change.disconnect(update_active_id);
		}
		this.tab = tab;
		if (this.tab != null){
			repopulate();
			this.tab.on_session_change.connect(update_active_id);
		} else {
			this.sensitive = false;
		}
		tab_changing = false;
	}
	
	public void repopulate(){
		this.sensitive = false;
		this.remove_all();
		if (this.tab != null){
			foreach (string key in this.tab.session_registry.sessions.get_keys()){
				Dragonstone.Interface.Session? session = this.tab.session_registry.sessions.get(key);
				if (session != null){
					this.append(key,@"$(session.get_name()) [$key]");
				}
			}
			update_active_id();
			this.sensitive = true;
		}
	}
	
	public void update_active_id(){
		if (this.tab != null){
			this.set_active_id(this.tab.current_session_id);
		}
	}
	
	private void on_change(){
		if (this.tab != null && !tab_changing){
			string? id = this.get_active_id();
			if (id != null && id != tab.current_session_id){
				this.tab.set_tab_session(id);
			}
		}
	}
}
