public class Dragonstone.Util.ResourceFileWriteHelper : Object {
	
	private Dragonstone.Request request = null;
	private File file = null;
	private FileOutputStream outstream = null;
	public bool error = false;
	public bool cancelled = false;
	public bool closed = false;
	public int64 size = 0;
	public int64 progress = 0;
	public string filepath = null;
	
	public ResourceFileWriteHelper(Dragonstone.Request request, string filepath, int64 size){
		this.request = request;
		this.size = size;
		this.filepath = filepath;
		try {
			this.file = File.new_for_path(filepath);
			this.outstream = file.create(FileCreateFlags.PRIVATE);
		}catch(Error e){
			print(e.message);
			request.setStatus("error/internalError","Something went wrong wile opening "+filepath+":\n"+e.message);
			error = true;
			closed = true;
			return;
		}
		request.setStatus("loading","0/"+size.to_string("%x"));
	}
	
	public void append(uint8[] buffer){
		if (this.closed) {return;}
		try{
			this.outstream.write(buffer);
			this.progress += buffer.length;
			request.setStatus("loading",this.progress.to_string("%x")+"/"+this.size.to_string("%x"));
		}catch(Error e){
			request.setStatus("error/internalError","Something went wrong wile writing to "+filepath+":\n"+e.message);
			error = true;
			this.close();
		}
	}
	
	public void appendString(string buffer){
		this.append(buffer.data);
	}
	
	public void cancel(){
		if (this.closed) {return;}
		close();
		cancelled = true;
		request.setStatus("cancelled");
		try{
			file.delete();
		}catch(Error e){
			error = true;
			request.setStatus("error/internalError","Something went wrong wile deleting "+filepath+":\n"+e.message);
		}
	}
	
	public void close(){
		if (this.closed) {return;}
		this.closed = true;
		try {
			this.outstream.close();
		}catch(Error e){
			error = true;
			request.setStatus("error/internalError","Something went wrong wile closing "+filepath+":\n"+e.message);
		}
	}
}
