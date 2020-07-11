public class Dragonstone.AsmInit.Gopher.Type.Registry {
	public static void register_initalizer(string name,Dragonstone.Asm.SimpleAsmObject object){
		var desc = new Dragonstone.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			constr
		);
		object.add_asm_function(desc);
	}
	
	private static Object constr(){
		return new Dragonstone.Registry.GopherTypeRegistry();
	}
}
