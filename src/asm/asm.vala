public interface Dragonstone.Asm.ObjectProvider : Object {
	public abstract void foreach_asm_object(Func<string> cb); // iterates over all functions this object provides
	public abstract Dragonstone.Asm.AsmObject? get_asm_object(string name);
}

public interface Dragonstone.Asm.AsmObject : Object{
	public abstract void foreach_asm_function(Func<string> cb);
	//if returnvalue is null the command was executed successfully without anyreturn message
	public abstract Dragonstone.Asm.Scriptreturn? exec(string method, string arg);
	public abstract string? get_default_helptext(string method);
	public abstract string? get_unlocalized_helptext(string method);
}

public class Dragonstone.Asm.Scriptreturn : Object {
	public bool success = false;
	public bool syntax_error = false;
	public int line = 1;
	public string? instruction = null;
	public string? script_source = null;
	public string? messsage_unlocalized = null;
	public string? messsage_localizable = null;
	
	public Scriptreturn(bool success, string? messsage_unlocalized = null, string? messsage_localizable = null){
		this.success = success;
		this.messsage_unlocalized = messsage_unlocalized;
		this.messsage_localizable = messsage_localizable;
	}
}

public class Dragonstone.Asm.Scriptrunner : Object {
	public Dragonstone.Asm.ObjectProvider object_provider;
	
	public Scriptrunner(Dragonstone.Asm.ObjectProvider object_provider){
		this.object_provider;
	}
	
	//if returnvalue is null the command was executed successfully withou anyreturn message
	public Dragonstone.Asm.Scriptreturn? exec_line(string _line){
		string line = _line.strip();
		if (line.has_prefix("#") || line == ""){ return null; }
		string[] split = line.split("\t",2);
		string args;
		if (split.length == 2){
			args = split[1];
		} else {
			args = "";
		}
		string[] object_and_func = split[0].split(".",2);
		if (object_and_func.length != 2){
			var returnvalue = new Dragonstone.Asm.Scriptreturn(false,"No object specified!","asm.error.missing_object");
			returnvalue.syntax_error = true;
			returnvalue.instruction = line;
			return returnvalue;
		}
		string object_name = object_and_func[0];
		string function_name = object_and_func[1];
		Dragonstone.Asm.AsmObject? object = object_provider.get_asm_object(object_name);
		if (object == null){
			var returnvalue = new Dragonstone.Asm.Scriptreturn(false,@"Object $object_name does not exist!","asm.error.null_object");
			returnvalue.instruction = line;
			return returnvalue;
		}
		var returnvalue = object.exec(function_name,args);
		if (returnvalue != null){
			returnvalue.instruction = line;
		}
		return returnvalue;
	}
	
	public Dragonstone.Asm.Scriptreturn? exec_script(string script){
		int linenum = 0;
		Dragonstone.Asm.Scriptreturn? returnval = null;
		foreach(string line in script.split("\n")){
			returnval = this.exec_line(line);
			if (returnval != null){
				if (!returnval.success){
					return returnval;
				}
			}
			linenum++;
		}
		return returnval;
	}
}
