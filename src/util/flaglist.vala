public class Fossil.Util.Flaglist : Object {
	public List<string> flags = new List<string>();
	
	public void set_flag(string flag, bool state = true){
		if (state) {
			lock(flags) {
				if (!has_flag(flag)){
					flags.append(flag);
				}
			}
		} else {
			this.clear_flag(flag);
		}
	}
	
	public void clear_flag(string flag){
		if (has_flag(flag)){
			unowned List<string>? link = flags.find_custom(flag,(a,b) => {
				if(a==b){ return 0; }
				return 1;
			});
			flags.delete_link(link);
		}
	}
	
	public bool has_flag(string flag){
		foreach( string f in flags ) {
			if (f==flag) {return true;}
		}
		return false;
	}
}
