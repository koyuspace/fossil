public class Dragonstone.Downloader : Object {
	public static async Dragonstone.DownloaderReturnCode save_resource(Dragonstone.Resource resource,string filepath){
		if (!(resource is Dragonstone.IResourceData ||
			resource is Dragonstone.IResourceText)){
			return Dragonstone.DownloaderReturnCode.INCOMPATIBLE_RESOURCE; 
		}
		var file = File.new_for_path (filepath);
		if (file.query_exists ()) {
			print(@"There alsready is a file at $filepath, not downloading\n");
			return Dragonstone.DownloaderReturnCode.ALREADY_EXISTS;
		}
		try{
			var file_stream = file.create (FileCreateFlags.NONE);
			if (!file.query_exists ()) {
				return Dragonstone.DownloaderReturnCode.NO_PERMISSION;
			}
			if (resource is Dragonstone.IResourceData){
				foreach (Bytes bytes in (resource as Dragonstone.IResourceData).getData()){
					yield file_stream.write_bytes_async(bytes);
				}
				return Dragonstone.DownloaderReturnCode.OK;
			} else if (resource is Dragonstone.IResourceText){
				var data_out = new DataOutputStream(file_stream);
				data_out.put_string((resource as Dragonstone.IResourceText).getText());
				return Dragonstone.DownloaderReturnCode.OK;
			} else {
				return Dragonstone.DownloaderReturnCode.INCOMPATIBLE_RESOURCE;
			}
		} catch (Error e){
			print(@"Something went wrong while downloading to $filepath\n$(e.message)\n");
			return Dragonstone.DownloaderReturnCode.ERROR;
		}
		
	}
}

public enum Dragonstone.DownloaderReturnCode {
	OK,
	ALREADY_EXISTS,
	NO_PERMISSION,
	ERROR,
	INCOMPATIBLE_RESOURCE
}
