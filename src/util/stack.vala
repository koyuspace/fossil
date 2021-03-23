public class Fossil.Util.Stack<G> : Object{
	
	public List<G> list = new List<G>();
	
	public void push(G thingy){
		list.append(thingy);
	}
	
	public G pop(){
		unowned List<G> entry = list.last();
		if(entry == null){ return null; }
		list.remove_link (entry);
		return entry.data;
	}
	
	public void clear(){
		if (list.length()>0){
			list = new List<G>();
		}
	}
	
	public uint size(){
		return list.length();
	}
	
}
