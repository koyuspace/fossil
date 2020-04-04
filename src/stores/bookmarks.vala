public class Dragonstone.Store.Bookmarks :  Object, Dragonstone.ResourceStore {
	public void request(Dragonstone.Request request,string? filepath = null){
		if (request.uri == "about:bookmarks/" || request.uri == "about:bookmarks") {
			request.setStatus("interactive/bookmark_folders");
		} else if (request.uri.has_prefix("about:bookmarks/")) {
			request.setStatus("interactive/bookmarks",request.uri.substring(request.uri.index_of_char('/')+1));
		} else {
			request.setStatus("error/resourceUnavaiable");
		}
	}
}
