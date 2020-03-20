public class Dragonstone.Store.About : Object, Dragonstone.ResourceStore {

	public void request(Dragonstone.Request request,string? filepath = null){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			return;
		}
		if (request.uri == "about:blank") {
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,filepath,0);
			helper.appendString("");
			if (helper.error){return;}
			helper.close();
			var resource = new Dragonstone.Resource(request.uri,filepath,true);
			resource.add_metadata("text/plain","Nothing");
			request.setResource(resource,"test");
		} else {
			request.setStatus("error/resourceUnavaiable");
		}
	}
}
