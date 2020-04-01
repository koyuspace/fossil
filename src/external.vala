public class Dragonstone.External {

	public static void open_uri(string uri){
		try {
			Pid child_pid;
			GLib.Process.spawn_async (null, {"xdg-open",uri}, null, GLib.SpawnFlags.SEARCH_PATH, null, out child_pid);
		} catch (Error e){
			print(@"Error while spawing xdg-open: $(e.message)\n");
		}
	}
	
	public static void open_file(string filepath){
		try {
			Pid child_pid;
			GLib.Process.spawn_async (null, {"xdg-open",filepath}, null, GLib.SpawnFlags.SEARCH_PATH, null, out child_pid);
		} catch (Error e){
			print(@"Error while spawing xdg-open: $(e.message)\n");
		}
	}
}
