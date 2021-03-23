public class Fossil.Asm.Argparse : Object {
	
	public string[] arguments;
	
	public const uint TYPE_NULL = 1;
	public const uint TYPE_STRING = 2;
	public const uint TYPE_UINT = 4;
	
	public Argparse(string args){
		arguments = args.split("\t");
	}
	
	public uint length {
		get {
			return arguments.length;
		}
	}
	
	public string? get_string(uint argnum, string? _default = null){
		if (argnum < this.length){
			return arguments[argnum];
		} else {
			return _default;
		}
	}
	
	public uint64? get_uint(uint argnum, uint64? _default = null){
		string? text = get_string(argnum);
		if (text == null){ return _default; }
		uint64 val;
		if (Fossil.Util.Intparser.try_parse_unsigned(text, out val)){
			return val;
		}
		return _default;
	}
	
	public bool verify_argument(uint argnum, uint type){
		if (argnum >= this.length){
			return (type&TYPE_NULL) > 0;
		}
		bool passed = true;
		if ((type&TYPE_STRING) > 0){
			passed = passed && (get_string(argnum) != null);
		}
		if ((type&TYPE_UINT) > 0){
			passed = passed && (get_uint(argnum) != null);
		}
		return passed;
	}
	
	public static uint parse_type(string type){
		uint rettype = 0;
		foreach(string t in type.split("/")){
			if (t == "NULL"){
				rettype = rettype|TYPE_NULL;
			} else if (t == "STRING"){
				rettype = rettype|TYPE_STRING;
			} else if (t == "UINT"){
				rettype = rettype|TYPE_UINT;
			} 
		}
		return rettype;
	}
}
