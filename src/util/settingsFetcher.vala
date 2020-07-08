public class Dragonstone.Util.SettingsFetcher {
	public static Dragonstone.Settings.Rom? fetch_settings_rom_from_superregistry(string id,  Dragonstone.SuperRegistry super_registry, out Dragonstone.Asm.Scriptreturn? error = null){
		string[] split = id.split(":",2);
		if (split.length != 2){
			error = new Dragonstone.Asm.Scriptreturn(false,@"Invalid settings Id: missing provider '$id'","util.settings_fetcher.fetch_settings_rom_from_superregistry.asm.error.missng_provider_name");
			return null;
		}
		string provider_name = split[0];
		string rom_name = split[1];
		Dragonstone.Settings.Provider? provider = (Dragonstone.Settings.Provider) super_registry.retrieve(provider_name);
		if (provider == null){
			error = new Dragonstone.Asm.Scriptreturn(false,@"No settings provider found at '$provider_name'","util.settings_fetcher.fetch_settings_rom_from_superregistry.asm.error.provider_not_found");
			return null;
		}
		Dragonstone.Settings.Rom? rom = provider.get_object(rom_name);
		if (rom == null){
			error = new Dragonstone.Asm.Scriptreturn(false,@"No settings rom found at '$id'","util.settings_fetcher.fetch_settings_rom_from_superregistry.asm.error.rom_not_found");
			return null;
		}
		error = null;
		return rom;
	}
}
