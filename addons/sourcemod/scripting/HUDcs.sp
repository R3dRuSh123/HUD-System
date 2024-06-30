#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <clientprefs>

#define MAX_STRING 256

char g_HudMessage1[MAX_STRING];
char g_HudMessage2[MAX_STRING];
int g_HudColor1[3];
int g_HudColor2[3];
bool g_ShowHUD = true;
char g_Prefix[MAX_STRING] = "";

ConVar sm_hud_message_1;
ConVar sm_hud_message_2;
ConVar sm_hud_color_1;
ConVar sm_hud_color_2;
ConVar sm_hud_prefix;

public Plugin myinfo = 
{ 
    name = "HUD System", 
    author = "-R3d RuSh.", 
    description = "", 
    version = "", 
    url = "https://github.com/R3dRuSh123/HUD-MESSAGE/" 
}; 

public OnPluginStart() 
{
    sm_hud_message_1 = CreateConVar("sm_hud_message_1", "★ GO.FACKRYGUNS.RO ★", "Primul mesaj din HUD");
    sm_hud_message_2 = CreateConVar("sm_hud_message_2", "★ !CASE !QUEST !MENIU !DISCORD ★", "Al doilea mesaj din HUD");
    sm_hud_color_1 = CreateConVar("sm_hud_color_1", "255 255 255", "Culoarea primului mesaj HUD (RGB)");
    sm_hud_color_2 = CreateConVar("sm_hud_color_2", "66 178 212", "Culoarea celui de-al doilea mesaj HUD (RGB)");
    sm_hud_prefix = CreateConVar("sm_hud_prefix", "★", "PREFIX pentru mesajele din CHAT");

    AutoExecConfig(true, "HUDcs");

    ReadConfigValues();

    HookConVarChange(sm_hud_message_1, OnConVarChanged_HUDMessage1);
    HookConVarChange(sm_hud_message_2, OnConVarChanged_HUDMessage2);
    HookConVarChange(sm_hud_color_1, OnConVarChanged_HUDColor1);
    HookConVarChange(sm_hud_color_2, OnConVarChanged_HUDColor2);
    HookConVarChange(sm_hud_prefix, OnConVarChanged_HUDPrefix);

    CreateTimer(0.7, HUD, _, TIMER_REPEAT); 
    RegConsoleCmd("sm_hud", Command_HUDMenu);
} 

void ReadConfigValues()
{
    GetConVarString(sm_hud_message_1, g_HudMessage1, sizeof(g_HudMessage1));
    GetConVarString(sm_hud_message_2, g_HudMessage2, sizeof(g_HudMessage2));
    GetConVarString(sm_hud_prefix, g_Prefix, sizeof(g_Prefix));
    UpdateHUDColor();
}

void UpdateHUDColor()
{
    char color1[16];
    GetConVarString(sm_hud_color_1, color1, sizeof(color1));
    ParseColorString(color1, g_HudColor1);

    char color2[16];
    GetConVarString(sm_hud_color_2, color2, sizeof(color2));
    ParseColorString(color2, g_HudColor2);
}

void ParseColorString(const char[] colorString, int colorArray[3])
{
    static char buffer[3][4];
    int numColors = ExplodeString(colorString, " ", buffer, sizeof(buffer), sizeof(buffer[]));

    for (int i = 0; i < numColors; i++)
    {
        colorArray[i] = StringToInt(buffer[i]);
    }
}

public Action HUD(Handle timer) 
{ 
    if (!g_ShowHUD) 
    {
        return Plugin_Continue;
    }

    for (int i = 1; i <= MaxClients; i++) 
    { 
        if (IsClientInGame(i))
        {
            SetHudTextParams(-1.0, 0.1, 5.0, g_HudColor1[0], g_HudColor1[1], g_HudColor1[2], 255, 0, 0.0, 0.0, 0.0); 
            ShowHudText(i, -1, g_HudMessage1);

            SetHudTextParams(-1.0, 0.13, 5.0, g_HudColor2[0], g_HudColor2[1], g_HudColor2[2], 255, 0, 0.0, 0.0, 0.0);
            ShowHudText(i, -1, g_HudMessage2);
        } 
    } 

    return Plugin_Continue;
}

public Action Command_HUDMenu(int client, int args)
{
    if (!IsClientInGame(client)) 
    {
        return Plugin_Handled;
    }

    ShowHUDMenu(client);

    return Plugin_Handled;
}

void ShowHUDMenu(int client)
{
    Handle menu = CreateMenu(MenuHandler_HUDToggle);

    SetMenuTitle(menu, "★ Meniu HUD ★");

    if (g_ShowHUD) 
    {
        AddMenuItem(menu, "disable", "★ Disable HUD ★");
    } 
    else 
    {
        AddMenuItem(menu, "enable", "★ Enable HUD ★");
    }

    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MenuHandler_HUDToggle(Handle menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_End)
    {
        CloseHandle(menu);
    }
    else if (action == MenuAction_Select)
    {
        char buffer[64];
        GetMenuItem(menu, param2, buffer, sizeof(buffer));

        if (StrEqual(buffer, "disable") || StrEqual(buffer, "enable"))
        {
            ToggleHUD(client);
        }
    }

    return 0;
}

void ToggleHUD(int client)
{
    g_ShowHUD = !g_ShowHUD;
    if (g_ShowHUD) 
    {
        PrintToChat(client, "%s \x01You \x04ENABLED \x0BHUD\x01 !", g_Prefix);
    } 
    else 
    {
        PrintToChat(client, "%s \x01You \x02DISABLED \x0BHUD\x01 !", g_Prefix);
    }

    ShowHUDMenu(client);
}

public void OnConVarChanged_HUDMessage1(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    GetConVarString(sm_hud_message_1, g_HudMessage1, sizeof(g_HudMessage1));
}

public void OnConVarChanged_HUDMessage2(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    GetConVarString(sm_hud_message_2, g_HudMessage2, sizeof(g_HudMessage2));
}

public void OnConVarChanged_HUDColor1(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    UpdateHUDColor();
}

public void OnConVarChanged_HUDColor2(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    UpdateHUDColor();
}

public void OnConVarChanged_HUDPrefix(ConVar cvar, const char[] oldValue, const char[] newValue)
{
    GetConVarString(sm_hud_prefix, g_Prefix, sizeof(g_Prefix));
}