public delegate Object Fossil.Asm.SuperRegistrySimpleConstructorFunction();

public class Fossil.Asm.SuperRegistrySimpleConstructorFunctionDescriptor : Fossil.Asm.FunctionDescriptor {
	
	Fossil.Asm.SuperRegistrySimpleConstructorFunction constructor_function;
	
	public SuperRegistrySimpleConstructorFunctionDescriptor(string name, owned Fossil.Asm.SuperRegistrySimpleConstructorFunction constructor_function){
		base.empty();
		this.constructor_function = (owned) constructor_function;
		this.name = name;
		this.callback = this.construct_object;
		this.localizable_helptext = "asm.help.cinstructor_simple";
		this.unlocalized_helptext = @"$name <name> Initalizes an object and stores it in the context at <name>";
	}
	
	private Fossil.Asm.Scriptreturn? construct_object(string _arg, Object? context = null){
		string arg = _arg.strip();
		if (arg == ""){
			return new Fossil.Asm.Scriptreturn.missing_argument();
		}
		Fossil.SuperRegistry? super_registry = (Fossil.SuperRegistry) context;
		if (super_registry == null){
			print(@"error while constructing $arg = new $name(): wrong context\n");
			return new Fossil.Asm.Scriptreturn.wrong_context("SuperRegistry");
		}
		print(@"constructing: $arg = new $name()\n");
		super_registry.store(arg,this.constructor_function());
		return null;
	}
}
