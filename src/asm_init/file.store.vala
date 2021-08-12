public class Fossil.AsmInit.File.Store {
	public static void register_initializer(string name,Fossil.Asm.SimpleAsmObject object){
		var desc = new Fossil.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			constr
		);
		object.add_asm_function(desc);
	}
	
	private static Object constr(){
		return new Fossil.Store.File();
	}
}
