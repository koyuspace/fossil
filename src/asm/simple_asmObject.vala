public class Fossil.Asm.SimpleAsmObject : Object, Fossil.Asm.AsmObject {
	
	protected HashTable<string,Fossil.Asm.FunctionDescriptor> asm_functions = new HashTable<string,Fossil.Asm.FunctionDescriptor>(str_hash,str_equal);
	
	public void add_asm_function(Fossil.Asm.FunctionDescriptor function) {
		asm_functions.set(function.name,function);
	}
	
	public void foreach_asm_function(Func<string> cb){
		asm_functions.@foreach((name,_) => {
			cb(name);
		});
	}
	
	public Fossil.Asm.Scriptreturn? exec(string method, string arg, Object? context = null){
		var function = asm_functions.get(method);
		if (function != null){
			return function.callback(arg,context);
		}
		return new Fossil.Asm.Scriptreturn.unknown_function(method);
	}
	
	public string? get_localizable_helptext(string method){
		var function = asm_functions.get(method);
		if (function != null){
			return function.localizable_helptext;
		}
		return null;
	}
	
	public string? get_unlocalized_helptext(string method){
		var function = asm_functions.get(method);
		if (function != null){
			return function.unlocalized_helptext;
		}
		return null;
	}
}
