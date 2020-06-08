public class Dragonstone.View.TlsSession : Gtk.ScrolledWindow, Dragonstone.IView{

	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.Session.Tls? session = null;
	
	private Dragonstone.Widget.MenuSwitch cache_switch;
	private Gtk.Button generate_certificate_button;
	private Gtk.TextView certificate_pem_text;
	
	private Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
	
	public TlsSession(Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status == "interactive/tls_session")) {return false;}
		this.request = request;
		this.tab = tab;
		session = tab.session as Dragonstone.Session.Tls;
		if (session != null){
			appendWidget(new Gtk.Label(translation.localize("view.session.tls.title")));
			var localizd_name_entry_placeholder = translation.localize("view.session.tls.name_entry.placeholder");
			var name_entry = new Dragonstone.Widget.TextEntrySingleLine(localizd_name_entry_placeholder,session.get_name(),"go-jump-symbolic");
			name_entry.submit.connect((name) => {
				if (name != ""){
					session.set_name(name);
				}
			});
			appendWidget(name_entry);
			appendWidget(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
			var cache_switch_localized = translation.localize("view.session.tls.cache_switch.label");
			cache_switch = new Dragonstone.Widget.MenuSwitch(cache_switch_localized);
			cache_switch.switch_widget.set_state(session.use_cache);
			session.notify["use_cache"].connect(update_cache_button);
			cache_switch.switch_widget.state_set.connect( e => {
				session.use_cache = cache_switch.switch_widget.get_state();
				return false;
			});
			appendWidget(cache_switch);
			var cachelink_loclized = translation.localize("view.session.tls.view_cache.label");
			var cachelink = new Dragonstone.Widget.LinkButton(tab,cachelink_loclized,"about:cache");
			cachelink.set_relief(Gtk.ReliefStyle.NORMAL);
			appendWidget(cachelink);
			appendWidget(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
			var generate_new_certificate_localized = translation.localize("view.session.tls.generate_new_certificate.label");
			generate_certificate_button = new Gtk.Button.with_label(generate_new_certificate_localized);
			generate_certificate_button.clicked.connect(() => {
				generate_certificate_button.sensitive = false;
				generate_new_certificate();
			});
			generate_certificate_button.get_style_context().add_class("destructive-action");
			appendWidget(generate_certificate_button);
			var clear_certificate_localized = translation.localize("view.session.tls.clear_certificate.label");
			var clear_certificate_button = new Gtk.Button.with_label(clear_certificate_localized);
			clear_certificate_button.clicked.connect(() => {
				session.tls_certificate_pems = null;
			});
			clear_certificate_button.get_style_context().add_class("destructive-action");
			appendWidget(clear_certificate_button);
			appendWidget(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
			certificate_pem_text = new Gtk.TextView();
			certificate_pem_text.monospace = true;
			certificate_pem_text.buffer.text = "";
			var get_pem_localized = translation.localize("view.session.tls.get_pem.label");
			var no_certificate_placeholder = translation.localize("view.session.tls.no_certificate.placeholder");
			var get_pem_button = new Gtk.Button.with_label(get_pem_localized);
			get_pem_button.clicked.connect(() => {
				if (session.tls_certificate_pems != null){
					certificate_pem_text.buffer.text = session.tls_certificate_pems;
				} else {
					certificate_pem_text.buffer.text = no_certificate_placeholder;
				}
			});
			appendWidget(get_pem_button);
			
			var set_pem_localized = translation.localize("view.session.tls.set_pem.label");
			var set_pem_button = new Gtk.Button.with_label(set_pem_localized);
			set_pem_button.clicked.connect(() => {
				if (certificate_pem_text.buffer.text != ""){
					session.tls_certificate_pems = certificate_pem_text.buffer.text;
				} else {
					session.tls_certificate_pems = null;
				}
			});
			set_pem_button.get_style_context().add_class("suggested-action");
			appendWidget(set_pem_button);
			var pem_certificate_purpose_localized = translation.localize("view.session.tls.pemview.label");
			appendWidget(new Gtk.Label(pem_certificate_purpose_localized));
			appendWidget(certificate_pem_text);
		} else {
			appendWidget(new Gtk.Label(translation.localize("view.session.tls.not_a_tls_session")));
		}
		
		box.homogeneous = false;
		add(box);
		show_all();
		return true;
	}
	
	private void update_cache_button(){
		print("update cache switch\n");
		cache_switch.switch_widget.set_active(session.use_cache);
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/tls_session";
		}
	}
	
	private void appendWidget(Gtk.Widget widget){
		box.pack_start(widget);
		box.set_child_packing(widget,false,false,1,Gtk.PackType.START);
	}
	
	private void generate_new_certificate(){
		lock(generate_certificate_button){
			var pems = Dragonstone.Util.TlsCertficateGenerator.generate_signed_certificate_key_pair_pem();
			if (pems != null){
				session.tls_certificate_pems = pems;
			}
			generate_certificate_button.sensitive = true;
		}
	}
	
	public void cleanup(){
		if (session != null){
			session.notify["use_cache"].disconnect(update_cache_button);
		}
	} 
}
