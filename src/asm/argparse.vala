public class Dragonstone.Asm.Argparse : Object {
	
	public string[] arguments;
	
	public Argparse(string args){
		arguments = args.split("\t");
	}
	
	public uint length {
		get {
			return arguments.length;
		}
	}
	
	public string? get_string (uint argnum){
		if (argnum < this.length){
			return arguments[argnum];
		}else{
			return null;
		}
	}
}
