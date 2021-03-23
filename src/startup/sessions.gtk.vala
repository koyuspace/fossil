public class Fossil.Startup.Sessions.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][sessions] setup_views");
			view_registry.add_view("fossil.tls_session",() => {
				return new Fossil.GtkUi.View.TlsSession(translation);
			});
			var no_session_configuration_view_factory = new Fossil.GtkUi.LegacyUtil.MessageViewFactory("error/uri/unknownScheme","action-unavailable-symbolic",translation,"view.no_session_panel.label","view.no_session_panel.sublabel");
			view_registry.add_view("fossil.no_session_panel",no_session_configuration_view_factory.construct_view);
			
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/tls_session","fossil.tls_session"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("error/uri/unknownScheme","fossil.no_session_panel").prefix("session://"));
		}
	}
	
}
