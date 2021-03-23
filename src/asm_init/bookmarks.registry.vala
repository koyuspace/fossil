public class Fossil.AsmInit.Bookmarks.Registry {
	public static void register_initalizer(string name,Fossil.Asm.SimpleAsmObject object){
		var desc = new Fossil.Asm.SuperRegistrySimpleConstructorFunctionDescriptor(
			name,
			constr
		);
		object.add_asm_function(desc);
	}
	
	private static Object constr(){
		return new Fossil.Registry.BookmarkRegistry();
	}
}
