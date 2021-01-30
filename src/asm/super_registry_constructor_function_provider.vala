public delegate Object Dragonstone.Asm.SuperRegistrySimpleConstructorFunction();

public class Dragonstone.Asm.SuperRegistrySimpleConstructorFunctionDescriptor : Dragonstone.Asm.FunctionDescriptor {
	
	Dragonstone.Asm.SuperRegistrySimpleConstructorFunction constructor_function;
	
	public SuperRegistrySimpleConstructorFunctionDescriptor(string name, owned Dragonstone.Asm.SuperRegistrySimpleConstructorFunction constructor_function){
		base.empty();
		this.constructor_function = (owned) constructor_function;
		this.name = name;
		this.callback = this.construct_object;
		this.localizable_helptext = "asm.help.cinstructor_simple";
		this.unlocalized_helptext = @"$name <name> Initalizes an object and stores it in the context at <name>";
	}
	
	private Dragonstone.Asm.Scriptreturn? construct_object(string _arg, Object? context = null){
		string arg = _arg.strip();
		if (arg == ""){
			return new Dragonstone.Asm.Scriptreturn.missing_argument();
		}
		Dragonstone.SuperRegistry? super_registry = (Dragonstone.SuperRegistry) context;
		if (super_registry == null){
			print(@"error while constructing $arg = new $name(): wrong context\n");
			return new Dragonstone.Asm.Scriptreturn.wrong_context("SuperRegistry");
		}
		print(@"constructing: $arg = new $name()\n");
		super_registry.store(arg,this.constructor_function());
		return null;
	}
}
