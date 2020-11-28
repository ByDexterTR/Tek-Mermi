#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

ConVar g_Flag = null;
bool BunnyAktifmi = true, SadeHsmi = true, Oyun = false, Sekmeme = false, Gravity = false, KillAldi[MAXPLAYERS] =  { false, ... };
int Hangisilah = 1, sure = -1;
float Player_Speed = 1.0;
Handle h_timer = null;
int weaponEnt = -1;

public Plugin myinfo = 
{
	name = "Tek Mermi", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	g_Flag = CreateConVar("sm_tekmermi_flag", "f", "Komutçu harici kimler kullanabilsin");
	
	RegConsoleCmd("sm_tekmermi", Command_TekMermi);
	RegConsoleCmd("sm_tekmermi0", Command_TekMermi0);
	HookEvent("round_start", RoundStartEnd);
	HookEvent("round_end", RoundStartEnd);
	HookEvent("weapon_fire", WeaponFire);
	HookEvent("player_death", OnClientDead);
	AutoExecConfig(true, "Tek-Mermi", "ByDexter");
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		OnClientPostAdminCheck(i);
}

public void OnPluginEnd() { Duzelt(); }

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyun)
	{
		Duzelt();
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (Oyun)
	{
		if (damagetype & DMG_SLASH)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action Command_TekMermi0(int client, int args)
{
	char Yetkiliflag[4];
	g_Flag.GetString(Yetkiliflag, sizeof(Yetkiliflag));
	if (warden_iswarden(client) || CheckAdminFlag(client, Yetkiliflag))
	{
		if (Oyun)
		{
			Duzelt();
			PrintToChatAll("[SM] \x01Tek Mermi \x10%N \x01tarafından durduruldu!", client);
			return Plugin_Handled;
		}
		else
		{
			ReplyToCommand(client, "[SM] Tek Mermi oyunu zaten aktif değil!");
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

public Action Command_TekMermi(int client, int args)
{
	char Yetkiliflag[4];
	g_Flag.GetString(Yetkiliflag, sizeof(Yetkiliflag));
	if (warden_iswarden(client) || CheckAdminFlag(client, Yetkiliflag))
	{
		if (!Oyun)
		{
			Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			return Plugin_Handled;
		}
		else
		{
			ReplyToCommand(client, "[SM] Oyun zaten aktif: sm_tekmermi0");
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

Menu Menu_TekMermi()
{
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n   ★ Tek Mermi - Ayarlar ★\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	
	menu.AddItem("0", "→ Oyunu Başlat!");
	
	if (BunnyAktifmi)
		menu.AddItem("1", "→ Bunny: Aktif");
	else
		menu.AddItem("1", "→ Bunny: Devredışı");
	
	if (SadeHsmi)
		menu.AddItem("2", "→ Sadece HS: Aktif");
	else
		menu.AddItem("2", "→ Sadece HS: Devredışı");
	
	if (Hangisilah == 1)
		menu.AddItem("3", "→ Silah: Ak47");
	else if (Hangisilah == 2)
		menu.AddItem("3", "→ Silah: M4a4");
	else if (Hangisilah == 3)
		menu.AddItem("3", "→ Silah: M4a1-s");
	else if (Hangisilah == 4)
		menu.AddItem("3", "→ Silah: Famas");
	else if (Hangisilah == 5)
		menu.AddItem("3", "→ Silah: Deagle");
	
	if (Sekmeme)
		menu.AddItem("4", "→ Sekmeme: Açık");
	else
		menu.AddItem("4", "→ Sekmeme: Kapat");
	
	if (Gravity)
		menu.AddItem("5", "→ Gravity: Açık\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	else
		menu.AddItem("5", "→ Gravity: Kapat\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	
	menu.ExitBackButton = false;
	menu.ExitButton = true;
	
	return menu;
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		if (!Oyun)
		{
			char Item[4];
			menu.GetItem(position, Item, sizeof(Item));
			if (strcmp(Item, "0") == 0)
			{
				if (BunnyAktifmi)
				{
					SetCvar("sv_enablebunnyhopping", 1);
					SetCvar("sv_autobunnyhopping", 1);
					SetCvar("sv_airaccelerate", 2000);
					SetCvar("sv_staminajumpcost", 0);
					SetCvar("sv_staminalandcost", 0);
					SetCvar("sv_staminamax", 0);
					SetCvar("sv_staminarecoveryrate", 60);
				}
				else
				{
					SetCvar("sv_enablebunnyhopping", 0);
					SetCvar("sv_autobunnyhopping", 0);
					SetCvar("sv_airaccelerate", 101);
					SetCvarFloat("sv_staminajumpcost", 0.080);
					SetCvarFloat("sv_staminalandcost", 0.050);
					SetCvar("sv_staminamax", 80);
					SetCvar("sv_staminarecoveryrate", 60);
				}
				if (SadeHsmi)
				{
					SetCvar("mp_damage_headshot_only", 1);
				}
				else
				{
					SetCvar("mp_damage_headshot_only", 0);
				}
				PrintToChatAll("[SM] \x01Tek Mermi \x10%N \x01tarafından başlatıldı!", client);
				Oyun = true;
				sure = 15;
				if (h_timer != null)
					delete h_timer;
				h_timer = CreateTimer(1.0, Sureeksilt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			}
			else if (strcmp(Item, "1") == 0)
			{
				if (BunnyAktifmi)
					BunnyAktifmi = false;
				else
					BunnyAktifmi = true;
				Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			}
			else if (strcmp(Item, "2") == 0)
			{
				if (SadeHsmi)
					SadeHsmi = false;
				else
					SadeHsmi = true;
				Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			}
			else if (strcmp(Item, "3") == 0)
			{
				Hangisilah++;
				if (Hangisilah == 6)
					Hangisilah = 1;
				Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			}
			else if (strcmp(Item, "4") == 0)
			{
				if (Sekmeme)
					Sekmeme = false;
				else
					Sekmeme = true;
				Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			}
			else if (strcmp(Item, "5") == 0)
			{
				if (Gravity)
					Gravity = false;
				else
					Gravity = true;
				Menu_TekMermi().Display(client, MENU_TIME_FOREVER);
			}
		}
		else
		{
			PrintToChat(client, "[SM] Oyun zaten aktif: sm_tekmermi0");
			delete menu;
			return;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action Sureeksilt(Handle timer, any data)
{
	sure--;
	if (sure > 0)
	{
		PrintHintTextToAll("→ %d Saniye sonra Tek Mermi başlayacak ←", sure);
	}
	else
	{
		if (Sekmeme)
			SekmemeAyarla(true);
		else
			SekmemeAyarla(false);
		
		if (!BunnyAktifmi)
			BunnyAyarla(false);
		else
			BunnyAyarla(true);
		
		if (Gravity)
			SetCvar("sv_gravity", 400);
		else
			SetCvar("sv_gravity", 800);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
			{
				ClearWeapon(i);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", Player_Speed);
				if (Hangisilah == 1)
				{
					weaponEnt = GivePlayerItem(i, "weapon_ak47");
				}
				else if (Hangisilah == 2)
				{
					weaponEnt = GivePlayerItem(i, "weapon_m4a1");
				}
				else if (Hangisilah == 3)
				{
					weaponEnt = GivePlayerItem(i, "weapon_m4a1_silencer");
				}
				else if (Hangisilah == 4)
				{
					weaponEnt = GivePlayerItem(i, "weapon_famas");
				}
				else if (Hangisilah == 5)
				{
					weaponEnt = GivePlayerItem(i, "weapon_deagle");
				}
				SetPlayerWeaponAmmo(i, weaponEnt, 0, 1);
			}
		}
		PrintToChatAll("[SM] \x01Tek Mermi başladı!");
		PrintHintTextToAll("→ TEK MERMI BASLADI ←");
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		h_timer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyun)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		CreateTimer(0.1, MermiVer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyun)
	{
		int attacker = GetClientOfUserId(event.GetInt("attacker"));
		if (IsClientInGame(attacker))
			KillAldi[attacker] = true;
		CreateTimer(0.2, MermiVerEx, attacker, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action MermiVer(Handle timer, int client)
{
	if (!KillAldi[client])
		SetPlayerWeaponAmmo(client, weaponEnt, 0, 1);
}

public Action MermiVerEx(Handle timer, int attacker)
{
	SetPlayerWeaponAmmo(attacker, weaponEnt, 1, 0);
	KillAldi[attacker] = false;
}

void Duzelt()
{
	SekmemeAyarla(false);
	BunnyAyarla(false);
	SetCvar("sv_gravity", 800);
	SetCvar("mp_teammates_are_enemies", 0);
	SetCvar("mp_friendlyfire", 0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
			{
				ClearWeapon(i);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
			KillAldi[i] = false;
		}
	}
	Oyun = false;
	if (h_timer != null)
	{
		delete h_timer;
		h_timer = null;
	}
}

stock int GetWeapon(int client, const char[] className)
{
	int offset = GetWeaponsOffset(client) - 4;
	int weapon = INVALID_ENT_REFERENCE;
	for (int i = 0; i < 48; i++)
	{
		offset += 4;
		weapon = GetEntDataEnt2(client, offset);
		if (!Weapon_IsValid(weapon)) {
			continue;
		}
		if (Entity_ClassNameMatches(weapon, className)) {
			return weapon;
		}
	}
	return INVALID_ENT_REFERENCE;
}

stock bool Weapon_IsValid(int weapon)
{
	if (!IsValidEdict(weapon)) {
		return false;
	}
	return Entity_ClassNameMatches(weapon, "weapon_", true);
}

stock bool Entity_ClassNameMatches(int entity, const char[] className, bool partialMatch = false)
{
	char entity_className[64];
	Entity_GetClassName(entity, entity_className, sizeof(entity_className));
	if (partialMatch) {
		return (StrContains(entity_className, className) != -1);
	}
	return StrEqual(entity_className, className);
}

stock int Entity_GetClassName(int entity, char[] buffer, int size)
{
	return GetEntPropString(entity, Prop_Data, "m_iClassname", buffer, size);
}

stock int GetWeaponsOffset(int client)
{
	static int offset = -1;
	if (offset == -1) {
		offset = FindDataMapInfo(client, "m_hMyWeapons");
	}
	return offset;
}

stock void BunnyAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("sv_enablebunnyhopping", 1);
		SetCvar("sv_autobunnyhopping", 1);
		SetCvar("sv_airaccelerate", 2000);
		SetCvar("sv_staminajumpcost", 0);
		SetCvar("sv_staminalandcost", 0);
		SetCvar("sv_staminamax", 0);
		SetCvar("sv_staminarecoveryrate", 60);
	}
	else
	{
		SetCvar("sv_enablebunnyhopping", 0);
		SetCvar("sv_autobunnyhopping", 0);
		SetCvar("sv_airaccelerate", 101);
		SetCvarFloat("sv_staminajumpcost", 0.080);
		SetCvarFloat("sv_staminalandcost", 0.050);
		SetCvar("sv_staminamax", 80);
		SetCvar("sv_staminarecoveryrate", 60);
	}
}

stock void SekmemeAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("weapon_accuracy_nospread", 1);
		SetCvarFloat("weapon_recoil_cooldown", 0.0);
		SetCvarFloat("weapon_recoil_decay1_exp", 9999.0);
		SetCvarFloat("weapon_recoil_decay2_exp", 9999.0);
		SetCvarFloat("weapon_recoil_decay2_lin", 9999.0);
		SetCvarFloat("weapon_recoil_scale", 0.0);
		SetCvar("weapon_recoil_suppression_shots", 500);
		SetCvarFloat("weapon_recoil_view_punch_extra", 0.0);
	}
	else
	{
		SetCvar("weapon_accuracy_nospread", 0);
		SetCvarFloat("weapon_recoil_cooldown", 0.55);
		SetCvarFloat("weapon_recoil_decay1_exp", 3.5);
		SetCvarFloat("weapon_recoil_decay2_exp", 8.0);
		SetCvarFloat("weapon_recoil_decay2_lin", 18.0);
		SetCvarFloat("weapon_recoil_scale", 2.0);
		SetCvar("weapon_recoil_suppression_shots", 4);
		SetCvarFloat("weapon_recoil_view_punch_extra", 0.055);
	}
}

stock void SetPlayerWeaponAmmo(int client, int weaponEntt, int clip = -1, int ammo = -1)
{
	if (weaponEntt == INVALID_ENT_REFERENCE || !IsValidEdict(weaponEntt))
		return;
	if (clip != -1)
		SetEntProp(weaponEntt, Prop_Data, "m_iClip1", clip);
	if (ammo != -1)
	{
		SetEntProp(weaponEntt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
		SetEntProp(weaponEntt, Prop_Send, "m_iSecondaryReserveAmmoCount", ammo);
	}
}

stock void ClearWeapon(int client)
{
	for (int j = 0; j < 12; j++)
	{
		int weapon = GetPlayerWeaponSlot(client, j);
		if (weapon != -1)
		{
			RemovePlayerItem(client, weapon);
			RemoveEntity(weapon);
		}
	}
	GivePlayerItem(client, "weapon_knife");
}

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

stock void SetCvarFloat(char[] cvarName, float value)
{
	ConVar FloatCvar = FindConVar(cvarName);
	if (FloatCvar == null)return;
	int flags = FloatCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
	FloatCvar.FloatValue = value;
	flags |= FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
}

stock bool CheckAdminFlag(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
} 