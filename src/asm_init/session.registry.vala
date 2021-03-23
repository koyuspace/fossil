public class Fossil.AsmInit.Session.Registry {
	public static void register_initalizer(string name,Fossil.Asm.SimpleAsmObject object){
		object.add_asm_function(new Fossil.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			() => {
				return new Fossil.Registry.SessionRegistry();
			}
		));
	}
}
