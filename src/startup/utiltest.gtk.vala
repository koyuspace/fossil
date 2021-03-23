public class Fossil.Startup.Utilfossil.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		if (view_registry != null){
			print("[startup][utilfossil] setup_views()\n");
			view_registry.add_view("uri_merge_fossil",() => { return new Fossil.GtkUi.View.UriMergeInternal(); });
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/uri_merge_fossil","uri_merge_fossil"));
		}
	}
}
