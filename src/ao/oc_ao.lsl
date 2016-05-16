//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//       _   ___     __            __  ___  _                               //
//      | | / (_)___/ /___ _____ _/ / / _ \(_)__ ___ ________ ________      //
//      | |/ / / __/ __/ // / _ `/ / / // / (_-</ _ `/ __/ _ `/ __/ -_)     //
//      |___/_/_/  \__/\_,_/\_,_/_/ /____/_/___/\_, /_/  \_,_/\__/\__/      //
//                                             /___/                        //
//                                                                          //
//                                        _                                 //
//                                        \`*-.                             //
//                                         )  _`-.                          //
//                                        .  : `. .                         //
//                                        : _   '  \                        //
//                                        ; *` _.   `*-._                   //
//                                        `-.-'          `-.                //
//                                          ;       `       `.              //
//                                          :.       .        \             //
//                                          . \  .   :   .-'   .            //
//                                          '  `+.;  ;  '      :            //
//                                          :  '  |    ;       ;-.          //
//                                          ; '   : :`-:     _.`* ;         //
//     OpenCollar AO - 160515.4          .*' /  .*' ; .*`- +'  `*'          //
//                                       `*-*   `*-*  `*-*'                 //
// ------------------------------------------------------------------------ //
//  Copyright (c) 2008 - 2016 Nandana Singh, Jessenia Mocha, Alexei Maven,  //
//  Wendy Starfall, littlemousy, Romka Swallowtail, Garvin Twine et al.     //
// ------------------------------------------------------------------------ //
//  This script is free software: you can redistribute it and/or modify     //
//  it under the terms of the GNU General Public License as published       //
//  by the Free Software Foundation, version 2.                             //
//                                                                          //
//  This script is distributed in the hope that it will be useful,          //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this script; if not, see www.gnu.org/licenses/gpl-2.0        //
// ------------------------------------------------------------------------ //
//  This script and any derivatives based on it must remain "full perms".   //
//                                                                          //
//  "Full perms" means maintaining MODIFY, COPY, and TRANSFER permissions   //
//  in Second Life(R), OpenSimulator and the Metaverse.                     //
//                                                                          //
//  If these platforms should allow more fine-grained permissions in the    //
//  future, then "full perms" will mean the most permissive possible set    //
//  of permissions allowed by the platform.                                 //
// ------------------------------------------------------------------------ //
//           github.com/OpenCollar/opencollar/tree/master/src/ao            //
// ------------------------------------------------------------------------ //
//////////////////////////////////////////////////////////////////////////////

string g_sFancyVersion = "⁶⋅¹⋅⁰";
float g_fBuildVersion = 160515.3;
integer g_iUpdateAvailable;
key g_kWebLookup;

integer g_iInterfaceChannel = -12587429;
integer g_iHUDChannel = -1812221819;
string g_sPendingCmd;

key g_kWearer;
string g_sCard;
integer g_iCardLine;
key g_kCard;
integer g_iReady;

list g_lAnimStates = [
        "Crouching",            //00
        "CrouchWalking",        //01
        "Falling Down",         //02 
        "Flying",               //03
        "FlyingSlow",           //04
        "Hovering",             //05
        "Hovering Down",        //06
        "Hovering Up",          //07
        "Jumping",              //08
        "Landing",              //09
        "PreJumping",           //10
        "Running",              //11
        "Standing",             //12
        "Sitting",              //13
        "Sitting on Ground",    //14
        "Standing Up",          //15
        "Striding",             //16
        "Soft Landing",         //17
        "Taking Off",           //18
        "Turning Left",         //19
        "Turning Right",        //20
        "Walking"               //21
        ];

string g_sJson_Anims = "{}";
string g_sJsonNull;
integer g_iAO_ON = TRUE;
integer g_iSitAnimOn;
string g_sSitAnim;
integer g_iSitAnywhereOn;
string g_sSitAnywhereAnim;
string g_sWalkAnim;
integer g_iChangeInterval = 45;
integer g_iLocked;
integer g_iShuffle;
integer g_iStandPause;

list g_lMenuIDs;
list g_lAnims2Choose;
/*
integer g_iProfiled;
Debug(string sStr) {
    if (!g_iProfiled){
        g_iProfiled=1;
        llScriptProfiler(1);
    }
    llOwnerSay(llGetScriptName() + "(min free:"+(string)(llGetMemoryLimit()-llGetSPMaxMemory())+")["+(string)llGetFreeMemory()+"] :\n" + sStr);
}*/

//options
float g_fGap = 0.001; // This is the space between buttons
float g_Yoff = 0.002; // space between buttons and screen top/bottom border
float g_Zoff = 0.04; // space between buttons and screen left/right border

list g_lButtons ; // buttons names for Order menu
list g_lPrimOrder = [0,1,2,3,4]; // -- List must always start with '0','1'
// -- 0:Spacer, 1:Root, 2:Power, 3:Sit Anywhere, 4:Menu
// -- Spacer serves to even up the list with actual link numbers

integer g_iLayout = 1;
integer g_iHidden = FALSE;
integer g_iPosition = 69;
integer g_iOldPos;
integer g_iNewPos;

vector g_vAOoffcolor = <0.5,0.5,0.5>;
vector g_vAOoncolor = <1,1,1>;
string g_sDarkLock = "e633ced3-2327-4288-8d4f-7cc530be0faa";
string g_sLightLock = "8aadf1ed-63d1-2bc5-174b-7c074f676b88";

string g_sTexture = "Dark"; // current style

FindButtons() { // collect buttons names & links
    g_lButtons = [" ", "Minimize"] ; // 'Minimize' need for g_sTexture
    g_lPrimOrder = [0, 1];  //  '1' - root prim
    integer i;
    for (i=2; i<=llGetNumberOfPrims(); ++i) {
        g_lButtons += llGetLinkPrimitiveParams(i, [PRIM_DESC]);
        g_lPrimOrder += i;
    }
}

DoPosition(float yOff, float zOff) {   // Places the buttons
    integer i;
    integer LinkCount=llGetListLength(g_lPrimOrder);
    for (i=2;i<=LinkCount;++i) {
        llSetLinkPrimitiveParamsFast(llList2Integer(g_lPrimOrder,i),[PRIM_POSITION,<0, yOff*(i-1), zOff*(i-1)>]);
    }
}

DoTextures(string style) {
    list lTextures = [
    "Dark",
    "Minimize~e1482c7e-8609-fcb0-56d8-18c3c94d21c0",
    "Power~e630e9e0-799e-6acc-e066-196cca7b37d4",
    "SitAny~251b2661-235e-b4d8-0c75-248b6bdf6675",
    "Menu~f3ec1052-6ec4-04ba-d752-937a4d837bf8",
    "Light",
    "Minimize~b59f9932-5de4-fc23-b5aa-2ab46d22c9a6",
    "Power~42d4d624-ca72-1c74-0045-f782d7409061",
    "SitAny~349340c5-0045-c32d-540e-52b6fb77af55",
    "Menu~52c3f4cf-e87e-dbdd-cf18-b2c4f6002a96"
    ];
    integer i = llListFindList(lTextures,[style]);
    integer iEnd = i+4;
    while (++i <= iEnd) {
        string sData = llStringTrim(llList2String(lTextures,i),STRING_TRIM);
        list lParams = llParseStringKeepNulls(sData,["~"],[]);
        string sButton = llStringTrim(llList2String(lParams,0),STRING_TRIM);
        integer link = llListFindList(g_lButtons,[sButton]);
        if (link > 0) {
            sData = llStringTrim(llList2String(lParams,1),STRING_TRIM);
            if (sData != "" && sData != ",") {
                llSetLinkPrimitiveParamsFast(link,[PRIM_TEXTURE, ALL_SIDES, sData, <1,1,0>, ZERO_VECTOR, 0]);
            }
        }
    }
}

DefinePosition() {
    integer iPosition = llGetAttached();
    vector vSize = llGetScale();
//  Allows manual repositioning, without resetting it, if needed
    if (iPosition != g_iPosition && iPosition > 30) { //do this only when attached to the hud
        vector vOffset = <0, vSize.y/2+g_Yoff, vSize.z/2+g_Zoff>;
        if (iPosition == ATTACH_HUD_TOP_RIGHT || iPosition == ATTACH_HUD_TOP_CENTER || iPosition == ATTACH_HUD_TOP_LEFT) vOffset.z = -vOffset.z;
        if (iPosition == ATTACH_HUD_TOP_LEFT || iPosition == ATTACH_HUD_BOTTOM_LEFT) vOffset.y = -vOffset.y;
        llSetPos(vOffset); // Position the Root Prim on screen
        g_iPosition = iPosition;
    }
    if (g_iHidden) llSetLinkPrimitiveParamsFast(LINK_ALL_OTHERS, [PRIM_POSITION,<1,0,0>]);
    else {
        float fYoff = vSize.y + g_fGap;
        float fZoff = vSize.z + g_fGap;
        if (iPosition == ATTACH_HUD_TOP_LEFT || iPosition == ATTACH_HUD_TOP_CENTER || iPosition == ATTACH_HUD_TOP_RIGHT)
            fZoff = -fZoff;
        if (iPosition == ATTACH_HUD_TOP_CENTER || iPosition == ATTACH_HUD_TOP_LEFT || iPosition == ATTACH_HUD_BOTTOM || iPosition == ATTACH_HUD_BOTTOM_LEFT)
            fYoff = -fYoff;
        if (iPosition == ATTACH_HUD_TOP_CENTER || iPosition == ATTACH_HUD_BOTTOM) g_iLayout = 0;
        if (g_iLayout) fYoff = 0;
        else fZoff = 0;
        DoPosition(fYoff, fZoff);
    }
}

DoButtonOrder() {   // -- Set the button order and reset display
    integer iOldPos = llList2Integer(g_lPrimOrder,g_iOldPos);
    integer iNewPos = llList2Integer(g_lPrimOrder,g_iNewPos);
    integer i = 2;
    list lTemp = [0,1];
    for(;i<llGetListLength(g_lPrimOrder);++i) {
        integer iTempPos = llList2Integer(g_lPrimOrder,i);
        if (iTempPos == iOldPos) lTemp += [iNewPos];
        else if (iTempPos == iNewPos) lTemp += [iOldPos];
        else lTemp += [iTempPos];
    }
    g_lPrimOrder = lTemp;
    g_iOldPos = -1;
    g_iNewPos = -1;
    DefinePosition();
}

DetermineColors() {
    g_vAOoncolor = llGetColor(0);
    g_vAOoffcolor = g_vAOoncolor/2;
    DoStatus();
}

DoStatus() {
    vector vColor = g_vAOoffcolor;
    if (g_iAO_ON) vColor = g_vAOoncolor;
    llSetLinkColor(llListFindList(g_lButtons,["Power"]), vColor, ALL_SIDES);
    if (g_iSitAnywhereOn) vColor = g_vAOoncolor;
    else vColor = g_vAOoffcolor;
    llSetLinkColor(llListFindList(g_lButtons,["SitAny"]), vColor, ALL_SIDES);
}

//ao functions

SetAnimOverride(integer iAfterReadCard) {
    llResetAnimationOverride("ALL");
    integer i;
    if (g_sSitAnywhereAnim == "") {
        g_sSitAnywhereAnim = llJsonGetValue(g_sJson_Anims,["Sitting on Ground"]);
        i = llSubStringIndex(g_sSitAnywhereAnim,",");
        if (~i) g_sSitAnywhereAnim = llGetSubString(g_sSitAnywhereAnim,0,i-1);
        else if (g_sSitAnywhereAnim == g_sJsonNull) g_sSitAnywhereAnim = "";
        if (g_sSitAnywhereAnim) llSetAnimationOverride("Sitting on Ground",g_sSitAnywhereAnim);
    }
    if (g_sSitAnim == "") {
        g_sSitAnim = llJsonGetValue(g_sJson_Anims,["Sitting"]);
        i = llSubStringIndex(g_sSitAnim,",");
        if (~i) g_sSitAnim = llGetSubString(g_sSitAnim,0,i-1);
        else if (g_sSitAnim == g_sJsonNull) g_sSitAnim = "";
    }
    if (g_sWalkAnim == "") {
        g_sWalkAnim = llJsonGetValue(g_sJson_Anims,["Walking"]);
        i = llSubStringIndex(g_sSitAnim,",");
        if (~i) g_sWalkAnim = llGetSubString(g_sWalkAnim,0,i-1);
        else if (g_sWalkAnim == g_sJsonNull) g_sWalkAnim = "";
    }
    i = 22;
    string sAnim;
    string sAnimState;
    do {
        sAnimState = llList2String(g_lAnimStates,i);
        if (~llSubStringIndex(g_sJson_Anims,sAnimState)) {
            sAnim = llJsonGetValue(g_sJson_Anims,[sAnimState]);
            if (~llSubStringIndex(sAnim,",")) 
                sAnim = llList2String(llParseString2List(sAnim,[","],[]),0);
            else if (sAnim == g_sJsonNull) jump next;
            if (llGetInventoryType(sAnim) == INVENTORY_ANIMATION) {
                if (sAnimState != "Sitting" || g_iSitAnimOn) {
                    if (sAnimState == "Walking" && g_sWalkAnim != "") 
                        llSetAnimationOverride(sAnimState, g_sWalkAnim);
                    else if (sAnimState == "Sitting" && g_sSitAnim != "") 
                        llSetAnimationOverride(sAnimState, g_sSitAnim);
                    else llSetAnimationOverride(sAnimState, sAnim);
                }
            } else llOwnerSay(sAnim+" could not be found.");
        }
        @next;
    } while (i--);
    llSetTimerEvent(g_iChangeInterval);
    if (iAfterReadCard) llOwnerSay("AO ready ("+(string)((100*llGetFreeMemory())/65536)+"% free memory)");
}

SwitchAOAnim(string sAnimState) {
    string sCurAnim = llGetAnimationOverride(sAnimState);
    string sTest = llJsonGetValue(g_sJson_Anims, [sAnimState]);
    list lAnims = llParseString2List(sTest, [","],[]);
    integer index;
    if (g_iShuffle && sAnimState == "Standing") 
        index = (integer)llFrand(llGetListLength(lAnims));
    else {
        index = llListFindList(lAnims,[sCurAnim]);
        if (index == llGetListLength(lAnims)-1) index = 0;
        else index += 1;
    }
    if (g_iReady) llSetAnimationOverride(sAnimState, llList2String(lAnims,index));
}

ToggleSitAnywhere() {
    if (g_iStandPause)
        llOwnerSay("SitAnywhere is not possible while you are in a collar pose.");
    else if (g_iAO_ON) {
        if (g_iSitAnywhereOn) {
            llSetTimerEvent(g_iChangeInterval);
            SwitchAOAnim("Standing");
        } else {
            llSetTimerEvent(0.0);
            llSetAnimationOverride("Standing",g_sSitAnywhereAnim);
        }
        g_iSitAnywhereOn = !g_iSitAnywhereOn;
        DoStatus();
    } else llOwnerSay("SitAnywhere is not possible while the AO is turned off.");
}

Notify(key kID, string sStr, integer iAlsoNotifyWearer) {
    if (kID == g_kWearer) llOwnerSay(sStr);
    else {
        llRegionSayTo(kID,0,sStr);
        if (iAlsoNotifyWearer) llOwnerSay(sStr);
    }
}

//menus

Dialog(key kID, string sPrompt, list lChoices, list lUtilityButtons, string sName) {
    integer iChannel = llRound(llFrand(10000000)) + 100000;  
    while (~llListFindList(g_lMenuIDs, [iChannel]))
        iChannel = llRound(llFrand(10000000)) + 100000;
    integer iListener = llListen(iChannel, "",kID, "");
    integer iTime = llGetUnixTime() + 180;
    integer iIndex = llListFindList(g_lMenuIDs, [kID]);
    if (~iIndex) g_lMenuIDs = llListReplaceList(g_lMenuIDs,[kID, iChannel, iListener, iTime, sName],iIndex,iIndex+4);
    else g_lMenuIDs += [kID, iChannel, iListener, iTime, sName];
    if (!g_iAO_ON || !g_iChangeInterval) llSetTimerEvent(20);
    llDialog(kID,sPrompt,SortButtons(lChoices,lUtilityButtons),iChannel);
}

list SortButtons(list lButtons, list lStaticButtons) {
    list lSpacers;
    list lAllButtons = lButtons + lStaticButtons;
    //cutting off too many buttons, no multi page menus as of now
    while (llGetListLength(lAllButtons)>12) {
        lButtons = llDeleteSubList(lButtons,0,0);
        lAllButtons = lButtons + lStaticButtons;
    }
    while (llGetListLength(lAllButtons) % 3 != 0 && llGetListLength(lAllButtons) < 12) {
        lSpacers += "-";
        lAllButtons = lButtons + lSpacers + lStaticButtons;
    }
    integer i = llListFindList(lAllButtons, ["BACK"]);
    if (~i) lAllButtons = llDeleteSubList(lAllButtons, i, i);
    list lOut = llList2List(lAllButtons, 9, 11);
    lOut += llList2List(lAllButtons, 6, 8);
    lOut += llList2List(lAllButtons, 3, 5);
    lOut += llList2List(lAllButtons, 0, 2);
    if (~i) lOut = llListInsertList(lOut, ["BACK"], 2);
    return lOut;
}

MenuAO(key kID) {
    string sPrompt = "\n[http://www.opencollar.at/ao.html OpenCollar AO]\t"+g_sFancyVersion;
    if (g_iUpdateAvailable) sPrompt+= "\n\nUPDATE AVAILABLE: A new patch has been released.\nPlease install at your earliest convenience. Thanks!\n\nwww.opencollar.at/updates";
    list lButtons = ["LOCK"];
    if (g_iLocked) lButtons = ["UNLOCK"];
    if (kID == g_kWearer) lButtons += "Collar Menu";
    else lButtons += "-";
    lButtons += ["Load","Sits","Ground Sits","Walks"];
    if (g_iSitAnimOn) lButtons += ["Sits ☒"];
    else lButtons += ["Sits ☐"];
    if (g_iShuffle) lButtons += "Shuffle ☒";
    else lButtons += "Shuffle ☐";
    lButtons += ["Stand Time","Next Stand"];
    if (kID == g_kWearer) lButtons += "HUD Style";
    Dialog(kID, sPrompt, lButtons, ["Cancel"], "AO");
}

MenuLoad(key kID) {
    string sPrompt = "\nChoose one of the configuration notecards to load:";
    list lButtons;
    integer i = llGetInventoryNumber(INVENTORY_NOTECARD);
    string sNotecardName;
    do {
        sNotecardName = llGetInventoryName(INVENTORY_NOTECARD, --i);
        if (llSubStringIndex(sNotecardName,".") && sNotecardName != "") lButtons += sNotecardName;
    } while (i > 0);
    Dialog(kID, sPrompt, llListSort(lButtons,1,TRUE), ["BACK"],"Load");
}

MenuInterval(key kID) {
    string sInterval = "won't change automatically.";
    if (g_iChangeInterval) sInterval = "change every "+(string)g_iChangeInterval+" seconds.";
    Dialog(kID, "\nStands " +sInterval, ["Never","20","30","45","60","90","120","180"], ["BACK"],"Interval");
}

MenuChooseAnim(key kID, string sAnimState) {
    string sAnim = g_sSitAnywhereAnim;
    if (sAnimState == "Walking") sAnim = g_sWalkAnim;
    else if (sAnimState == "Sitting") sAnim = g_sSitAnim;
    string sPrompt = "\n"+sAnimState+": \""+sAnim+"\"\n";
    g_lAnims2Choose = llListSort(llParseString2List(llJsonGetValue(g_sJson_Anims,[sAnimState]),[","],[]),1,TRUE);
    list lButtons;
    integer iEnd = llGetListLength(g_lAnims2Choose);
    integer i;
    while (++i<=iEnd) {
        lButtons += (string)i;
        sPrompt += "\n"+(string)i+": "+llList2String(g_lAnims2Choose,i-1);
    }
    Dialog(kID, sPrompt, lButtons, ["BACK"],sAnimState);
}

MenuOptions(key kID) {
    Dialog(kID,"\nCustomize your AO!",["Horizontal","Vertical","Order","Dark","Light"],["BACK"], "options");
}

OrderMenu(key kID) {
    string sPrompt = "\nWhich button do you want to re-order?";
    integer i;
    list lButtons;
    integer iPos;
    for (i=2;i<llGetListLength(g_lPrimOrder);++i) {
        iPos = llList2Integer(g_lPrimOrder,i);
        lButtons += llList2List(g_lButtons,iPos,iPos);
    }
    Dialog(kID, sPrompt, lButtons, ["Reset","BACK"], "ordermenu");
}

//command handling

TranslateCollarCMD(integer iAuth,string sCommand, key kID){
    if (!llSubStringIndex(sCommand,"ZHAO_"))
        sCommand = llToLower(llGetSubString(sCommand,5,-1));
    else return;
    if (g_iLocked && sCommand == "unlock") {
        if (iAuth <= g_iLocked) Command(kID,sCommand);
        else Notify(kID,"Access denied!",FALSE);
    } else if (sCommand == "lock") {
        if (iAuth == 500 || kID == g_kWearer) Command(kID,"lock "+(string)iAuth);
    } else if (!llSubStringIndex(sCommand,"stand")) {
        if (~llSubStringIndex(sCommand,"on")) {
            g_iStandPause = TRUE;
            llResetAnimationOverride("Standing");
        } else if (~llSubStringIndex(sCommand,"off")) {
            g_iStandPause = FALSE;
            SwitchAOAnim("Standing");
        }        
    } else if ((!g_iLocked && iAuth) || (iAuth <= g_iLocked)) {
        if (~llSubStringIndex(sCommand,"menu")) MenuAO(kID);
        if (!g_iLocked && !llSubStringIndex(sCommand,"ao")) Command(kID,llGetSubString(sCommand,2,-1));
    }
}

Command(key kID, string sCommand) {
    list lParams = llParseString2List(sCommand,[" "],[]);
    sCommand = llList2String(lParams,0);
    string sValue = llList2String(lParams,1);
    if (!g_iReady) {
        Notify(kID,"Please load a configuration card first!",TRUE);
        MenuLoad(kID);
        return;
    } else if (sCommand == "on") {
        SetAnimOverride(TRUE);
        g_iAO_ON = TRUE;
        llSetTimerEvent(g_iChangeInterval);
        DoStatus();
    } else if (sCommand == "off") {
        llResetAnimationOverride("ALL");
        g_iAO_ON = FALSE;
        llSetTimerEvent(0.0);
        DoStatus();
    } else if (sCommand == "unlock") {
        g_iLocked = FALSE;
        llOwnerSay("@detach=y");
        g_iHidden = FALSE;
        DefinePosition();
        DoTextures(g_sTexture);
        Notify(kID,"AO unlocked!",FALSE);
    } else if (sCommand == "lock") {
        g_iLocked = (integer)sValue;
        llOwnerSay("@detach=n");
        g_iHidden = TRUE;
        DefinePosition();
        Notify(kID,"AO locked!",FALSE);
        integer iLink = llListFindList(g_lButtons,["Minimize"]);
        if (g_sTexture == "Dark")
            llSetLinkPrimitiveParamsFast(iLink,[PRIM_TEXTURE, ALL_SIDES, g_sDarkLock, <1,1,0>, ZERO_VECTOR, 0]);
        else if (g_sTexture == "Light")
            llSetLinkPrimitiveParamsFast(iLink,[PRIM_TEXTURE, ALL_SIDES, g_sLightLock, <1,1,0>, ZERO_VECTOR, 0]);
    } else if (sCommand == "menu") MenuAO(kID);
}

StartUpdate(key kID) {
    integer iPin = (integer)llFrand(99999998.0) + 1;
    llSetRemoteScriptAccessPin(iPin);
    llRegionSayTo(kID, -7483220, "ready|" + (string)iPin );
}

default {
    state_entry() {
        if (llGetInventoryType("oc_installer_sys")==INVENTORY_SCRIPT) return;
        g_kWearer = llGetOwner();
        g_sJsonNull = llUnescapeURL("%EF%B7%90");
        g_iInterfaceChannel = -llAbs((integer)("0x" + llGetSubString(g_kWearer,30,-1)));
        llListen(g_iInterfaceChannel, "", "", "");
        g_iHUDChannel = -llAbs((integer)("0x"+llGetSubString((string)llGetOwner(),-7,-1)));
        FindButtons();
        DefinePosition();
        DoTextures("Dark");
        DetermineColors();
        MenuLoad(g_kWearer);
    }
    
    on_rez(integer iStart) {
        if (g_kWearer != llGetOwner()) llResetScript();
        if (g_iLocked) llOwnerSay("@detach=n");
        g_iReady = FALSE;
        g_kWebLookup = llHTTPRequest("https://raw.githubusercontent.com/VirtualDisgrace/Collar/live/web/~ao", [HTTP_METHOD, "GET"],"");
        llRequestPermissions(g_kWearer,PERMISSION_OVERRIDE_ANIMATIONS);
    }
    
    attach(key kID) {
        if (kID == NULL_KEY) llResetAnimationOverride("ALL");
        else if (llGetAttached() <= 30) {
            llOwnerSay("Sorry, this device can only be attached to the HUD.");
            llRequestPermissions(kID, PERMISSION_ATTACH);
            llDetachFromAvatar();
        } else DefinePosition();
    }
    
    touch_start(integer total_number) {
        if(llGetAttached()) {
            if (g_iLocked) return;
            string sButton = (string)llGetObjectDetails(llGetLinkKey(llDetectedLinkNumber(0)),[OBJECT_DESC]);
            string sMessage = "";
            if (sButton == "Menu") 
                MenuAO(g_kWearer);
            else if (sButton == "SitAny") {
                if (!g_iLocked) ToggleSitAnywhere();
            } else if (llSubStringIndex(llToLower(sButton),"ao")>=0) {   // The Hide Button
                g_iHidden = !g_iHidden;
                DefinePosition();
            } else if (sButton == "Power") {
                if (g_iAO_ON) Command(g_kWearer,"off");
                else if (g_iReady) Command(g_kWearer,"on");
            }
        } else if (llDetectedKey(0) == g_kWearer) MenuAO(g_kWearer);
    }
    
    listen(integer iChannel, string sName, key kID, string sMessage) {
        if (iChannel == g_iInterfaceChannel) {
            if (llGetOwnerKey(kID) != g_kWearer) return;    
            if (llUnescapeURL(sMessage) == "SAFEWORD") {
                if (g_iLocked) {
                    Command(g_kWearer,"unlock");
                    Notify(g_kWearer,"AO unlocked due to safeword usage.",FALSE);
                }
                return;
            } else if (sMessage == "-.. --- / .- ---") {
                StartUpdate(kID);
                return;
            }
            list lParams = llParseString2List(sMessage,["|"],[]);
            string sMessageType = llList2String(lParams,0);
            integer iAuth;
            if (sMessageType == "AuthReply") {
                iAuth = llList2Integer(lParams,2);
                if (g_sPendingCmd) {
                    TranslateCollarCMD(iAuth,g_sPendingCmd, llList2Key(lParams,1));
                    g_sPendingCmd = "";
                }
            } else if (sMessageType == "CollarCommand") {
                iAuth = llList2Integer(lParams,1);
                TranslateCollarCMD(iAuth,llList2String(lParams,2), llList2Key(lParams,3));
            }
        } else if (~llListFindList(g_lMenuIDs,[kID, iChannel])) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            string sMenuType = llList2String(g_lMenuIDs, iMenuIndex+4);
            llListenRemove(llList2Integer(g_lMenuIDs,iMenuIndex+2));
            g_lMenuIDs = llDeleteSubList(g_lMenuIDs,iMenuIndex, iMenuIndex+4);
            if (llGetListLength(g_lMenuIDs) == 0 && (!g_iAO_ON || !g_iChangeInterval)) llSetTimerEvent(0.0);
            if (sMenuType == "AO") {
                if (sMessage == "Cancel") return;
                else if (sMessage == "-") MenuAO(kID);
                else if (g_iLocked && sMessage != "UNLOCK") {
                    Notify(kID,"Unlock the AO first!",FALSE);
                    return;
                } else if (~llSubStringIndex(sMessage,"LOCK")) {
                    g_sPendingCmd = "ZHAO_"+sMessage;
                    llRegionSayTo(g_kWearer,g_iInterfaceChannel,"AuthRequest|"+(string)kID);
                } else if (sMessage == "HUD Style") MenuOptions(kID);
                else if (sMessage == "Load") MenuLoad(kID);
                else if (sMessage == "Sits") MenuChooseAnim(kID,"Sitting");
                else if (sMessage == "Walks") MenuChooseAnim(kID,"Walking");
                else if (sMessage == "Ground Sits") MenuChooseAnim(kID,"Sitting on Ground");
                else if (!llSubStringIndex(sMessage,"Sits")) {
                    if (~llSubStringIndex(sMessage,"☒")) {
                        g_iSitAnimOn = FALSE;
                        llResetAnimationOverride("Sitting");
                    } else {
                        g_iSitAnimOn = TRUE;
                        llSetAnimationOverride("Sitting",g_sSitAnim);
                    }
                    MenuAO(kID);
                } else if (sMessage == "Stand Time") MenuInterval(kID);
                else if (sMessage == "Next Stand") {
                    SwitchAOAnim("Standing");
                    MenuAO(kID);
                } else if (!llSubStringIndex(sMessage,"Shuffle")) {
                    if (~llSubStringIndex(sMessage,"☒")) g_iShuffle = FALSE;
                    else g_iShuffle = TRUE;
                    MenuAO(kID);
                } else if (sMessage == "Collar Menu") llRegionSayTo(g_kWearer,g_iHUDChannel,(string)g_kWearer+":menu");
            } else if (sMenuType == "Load") {
                if (llGetInventoryType(sMessage) == INVENTORY_NOTECARD) {
                    g_sCard = sMessage;
                    g_iCardLine = 0;
                    g_sJson_Anims = "{}";
                    g_kCard = llGetNotecardLine(g_sCard, g_iCardLine);
                } else if (g_iReady && sMessage == "BACK") MenuAO(kID);
                else {
                    llOwnerSay("Could not find configuration Notecard: "+sMessage);
                    MenuLoad(kID);
                }
            } else if (sMenuType == "Interval") {
                if (sMessage == "BACK") {
                    MenuAO(kID);
                    return;
                } else if (sMessage == "Never") {
                    g_iChangeInterval = FALSE;
                    llSetTimerEvent(g_iChangeInterval);
                } else if ((integer)sMessage >= 20) {
                    g_iChangeInterval = (integer)sMessage;
                    if (g_iAO_ON && !g_iSitAnywhereOn) llSetTimerEvent(g_iChangeInterval);
                }
                MenuInterval(kID);
            } else if (~llListFindList(["Walking","Sitting on Ground","Sitting"],[sMenuType])) {
                if (sMessage == "BACK") MenuAO(kID);
                else if (sMessage == "-") MenuChooseAnim(kID,sMenuType);
                else {
                    sMessage = llList2String(g_lAnims2Choose,((integer)sMessage)-1);
                    g_lAnims2Choose = [];
                    if (llGetInventoryType(sMessage) == INVENTORY_ANIMATION) {
                        if (sMenuType == "Sitting") g_sSitAnim = sMessage;
                        else if (sMenuType == "Sitting on Ground") g_sSitAnywhereAnim = sMessage;
                        else if (sMenuType == "Walking") g_sWalkAnim = sMessage;
                        llSetAnimationOverride(sMenuType,sMessage);
                    } else llOwnerSay("No "+sMenuType+" animation set.");
                    MenuChooseAnim(kID,sMenuType);
                }
            } else if (sMenuType == "options") {
                if (sMessage == "BACK") {
                    MenuAO(kID);
                    return;
                } else if (sMessage == "Horizontal") {
                    g_iLayout = 0;
                    DefinePosition();
                } else if (sMessage == "Vertical") {
                    g_iLayout = 1;
                    DefinePosition();
                } else if (sMessage == "Order") {
                    OrderMenu(kID);
                    return;
                } else DoTextures(sMessage);
                MenuOptions(kID);
            } else if (sMenuType == "ordermenu") {
                if (sMessage == "BACK") MenuOptions(kID);
                else if (sMessage == "-") OrderMenu(kID);
                else if (sMessage == "Reset") {
                    FindButtons();
                    Notify(kID,"Order position reset to default.",FALSE);
                    DefinePosition();
                    OrderMenu(kID);
                } else if (llSubStringIndex(sMessage,":") >= 0) {
                    g_iNewPos = llList2Integer(llParseString2List(sMessage,[":"],[]),1);
                    DoButtonOrder();
                    OrderMenu(kID);
                } else {
                    list lButtons;
                    string sPrompt;
                    integer iTemp = llListFindList(g_lButtons,[sMessage]);
                    g_iOldPos = llListFindList(g_lPrimOrder, [iTemp]);
                    sPrompt = "\nWhich slot do you want to swap for the "+sMessage+" button.";
                    integer i;
                    for (i=2;i<llGetListLength(g_lPrimOrder);++i) {
                        if (g_iOldPos != i) {
                            integer iTemp = llList2Integer(g_lPrimOrder,i);
                            lButtons +=[llList2String(g_lButtons,iTemp)+":"+(string)i];
                        }
                    }
                    Dialog(kID, sPrompt, lButtons, ["BACK"],"ordermenu");
                }
            }
        }
    }
    
    timer() {
        if (g_iAO_ON && g_iChangeInterval) SwitchAOAnim("Standing");
        integer iLength = llGetListLength(g_lMenuIDs);
        integer n = iLength - 5;
        integer iNow = llGetUnixTime();
        for (n; n>=0; n=n-5) {
            integer iDieTime = llList2Integer(g_lMenuIDs,n+3);
            if (iNow > iDieTime) {
                llListenRemove(llList2Integer(g_lMenuIDs,n+2));
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs,n,n+4);
            }
        }
        if (!llGetListLength(g_lMenuIDs) && (!g_iAO_ON || !g_iChangeInterval)) llSetTimerEvent(0.0);
    }

    dataserver(key kRequest, string sData) {
        if (kRequest == g_kCard) {
            if (sData != EOF) {
                if (llGetSubString(sData,0,0) == "[") {
                    string sAnimationState = llStringTrim(llGetSubString(sData,1,llSubStringIndex(sData,"]")-1),STRING_TRIM);
                    if (sAnimationState == "Sitting On Ground") sAnimationState = "Sitting on Ground";
                    if (llStringLength(sData)-1 > llSubStringIndex(sData,"]")) {
                        sData = llGetSubString(sData,llSubStringIndex(sData,"]")+1,-1);
                        list lTemp = llParseString2List(sData, ["|"],[]);
                        integer i = llGetListLength(lTemp);
                        while(i--) { //check if the animation from the notecard is present
                            if (llGetInventoryType(llList2String(lTemp,i)) != INVENTORY_ANIMATION)
                                lTemp = llDeleteSubList(lTemp,i,i);
                        }
                        g_sJson_Anims = llJsonSetValue(g_sJson_Anims, [sAnimationState],llDumpList2String(lTemp,","));
                    }     
                }
                g_kCard = llGetNotecardLine(g_sCard,++g_iCardLine);
            } else {
                llOwnerSay("Configuration "+g_sCard+" loaded.");
                g_iCardLine = 0;
                g_kCard = "";
                llRequestPermissions(g_kWearer,PERMISSION_OVERRIDE_ANIMATIONS);
            }
        }
    }
    
    run_time_permissions(integer iFlag) {
        if (iFlag & PERMISSION_OVERRIDE_ANIMATIONS) {
            g_iReady = TRUE;
            if (g_iAO_ON) SetAnimOverride(TRUE);
        }
    }
    http_response(key kRequestID, integer iStatus, list lMeta, string sBody) {
        if (kRequestID == g_kWebLookup && iStatus == 200)  {
            if ((float)sBody > g_fBuildVersion) g_iUpdateAvailable = TRUE;
            else g_iUpdateAvailable = FALSE;
        }
    }
    changed(integer iChange) {
        if (iChange & CHANGED_INVENTORY)
            llOwnerSay("AO's content has changed, remember to reload the configuraton notecard if you changed anything.");
        else if (iChange & CHANGED_COLOR) {
            if (llGetColor(0) != g_vAOoncolor) DetermineColors();
        } else if (iChange & CHANGED_LINK) llResetScript();
    }
}
