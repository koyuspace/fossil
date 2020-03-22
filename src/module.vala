public class Dragonstone.ModuleRegistry : Object {
	private List<Dragonstone.IModule> modules	= new List<Dragonstone.IModule>();
	private List<Dragonstone.IModuleFactory> module_factories = new List<Dragonstone.IModuleFactory>();
	private List<string> loading_modules = new List<string>();
	
	//Signals
	public signal void shutdown(); //shutdown all modules
	public signal void factory_added(string module_type);
	public signal void module_loaded(string module_type);
	public signal void module_shutdown(string module_type);
	
	public bool add_factory(Dragonstone.IModuleFactory factory){
		if (has_factory(factory.module_type)) { return false; }
		module_factories.append(factory);
		factory_added(factory.module_type);
		return true;
	}
	
	public bool has_factory(string module_type){
		foreach (Dragonstone.IModuleFactory factory in module_factories){
			if (factory.module_type == module_type){
				return true;
			}
		}
		return false;
	}
	
	public Dragonstone.IModuleFactory? get_factory(string module_type){
		foreach (Dragonstone.IModuleFactory factory in module_factories){
			if (factory.module_type == module_type){
				return factory;
			}
		}
		return null;
	}
	
	public bool is_module_loaded(string module_type){
		foreach (Dragonstone.IModule module in modules){
			if (module.module_type == module_type){
				return true;
			}
		}
		return false;
	}
	
	public Dragonstone.IModule? get_module(string module_type){
		foreach (Dragonstone.IModule module in modules){
			if (module.module_type == module_type){
				return module;
			}
		}
		return null;
	}
	
	public bool insert_and_initalize_module(Dragonstone.Module module){
		if (module.initalize(this)) {
			modules.append(module);
			return true;
		}
		return false;
	}
	
	public Dragonstone.ModuleLoadError? load_module(string module_type){
		var factory = get_factory(module_type);
		if (factory == null) { return new Dragonstone.ModuleLoadError.no_factory(module_type);}
		if (loading_modules.index(module_type) >= 0){
			return new Dragonstone.ModuleLoadError.recursive_dependancy(module_type);
		}
		loading_modules.append(module_type);
		Dragonstone.ModuleLoadError? error = null;
		foreach(string m_type in factory.module_dependencies){
			error = load_module(m_type);
			if (error != null){
				break;
			}
		}
		if (error == null) {
			var module = factory.makeModule();
			if (!insert_and_initalize_module(module)) {
				error = new Dragonstone.ModuleLoadError.initalization_failed(module_type);
			}
		}
		loading_modules.remove(module_type);
		if(error == null){
			module_loaded(module_type);
		}
		return error;
	}
	
	public bool shutdown_module(string module_type){
		var module = get_module(module_type);
		if (module == null){ return false; }
		module.shutdown();
		module_shutdown(module_type);
		return true;
	}
	
}

public enum Dragonstone.ModuleLoadErrors {
	NO_FACTORY,
	RECURSIVE_DEPENDANCY,
	INITALIZATION_FAILED;
	
	public string to_string() {
		switch (this) {
			case NO_FACTORY:
				return "No Factory found!";
			case RECURSIVE_DEPENDANCY:
				return "Recursive dependancy found!";
			default:
				assert_not_reached();
		}
	}
}

public class Dragonstone.ModuleLoadError : Object{
	public string module_type { get; protected set; }
	public Dragonstone.ModuleLoadErrors error { get; protected set; }
	
	public ModuleLoadError.no_factory(string module_type){
		this.module_type = module_type;
		this.error = Dragonstone.ModuleLoadErrors.NO_FACTORY;
	}
	
	public ModuleLoadError.recursive_dependancy(string module_type){
		this.module_type = module_type;
		this.error = Dragonstone.ModuleLoadErrors.RECURSIVE_DEPENDANCY;
	}
	
	public ModuleLoadError.initalization_failed(string module_type){
		this.module_type = module_type;
		this.error = Dragonstone.ModuleLoadErrors.INITALIZATION_FAILED;
	}
	
	public string to_string(){
		return @"Error while lodig '$module_type': $error";
	}
	
}

//the actual module, that does the work
public abstract class Dragonstone.IModule : Object {
	public string module_type { get; construct; }
	public signal void on_shutdown(); //hook on dependencies to perform self shutdown
	public abstract bool initalize(Dragonstone.ModuleRegistry registry); //initalizes the module, returns true on success
	public abstract void shutdown(); //makes the module cancel all ongoing operations, and unhook it from all external things
}

// the module factory
public abstract class Dragonstone.IModuleFactory : Object {
	public string module_type { get; construct; }
	public abstract string[] module_dependencies { get; construct; }
	public abstract Dragonstone.IModule makeModule(); //makes a new module
}
