public class Dragonstone.Downloader : Object {
	public static async Dragonstone.DownloaderReturnCode save_resource(Dragonstone.Resource resource,string filepath){
		if (resource.filepath == null){
			return Dragonstone.DownloaderReturnCode.INCOMPATIBLE_RESOURCE; 
		}
		var sourcefile = File.new_for_path(resource.filepath);
		var file = File.new_for_path(filepath);
		if (file.query_exists ()) {
			print(@"There alsready is a file at $filepath, not downloading\n");
			return Dragonstone.DownloaderReturnCode.ALREADY_EXISTS;
		}
		try{
			if (!sourcefile.query_exists ()) {
				return Dragonstone.DownloaderReturnCode.NO_PERMISSION;
			}
			sourcefile.copy(file,FileCopyFlags.NONE);
		} catch (Error e){
			print(@"Something went wrong while downloading to $filepath\n$(e.message)\n");
			return Dragonstone.DownloaderReturnCode.ERROR;
		}
		return Dragonstone.DownloaderReturnCode.OK;
	}
}

public enum Dragonstone.DownloaderReturnCode {
	OK,
	ALREADY_EXISTS,
	NO_PERMISSION,
	ERROR,
	INCOMPATIBLE_RESOURCE
}
