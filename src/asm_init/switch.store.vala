public class Dragonstone.AsmInit.Switch.Store {
	public static void register_initalizer(string name,Dragonstone.Asm.SimpleAsmObject object){
		var desc = new Dragonstone.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			constr
		);
		object.add_asm_function(desc);
	}
	
	private static Object constr(){
		return new Dragonstone.Store.Switch.default_configuration();
	}
}