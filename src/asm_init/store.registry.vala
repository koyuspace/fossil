public class Dragonstone.AsmInit.Store.Registry {
	public static void register_initalizer(string name,Dragonstone.Asm.SimpleAsmObject object){
		object.add_asm_function(new Dragonstone.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			() => {
				return new Dragonstone.Registry.StoreRegistry();
			}
		));
	}
}
