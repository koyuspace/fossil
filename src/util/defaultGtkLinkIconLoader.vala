public class Dragonstone.Util.DefaultGtkLinkIconLoader {

	//to be replaced in the near future by an icon registry
	public static string guess_icon_name_for_uri(string uri){
		if (uri.has_prefix("http")){ //move to before gopher when implemented
			return "text-html-symbolic";
		} else if (uri.has_prefix("mailto:")){
			return "mail-message-new-symbolic";
		} else if (uri.has_suffix("/")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".txt")){
			return "text-x-generic-symbolic";
		} else if (uri.has_suffix(".jpg")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".jpeg")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".png")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".bmp")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".gopher")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".gemini")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".tar")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".gz")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".xz")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".zip")){
			return "document-save-symbolic";
		} else if (uri.has_prefix("gopher://")){
			var slashindex = uri.index_of_char('/',10);
			if (slashindex < 0 || slashindex+1 >= uri.length){
				return "folder-symbolic";
			}
			var gophertype = uri.get(slashindex+1);
			if (gophertype == '0'){ //file
				return "text-x-generic-symbolic";
			} else if (gophertype == '1'){ //directory
				return "folder-symbolic";
			} else if (gophertype == '7'){ //search
				return "system-search-symbolic";
			} else if (gophertype == '9'){ //binary
				return "document-save-symbolic";
			} else if (gophertype == 'g'){ //gif
				return "image-x-generic-symbolic";
			} else if (gophertype == 'I'){ //image
				return "image-x-generic-symbolic";
			} else if (gophertype == 'p'){ //image
				return "image-x-generic-symbolic";
			}
		}
		return "go-jump-symbolic";
	}
	
}
