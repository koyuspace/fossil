public class Fossil.Util.Kv {
	public HashTable<string,string> values = new HashTable<string,string>(str_hash,str_equal);
	
	public static bool is_valid_key(string key){
		return !(key.contains("\n") || key.has_prefix("\t"));
	}
	
	public void import(string raw){
		string[] lines = raw.split("\n");
		string? multiline_key = null;
		string? multiline_value = null;
		foreach (string line in lines){
			string stripped_line = line.strip();
			if (line.has_prefix("\t")) {
				if (multiline_key != null){
					if (multiline_value != null){
						multiline_value += "\n"+line.substring(1);
					} else {
						multiline_value = line.substring(1);
					}
				}
			} else {
				if(stripped_line == ""){
					if (multiline_key != null){
						if (multiline_value != null){
							multiline_value += "\n";
						} else {
							multiline_value = "";
						}
					}
				} else {
					if (multiline_value != null){
						values.set(multiline_key,multiline_value);
					}
					multiline_key = stripped_line;
					multiline_value = null;
				}
			}
		}
		if (multiline_value != null){
			values.set(multiline_key,multiline_value);
		}
	}
	
	public string export(){
		string? export = null;
		values.foreach((key,val) => {
			if (is_valid_key(key)){
				if (export == null){
					export = "";
				} else {
					export += "\n";
				}
				export += key+"\n";
				export += "\t"+val.replace("\n","\n\t");
			}
		});
		if (export == null){
			export = "";
		}
		return export;
	}
	
	public bool set_if_null(string key, string val){
		if (!is_valid_key(key)){ return false; }
		if (values.get(key) == null){
			values.set(key,val);
			return true;
		}
		return false;
	}
	
	public bool set_value(string key, string val){
		if (!is_valid_key(key)){ return false; }
		values.set(key,val);
		return true;
	}
	
	public string? get_value(string key){
		if (!is_valid_key(key)){ return null; }
		return values.get(key);
	}
}
