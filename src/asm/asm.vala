public interface Dragonstone.Asm.ObjectProvider : Object {
	public abstract void foreach_asm_object(HFunc<string,Dragonstone.Asm.AsmObject> cb); // iterates over all functions this object provides
	public abstract Dragonstone.Asm.AsmObject? get_asm_object(string name);
}

public interface Dragonstone.Asm.AsmObject : Object{
	public abstract void foreach_asm_function(Func<string> cb);
	//if returnvalue is null the command was executed successfully without anyreturn message
	public abstract Dragonstone.Asm.Scriptreturn? exec(string method, string arg, Object? context = null);
	public abstract string? get_localizable_helptext(string method);
	public abstract string? get_unlocalized_helptext(string method);
}

public class Dragonstone.Asm.Scriptreturn : Object {
	public bool success = false;
	public bool stop = false; //if set the script is supposed to exit (independant of the success value)
	public bool syntax_error = false;
	public int line = 1;
	public string? instruction = null;
	public string? script_source = null;
	public string? message_unlocalized = null;
	public string? message_localizable = null;
	
	public Scriptreturn(bool success, string? message_unlocalized = null, string? message_localizable = null){
		this.success = success;
		this.stop = !success;
		this.message_unlocalized = message_unlocalized;
		this.message_localizable = message_localizable;
	}
	
	public Scriptreturn stop_script(){
		this.stop = true;
		return this;
	}
	
	public string to_string(){
		string output = "";
		if (!success) {
			output += @"Error [$line]";
		} else {
			output += @"Ok    [$line]";
		}
		if (instruction != null){
			output+=@" | $instruction";
		}
		if (message_unlocalized != null){
			output+=@" : $message_unlocalized";
		}
		return output+"\n";
	}
	
	public Scriptreturn.unknown_function(string function_name = ""){
		this.message_unlocalized = @"Unknown function: $function_name";
		this.message_localizable = "asm.error.unknown_function";
	}
	
	public Scriptreturn.missing_argument(){
		this.message_unlocalized = @"Missing argument! (see help and documentation)";
		this.message_localizable = "asm.error.missing_argument";
	}
	
	public Scriptreturn.too_many_arguments(){
		this.message_unlocalized = @"Too many argument! (see help and documentation)";
		this.message_localizable = "asm.error.too_many_arguments";
	}
	
	public Scriptreturn.wrong_context(string expected_context){
		this.message_unlocalized = @"This function needs a $expected_context context to work";
		this.message_localizable = "asm.error.wrong_context";
	}
}

public class Dragonstone.Asm.Scriptrunner : Object {
	public Dragonstone.Asm.ObjectProvider object_provider;
	public Dragonstone.Asm.AsmObject? default_object = null;
	
	public Scriptrunner(Dragonstone.Asm.ObjectProvider object_provider, Dragonstone.Asm.AsmObject? default_object = null){
		this.object_provider = object_provider;
		this.default_object = null;
	}
	
	//if returnvalue is null the command was executed successfully without any return message
	//[<object>:]<function>[<\t>arguments]
	//#[<comment>]
	public Dragonstone.Asm.Scriptreturn? exec_line(string _line, Object? context = null){
		string line = _line.strip();
		if (line.has_prefix("#") || line == ""){ return null; }
		string[] split = line.split("\t",2);
		string args;
		if (split.length == 2){
			args = split[1];
		} else {
			args = "";
		}
		string[] object_and_func = split[0].split(":",2);
		Dragonstone.Asm.AsmObject? object = null;
		string function_name = "";
		if (object_and_func.length != 2){
			if (default_object != null){
				object = default_object;
				function_name = object_and_func[0];
			} else {
				var returnvalue = new Dragonstone.Asm.Scriptreturn(false,"No object specified!","asm.error.missing_object");
				returnvalue.syntax_error = true;
				returnvalue.instruction = line;
				return returnvalue;
			}
		} else {
			string object_name = object_and_func[0];
			function_name = object_and_func[1];
			object = object_provider.get_asm_object(object_name);
			if (object == null){
				var returnvalue = new Dragonstone.Asm.Scriptreturn(false,@"Object $object_name does not exist!","asm.error.null_object");
				returnvalue.instruction = line;
				return returnvalue;
			}
		}
		var returnvalue = object.exec(function_name,args,context);
		if (returnvalue != null){
			returnvalue.instruction = line;
		}
		return returnvalue;
	}
	
	public Dragonstone.Asm.Scriptreturn? exec_script(string script, Object? context = null){
		int linenum = 0;
		Dragonstone.Asm.Scriptreturn? returnval = null;
		foreach(string line in script.split("\n")){
			returnval = this.exec_line(line,context);
			if (returnval != null){
				if (!returnval.success || returnval.stop){
					return returnval;
				}
			}
			linenum++;
		}
		return returnval;
	}
}

public delegate Dragonstone.Asm.Scriptreturn? Dragonstone.Asm.Function(string arg, Object? context = null);

public class Dragonstone.Asm.FunctionDescriptor : Object {
	public Dragonstone.Asm.Function callback = dummy_callback;
	public string name = "";
	public string localizable_helptext = "";
	public string unlocalized_helptext = "";
	
	private static Dragonstone.Asm.Scriptreturn? dummy_callback(string arg, Object? context){
		return null;
	}
	
	public FunctionDescriptor.empty(){}
	
	public FunctionDescriptor(owned Dragonstone.Asm.Function callback, string name, string localizable_helptext, string unlocalized_helptext){
		this.callback = (owned) callback;
		this.name = name;
		this.localizable_helptext = localizable_helptext;
		this.unlocalized_helptext = unlocalized_helptext;
	}
}
