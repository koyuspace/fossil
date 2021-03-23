public class Fossil.Startup.Upload.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Fossil.Registry.MimetypeGuesser);
		var tempfilebase = GLib.Environment.get_tmp_dir()+"/";
		if (view_registry != null && translation != null){
			print("[startup][upload][gtk] setup_views()\n");
			view_registry.add_view("upload.file",() => { return new Fossil.GtkUi.View.UploadFile(translation,mimeguesser); });
			view_registry.add_view("upload.text",() => {
				var tempfilepath = tempfilebase+"fossil_upload_"+GLib.Uuid.string_random();
				return new Fossil.GtkUi.View.UploadText(tempfilepath,translation,mimeguesser);
			});
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/upload","upload.file"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/upload/text","upload.text"));
		}
	}
}
