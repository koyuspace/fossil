public interface Dragonstone.IResourceData : Object {
	
	public virtual uint64 getDataSize(){
		uint64 size = 0;
		unowned List<Bytes>? list = getData();
		if(list == null){return 0;}
		foreach(unowned Bytes bytearray in list){
			size = size+bytearray.length;
		}
		return size;
	}
	
	public abstract unowned List<Bytes>? getData();
	
	public virtual string? getDataAsString(){
		unowned List<Bytes>? list = getData();
		if(list == null){return null;}
		string output = "";
		foreach(unowned Bytes bytes in list){
			if (bytes != null){
				output = output+((string) (bytes.get_data())).substring(0,bytes.length);
				//somethimes the buffers become a bit too long, until i have a proper
				//fix a substring should do the job
			}
		}
		return output;
	}
	
}
