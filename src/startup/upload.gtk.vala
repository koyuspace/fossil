public class Dragonstone.Startup.Upload.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Dragonstone.Registry.MimetypeGuesser);
		var tempfilebase = GLib.Environment.get_tmp_dir()+"/";
		if (view_registry != null && translation != null){
			print("[startup][upload][gtk] setup_views()\n");
			view_registry.add_view("upload.file",() => { return new Dragonstone.View.UploadFile(translation,mimeguesser); });
			view_registry.add_view("upload.text",() => {
				var tempfilepath = tempfilebase+"dragonstone_upload_"+GLib.Uuid.string_random();
				return new Dragonstone.View.UploadText(tempfilepath,translation,mimeguesser);
			});
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/upload","upload.file"));
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/upload/text","upload.text"));
		}
	}
}