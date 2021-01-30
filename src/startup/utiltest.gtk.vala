public class Dragonstone.Startup.Utiltest.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		if (view_registry != null){
			print("[startup][utiltest] setup_views()\n");
			view_registry.add_view("uri_merge_test",() => { return new Dragonstone.GtkUi.View.UriMergeTest(); });
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/uri_merge_test","uri_merge_test"));
		}
	}
}
