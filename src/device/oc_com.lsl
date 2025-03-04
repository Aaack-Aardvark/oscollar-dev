
//  oc_com.lsl
//
//  Copyright (c) 2008 - 2017 Nandana Singh, Garvin Twine, Cleo Collins,
//  Master Starship, Satomi Ahn, Joy Stipe, Wendy Starfall, littlemousy,
//  Romka Swallowtail, Sumi Perl et al.
//
//  This script is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published
//  by the Free Software Foundation, version 2.
//
//  This script is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this script; if not, see www.gnu.org/licenses/gpl-2.0
//

// Debug(string sStr) { llOwnerSay("Debug ["+llGetScriptName()+"]: " + sStr); }

integer g_iPrivateListenChan = 1;
integer g_iPublicListenChan = TRUE;
string g_sPrefix = ".";

integer g_iLockMeisterChan = -8888;

integer g_iPublicListener;
integer g_iPrivateListener;
integer g_iLockMeisterListener;
integer g_iLeashPrim;

integer g_iHUDListener;
integer g_iHUDChan;

integer CMD_ZERO = 0;
integer CMD_OWNER = 500;
integer CMD_WEARER = 503;
integer CMD_SAFEWORD = 510;

integer NOTIFY=1002;
integer NOTIFY_OWNERS=1003;
integer LINK_AUTH = 2;
integer LINK_DIALOG = 3;
integer LINK_SAVE = 5;
integer LINK_ANIM = 6;
integer LINK_UPDATE = -10;
integer REBOOT = -1000;
integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_RESPONSE = 2002;
integer LM_SETTING_DELETE = 2003;

integer ANIM_LIST_REQUEST = 7002;
integer TOUCH_REQUEST = -9500;
integer TOUCH_CANCEL = -9501;
integer TOUCH_RESPONSE = -9502;
integer TOUCH_EXPIRE = -9503;
string g_sSafeWord;

integer g_iInterfaceChannel;
integer g_iListenHandleAtt;

integer AUTH_REQUEST = 600;
integer AUTH_REPLY = 601;

key g_kWearer = NULL_KEY;
string g_sGlobalToken = "global_";
string g_sDeviceName = "Collar";
string g_sWearerName;

list g_lTouchRequests;
integer g_iStrideLength = 4;

integer FLAG_TOUCHSTART = 0x01;
integer FLAG_TOUCHEND = 0x02;

integer g_iNeedsPose;
string g_sPOSE_ANIM = "turn_180";

integer g_iTouchNotify;
integer g_iHighlander = TRUE;
list g_lCore5Scripts = ["LINK_AUTH","oc_auth","LINK_DIALOG","oc_dialog","LINK_RLV","oc_rlvsys","LINK_SAVE","oc_settings","LINK_ANIM","oc_anim"];
list g_lFoundCore5Scripts;
list g_lWrongRootScripts;
integer g_iVerify;

string g_sObjectName;

string NameURI(key kID)
{
    return "secondlife:///app/agent/"+(string)kID+"/about";
}

ClearUser(key kRCPT, integer iNotify)
{
    integer iIndex = llListFindList(g_lTouchRequests, [kRCPT]);
    while (iIndex != -1) {
        if (iNotify) {
            key kID = llList2Key(g_lTouchRequests, iIndex-1);
            integer iAuth = llList2Integer(g_lTouchRequests, iIndex+2);
            llMessageLinked(LINK_THIS, TOUCH_EXPIRE, (string)kRCPT + "|" + (string)iAuth, kID);
        }
        g_lTouchRequests = llDeleteSubList(g_lTouchRequests, iIndex-1, iIndex-2 + g_iStrideLength);
        iIndex = llListFindList(g_lTouchRequests, [kRCPT]);
    }
    if (g_iNeedsPose && llGetListLength(g_lTouchRequests)==0) llStopAnimation(g_sPOSE_ANIM);
}

sendCommandFromLink(integer iLinkNumber, string sType, key kToucher)
{
    integer iTrig;
    integer iNTrigs = llGetListLength(g_lTouchRequests);
    for (iTrig = 0; iTrig < iNTrigs; iTrig+=g_iStrideLength) {
        if (llList2Key(g_lTouchRequests, iTrig + 1) == kToucher) {
            integer iTrigFlags = llList2Integer(g_lTouchRequests, iTrig+2);
            if (((iTrigFlags & FLAG_TOUCHSTART) && sType == "touchstart")
                || ((iTrigFlags & FLAG_TOUCHEND) && sType == "touchend")) {
                integer iAuth = llList2Integer(g_lTouchRequests, iTrig+3);
                string sReply = (string)kToucher + "|" + (string)iAuth + "|" + sType +"|"+ (string)iLinkNumber;
                llMessageLinked(LINK_THIS, TOUCH_RESPONSE, sReply, llList2Key(g_lTouchRequests, iTrig));
            }
            if (sType =="touchend") ClearUser(kToucher, FALSE);
            return;
        }
    }
    string sDesc = llDumpList2String(llGetLinkPrimitiveParams(iLinkNumber, [PRIM_DESC]) + llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_DESC]), "~");
    list lDescTokens = llParseStringKeepNulls(sDesc, ["~"], []);
    integer iNDescTokens = llGetListLength(lDescTokens);
    integer iDescToken;
    for (iDescToken = 0; iDescToken < iNDescTokens; iDescToken++) {
        string sDescToken = llList2String(lDescTokens, iDescToken);
        if (sDescToken == sType || sDescToken == sType+":" || sDescToken == sType+":none") return;
        else if (llSubStringIndex(sDescToken, sType+":") == 0) {
            string sCommand = llGetSubString(sDescToken, llStringLength(sType)+1, -1);
            if (sCommand != "") llMessageLinked(LINK_AUTH, CMD_ZERO, sCommand, kToucher);
            return;
        }
    }
    if (sType == "touchstart") {
        llMessageLinked(LINK_AUTH, CMD_ZERO, "menu", kToucher);
        if (g_iTouchNotify && kToucher != g_kWearer)
            llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"\n\nsecondlife:///app/agent/"+(string)kToucher+"/about touched your %DEVICETYPE%.\n", g_kWearer);
    }
}

MoveAnims(integer i) {
    key kAnimator = llGetLinkKey(LINK_ANIM);
    string sAnim;
    list lAnims;
    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"\n\nFetching "+(string)i+" animations from the %DEVICETYPE%'s root...\n", g_kWearer);
    while (i > 0) {
        sAnim = llGetInventoryName(INVENTORY_ANIMATION, --i);
        llGiveInventory(kAnimator, sAnim);
        lAnims += sAnim;
        if (llGetInventoryType(sAnim) == INVENTORY_ANIMATION) {
            if (llGetInventoryPermMask(sAnim,MASK_OWNER) & PERM_COPY)
                llRemoveInventory(sAnim);
        }
    }
    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"\n\nThe following animations have been moved to the %DEVICETYPE%'s animator module and are now ready to use:\n\n"+llList2CSV(lAnims)+"\n", g_kWearer);
    llMessageLinked(LINK_ANIM, ANIM_LIST_REQUEST, "", "");
}

UserCommand(key kID, integer iAuth, string sStr) {
    if (sStr == "ping") {
        llRegionSayTo(kID, g_iHUDChan, (string)g_kWearer+":pong");
        return;
    }
    list lParams = llParseString2List(sStr, [" "], []);
    string sCommand = llToLower(llList2String(lParams, 0));
    string sValue = llList2String(lParams, 1);
    if (iAuth == CMD_OWNER || kID == g_kWearer) {
        if (sCommand == "prefix") {
            if (sValue == "") {
                llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"\n\n%WEARERNAME%'s prefix is: %PREFIX%\n", kID);
                return;
            } else if (sValue == "reset") {
                g_sPrefix = llToLower(llGetSubString(llKey2Name(llGetOwner()), 0, 1));
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"prefix", "");
            } else {
                g_sPrefix = sValue;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"prefix=" + g_sPrefix, "");
            }
            llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"prefix=" + g_sPrefix, "");
            llMessageLinked(LINK_DIALOG, NOTIFY, "1"+"\n\n%WEARERNAME%'s new prefix is: %PREFIX%\n", kID);
        }
        else if (sCommand == "device" && sValue == "name") {
            string sMessage;
            string sObjectName = llGetObjectName();
            string sCmdOptions = llDumpList2String(llDeleteSubList(lParams,0,1), " ");
            if (sValue == "") {
                sMessage = "\n"+sObjectName+"'s current device name is \"" + g_sDeviceName + "\".\nDevice Name command help:\n%PREFIX% device name [newname|reset]\n";
                llMessageLinked(LINK_DIALOG, NOTIFY, "0"+sMessage, kID);
            } else if (sCmdOptions == "reset") {
                g_sDeviceName = "Collar";
                sMessage = "The device name is reset to \""+g_sDeviceName+"\".";
                llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"DeviceName", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
            } else {
                g_sDeviceName = sCmdOptions;
                sMessage = sObjectName+"'s new device name is \""+ g_sDeviceName+"\".";
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
            }
            if (sValue != "") llMessageLinked(LINK_DIALOG, NOTIFY, "1"+sMessage, kID);
        } else if (sCommand == "name") {
            if (iAuth != CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            else {
                string sMessage;
                if (sValue == "") {
                    sMessage = "\n\nsecondlife:///app/agent/"+(string)g_kWearer+"/about's current name is " + g_sWearerName;
                    sMessage += "\nName command help: <prefix>name [newname|reset]\n";
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+sMessage, kID);
                } else if(sValue == "reset") {
                    sMessage=g_sWearerName+"'s name is reset to ";
                    g_sWearerName = NameURI(g_kWearer);
                    llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"WearerName", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"WearerName="+g_sWearerName, "");
                    sMessage += g_sWearerName;
                    llMessageLinked(LINK_DIALOG, NOTIFY, "1"+sMessage, kID);
                } else {
                    string sNewName = llDumpList2String(llList2List(lParams, 1,-1)," ") ;
                    sMessage=g_sWearerName+"'s new name is ";
                    g_sWearerName = "["+NameURI(g_kWearer)+" "+sNewName+"]";
                    sMessage += g_sWearerName;
                    llMessageLinked(LINK_DIALOG, NOTIFY, "1"+sMessage, kID);
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"WearerName=" + sNewName, "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"WearerName="+sNewName, "");
                }
            }
        } else if (sCommand == "channel") {
            integer iNewChan = (integer)sValue;
            if (sValue == "") {
                string sMessage= "The %DEVICETYPE% is listening on channel";
                if (g_iPublicListenChan) sMessage += "s 0 and";
                sMessage += " "+(string)g_iPrivateListenChan+".";
                llMessageLinked(LINK_DIALOG, NOTIFY, "0"+sMessage, kID);
            } else if (iNewChan > 0) {
                g_iPrivateListenChan =  iNewChan;
                llListenRemove(g_iPrivateListener);
                g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
                llMessageLinked(LINK_DIALOG, NOTIFY, "1"+"Now listening on channel " + (string)g_iPrivateListenChan, kID);
                if (g_iPublicListenChan) {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                } else {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                    llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                }
            } else if (iNewChan == 0) {
                g_iPublicListenChan = TRUE;
                llListenRemove(g_iPublicListener);
                g_iPublicListener = llListen(0, "", NULL_KEY, "");
                llMessageLinked(LINK_DIALOG, NOTIFY, "1"+"\n\nPublic channel listener enabled.\nTo disable it type: /%CHANNEL% %PREFIX% channel -1\n", kID);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",TRUE", "");
            } else if (iNewChan == -1) {
                g_iPublicListenChan = FALSE;
                llListenRemove(g_iPublicListener);
                llMessageLinked(LINK_DIALOG, NOTIFY, "1"+"\n\nPublic channel listener disabled.\nTo enable it type: /%CHANNEL% %PREFIX% channel 0\n", kID);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
                llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken + "channel=" + (string)g_iPrivateListenChan + ",FALSE", "");
            }
        } else if (kID == g_kWearer) {
            if (sStr == "mv anims") {
                integer i = llGetInventoryNumber(INVENTORY_ANIMATION);
                if (i > 0) MoveAnims(i);
            } else if (sCommand == "busted") {
                if (sValue == "on") {
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"touchNotify=1", "");
                    g_iTouchNotify=TRUE;
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Touch notification is now enabled.", g_kWearer);
                } else if (sValue == "off") {
                    llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"touchNotify", "");
                    g_iTouchNotify=FALSE;
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Touch notification is now disabled.", g_kWearer);
                } else if (sValue == "") {
                    if (g_iTouchNotify) {
                        llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Touch notification is now disabled.", g_kWearer);
                        llMessageLinked(LINK_SAVE, LM_SETTING_DELETE, g_sGlobalToken+"touchNotify", "");
                        g_iTouchNotify = FALSE;
                    } else {
                        llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Touch notification is now enabled.", g_kWearer);
                        llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sGlobalToken+"touchNotify=1", "");
                        g_iTouchNotify = TRUE;
                    }
                }
            }
        }
    }
}

default
{
    on_rez(integer iParam)
    {
        llResetScript();
    }

    state_entry()
    {
        g_kWearer = llGetOwner();
        g_sWearerName = NameURI(g_kWearer);
        llMessageLinked(LINK_SET, LM_SETTING_RESPONSE, g_sGlobalToken+"DeviceName="+g_sDeviceName, "");
        g_sPrefix = llToLower(llGetSubString(llKey2Name(g_kWearer), 0, 1));
        g_iHUDChan = -llAbs((integer)("0x" + llGetSubString((string)g_kWearer, -7, -1)));
        g_iInterfaceChannel = (integer)("0x" + llGetSubString(g_kWearer, 30, -1));
        if (g_iInterfaceChannel > 0) g_iInterfaceChannel = -g_iInterfaceChannel;
        g_iPublicListener = llListen(0, "", NULL_KEY, "");
        g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
        g_iLockMeisterListener = llListen(g_iLockMeisterChan, "", "", "");
        g_iListenHandleAtt = llListen(g_iInterfaceChannel, "", "", "");
        g_iHUDListener = llListen(g_iHUDChan, "", NULL_KEY ,"");
        integer iAttachPt = llGetAttached();
        if ((iAttachPt > 0 && iAttachPt < 31) || iAttachPt == 39) {
            llRequestPermissions(g_kWearer, PERMISSION_TRIGGER_ANIMATION);
            llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=Yes");
        }
    }

    attach(key kID)
    {
        if (kID == NULL_KEY)
            llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=No");
    }

    listen(integer iChan, string sName, key kID, string sMsg) {
        if (iChan == g_iLockMeisterChan) {
            if(sMsg ==(string)g_kWearer+"collar")
                llSay(g_iLockMeisterChan,(string)g_kWearer + "collar ok");
            if(sMsg == (string)g_kWearer+"|LMV2|RequestPoint|collar") {
                if(g_iLeashPrim)
                    llRegionSayTo(kID, g_iLockMeisterChan, (string)g_kWearer+"|LMV2|ReplyPoint|collar|"+(string)llGetLinkKey(g_iLeashPrim));
                else
                    llRegionSayTo(kID, g_iLockMeisterChan, (string)g_kWearer+"|LMV2|ReplyPoint|collar|"+(string) llGetKey());
            }
            return;
        }
        key kOwnerID = llGetOwnerKey(kID);
        if (iChan == g_iHUDChan) {
            if (sMsg == (string)g_kWearer + ":ping")
                llMessageLinked(LINK_AUTH, CMD_ZERO, "ping", kOwnerID);
            else if (llSubStringIndex(sMsg,(string)g_kWearer + ":") == 0){
                sMsg = llGetSubString(sMsg, 37, -1);
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kOwnerID);
            } else
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kOwnerID);
        }
        if (iChan == g_iInterfaceChannel && kOwnerID == g_kWearer) {
            if (sMsg == "OpenCollar?") llRegionSayTo(g_kWearer, g_iInterfaceChannel, "OpenCollar=Yes");
            else if (sMsg == "OpenCollar=Yes" && g_iHighlander) {
                llOwnerSay("\n\nATTENTION: You are attempting to wear more than one collar core. This causes errors with other compatible accessories and your RLV relay. For a smooth experience, and to avoid wearing unnecessary script duplicates, please consider to take off \""+sName+"\" manually if it doesn't detach automatically.\n");
                llRegionSayTo(kID,g_iInterfaceChannel,"There can be only one!");
            } else if (sMsg == "There can be only one!" && g_iHighlander) {
                llOwnerSay("/me has been detached.");
                llRequestPermissions(g_kWearer,PERMISSION_ATTACH);
            } else {
                if (llSubStringIndex(sMsg, "AuthRequest") == 0) {
                    llMessageLinked(LINK_AUTH, AUTH_REQUEST, (string)kID+(string)g_iInterfaceChannel, llGetSubString(sMsg,12,-1));
                }
            }
        }
        if (iChan == 0 || iChan == g_iPrivateListenChan) {
            if (kOwnerID == g_kWearer) {
                string sw = sMsg;
                if (llGetSubString(sw, 0, 3) == "/me ") sw = llGetSubString(sw, 4, -1);
                if (llGetSubString(sw, 0, 1) == "((" && llGetSubString(sw, -2, -1) == "))") sw = llStringTrim(llGetSubString(sw, 2, -3), STRING_TRIM);
                if (llSubStringIndex(sw, g_sPrefix)==0) sw = llGetSubString(sw, llStringLength(g_sPrefix), -1);
                if (sw == g_sSafeWord || sw == "RED") {
                    llMessageLinked(LINK_SET, CMD_SAFEWORD, "", "");
                    llRegionSayTo(g_kWearer, g_iInterfaceChannel, "%53%41%46%45%57%4F%52%44");
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"You used the safeword, your owners have been notified.",g_kWearer);
                    llMessageLinked(LINK_DIALOG, NOTIFY_OWNERS, "\n\n%WEARERNAME% had to use the safeword. Please check on %WEARERNAME%'s well-being in case further care is required.\n","");
                    return;
                }
            }
            if (llSubStringIndex(sMsg, g_sPrefix) == 0) sMsg = llGetSubString(sMsg, llStringLength(g_sPrefix), -1);
            else if (llSubStringIndex(sMsg, "/"+g_sPrefix) == 0) sMsg = llGetSubString(sMsg, llStringLength(g_sPrefix)+1, -1);
            else if (llGetSubString(sMsg, 0, 0) == "*") sMsg = llGetSubString(sMsg, 1, -1);
            else if ((llGetSubString(sMsg, 0, 0) == "#") && (kID != g_kWearer)) sMsg = llGetSubString(sMsg, 1, -1);
            else return;
            sMsg = llStringTrim(sMsg,STRING_TRIM_HEAD);
            if (sMsg != "") {
                if (kID == g_kWearer && llToLower(sMsg) == "verify") {
                    llOwnerSay("Verifying core...");
                    llMessageLinked(LINK_ALL_OTHERS, LINK_UPDATE, "LINK_REQUEST", "");
                    llSetTimerEvent(2);
                    g_iVerify = TRUE;
                    g_lWrongRootScripts = [];
                    string sScriptName;
                    integer i = llGetListLength(g_lCore5Scripts) -1;
                    do {
                        sName = llList2String(g_lCore5Scripts,i);
                        if (llGetInventoryType(sScriptName) == INVENTORY_SCRIPT)
                            g_lWrongRootScripts += sScriptName;
                        i = i - 2;
                    } while (i>0);
                    return;
                }
                llMessageLinked(LINK_AUTH, CMD_ZERO, sMsg, kID);
            }
        }
    }

    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
        if (iNum >= CMD_OWNER && iNum <= CMD_WEARER) UserCommand(kID, iNum, sStr);
        else if (iNum == LM_SETTING_RESPONSE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            if (sToken == g_sGlobalToken+"prefix") {
                if (sValue != "") g_sPrefix=sValue;
            } else if (sToken == "leashpoint") g_iLeashPrim = (integer)sValue;
            else if (sToken == g_sGlobalToken+"DeviceName") g_sDeviceName = sValue;
            else if (sToken == g_sGlobalToken+"touchNotify") g_iTouchNotify = (integer)sValue;
            else if (sToken == g_sGlobalToken+"WearerName") {
                 if (llSubStringIndex(sValue, "secondlife:///app/agent"))
                    g_sWearerName = "["+NameURI(g_kWearer)+" " + sValue + "]";
            } else if (sToken == "intern_Highlander") g_iHighlander = (integer)sValue;
            else if (sToken == g_sGlobalToken+"safeword") g_sSafeWord = sValue;
            else if (sToken == g_sGlobalToken+"channel") {
                g_iPrivateListenChan = (integer)sValue;
                if (llGetSubString(sValue, llStringLength(sValue)-5 , -1) == "FALSE") g_iPublicListenChan = FALSE;
                else g_iPublicListenChan = TRUE;
                llListenRemove(g_iPublicListener);
                if (g_iPublicListenChan == TRUE) g_iPublicListener = llListen(0, "", NULL_KEY, "");
                llListenRemove(g_iPrivateListener);
                g_iPrivateListener = llListen(g_iPrivateListenChan, "", NULL_KEY, "");
            }
        } else if (iNum == TOUCH_REQUEST) {
            list lParams = llParseStringKeepNulls(sStr, ["|"], []);
            key kRCPT = llList2Key(lParams, 0);
            integer iFlags = llList2Integer(lParams, 1);
            integer iAuth = llList2Integer(lParams, 2);
            ClearUser(kRCPT, TRUE);
            g_lTouchRequests += [kID, kRCPT, iFlags, iAuth];
            if (g_iNeedsPose) llStartAnimation(g_sPOSE_ANIM);
        } else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_AUTH") LINK_AUTH = iSender;
            else if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_SAVE") LINK_SAVE = iSender;
            else if (sStr == "LINK_ANIM") LINK_ANIM = iSender;
            if (sStr != "LINK_REQUEST") {
                if (llListFindList(g_lFoundCore5Scripts,[sStr,iSender]) == -1)
                    g_lFoundCore5Scripts += [sStr,iSender];
                if (llGetListLength(g_lFoundCore5Scripts) >= 10) llSetTimerEvent(0.5);
            }
        } else if (iNum == TOUCH_CANCEL) {
            integer iIndex = llListFindList(g_lTouchRequests, [kID]);
            if (iIndex != -1) {
                g_lTouchRequests = llDeleteSubList(g_lTouchRequests, iIndex, iIndex-1+g_iStrideLength);
                if (g_iNeedsPose && llGetListLength(g_lTouchRequests) == 0) llStopAnimation(g_sPOSE_ANIM);
            }
        } else if (iNum == AUTH_REPLY) llRegionSayTo(kID, g_iInterfaceChannel, sStr);
        else if (iNum == REBOOT && sStr == "reboot") {
            integer i = llGetInventoryNumber(INVENTORY_SCRIPT);
            string sScriptName;
            while (i > 0) {
                sScriptName = llGetInventoryName(INVENTORY_SCRIPT, --i);
                if (sScriptName != "oc_com" && sScriptName != "oc_sys"
                && llGetInventoryType(sScriptName) == INVENTORY_SCRIPT
                && llGetScriptState(sScriptName) == FALSE) {
                    llSetScriptState(sScriptName, TRUE);
                    llResetOtherScript(sScriptName);
                }
            }
            if (llGetInventoryType("oc_sys") == INVENTORY_SCRIPT && llGetScriptState("oc_sys") == FALSE) {
                llSetScriptState("oc_sys",TRUE);
                llResetOtherScript("oc_sys");
            }
            llResetScript();
        }
    }

    touch_start(integer iNum)
    {
        sendCommandFromLink(llDetectedLinkNumber(0), "touchstart", llDetectedKey(0));
    }

    touch_end(integer iNum)
    {
        sendCommandFromLink(llDetectedLinkNumber(0), "touchend", llDetectedKey(0));
    }

    run_time_permissions(integer iPerm)
    {
        if (iPerm & PERMISSION_TRIGGER_ANIMATION) g_iNeedsPose = TRUE;
        if (iPerm & PERMISSION_ATTACH) {
            llOwnerSay("@detach=yes");
            llDetachFromAvatar();
        }
    }

    timer()
    {
        llSetTimerEvent(0.0);
        string sMessage;
        if (llGetListLength(g_lWrongRootScripts) > 0) {
            sMessage = "\nFalse root prim placement:\n";
            do {
                sMessage += llList2String(g_lWrongRootScripts,0);
                g_lWrongRootScripts =  llDeleteSubList(g_lWrongRootScripts,0,0);
            } while (llGetListLength(g_lWrongRootScripts) > 0);
        }
        if(sMessage) sMessage += "\n";
        integer i;
        integer index;
        list lTemp = ["Missing Scripts:"];
        do {
            index = llListFindList(g_lFoundCore5Scripts,llList2List(g_lCore5Scripts, i, i));
            if (index == -1) {
                if (llSubStringIndex(sMessage,llList2String(g_lCore5Scripts, i+1)) == -1)
                    lTemp += [llList2String(g_lCore5Scripts, i+1)];
            } else
                sMessage += "\n"+llList2String(g_lCore5Scripts, i+1) + "\t(Link# "+llList2String(g_lFoundCore5Scripts, index+1)+")";
            i = i + 2;
        } while (i < 10);
        i = llGetLinkNumber();
        if (i != 1) sMessage += "\noc_com\t(not in root prim!)";
        string sSaveIntegrity = "intern_integrity=";
        if (llSubStringIndex(sMessage,"False") == -1 && llGetListLength(lTemp) == 1) {
            g_lFoundCore5Scripts = llListSort(g_lFoundCore5Scripts,2, TRUE);
            if (llListFindList(g_lFoundCore5Scripts,["LINK_ANIM",6,"LINK_AUTH",2,"LINK_DIALOG",3,"LINK_RLV",4,"LINK_SAVE",5])) {
                sMessage = "All operational!";
                sSaveIntegrity += "handmade";
            } else {
                sMessage = "Optimal conditions!";
                sSaveIntegrity += "professional";
            }
            llMessageLinked(LINK_THIS,LM_SETTING_RESPONSE, sSaveIntegrity, "");
            llMessageLinked(LINK_SAVE,LM_SETTING_SAVE, sSaveIntegrity, "");
            lTemp = [];
            g_lFoundCore5Scripts = [];
        } else {
            if (llGetListLength(lTemp) ==1) lTemp = [];
            sMessage = "\n\nCore corruption detected:\n"+ llDumpList2String(lTemp,"\n")+sMessage;
            if (i == 1) sMessage += "\noc_com\t(root)";
            llMessageLinked(LINK_SAVE,LM_SETTING_DELETE,"intern_integrity","");
        }
        g_lFoundCore5Scripts = [];
        if (g_iVerify) {
            g_iVerify = FALSE;
            llOwnerSay(sMessage);
        }
    }
}
