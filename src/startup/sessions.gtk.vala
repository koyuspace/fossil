public class Dragonstone.Startup.Sessions.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][sessions] setup_views");
			view_registry.add_view("dragonstone.tls_session",() => {
				return new Dragonstone.View.TlsSession(translation);
			});
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/tls_session","dragonstone.tls_session"));
		}
	}
	
}
