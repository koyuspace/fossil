public class Dragonstone.Startup.Sessions.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][sessions] setup_views");
			view_registry.add_view("dragonstone.tls_session",() => {
				return new Dragonstone.GtkUi.View.TlsSession(translation);
			});
			var no_session_configuration_view_factory = new Dragonstone.GtkUi.Util.MessageViewFactory("error/uri/unknownScheme","action-unavailable-symbolic",translation,"view.no_session_panel.label","view.no_session_panel.sublabel");
			view_registry.add_view("dragonstone.no_session_panel",no_session_configuration_view_factory.construct_view);
			
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/tls_session","dragonstone.tls_session"));
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("error/uri/unknownScheme","dragonstone.no_session_panel").prefix("session://"));
		}
	}
	
}
