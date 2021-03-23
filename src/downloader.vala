public class Fossil.Downloader : Object {
	public static async Fossil.DownloaderReturnCode save_resource(Fossil.Resource resource,string filepath){
		if (resource.filepath == null){
			return Fossil.DownloaderReturnCode.INCOMPATIBLE_RESOURCE; 
		}
		var sourcefile = File.new_for_path(resource.filepath);
		var file = File.new_for_path(filepath);
		if (file.query_exists ()) {
			print(@"[download][error] There alsready is a file at $filepath, not downloading\n");
			return Fossil.DownloaderReturnCode.ALREADY_EXISTS;
		}
		try{
			if (!sourcefile.query_exists ()) {
				return Fossil.DownloaderReturnCode.NO_PERMISSION;
			}
			sourcefile.copy(file,FileCopyFlags.NONE);
		} catch (Error e){
			print(@"[download][error] Something went wrong while downloading to $filepath\n$(e.message)\n");
			return Fossil.DownloaderReturnCode.ERROR;
		}
		return Fossil.DownloaderReturnCode.OK;
	}
}

public enum Fossil.DownloaderReturnCode {
	OK,
	ALREADY_EXISTS,
	NO_PERMISSION,
	ERROR,
	INCOMPATIBLE_RESOURCE
}
