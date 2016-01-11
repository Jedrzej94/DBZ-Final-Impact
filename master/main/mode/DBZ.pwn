/**---------------------------------------------------------------------------**\
				========================================
				 Dragon Ball Z: Final Impact - gamemode
				========================================

Description:
	Advanced script which is manipulating 3D models with animations in game.

Purpose:
	Main purpose of the game mode was to have fun and let people enjoy DBZ world,
	together in the online mode.

Legal:
	The Initial Developer of the Original Code is JÍdrzej Chmielewski.
	Portions created by the Initial Developer are Copyright (C) 2015
	the Initial Developer. All Rights Reserved.

Version:
	1.00.01

\**---------------------------------------------------------------------------**/

/* PROGRESS

26/10/2013 -
Started doing re-build of the whole script. The previous one was too buggy and messy.
I did that to prevent any bugs with deaths and spawns, which I experienced a lot in the old version.

30/10/2013 -
Created custom class selection, which is used to prevent any bugs. Fixed all the bugs right now,
working now on character list and character stats.

18:06 -
Finished character class selection & character list bugs.

11/11/2013 -
Fixed problem with CJ skin in class selection and after spawn. Also other bugs relationed with
class selection has been fixed.
14:06 -
Started scripting MySQL user database.
16:00 -
Finished managing MySQL database and script-side MySQL (sign up & sign in features)

26/11/2013 -
00:59 -
Finished saving & loading features for MySQL, also implemented Porunga Shenron to the game.
Ability to check player distance between the ground, which gonna be useful for Bukujutsu.

26/11/2013 -
12:00 -
Started creating some animations (i.e. flying, running, standing, spirit bomb).
21:44 -
Have done some animations (charge, flying, running, kamehameha - which is done really bad).
Started working on energy bar.
22:33 -
Finished work at energy bar (bar, charging, basic functions to operate KI bar).

27/11/2013 -
Fixed bug with character names in character list, also fixed all the bugs related with flying,
and implemented new animations to them.

28/11/2013 -
Added Kami's palace object & Kinton cloud.
17:43 -
Started working at Kinton's cloud flying system.
23:52 -
Finished implementing Flying nimbus (Kinton's cloud) to the game and optimized it.
Also added some special animations to it, to make it more real, now trying to find some sounds for it.

29/11/2013 -
03:10 -
Finished kamehameha new sound and implemented it to the game with animation. But animation is gonna be changed,
because current one is really ugly. Still looking for people to create animations, I created some already,
but I don't have that much experience in 3ds max.

2/12/2013 -
Created installer (with uninstaller) which gonna install all files automatically. So, basically, user doesn't
have to download loads of files and install them manually, instead of that, he's gonna download
installer and install files to his GTA: San Andreas folder and job done. While uninstalling Dragon Ball files -
all default SA-MP files will be restored.

09/12/2013 -
Added mega jump (+sound) and made security questions to avoid any mega jump in unwanted places (and playing sounds).
Also (something small) added - clearing chat when user connected to the game.

06/01/2014 -
Added new Kamehameha animation.

04/03/2014 -
Instant transmission for Goku (normal). Also animations added to it (performing action).
Shenron model added. Trying to add more animations now.

05/03/2014 -
Edited animation of Instant Transmission. It's even more smooth now, and looks very realistic (like from anime).
New animation of running.

07/03/2014 -
Making progress of creating Dragon Balls. Also edited old objects (models) to make them more real (bug fixes).
Soon, I want to make a system for Dragon Balls, to collect them.

*/

// Include'y.
#include    <a_samp>
#include    <zcmd>
#include    <audio>
#include    <sscanf2>
#include    <pprogress>
#include    <a_mysql_R5>
#include    <MapAndreas>

// Definicje/Macro's.
#define     SAMP_VERSION            "0.3z R2-2"

#define     GAMEMODE_VERSION        "1.00.01"
#define     GAMEMODE_TEXT           "§ DBZ: Final Impact §"
#define     GAMEMODE_AREA           "[DBZ]v"GAMEMODE_VERSION""
#define     GAMEMODE_HOST           "Dragon Ball Z: Final Impact v"GAMEMODE_VERSION""

#define 	PublicEx%0(%1)  		forward %0(%1); public %0(%1)
#define 	ClearChatForPlayer(%0) 	for(new i; i != 30; i++)SendClientMessage((%0), -1, " ")

#define     SCM 					SendClientMessage
#define     SPD 					ShowPlayerDialog

// Klawisze.
#define 	KEY_AIM 				KEY_HANDBRAKE
#define     KEY_ENTER               KEY_SECONDARY_ATTACK
#define 	PRESSED(%0) 			(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define 	RELEASED(%0) 			(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define 	HOLDING(%0) 			((newkeys & (%0)) == (%0))

// Latanie.
#define     FLY_NONE                (-1)
#define     FLY_BUKUJUTSU           (0)
#define     FLY_CLOUD               (1)

// Czy korzysta z animacji.
#define     USING_ANIM_SWIM     	(0)
#define     USING_ANIM_UNDERWATER   (1)
#define     USING_ANIM_CLIMB        (2)

// Definicje audio.
#define     AUDIO_NONE              (-1)
#define     AUDIO_POWERUP_START     (0)
#define     AUDIO_POWERUP_LOOP      (1)
#define     AUDIO_POWERUP_FINISH    (2)

#define     AUDIO_AURA_START        (3)
#define     AUDIO_AURA_LOOP         (4)

#define     AUDIO_DASH_START        (5)
#define     AUDIO_DASH_LOOP         (6)
#define     AUDIO_DASH_FINISH       (7)

#define     AUDIO_FLY_UP_DOWN       (8)
#define     AUDIO_JUMP              (9)

#define     AUDIO_KAMEHAME          (10)
#define     AUDIO_HA              	(11)

#define     AUDIO_KAME              (12)

#define     AUDIO_INSTANT           (13)

#define     AUDIO_KINTON_START      (14)
#define     AUDIO_KINTON_START2     (15)
#define     AUDIO_KINTON_FLY     	(16)
#define     AUDIO_KINTON_BREAK      (17)

// Aktualnie grane audio.
#define     AUDIO_PLAY_NONE         (-1)
#define     AUDIO_PLAY_CHARGE       (0)
#define     AUDIO_PLAY_DASH         (1)
#define     AUDIO_PLAY_FLY_UD       (2)
#define     AUDIO_PLAY_AURA         (3)
#define     AUDIO_PLAY_KINTON       (4)
#define     AUDIO_PLAY_KAME         (5)

// Super ataki.
#define     ATTACK_NONE             (-1)
#define     ATTACK_KAMEHAMEHA       (0)

// Limity.
#undef      MAX_PLAYERS
#define     MAX_PLAYERS             (50)
#define     MAX_CLASSES             (8)
#define     MAX_AUDIOS              (6)

// MySQL szczegÛ≥y.
#define     MYSQL_HOST              "localhost"
#define     MYSQL_USER              "root"
#define     MYSQL_PASS              ""
#define     MYSQL_DATA              "dragonball"

// Dialogi.
#define     DIALOG_NONE             (-1)
#define     DIALOG_REGISTER         (0)
#define     DIALOG_LOGIN            (1)
#define     DIALOG_CHARS       		(2)

// Wirtualne úwiaty.
#define		VIRTUAL_DEFAULT     	(501)

// Kolory.
#define     COL_RED                 "{FF003F}"
#define     COL_WHITE               "{FFFFFF}"
#define     COL_ORANGE              "{EDBC6D}"
#define     COL_YELLOW              "{F2EE0C}"
#define     COL_LIMON               "{45ED48}"
#define     COL_GREEN              	"{1CAD2F}"
#define     COL_LBLUE               "{4CE0DE}"
#define     COL_DBLUE               "{3E36E0}"
#define     COL_LYELL               "{FFFF7D}"
#define     COL_DEF                 "{9EB8E8}"

#define 	COLOR_WHITE         	0xFFFFFFFF
#define 	COLOR_GREEN         	0x33AA33FF
#define 	COLOR_RED           	0xAA3333FF
#define 	COLOR_GREY         		0xA4A4A4FF
#define 	COLOR_DARKORANGE 		0xFDAE33FF
#define 	COLOR_ORANGE 			0xFFC973FF
#define 	COLOR_BEZ          		0xFFF4BD4A
#define 	COLOR_YELLOW        	0xFFFF00FF
#define 	COLOR_LIGHTRED      	0xFF0000FF
#define 	COLOR_LIMON         	0x00D900C8
#define 	COLOR_PINK	    		0xFFB9FFFF
#define 	COLOR_PURPLE       		0xD5AAFFFF
#define 	COLOR_NICK 				0xF3F3F3FF
#define 	COLOR_SAMP          	0xa9c4e4AA
#define     COLOR_HOVER				0xFF4040AA

// Native'y.
native 		WP_Hash(buffer[], len, const str[]);

// Enum'y.
enum E_PLAYER_DATA
{
	E_PLAYER_UID,
	
	E_PLAYER_CURRENT_AUDIO,
	E_PLAYER_PLAYING_AUDIO[MAX_AUDIOS],
	
	Float:E_PLAYER_INSTANT_X,
	Float:E_PLAYER_INSTANT_Y,
	Float:E_PLAYER_INSTANT_Z,
	
	bool:E_PLAYER_SELECTING_TD,
	bool:E_PLAYER_USING_CLOUD,
	bool:E_PLAYER_USING_BUKUJUTSU,
	bool:E_PLAYER_LOGGED
};

// Player characters data.
enum E_PLAYER_CHARACTERS_DATA
{
    E_CHOSEN_SLOT,
    E_SELECT_CHAR,
    
    // Wartoúci do zapisania.
    E_CHAR_CREATED[4],
    E_CHAR_SKINID[4],
    E_CHAR_KI[4],
    E_CHAR_TOTKI[4]
};

new CharName[MAX_PLAYERS][4][24];

// Player textdraws.
enum E_PLAYER_TEXTDRAWS_DATA
{
	PlayerText:E_PLAYER_REQUESTCLASS[4],

	PlayerText:E_PLAYER_CHARLIST[3],
	PlayerText:E_PLAYER_CHARLIST_BOXES[6],
	PlayerText:E_PLAYER_CHARLIST_BOXINFO[6],
	
	PlayerBar:E_PLAYER_KI_BAR
};

// Class settings.
enum E_CLASS_DATA
{
    E_CLASS_SKINID,
	E_CLASS_NAME[24],
	Float:E_CLASS_HP,
	E_CLASS_START_KI,
	E_CLASS_KI_RECHARGE,
	
	E_CLASS_IS_TRANSFORM,
	E_CLASS_TRANSFORM_SKIN_REQ,
	E_CLASS_TRANSFORM_KI_REQ
};

// --- Tablice/zmienne ---
new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];
new PlayerChars[MAX_PLAYERS][E_PLAYER_CHARACTERS_DATA];
new PlayerTextDraw[E_PLAYER_TEXTDRAWS_DATA];

new ClassData[MAX_CLASSES][E_CLASS_DATA] =
{
	{0, "Debug",                    100.0, 0, 	  0,    0, 0, 0},

	{1, "Goku",                     100.0, 500,   20,   0, 0, 0},
	{2, "Goku Super Saiyan",        120.0, 1000,  50,   1, 1, 1000},
	{3, "Goku Super Saiyan 2",      150.0, 5000,  200,  1, 2, 10000},
	{4, "Goku Super Saiyan 3",      200.0, 15000, 2500, 1, 3, 30000},

	{5, "GokuGT",                   110.0, 1000,  30,   0, 0, 0},
	{6, "GokuGT Super Saiyan",      150.0, 5000,  350,  1, 5, 2500},
	{7, "GokuGT Super Saiyan 4",    200.0, 20000, 4000, 1, 6, 20000}
};

// --- Poprawne za≥adowanie GameMode'u ---
main()
{
	print("\n\n");
	print(" ============================================== ");
	print(" |                                            | ");
	print(" |         Dragon Ball Z: Final Impact        | ");
	print(" |   All rights reserved @Copyright Riddick   | ");
	print(" |                                            | ");
	print(" ==============================================\n");
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------- OnGameModeInit ----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnGameModeInit()
{
	SendRconCommand("mapname "GAMEMODE_AREA"");
    SendRconCommand("gamemodetext "GAMEMODE_TEXT"");
	SendRconCommand("hostname  "GAMEMODE_HOST"");
    
    ShowNameTags(true);
    UsePlayerPedAnims();
    ShowPlayerMarkers(true);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);
	Audio_SetPack("dbz_audio_pack", true);
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	
	mysql_debug(true);
	mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATA, MYSQL_PASS);
	
	// Sprawdü po≥πczenie z bazπ.
	if(mysql_ping() <= 0)print("MySQL: Dead Connection/Error while connecting.");
	else 				 print("MySQL: Successful connection.");
	
	// StwÛrz bazÍ danych jeúli nie istnieje.
	new query[500];
	strcat(query, "CREATE TABLE IF NOT EXISTS `playerdata` (UID INT, username VARCHAR(24), password VARCHAR(129), ");
	strcat(query, "CHAR_CREATED1 TINYINT, CHAR_NAME1 VARCHAR(24), CHAR_SKINID1 TINYINT, CHAR_KI1 INT, CHAR_TOTKI1 INT, ");
	strcat(query, "CHAR_CREATED2 TINYINT, CHAR_NAME2 VARCHAR(24), CHAR_SKINID2 TINYINT, CHAR_KI2 INT, CHAR_TOTKI2 INT, ");
    strcat(query, "CHAR_CREATED3 TINYINT, CHAR_NAME3 VARCHAR(24), CHAR_SKINID3 TINYINT, CHAR_KI3 INT, CHAR_TOTKI3 INT, ");
    strcat(query, "CHAR_CREATED4 TINYINT, CHAR_NAME4 VARCHAR(24), CHAR_SKINID4 TINYINT, CHAR_KI4 INT, CHAR_TOTKI4 INT)");
	mysql_query(query);

   	// Kame House.
	CreateObject(19522, 620.98, -2558.15, 3.04,  0.00, 0.00, 116.64, 500.0);
	CreateObject(620, 	611.33, -2570.33, -5.19, 0.00, 0.00, 297.36, 500.0);
	CreateObject(619, 	630.72, -2558.10, -0.88, 0.00, 0.00, 132.26, 500.0);
	CreateObject(619, 	607.15, -2546.95, -1.96, 0.00, 0.00, 322.88, 500.0);
	CreateObject(747, 	612.65, -2556.89, 1.97,  0.00, 0.00, 0.00, 	 500.0);
	CreateObject(1255, 	619.99, -2548.84, 2.74,  0.00, 0.00, 139.50, 500.0);
	CreateObject(1609, 	626.21, -2547.36, 2.19,  0.00, 0.00, 33.71,  500.0);
	CreateObject(647, 	629.12, -2558.73, 3.18,  0.00, 0.00, 0.00, 	 500.0);
	CreateObject(647, 	612.73, -2567.77, 2.93,  0.00, 0.00, 4.23, 	 500.0);
	CreateObject(647, 	616.96, -2566.10, 2.95,  0.00, 0.00, 331.30, 500.0);

	// Cell arena.
	CreateObject(19525, 202.00, 1409.27, 9.48,   0.00, 0.00, 0.00);
	
	// Kami's palace.
	CreateObject(19524, -1599.32, -2081.45, 947.41,   0.00, 0.00, 0.00);
	CreateObject(19535, -1648.56, -2070.79, 956.15,   0.00, 0.00, 73.78); // Dragon Balls.
	
	// PostaÊ debugowa.
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------- OnGameModeExit ----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnGameModeExit()
{
	mysql_close();
    Audio_DestroyTCPServer();
	return 1;
}

CMD:kami(playerid, params[])
{
	SetPlayerPos(playerid, -1596.59, -2157.14, 930.31);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------ OnPlayerConnect ----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerConnect(playerid)
{
 	SetTimerEx("OnPlayerConnectEx", 300, false, "d", playerid);
 	
 	RemoveBuildingForPlayer(playerid, 3682, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 190.9141, 1371.7734, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 190.9141, 1371.7734, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1392.1563, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1390.5703, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1387.8516, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 203.9531, 1409.9141, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 199.3828, 1407.1172, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 204.6406, 1409.8516, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1404.2344, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1400.6563, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1409.0000, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 16086, 232.2891, 1434.4844, 13.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 183.0391, 1455.7500, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 198.0000, 1462.0156, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.2422, 1460.3203, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.3047, 1461.0078, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 199.5859, 1463.7266, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 181.1563, 1463.7266, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 185.9219, 1462.8750, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 202.3047, 1462.8750, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 189.5000, 1462.8750, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1451.8281, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1454.5469, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1456.1328, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1468.2109, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1464.6328, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 247.5547, 1471.0938, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1472.9766, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.8125, 1473.8281, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.1250, 1473.8906, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 16089, 342.1250, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16090, 315.7734, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16091, 289.7422, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16087, 358.6797, 1430.4531, 11.6172, 0.25);
	return 1;
}
// --- OnPlayerConnectEx ---
PublicEx OnPlayerConnectEx(playerid)
{
	SpawnPlayer(playerid);
	ClearChatForPlayer(playerid);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------- OnPlayerClickMap --------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	MapAndreas_FindZ_For2DCoord(fX, fY, fZ);
	PlayerData[playerid][E_PLAYER_INSTANT_X] = fX;
	PlayerData[playerid][E_PLAYER_INSTANT_Y] = fY;
	PlayerData[playerid][E_PLAYER_INSTANT_Z] = fZ;
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//----------------- OnPlayerDisconnect --------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerDisconnect(playerid, reason)
{
    OnPlayerSignOut(playerid);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//--------------- OnPlayerRequestClass --------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerRequestClass(playerid, classid)
{
    //SetTimerEx("OnPlayerConnectEx", 200, false, "d", playerid);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------- OnPlayerDeath -----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerDeath(playerid, killerid, reason)
{
    HidePlayerProgressBar(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR]);
    
	// Szybki lot & wznoszenie siÍ i opszuczanie.
	if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
	{
	    RemovePlayerAttachedObject(playerid, 0);
	    PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU] = false;
	}

	// Kinton cloud.
	if(PlayerData[playerid][E_PLAYER_USING_CLOUD])
	{
	    RemovePlayerAttachedObject(playerid, 1);
	    PlayerData[playerid][E_PLAYER_USING_CLOUD] = false;
	}
	
	// Wy≥πczanie wszystkich düwiÍkÛw w trakcie úmierci.
	for(new i = 0; i != MAX_AUDIOS; i++)
	{
		if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][i])
		{
			PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][i] = 0;
			Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
		}
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------- OnPlayerSpawn -----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerSpawn(playerid)
{
	// Gracz siÍ wciπø czeka na po≥πczenie z Audio pluginem.
    if(!PlayerData[playerid][E_PLAYER_LOGGED])
    {
        SelectTextDrawEx(playerid, -1);
        SetPlayerVirtualWorld(playerid, playerid);
		SetPlayerCameraPos(playerid, 618.5688, -2505.0771, 1.9345);
		SetPlayerCameraLookAt(playerid, 618.5833, -2506.0806, 2.1645);
		
		GameTextForPlayer(playerid, "~y~Connecting to~n~~r~audio plugin...", 60000, 3);
		ApplyAnimation(playerid, "FAT", "null", 0.0, 0, 0, 0, 0, 0, 1);
		ApplyAnimation(playerid, "BEACH", "null", 0.0, 0, 0, 0, 0, 0, 1);
		ApplyAnimation(playerid, "DBZ", "null", 0.0, 0, 0, 0, 0, 0, 1);
		return 1;
	}
	
	// Rzeczywisty spawn gracza.
	CancelSelectTextDrawEx(playerid);
    SetPlayerPos(playerid, 225.6090, -1779.7428, 4.1685);
	SetPlayerFacingAngle(playerid, 176.1984);
	SetPlayerVirtualWorld(playerid, VIRTUAL_DEFAULT);
	SetCameraBehindPlayer(playerid);
	
	new slot = PlayerChars[playerid][E_CHOSEN_SLOT];
	SetPlayerHealth(playerid, ClassData[GetPlayerSkin(playerid)][E_CLASS_HP]);
	SetPlayerKI(playerid, PlayerChars[playerid][E_CHAR_KI][slot], PlayerChars[playerid][E_CHAR_TOTKI][slot]);
	ShowPlayerProgressBar(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR]);
	SetPlayerSkin(playerid, PlayerChars[playerid][E_CHAR_SKINID][slot]);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//---------------- Audio_OnClientConnect ------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public Audio_OnClientConnect(playerid)
{
	Audio_TransferPack(playerid);
	GameTextForPlayer(playerid, "~y~Preparing to load ~n~~r~audio plugin files.", 3000, 5);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//---------------- Audio_OnTransferFile -------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public Audio_OnTransferFile(playerid, file[], current, total, result)
{
	new string[64];
	format(string, sizeof(string), "~y~Loading~n~audio plugin file~n~~r~%d~w~/~r~%d", current, total);
	GameTextForPlayer(playerid, string, 3000, 5);

	if(current == total)
	{
	    GameTextForPlayer(playerid, "~n~~n~~y~Audio plugin~n~~r~successfully loaded!", 3000, 5);

		new query[128];
		format(query, sizeof(query), "SELECT * FROM `playerdata` WHERE `username` = '%s' LIMIT 1", PlayerName(playerid));
		mysql_query(query);
		mysql_store_result();

		// Rejestracja.
		if(!mysql_num_rows())
			SPD(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Sign up", "Welcome!\nPlease, register to save your stats about characters! Please enter your password below:", "Sign up", "Quit");

		// Logowanie.
		else if(mysql_num_rows())
			SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Sign in", "Welcome back!\nWe found you in our database. Please enter your account password below:", "Sign in", "Quit");
		
		mysql_free_result();
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//--------------------- Audio_OnStop ----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public Audio_OnStop(playerid, handleid)
{
	// --- £adowanie energii ---
	if(handleid == PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
	{
	    Audio_PlayEx(playerid, AUDIO_POWERUP_LOOP, false, true, false);
		CallLocalFunction("RechargeKI", "d", playerid);
	}
	
	// --- Latanie (Bukujutsu) ---
	if(handleid == PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH])
    {
		Audio_PlayEx(playerid, AUDIO_DASH_LOOP, false, true, false);
	}
	
	// --- Latanie (Kinton cloud) ---
	if(handleid == PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON])
	{
	    Audio_PlayEx(playerid, AUDIO_KINTON_FLY, false, true, false);
	}
	
	// --- Aura ---
	if(handleid == PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA])
	{
	    new Float:X, Float:Y, Float:Z;
	    GetPlayerPos(playerid, X, Y, Z);
	    Audio_PlayEx(playerid, AUDIO_AURA_LOOP, false, true, false);
 	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//---------------- OnPlayerKeyStateChange -----------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	// --- Latanie (Bukujutsu) ---
	if(PRESSED(KEY_ENTER))
	{
	    if(!PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU]
		&& !PlayerData[playerid][E_PLAYER_USING_CLOUD]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] && !IsPlayerUsingAnim(playerid, USING_ANIM_SWIM) && !IsPlayerUsingAnim(playerid, USING_ANIM_CLIMB))
		{
			SetPlayerFlyingMode(playerid, FLY_BUKUJUTSU);
		}
	    	
		else if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU]
		&& !PlayerData[playerid][E_PLAYER_USING_CLOUD]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
		{
		    SetPlayerFlyingMode(playerid, FLY_NONE);
  		}
	}
	
	// --- Mega skok ---
	if(PRESSED(KEY_JUMP))
	{
	    new Float:X, Float:Y, Float:Z;
		if(!PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU]
		&& !PlayerData[playerid][E_PLAYER_USING_CLOUD]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] && !IsPlayerUsingAnim(playerid, USING_ANIM_SWIM) && !IsPlayerUsingAnim(playerid, USING_ANIM_CLIMB))
		{
		    if(GetPlayerAltitude(playerid) <= 1.0)
		    {
				GetPlayerVelocity(playerid, X, Y, Z);
		    	SetPlayerVelocity(playerid, X, Y, Z + 3.0);

				Audio_Play(playerid, AUDIO_JUMP, false, false, false);
			}
		}
	}
	
	// --- £adowanie energii (KI) ---
	if(HOLDING(KEY_YES))
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE]	&&
		   !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA] && GetPlayerKI(playerid) < GetPlayerTotKI(playerid))
		{
		    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] = 1;
			ApplyAnimation(playerid, "DBZ", "SPIRIT_TRANSFORM", 4.1, 0, 1, 1, 1, 0, 1);
            Audio_PlayEx(playerid, AUDIO_POWERUP_START, false, false, false);
            SetPlayerAttachedObject(playerid, 0, 18692, 1, -0.717612, -0.063293, -2.000079, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
		}
	}

	else if(RELEASED(KEY_YES))
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA])
	    {
		    ClearAnimations(playerid);
		    RemovePlayerAttachedObject(playerid, 0);
		    Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
		    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] = 0;
	    }
	}
	
	// --- Wznoszenie siÍ i opuszczanie (düwiÍki) ---
	if(HOLDING(KEY_FIRE) || HOLDING(KEY_AIM))
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_FLY_UD]
		&& PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
		{
	    	PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_FLY_UD] = 1;
            Audio_PlayEx(playerid, AUDIO_FLY_UP_DOWN, false, true, false);
		}
	}

	else if(RELEASED(KEY_FIRE) || RELEASED(KEY_AIM))
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH]
		&& PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_FLY_UD]
		&& PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
		{
			PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_FLY_UD] = 0;
			Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
		}
	}
	
	// --- Aura ---
	if(PRESSED(KEY_NO))
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
	    {
	        PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA] = 1;
	        new Float:X, Float:Y, Float:Z;
		    GetPlayerPos(playerid, X, Y, Z);
		    Audio_PlayEx(playerid, AUDIO_AURA_START, false, false, false);
	        ApplyAnimation(playerid, "DBZ", "SPIRIT_TRANSFORM", 1.1, 0, 1, 1, 0, 0, 1);
            SetPlayerAttachedObject(playerid, 0, 18692, 1, -0.717612, -0.063293, -2.000079, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
			SetPlayerKI(playerid, PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] * 3, PlayerChars[playerid][E_CHAR_TOTKI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] * 3);
			CallLocalFunction("AuraEnergy", "d", playerid);
		}
	    
	    else if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA]
		&& !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
	    {
	        ClearAnimations(playerid);
	        RemovePlayerAttachedObject(playerid, 0);
	        PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA] = 0;
	        Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
	        
	        SetPlayerKI(playerid, PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] / 3, PlayerChars[playerid][E_CHAR_TOTKI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] / 3);
		}
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------ OnPlayerClickTextDraw ----------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(_:clickedid == INVALID_TEXT_DRAW)return CallLocalFunction("OnPlayerClickPlayerTextDraw", "dd", playerid, INVALID_TEXT_DRAW);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-------------- OnPlayerClickPlayerTextDraw --------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == PlayerText:INVALID_TEXT_DRAW && PlayerData[playerid][E_PLAYER_SELECTING_TD])
	{
	    SelectTextDraw(playerid, COLOR_HOVER);
		return 1;
	}
	
	// --- System wybieralki postaci ---
	for(new i = 1; i != 4; i++) // i = 1, poniewaø omijamy box w tle.
	{
	    new skinid = GetPlayerSkin(playerid),
	        slot = PlayerChars[playerid][E_CHOSEN_SLOT];
	    if(playertextid == PlayerTextDraw[E_PLAYER_REQUESTCLASS][i])
	    {
	        switch(i)
	        {
	            // SELECT.
	            case 1:
	            {
             		if(ClassData[skinid][E_CLASS_IS_TRANSFORM])return 1;
	                PlayerChars[playerid][E_CHAR_CREATED][slot] = 1;
                    PlayerChars[playerid][E_CHAR_SKINID][slot] = skinid;
					strmid(CharName[playerid][slot], ClassData[skinid][E_CLASS_NAME], 0, 24, 24);
					PlayerChars[playerid][E_CHAR_TOTKI][slot] = ClassData[skinid][E_CLASS_START_KI];
                    
					HidePlayerSelectionMenu(playerid);
	                ShowPlayerCharactersList(playerid, true);
	            }
	            
	            // LEFT.
	            case 2:
	            {
	                skinid -= 1;
	                if(skinid <= 0)skinid = MAX_CLASSES - 1;
	            }
	            
	            // RIGHT.
	            case 3:
	            {
	                skinid += 1;
	            	if(skinid > MAX_CLASSES - 1)skinid = 1;
	            }
			}
			
			SetPlayerSkin(playerid, skinid);
			ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);
            return 1;
		}
 	}
	
	// --- Lista postaci ---
	for(new i = 0; i != 6; i++)
	{
	    new select = PlayerChars[playerid][E_SELECT_CHAR];
		if(playertextid == PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][i])
		{
			switch(i)
			{
			    // WybÛr slotu z postaciπ.
			    case 0..3:
			    {
			        PlayerChars[playerid][E_CHOSEN_SLOT] = i;
					if(i != PlayerChars[playerid][E_SELECT_CHAR])
					{
						PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][select], -1);
						PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][select]);
						PlayerChars[playerid][E_SELECT_CHAR] = i;

						SetPlayerSkin(playerid, PlayerChars[playerid][E_CHAR_SKINID][ PlayerChars[playerid][E_CHOSEN_SLOT] ]);
						ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);

                        PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][i], COLOR_GREEN);
						PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][i]);
					}
				}
				
				// Przycisk: Choose.
				case 4:
				{
					if(PlayerChars[playerid][E_CHAR_CREATED][ PlayerChars[playerid][E_CHOSEN_SLOT] ])
						SPD(playerid, DIALOG_CHARS, DIALOG_STYLE_LIST, "Let's go!", "PLAY!\nChange character name\nCreate new character", "Select", "Cancel");
					else
						SPD(playerid, DIALOG_CHARS, DIALOG_STYLE_LIST, "Settings...", "Create new character...", "Select", "Cancel");
				}

				// Przycisk: Cancel.
				case 5:
				{
					if(PlayerChars[playerid][E_SELECT_CHAR] > 0)
					{
						PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][select], -1);
						PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][select]);
						PlayerChars[playerid][E_SELECT_CHAR] = 0;
						PlayerChars[playerid][E_CHOSEN_SLOT] = 0;
						
						PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], COLOR_GREEN);
						PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0]);
						SetPlayerSkin(playerid, PlayerChars[playerid][E_CHAR_SKINID][0]);
						ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);
					}
				}
			}
            return 1;
		}
	}
	
	return 0;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//------------------ OnDialogResponse ---------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	// --- DèWI KI POTWIERDZENIA I ANULOWANIA ---
	if(response)PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
	else 		PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);

	switch(dialogid)
	{
	    // Rejestracja.
	    case DIALOG_REGISTER:
	    {
	        if(!response)Kick(playerid);
	        else
	        {
	            if(strlen(inputtext) < 5 || strlen(inputtext) > 20 || !inputtext[0])
	            {
	                new string[124];
	                format(string, sizeof(string), "Welcome!\nPlease, register to save your stats about characters! Please enter your password below:\n"COL_RED"(Password must be at least 5 chars long and 20 chars maximum!)");
					SPD(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Sign up", string, "Sign up", "Quit");
	                return 1;
	            }
	            OnPlayerRegister(playerid, inputtext);
	        }
	        return 1;
		}
		
		// Logowanie.
		case DIALOG_LOGIN:
		{
		    if(!response)Kick(playerid);
		    else
		    {
		    	if(!inputtext[0])
				{
				    SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Sign in", "Welcome back!\nWe found you in our database. Please enter your account password below:", "Sign in", "Quit");
				    return 1;
				}
				OnPlayerLogin(playerid, inputtext);
		    }
		    return 1;
		}
		
	    // Lista postaci gracza.
	    case DIALOG_CHARS:
	    {
	    	if(!response)return 0;
		    else
		    {
		        // Jeúli postaÊ jest stworzona na danym slocie.
				if(PlayerChars[playerid][E_CHAR_CREATED][ PlayerChars[playerid][E_CHOSEN_SLOT] ])
				{
					switch(listitem)
			        {
					    // Zacznij grÍ wybranπ postaciπ.
						case 0:
						{
						    SpawnPlayer(playerid);
						    ShowPlayerCharactersList(playerid, false);
						}
						
						// Zmiana nazwy postaci.
						case 1:
						{
						    SPD(playerid, DIALOG_CHARS + 1, DIALOG_STYLE_INPUT, "Change character name", "Please enter new character name below:", "Done", "Cancel");
						}

						// StwÛrz nowπ postaÊ.
						case 2:
						{
						    ShowPlayerCharactersList(playerid, false);
						    ShowPlayerSelectionMenu(playerid);
						}
					}
				}
				
				// Jeúli postaÊ na danym slocie nie istnieje.
				else
				{
				    // StwÛrz nowπ postaÊ.
				    if(listitem == 0)
				    {
				       	ShowPlayerCharactersList(playerid, false);
				        ShowPlayerSelectionMenu(playerid);
					}
				}
				
			}
	        return 1;
	    }
	    
   		// Zmiana imienia postaci.
		case DIALOG_CHARS + 1:
		{
		    if(!response)SPD(playerid, DIALOG_CHARS, DIALOG_STYLE_LIST, "Let's go!", "PLAY!\nChange character name\nCreate new character", "Choose", "Cancel");
		    else
		    {
		        if(!inputtext[0])
		        {
		        	SPD(playerid, DIALOG_CHARS + 1, DIALOG_STYLE_INPUT, "Change character name", "Please enter new character name below:", "Done", "Cancel");
					return 1;
				}
				new slot = PlayerChars[playerid][E_CHOSEN_SLOT];
				strmid(CharName[playerid][slot], inputtext, 0, 24, 24);
				PlayerTextDrawSetString(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][slot], CharName[playerid][slot]);
		 		PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][slot]);
		    }
		}
	    
	}
	return 1;
}

CMD:cloud(playerid, params[])
{
	if(!PlayerData[playerid][E_PLAYER_USING_CLOUD] && !PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
	{
		SetPlayerFlyingMode(playerid, FLY_CLOUD);
	}

	else if(PlayerData[playerid][E_PLAYER_USING_CLOUD] && !PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
	{
	    SetPlayerFlyingMode(playerid, FLY_NONE);
	}
	return 1;
}


CMD:instant(playerid, params[])
{
	ApplyAnimation(playerid, "DBZ", "INSTANT_TRNSM", 4.1, 0, 1, 1, 1, 0, 1);
	SetTimerEx("InstantTransmission", 2000, false, "d", playerid);
	return 1;
}

CMD:anim(playerid, params[])
{
	new animid;
	ClearAnimations(playerid);
	if(sscanf(params, "d", animid))return SCM(playerid, -1, "Wpisz: /anim [2-12]");
	{
	    switch(animid)
	    {
	    	/*case 0:ApplyAnimation(playerid, "QILIN", "qilin_kai", 4.1, 0, 1, 1, 1, 0, 1);
	    	case 1:ApplyAnimation(playerid, "QILIN", "qilin_to", 4.1, 0, 1, 1, 1, 0, 1);
	    	case 2:ApplyAnimation(playerid, "QILIN", "qilin_xuli", 4.1, 0, 1, 1, 1, 0, 1);
	    	case 3:ApplyAnimation(playerid, "QILIN", "qilin_shifang", 4.1, 0, 1, 1, 1, 0, 1);*/
	    	
	    	case 0:ApplyAnimation(playerid, "DBZ", "FLY_STOP", 4.1, 0, 1, 1, 1, 0, 1);
	    	case 1:ApplyAnimation(playerid, "DBZ", "FLY_DASH2", 4.1, 0, 1, 1, 1, 0, 1);
	    	case 2:ApplyAnimation(playerid, "DBZ", "FLY_SLOW", 4.1, 0, 1, 1, 1, 0, 1);
            case 3:ApplyAnimation(playerid, "DBZ", "FLY_ACCEL", 4.1, 0, 1, 1, 1, 0, 1);
            
            case 4:ApplyAnimation(playerid, "DBZ", "SPIRIT_CHARGE", 4.1, 0, 1, 1, 1, 0, 1);
            case 5:ApplyAnimation(playerid, "DBZ", "SPIRIT_THROW", 4.1, 0, 1, 1, 1, 0, 1);
            case 6:ApplyAnimation(playerid, "DBZ", "SPIRIT_TRANSFORM", 4.1, 0, 1, 1, 1, 0, 1);
            case 7:ApplyAnimation(playerid, "DBZ", "SPIRIT_PUSH", 4.1, 0, 1, 1, 1, 0, 1);
            case 8:ApplyAnimation(playerid, "DBZ", "SPIRIT_MISC", 4.1, 0, 1, 1, 1, 0, 1);

            case 9:ApplyAnimation(playerid, "DBZ", "KAME_CHARGE", 4.1, 0, 1, 1, 1, 0, 1);
            case 10:ApplyAnimation(playerid, "DBZ", "KAME_ATTACK", 4.1, 0, 1, 1, 1, 0, 1);
            case 11:ApplyAnimation(playerid, "DBZ", "INSTANT_TRNSM", 4.1, 0, 1, 1, 1, 0, 1);
            case 12:ApplyAnimation(playerid, "DBZ", "INSTANT_TRNSM_OFF", 4.1, 0, 1, 1, 0, 0, 1);
		}
	}
	return 1;
}

CMD:ki(playerid, params[])
{
	new string[64];
	format(string, sizeof(string), "KI: %d / TOT_KI: %d", GetPlayerKI(playerid), GetPlayerTotKI(playerid));
	SCM(playerid, -1, string);
	return 1;
}

CMD:kame(playerid, params[])
{
    MoveCameraNextToPlayer(playerid, -1.5, 0.5, 500);
	Audio_PlayEx(playerid, AUDIO_KAME, false, false, false);
	ApplyAnimation(playerid, "DBZ", "KAME_CHARGE", 2.1, 0, 1, 1, 1, 0, 1);
	
	CreateSuperAttack(playerid, ATTACK_KAMEHAMEHA, 3500);
	SetPlayerAttachedObject(playerid, 0, 18844, 1, 0.047740, 0.253344, -0.152881, 0.000000, 0.000000, 0.000000, 0.002175, 0.001940, -0.002056);
	return 1;
}

PublicEx CreateSuperAttack(playerid, attackid, delay)
{
	if(delay)
	{
		SetTimerEx("CreateSuperAttack", 500, false, "ddd", playerid, attackid, delay - 500);
		return 1;
	}
	
	switch(attackid)
	{
	    case ATTACK_KAMEHAMEHA:
	    {
	        SetCameraBehindPlayer(playerid);
	        RemovePlayerAttachedObject(playerid, 0);
	        ApplyAnimation(playerid, "DBZ", "KAME_ATTACK", 4.1, 0, 0, 0, 1, 0, 1);
	        
	        new Float:i = 5.0;
	        while(i != 60.0)
	        {
	            CreateExplosionEx(playerid, i, 11, 5.0);
				i += 5.0;
	        }
	    }
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-------------------- FUNKCJE GAMEMODE'U -----------------------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
stock IsPlayerSpawned(playerid)
{
	switch(GetPlayerState(playerid))
	{
		case 0, 7, 9:return 0;
		default:	 return 1;
	}
	return -1;
}

// --- Pobieranie nicku gracza ---
stock PlayerName(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	for(new s; s < sizeof(pName); s++)
	{
		if(pName[s] == '_')
			pName[s] = ' ';
	}
	return pName;
}

// --- Pobieranie wysokoúcki gracza od ziemi ---
stock GetPlayerAltitude(playerid)
{
    new Float:Pos[3];
    GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

    new Float:ground = GetPointZPos(Pos[0], Pos[1]),
    	Float:altitude = (Pos[2] - ground);

	return floatround(altitude, floatround_round);
}

// --- Ustawianie düwiÍku audio ---
stock Audio_PlayEx(playerid, audioid, bool:pause, bool:loop, bool:downmix)
{
	Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
    PlayerData[playerid][E_PLAYER_CURRENT_AUDIO] = Audio_Play(playerid, audioid, pause, loop, downmix);
	return 1;
}

// --- Poruszenie kamerπ graczowi na krzyø ---
stock MoveCameraNextToPlayer(playerid, Float:distance, Float:offset, move_time)
{
    new Float:X, Float:Y, Float:Z, Float:Ang;
    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, Ang);

    new Float:newX = X + (distance * floatsin(-Ang, degrees));
    new Float:newY = Y + (distance * floatcos(-Ang, degrees));

    SetCameraBehindPlayer(playerid);
    SetPlayerCameraPos(playerid, newX, newY, Z);

    X = newX, Y = newY;
    Ang -= 90.0;

    newX += floatmul(floatsin(-Ang, degrees), offset);
    newY += floatmul(floatcos(-Ang, degrees), offset);
    InterpolateCameraPos(playerid, X, Y, Z, newX, newY, Z, move_time, CAMERA_MOVE);
    return 1;
}

// --- Stworzenie wybuchu przed graczem ---
stock CreateExplosionEx(playerid, Float:distance, type, Float:radius)
{
	new Float:X, Float:Y, Float:Z, Float:X2, Float:Y2, Float:Ang;
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, Ang);
	X2 = X + (distance * floatsin(-Ang, degrees));
	Y2 = Y + (distance * floatcos(-Ang, degrees));
	CreateExplosion(X2, Y2, Z, type, radius);
	return true;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// --- System wybierania postaci ---
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
stock ShowPlayerSelectionMenu(playerid, bool:interpolate = false)
{
	SetPlayerSkin(playerid, ClassData[1][E_CLASS_SKINID]);
    SetPlayerVirtualWorld(playerid, playerid);
	SetPlayerPos(playerid, 619.9042, -2548.7219, 3.6678);
	SetPlayerFacingAngle(playerid, 46.8508);
	ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);

	for(new i = 0; i != 4; i++)
	{
	    PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][i]);
	}
	SelectTextDrawEx(playerid, COLOR_HOVER);
	
	if(interpolate)
	{
	    InterpolateCameraPos(playerid, 618.5688, -2505.0771, 1.9345, 619.3730, -2543.8401, 2.5876, 4000);
		InterpolateCameraLookAt(playerid, 618.5833, -2506.0806, 2.1645, 619.5887, -2544.8220, 2.8676, 4000);
	}

	else
    {
        SetPlayerCameraPos(playerid, 619.3730, -2543.8401, 2.5876);
        SetPlayerCameraLookAt(playerid, 619.5887, -2544.8220, 2.8676);
	}
	return 1;
}

// --- Chowanie wybieralki dla gracza ---
stock HidePlayerSelectionMenu(playerid)
{
	for(new i = 0; i != 4; i++)
	{
	    PlayerTextDrawHide(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][i]);
	}
    CancelSelectTextDrawEx(playerid);
	return 1;
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// --- Pokazywanie graczowi listy postaci ---
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
stock ShowPlayerCharactersList(playerid, bool:show)
{
	if(show)
	{
	    // T≥o, czterogwiezdna smocza kula, character list tekst.
	    new string[20];
		switch(random(2))
		{
			case 0:format(string, sizeof(string), "DBZ:CHAR_SEL_GOKU");
			case 1:format(string, sizeof(string), "DBZ:CHAR_SEL_VEGETA");
		}
		PlayerTextDrawSetString(playerid, PlayerText:PlayerTextDraw[E_PLAYER_CHARLIST][0], string);
		
		for(new i = 0; i != 3; i++)
		{
		    PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][i]);
		}
		
		// Wszystkie box'y.
		for(new i = 0; i != 6; i++)
		{
		    PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][i]);
		}
		
		// Informacje w box'ach.
		PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][ PlayerChars[playerid][E_CHOSEN_SLOT] ], COLOR_GREEN);
		for(new slot = 0; slot != 4; slot++)
	    {
	        PlayerTextDrawSetString(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][slot], CharName[playerid][slot]);
		 	PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][slot]);
		}
		
		PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4]);
		PlayerTextDrawShow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5]);
		
		SelectTextDrawEx(playerid, COLOR_HOVER);
		HidePlayerProgressBar(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR]);
	}
	
	else
	{
	    // T≥o, czterogwiezdna smocza kula, character list tekst.
		for(new i = 0; i != 3; i++)
		{
		    PlayerTextDrawHide(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][i]);
		}

		// Wszystkie box'y & Informacje w box'ach.
		for(new i = 0; i != 6; i++)
		{
		    PlayerTextDrawHide(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][i]);
		    PlayerTextDrawHide(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][i]);
		}
		
		CancelSelectTextDrawEx(playerid);
	}
	return 1;
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// --- System KI (Energia) ---
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=
stock GetPlayerKI(playerid)return PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ];
stock GetPlayerTotKI(playerid)return PlayerChars[playerid][E_CHAR_TOTKI][ PlayerChars[playerid][E_CHOSEN_SLOT] ];

stock SetPlayerKI(playerid, current_ki, total_ki)
{
	new slot = PlayerChars[playerid][E_CHOSEN_SLOT];
	
	PlayerChars[playerid][E_CHAR_TOTKI][slot] = total_ki;
	PlayerChars[playerid][E_CHAR_KI][slot] = (current_ki > PlayerChars[playerid][E_CHAR_TOTKI][slot] ? PlayerChars[playerid][E_CHAR_TOTKI][slot] : current_ki);
    
    SetPlayerProgressBarMaxValue(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR], total_ki);
    UpdateEnergyBar(playerid);
	return 1;
}

// --- £adowanie energii ---
PublicEx RechargeKI(playerid)
{
	new slot = PlayerChars[playerid][E_CHOSEN_SLOT],
	    skinid = GetPlayerSkin(playerid);
	    
    if(PlayerChars[playerid][E_CHAR_KI][slot] + ClassData[skinid][E_CLASS_KI_RECHARGE] < PlayerChars[playerid][E_CHAR_TOTKI][slot])
    {
        if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
        {
			PlayerChars[playerid][E_CHAR_KI][slot] += ClassData[skinid][E_CLASS_KI_RECHARGE];
			SetTimerEx("RechargeKI", 1000, false, "d", playerid);
		}
	}

	else
 	{
 	    ClearAnimations(playerid);
 	    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] = 0;
      	Audio_PlayEx(playerid, AUDIO_POWERUP_FINISH, false, false, false);
 	    
		PlayerChars[playerid][E_CHAR_KI][slot] = PlayerChars[playerid][E_CHAR_TOTKI][slot];
		SetPlayerAttachedObject(playerid, 0, 18682, 1, -0.541098, -0.283703, -1.735160, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
	}
	UpdateEnergyBar(playerid);
	return 1;
}

// --- Odúwieøanie (aktualizacja) paska energii ---
stock UpdateEnergyBar(playerid)
{
    SetPlayerProgressBarValue(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR], PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ]);
	UpdatePlayerProgressBar(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR]);
	return 1;
}

// --- Zabieranie energii KI podczas korzystania z aury ---
PublicEx AuraEnergy(playerid)
{
	if(PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] - 1000 < 0)
	{
 		ClearAnimations(playerid);
        RemovePlayerAttachedObject(playerid, 0);
        PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA] = 0;
        Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);

		SetPlayerKI(playerid, 0, PlayerChars[playerid][E_CHAR_TOTKI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] / 3);
		ApplyAnimation(playerid, "FAT", "IDLE_tired", 4.0, 1, 0, 0, 0, 5000, 1);
	}

	else
	{
	    PlayerChars[playerid][E_CHAR_KI][ PlayerChars[playerid][E_CHOSEN_SLOT] ] -= 1000;
		UpdateEnergyBar(playerid);
	}

	if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_AURA])SetTimerEx("AuraEnergy", 500, false, "d", playerid);
	return 1;
}

// --- System natychmiastowej teleportacji ---
PublicEx InstantTransmission(playerid)
{
	CallLocalFunction("FreezePlayer", "dd", playerid, 1);
    Audio_PlayEx(playerid, AUDIO_INSTANT, false, false, false);
	SetPlayerPos(playerid, PlayerData[playerid][E_PLAYER_INSTANT_X], PlayerData[playerid][E_PLAYER_INSTANT_Y], PlayerData[playerid][E_PLAYER_INSTANT_Z] + 1.0);
	ApplyAnimation(playerid, "DBZ", "INSTANT_TRNSM_OFF", 2.1, 0, 1, 1, 0, 0, 1);
	return 1;
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// --- System Bukujutsu (Latanie) ---
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
stock SetPlayerFlyingMode(playerid, flying_mode)
{
    static Float:X, Float:Y, Float:Z;
    GetPlayerVelocity(playerid, X, Y, Z);
    
    switch(flying_mode)
    {
        // Bukujutsu.
        case FLY_BUKUJUTSU:
		{
		    SetPlayerVelocity(playerid, X, Y, Z + 10.0);
			SetTimerEx("FlyingMode", 600, false, "d", playerid);
			PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU] = true;
		}
		
		// Kinton cloud.
		case FLY_CLOUD:
		{
		    SetPlayerVelocity(playerid, X, Y, Z + 10.0);
			SetTimerEx("FlyingMode", 600, false, "d", playerid);
			PlayerData[playerid][E_PLAYER_USING_CLOUD] = true;
		}
		
		// Wy≥πczanie.
		default:
		{
  			ClearAnimations(playerid);
		    SetPlayerVelocity(playerid, X, Y, Z);

			// Szybki lot & wznoszenie siÍ i opszuczanie.
			if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
			{
			    RemovePlayerAttachedObject(playerid, 0);
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] = 0;
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_FLY_UD] = 0;
			    PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU] = false;
			}

			// Kinton cloud.
			if(PlayerData[playerid][E_PLAYER_USING_CLOUD])
			{
			    RemovePlayerAttachedObject(playerid, 1);
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] = 0;
			    PlayerData[playerid][E_PLAYER_USING_CLOUD] = false;
			}
			Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
		}
	}
	return 1;
}

// --- Tryb latania ---
PublicEx FlyingMode(playerid)
{
	new Keys, ud, lr;
	GetPlayerKeys(playerid, Keys, ud, lr);

	new Float:v_x, Float:v_y, Float:v_z,
 		Float:X, Float:Y, Float:Z;
	
	// Do przodu.
	if(ud & KEY_UP && !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
	{
 		GetPlayerCameraFrontVector(playerid, X, Y, Z);
	    v_x = X / 2;
		v_y = Y / 2;
	
	    // Szybciej.
		if(Keys & KEY_SPRINT)
		{
		    v_x *= 4.0;
			v_y *= 4.0;
			v_z *= 4.0;

			// Bukujutsu.
		    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] && PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
		    {
		        PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] = 1;
		        Audio_PlayEx(playerid, AUDIO_DASH_START, false, false, false);
		        ApplyAnimation(playerid, "DBZ", "FLY_ACCEL", 4.1, 1, 1, 1, 1, 0, 1);
		        //ApplyAnimation(playerid, "DBZ", "FLY_DASH2", 4.1, 1, 1, 1, 1, 0, 1);
				SetPlayerAttachedObject(playerid, 0, 18671, 1, 0.816622, 0.460711, -1.662187, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0);
			}

			// Kinton cloud.
            else if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 1 && PlayerData[playerid][E_PLAYER_USING_CLOUD])
			{
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] = 2;
				switch(random(2))
				{
					case 0:Audio_PlayEx(playerid, AUDIO_KINTON_START, false, false, false);
					case 1:Audio_PlayEx(playerid, AUDIO_KINTON_START2, false, false, false);
				}
				
				ApplyAnimation(playerid, "DBZ", "CLOUD_ACCEL", 4.0, 0, 1, 1, 1, 0, 1);
    			SetPlayerAttachedObject(playerid, 1, 19523, 9, 0.000000, -0.011999, 0.131999, -48.400005, -89.399978, 32.500000, 1.000000, 1.000000, 1.000000);
			}
		}

		else
		{
		    // Bukujutsu.
		    if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] && PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
		    {
			    RemovePlayerAttachedObject(playerid, 0);
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] = 0;
			}

			// Kinton cloud.
			else if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 2 && PlayerData[playerid][E_PLAYER_USING_CLOUD])
			{
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] = 1;
			    Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
			}
		}
	}

	// Wznoszenie siÍ i opuszczanie.
	if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE])
	{
		if(Keys & KEY_FIRE)v_z += 0.2;
		else if(Keys & KEY_AIM)v_z -= 0.2;
	}

	// Wolne latanie.
	if(Keys & KEY_WALK && !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH])
	{
		v_x /= 4.0;
		v_y /= 4.0;
		v_z /= 4.0;
	}

	// Sprawdzanie wysokoúci gracza od ziemi.
	if(GetPlayerAltitude(playerid) <= 3.0)
	{
	    SetPlayerFlyingMode(playerid, FLY_NONE);
		return 1;
	}

	// Zatrzymanie siÍ w powietrzu.
	if(v_z == 0.0)v_z = 0.025;
	SetPlayerVelocity(playerid, v_x, v_y, v_z);

	if(v_x == 0.0 && v_y == 0.0)
	{
	    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_CHARGE] && !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KAME])
	    {
	        if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
			{
			    if(!PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH])//ApplyAnimation(playerid, "DBZ", "FLY_STOP", 4.1, 1, 1, 1, 1, 0, 1);
				ApplyAnimation(playerid, "DBZ", "FLY_SLOW", 4.1, 1, 1, 1, 1, 0, 1);
				else
				{
				    RemovePlayerAttachedObject(playerid, 0);
					PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH] = 0;
					Audio_PlayEx(playerid, AUDIO_DASH_FINISH, false, false, false);
				}
			}
			
			if(PlayerData[playerid][E_PLAYER_USING_CLOUD])
			{
			    if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 2)
				{
				    Audio_PlayEx(playerid, AUDIO_KINTON_BREAK, false, false, false);
				    SetPlayerAttachedObject(playerid, 1, 19523, 9, 0.000000, -0.011998, 0.131999, -48.400005, -89.399978, -66.699996, 1.000000, 1.000000, 1.000000);
				}
				
				else if(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 1)
				{
				    Audio_Stop(playerid, PlayerData[playerid][E_PLAYER_CURRENT_AUDIO]);
				}
				
				else
				{
				    SetPlayerAttachedObject(playerid, 1, 19523, 9, 0.000000, -0.011998, 0.131999, -48.400005, -89.399978, -66.699996, 1.000000, 1.000000, 1.000000);
				}
   				PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] = 0;
				ApplyAnimation(playerid, "PED", "IDLE_STANCE", 4.0, 1, 1, 1, 0, 0, 1);
			}
		}
	}

	else
	{
		GetPlayerCameraFrontVector(playerid, v_x, v_y, v_z);
		GetPlayerCameraPos(playerid, X, Y, Z);
		SetPlayerLookAt(playerid, v_x * 500.0 + X, v_y * 500.0 + Y);

		if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU])
		{
			if(!IsPlayerUseAnim(playerid, "FLY_STOP") || !PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_DASH])
			{
			    ApplyAnimation(playerid, "DBZ", "FLY_SLOW", 4.1, 1, 1, 1, 1, 0, 1);
			    //ApplyAnimation(playerid, "DBZ", "FLY_STOP", 4.1, 1, 1, 1, 1, 0, 1);
			}
		}

		else if(PlayerData[playerid][E_PLAYER_USING_CLOUD])
		{
			if(!IsPlayerUseAnim(playerid, "CLOUD_SLOW") &&
			(PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 0 || PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] == 1))
			{
			    PlayerData[playerid][E_PLAYER_PLAYING_AUDIO][AUDIO_PLAY_KINTON] = 1;
				ApplyAnimation(playerid, "DBZ", "CLOUD_SLOW", 4.0, 1, 0, 0, 0, 0, 1);
				Audio_PlayEx(playerid, AUDIO_KINTON_FLY, false, true, false);
				SetPlayerAttachedObject(playerid, 1, 19523, 9, 0.000000, -0.011999, 0.131999, -48.400005, -89.399978, 32.500000, 1.000000, 1.000000, 1.000000);
			}
		}
	}
	
	if(PlayerData[playerid][E_PLAYER_USING_BUKUJUTSU] || PlayerData[playerid][E_PLAYER_USING_CLOUD])SetTimerEx("FlyingMode", 100, false, "d", playerid);
	return 1;
}

// --- Ustawianie kπta gracza wzglÍdem po≥oøenia kamery ---
stock SetPlayerLookAt(playerid, Float:x, Float:y)
{
	new Float:Px, Float:Py, Float: Pa;
	GetPlayerPos(playerid, Px, Py, Pa);
	Pa = floatabs(atan((y - Py) / (x - Px)));
	if(x <= Px && y >= Py)Pa = floatsub(180.0, Pa);
	else if(x < Px && y < Py)Pa = floatadd(Pa, 180.0);
	else if(x >= Px && y <= Py)Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if(Pa >= 360.0)Pa = floatsub(Pa, 360.0);
	SetPlayerFacingAngle(playerid, Pa);
	return;
}

// --- Zamroøenie gracza w miejscu z okreúlonym czasem ---
PublicEx FreezePlayer(playerid, time)
{
	if(time)
	{
	    TogglePlayerControllable(playerid, false);
	    SetTimerEx("FreezePlayer", 1000, false, "dd", playerid, time - 1);
	}

	else
	{
	    TogglePlayerControllable(playerid, true);
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// --- System sprawdzania animacji ---
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
stock IsPlayerUsingAnim(playerid, animid)
{
	switch(animid)
	{
		// P≥ywanie (Pod wodπ).
		case USING_ANIM_UNDERWATER:
		{
		    if(IsPlayerUseAnim(playerid, "SWIM_GLIDE") || IsPlayerUseAnim(playerid, "SWIM_DIVE_UNDER")
			|| IsPlayerUseAnim(playerid, "SWIM_UNDER") || IsPlayerUseAnim(playerid, "SWIM_DIVE_GLIDE"))
			{
			    return 1;
			}
		}

  		// P≥ywanie (ogÛlne).
	    case USING_ANIM_SWIM:
	    {
	        static animlib[32], animname[32];
	        GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));
	        if(!strcmp(animlib, "SWIM", true))
			{
				return 1;
			}
		}

		// Wspinanie siÍ.
		case USING_ANIM_CLIMB:
		{
			if(IsPlayerUseAnim(playerid, "CLIMB_idle") 		|| IsPlayerUseAnim(playerid, "CLIMB_jump")
			|| IsPlayerUseAnim(playerid, "CLIMB_jump2fall") || IsPlayerUseAnim(playerid, "CLIMB_jump_B")
			|| IsPlayerUseAnim(playerid, "CLIMB_Pull"))
			{
			    return 1;
			}
		}
	}
	return 0;
}

// --- Czy gracz uøywa danej animacji ---
stock IsPlayerUseAnim(playerid, aname[])
{
	new animname[32], animlib[32];
	GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));
	if(!strcmp(animname, aname, true))return 1;
	return 0;
}

// --- W≥asne funkcje sprawdzania, czy gracz ma w≥πczony kursor ---
stock SelectTextDrawEx(playerid, color)
{
	PlayerData[playerid][E_PLAYER_SELECTING_TD] = true;
	SelectTextDraw(playerid, color);
	return 1;
}

stock CancelSelectTextDrawEx(playerid)
{
    PlayerData[playerid][E_PLAYER_SELECTING_TD] = false;
    CancelSelectTextDraw(playerid);
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=
// --- System rejestracji ---
//=-=-=-=-=-=-=-=-=-=-=-=-=-=
stock OnPlayerRegister(playerid, password[])
{
	// Hash has≥a gracza.
	new HashStr[129];
	WP_Hash(HashStr, sizeof(HashStr), password);
	
	// StwÛrz konto graczowi.
	new query[230];
	format(query, sizeof(query), "INSERT INTO `playerdata` (`username`, `password`) VALUES ('%s', '%s')", PlayerName(playerid), HashStr);
	mysql_query(query);
	
	// Wymuú gracza do uøycia postaci ze slotu '0'.
	PlayerChars[playerid][E_SELECT_CHAR] = 0;
	PlayerChars[playerid][E_CHOSEN_SLOT] = 0;
	
	// Ustaw nazwy slotÛw.
	for(new slot = 0; slot != 4; slot++)
	{
	    strmid(CharName[playerid][slot], "Empty_slot", 0, 24, 24);
	}
	
	// Pokaø graczowi wybieralkÍ postaci.
	CreatePlayerTextDraws(playerid);
	ShowPlayerSelectionMenu(playerid, true);
	
	PlayerData[playerid][E_PLAYER_LOGGED] = true;
	return 1;
}

// --- Logowanie gracza ---
stock OnPlayerLogin(playerid, password[])
{
    new HashStr[129];
	WP_Hash(HashStr, sizeof(HashStr), password);
	
 	new query[220];
    format(query, sizeof(query), "SELECT * FROM `playerdata` WHERE `username` = '%s' AND `password` = '%s'", PlayerName(playerid), HashStr);
    mysql_query(query);
	mysql_store_result();
	
	// Za≥aduj dane gracza z bazy danych.
	if(mysql_num_rows())
	{
	    new tmp[24];
		format(query, sizeof(query), "SELECT * FROM `playerdata` WHERE `username` = '%s' LIMIT 1", PlayerName(playerid));
		mysql_query(query);

		mysql_store_result();
		while(mysql_fetch_row_format(query, "|"))
		{
		    mysql_fetch_field_row(tmp, "UID"); 			 PlayerData[playerid][E_PLAYER_UID] = strval(tmp);

		    mysql_fetch_field_row(tmp, "CHAR_CREATED1"); PlayerChars[playerid][E_CHAR_CREATED][0] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_NAME1");    strmid(CharName[playerid][0], tmp, 0, 24, 24);
		    mysql_fetch_field_row(tmp, "CHAR_SKINID1");  PlayerChars[playerid][E_CHAR_SKINID][0] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_KI1");  	 PlayerChars[playerid][E_CHAR_KI][0] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_TOTKI1"); 	 PlayerChars[playerid][E_CHAR_TOTKI][0] = strval(tmp);
		    
		    mysql_fetch_field_row(tmp, "CHAR_CREATED2"); PlayerChars[playerid][E_CHAR_CREATED][1] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_NAME2");    strmid(CharName[playerid][1], tmp, 0, 24, 24);
		    mysql_fetch_field_row(tmp, "CHAR_SKINID2");  PlayerChars[playerid][E_CHAR_SKINID][1] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_KI2");  	 PlayerChars[playerid][E_CHAR_KI][1] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_TOTKI2"); 	 PlayerChars[playerid][E_CHAR_TOTKI][1] = strval(tmp);
		    
		    mysql_fetch_field_row(tmp, "CHAR_CREATED3"); PlayerChars[playerid][E_CHAR_CREATED][2] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_NAME3");    strmid(CharName[playerid][2], tmp, 0, 24, 24);
		    mysql_fetch_field_row(tmp, "CHAR_SKINID3");  PlayerChars[playerid][E_CHAR_SKINID][2] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_KI3");  	 PlayerChars[playerid][E_CHAR_KI][2] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_TOTKI3"); 	 PlayerChars[playerid][E_CHAR_TOTKI][2] = strval(tmp);
		    
		    mysql_fetch_field_row(tmp, "CHAR_CREATED4"); PlayerChars[playerid][E_CHAR_CREATED][3] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_NAME4");    strmid(CharName[playerid][3], tmp, 0, 24, 24);
		    mysql_fetch_field_row(tmp, "CHAR_SKINID4");  PlayerChars[playerid][E_CHAR_SKINID][3] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_KI4");  	 PlayerChars[playerid][E_CHAR_KI][3] = strval(tmp);
		    mysql_fetch_field_row(tmp, "CHAR_TOTKI4"); 	 PlayerChars[playerid][E_CHAR_TOTKI][3] = strval(tmp);
		}
		mysql_free_result();

		// Wymuú gracza do uøycia postaci ze slotu '0'.
		PlayerChars[playerid][E_SELECT_CHAR] = 0;
		PlayerChars[playerid][E_CHOSEN_SLOT] = 0;
		
		PlayerData[playerid][E_PLAYER_LOGGED] = true;

		// Pokaø graczowi jego listÍ postaci.
		CreatePlayerTextDraws(playerid);
		ShowPlayerCharactersList(playerid, true);
		SetPlayerSkin(playerid, PlayerChars[playerid][E_CHAR_SKINID][0]);
	    SetPlayerVirtualWorld(playerid, playerid);
		SetPlayerPos(playerid, 619.9042, -2548.7219, 3.6678);
		SetPlayerFacingAngle(playerid, 46.8508);
		ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);
		
		InterpolateCameraPos(playerid, 618.5688, -2505.0771, 1.9345, 619.3730, -2543.8401, 2.5876, 4000);
		InterpolateCameraLookAt(playerid, 618.5833, -2506.0806, 2.1645, 619.5887, -2544.8220, 2.8676, 4000);
	}
	
	// B≥Ídne has≥o.
	else
	{
	    SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Sign in", "Welcome back!\nPlease enter your account password below:", "Sign in", "Quit");
	}
	return 1;
}

CMD:chars(playerid, params[])
{
    ShowPlayerCharactersList(playerid, true);
	SetPlayerSkin(playerid, PlayerChars[playerid][E_CHAR_SKINID][ PlayerChars[playerid][E_CHOSEN_SLOT] ]);
	SetPlayerVirtualWorld(playerid, playerid);
	SetPlayerPos(playerid, 619.9042, -2548.7219, 3.6678);
	SetPlayerFacingAngle(playerid, 46.8508);
	ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 4.1, 1, 0, 0, 0, 0, 1);

	SetPlayerCameraPos(playerid, 619.3730, -2543.8401, 2.5876);
	SetPlayerCameraLookAt(playerid, 619.5887, -2544.8220, 2.8676);
	return 1;
}

// --- Gdy gracz siÍ wyloguje ---
stock OnPlayerSignOut(playerid)
{
	// Zapis statystyk gracza.
	new query[500];
	format(query, sizeof(query), "UPDATE `playerdata` SET \
		`CHAR_CREATED1` = %d, `CHAR_NAME1` = '%s', `CHAR_SKINID1` = %d, `CHAR_KI1` = %d, `CHAR_TOTKI1` = %d, \
		`CHAR_CREATED2` = %d, `CHAR_NAME2` = '%s', `CHAR_SKINID2` = %d, `CHAR_KI2` = %d, `CHAR_TOTKI2` = %d, \
		`CHAR_CREATED3` = %d, `CHAR_NAME3` = '%s', `CHAR_SKINID3` = %d, `CHAR_KI3` = %d, `CHAR_TOTKI3` = %d, \
		`CHAR_CREATED4` = %d, `CHAR_NAME4` = '%s', `CHAR_SKINID4` = %d, `CHAR_KI4` = %d, `CHAR_TOTKI4` = %d",
	PlayerChars[playerid][E_CHAR_CREATED][0], CharName[playerid][0], PlayerChars[playerid][E_CHAR_SKINID][0], PlayerChars[playerid][E_CHAR_KI][0], PlayerChars[playerid][E_CHAR_TOTKI][0],
	PlayerChars[playerid][E_CHAR_CREATED][1], CharName[playerid][1], PlayerChars[playerid][E_CHAR_SKINID][1], PlayerChars[playerid][E_CHAR_KI][1], PlayerChars[playerid][E_CHAR_TOTKI][1],
	PlayerChars[playerid][E_CHAR_CREATED][2], CharName[playerid][2], PlayerChars[playerid][E_CHAR_SKINID][2], PlayerChars[playerid][E_CHAR_KI][2], PlayerChars[playerid][E_CHAR_TOTKI][2],
	PlayerChars[playerid][E_CHAR_CREATED][3], CharName[playerid][3], PlayerChars[playerid][E_CHAR_SKINID][3], PlayerChars[playerid][E_CHAR_KI][3], PlayerChars[playerid][E_CHAR_TOTKI][3]);
	mysql_query(query);
	
	// Niszczenie textdraw'Ûw.
	DestroyPlayerProgressBar(playerid, PlayerBar:PlayerTextDraw[E_PLAYER_KI_BAR]);
	
	// - > Wybieralka postaci.
	for(new i = 0; i != 4; i++)
	{
	    PlayerTextDrawDestroy(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][i]);
	}
	
	// - > Lista postaci.
	for(new i = 0; i != 3; i++)
	{
	    PlayerTextDrawDestroy(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][i]);
	}

	// - > Wszystkie box'y + informacje w box'ach.
	for(new i = 0; i != 6; i++)
	{
	    PlayerTextDrawDestroy(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][i]);
	    PlayerTextDrawDestroy(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][i]);
	}
	return 1;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// --- Tworzenie TextDraw'Ûw ---
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
stock CreatePlayerTextDraws(playerid)
{
	// Pasek energii.
	PlayerTextDraw[E_PLAYER_KI_BAR] = CreatePlayerProgressBar(playerid, 548.00, 47.00, 57.50, 4.19, -138658817, 0.0);
	
	// --- Wybieralka postaci ---
	PlayerTextDraw[E_PLAYER_REQUESTCLASS][0] = CreatePlayerTextDraw(playerid, 401.218780, 398.166748, "BACKGROUND_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 0.000000, 2.346298);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 249.718811, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][0], 0);

	PlayerTextDraw[E_PLAYER_REQUESTCLASS][1] = CreatePlayerTextDraw(playerid, 291.500000, 400.166687, "SELECT");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 362.000000, 19.249992);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][1], true);

	PlayerTextDraw[E_PLAYER_REQUESTCLASS][2] = CreatePlayerTextDraw(playerid, 253.500000, 396.083404, "LD_BEAT:left");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 27.000000, 26.249979);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][2], true);

	PlayerTextDraw[E_PLAYER_REQUESTCLASS][3] = CreatePlayerTextDraw(playerid, 370.500000, 396.083404, "LD_BEAT:right");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 27.000000, 26.249979);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], 4);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_REQUESTCLASS][3], true);

	// --- Lista postaci ---
	PlayerTextDraw[E_PLAYER_CHARLIST][0] = CreatePlayerTextDraw(playerid, 441.500000, 64.166671, "_");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 173.531478, 322.583953);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 3);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], -103);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][0], 4);

	PlayerTextDraw[E_PLAYER_CHARLIST][1] = CreatePlayerTextDraw(playerid, 588.500000, 57.166664, "CHARACTER_LIST");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 3);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][1], 1);

	PlayerTextDraw[E_PLAYER_CHARLIST][2] = CreatePlayerTextDraw(playerid, 590.453125, 48.416652, "DBZ:DB4");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 29.500000, 29.166656);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 3);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST][2], 4);

	// Box'y.
	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0] = CreatePlayerTextDraw(playerid, 612.500000, 95.416671, "FIRST_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 0.000000, 4.890738);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 446.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][0], 1);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1] = CreatePlayerTextDraw(playerid, 612.000000, 160.416671, "SECOND_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 0.000000, 4.890738);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 446.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][1], 0);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2] = CreatePlayerTextDraw(playerid, 612.000000, 225.416671, "THIRD_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 0.000000, 4.890738);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 446.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][2], 0);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3] = CreatePlayerTextDraw(playerid, 612.000000, 290.416656, "FOURTH_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 0.000000, 4.890738);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 446.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][3], 0);
	
	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4] = CreatePlayerTextDraw(playerid, 523.500000, 353.833282, "CHOOSE_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 0.000000, 1.562958);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 446.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][4], 0);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5] = CreatePlayerTextDraw(playerid, 612.500000, 353.833221, "CANCEL_BOX");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 0.000000, 1.562958);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 535.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 0);
	PlayerTextDrawUseBox(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], true);
	PlayerTextDrawBoxColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 102);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 0);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXES][5], 0);
	
	// Informacje w box'ach.
	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0] = CreatePlayerTextDraw(playerid, 450.000000, 96.250000, "EMPTY_SLOT1");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 608.500000, 46.666667);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][0], true);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1] = CreatePlayerTextDraw(playerid, 450.000000, 160.250000, "EMPTY_SLOT2");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 608.500000, 46.666667);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][1], true);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2] = CreatePlayerTextDraw(playerid, 450.000000, 224.250000, "EMPTY_SLOT3");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 608.500000, 46.666667);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][2], true);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3] = CreatePlayerTextDraw(playerid, 450.000000, 290.250000, "EMPTY_SLOT4");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 608.500000, 46.666667);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 1);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][3], true);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4] = CreatePlayerTextDraw(playerid, 454.000000, 353.119995, "CHOOSE");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 0.371499, 1.617498);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 520.500000, 60.666679);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][4], true);

	PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5] = CreatePlayerTextDraw(playerid, 544.000000, 353.119995, "CANCEL");
	PlayerTextDrawLetterSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 0.371499, 1.617498);
	PlayerTextDrawTextSize(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 608.000000, 62.999988);
	PlayerTextDrawAlignment(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 1);
	PlayerTextDrawColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], -1);
	PlayerTextDrawSetShadow(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 0);
	PlayerTextDrawSetOutline(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 1);
	PlayerTextDrawBackgroundColor(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 51);
	PlayerTextDrawFont(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 2);
	PlayerTextDrawSetProportional(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerTextDraw[E_PLAYER_CHARLIST_BOXINFO][5], true);
	return 1;
}
