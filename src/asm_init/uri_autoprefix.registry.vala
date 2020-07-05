public class Dragonstone.AsmInit.UriAutoprefix.Registry {
	public static void register_initalizer(string name,Dragonstone.Asm.SimpleAsmObject object){
		object.add_asm_function(new Dragonstone.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			() => {
				return new Dragonstone.Registry.UriAutoprefix();
			}
		));
	}
}
