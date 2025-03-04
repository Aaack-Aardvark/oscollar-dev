
//  oc_meshlabel.lsl
//
//  Copyright (c) 2006 - 2016 Xylor Baysklef, Kermitt Quirk,
//  Thraxis Epsilon, Gigs Taggart, Strife Onizuka, Huney Jewell,
//  Salahzar Stenvaag, Lulu Pink, Nandana Singh, Cleo Collins, Satomi Ahn,
//  Joy Stipe, Wendy Starfall, Romka Swallowtail, littlemousy,
//  Garvin Twine et al.
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

string g_sAppVersion = "2023.03.04";

string g_sParentMenu = "Apps";
string g_sSubMenu = "Label";

key g_kWearer = NULL_KEY;

integer CMD_OWNER = 500;
integer CMD_TRUSTED = 501;
integer CMD_WEARER = 503;

integer NOTIFY = 1002;
integer REBOOT = -1000;
integer LINK_DIALOG = 3;
integer LINK_RLV = 4;
integer LINK_SAVE = 5;
integer LINK_UPDATE = -10;
integer LM_SETTING_SAVE = 2000;
integer LM_SETTING_RESPONSE = 2002;

integer MENUNAME_REQUEST = 3000;
integer MENUNAME_RESPONSE = 3001;
integer MENUNAME_REMOVE = 3003;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer DIALOG_TIMEOUT = -9002;

integer g_iCharLimit = -1;

string UPMENU = "BACK";

string g_sTextMenu = "Set Label";
string g_sFontMenu = "Font";
string g_sColorMenu = "Color";

list g_lMenuIDs;
integer g_iMenuStride = 3;

string g_sCharmap = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁłŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽžſƒƠơƯưǰǺǻǼǽǾǿȘșʼˆˇˉ˘˙˚˛˜˝˳̣̀́̃̉̏΄΅Ά·ΈΉΊΌΎΏΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώϑϒϖЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяѐёђѓєѕіїјљњћќѝўџѠѡѢѣѤѥѦѧѨѩѪѫѬѭѮѯѰѱѲѳѴѵѶѷѸѹѺѻѼѽѾѿҀҁ҂҃҄҅҆҈҉ҊҋҌҍҎҏҐґҒғҔҕҖҗҘҙҚқҜҝҞҟҠҡҢңҤҥҦҧҨҩҪҫҬҭҮүҰұҲҳҴҵҶҷҸҹҺһҼҽҾҿӀӁӂӃӄӅӆӇӈӉӊӋӌӍӎӏӐӑӒӓӔӕӖӗӘәӚӛӜӝӞӟӠӡӢӣӤӥӦӧӨөӪӫӬӭӮӯӰӱӲӳӴӵӶӷӸӹӺӻӼӽӾӿԀԁԂԃԄԅԆԇԈԉԊԋԌԍԎԏԐԑԒԓḀḁḾḿẀẁẂẃẄẅẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹὍ–—―‗‘’‚‛“”„†‡•…‰′″‹›‼⁄ⁿ₣₤₧₫€℅ℓ№™Ω℮⅛⅜⅝⅞∂∆∏∑−√∞∫≈≠≤≥◊ﬁﬂﬃﬄ￼ ";

list g_lFonts;

key g_sFontTexture = "font_System 01";

integer x = 45;
integer y = 19;

integer g_iNumFaces = 6;

float g_fScrollTime = 0.5 ;
integer g_iSctollPos ;
string g_sScrollText;
list g_lLabelLinks ;
list g_lLabelBaseElements;
list g_lGlows;

integer g_iScroll = FALSE;
integer g_iShow;
vector g_vColor = <1,1,1>;
integer g_iHide;

string g_sLabelText = "";
string g_sSettingToken = "label_";

float Ureps;
float Vreps;

integer GetIndex(string sChar)
{
    integer i;
    if (sChar == "") return 854;
    else i = llSubStringIndex(g_sCharmap, sChar);
    if (i >= 0) return i;
    else return 854;
}

RenderString(integer iPos, string sChar)
{
    integer frame = GetIndex(sChar);
    integer i = iPos / g_iNumFaces;
    integer link = llList2Integer(g_lLabelLinks, i);
    integer face = iPos - g_iNumFaces * i;
    integer frameY = frame / x;
    integer frameX = frame - x * frameY;
    float Uoffset = -0.5 + (Ureps/2 + Ureps*(frameX)) ;
    float Voffset = 0.5 - (Vreps/2 + Vreps*(frameY)) ;
    llSetLinkPrimitiveParamsFast(link, [PRIM_TEXTURE, face, g_sFontTexture, <Ureps, Vreps,0>, <Uoffset, Voffset, 0>, 0]);
}

SetColor() {
    integer i=0;
    do {
        integer iLink = llList2Integer(g_lLabelLinks,i);
        float fAlpha = llList2Float(llGetLinkPrimitiveParams(iLink, [PRIM_COLOR,ALL_SIDES]), 1);
        llSetLinkPrimitiveParamsFast(iLink, [PRIM_COLOR, ALL_SIDES, g_vColor, fAlpha]);
    } while (++i < llGetListLength(g_lLabelLinks));
}

integer LabelsCount()
{
    integer ok = TRUE ;
    g_lLabelLinks = [] ;
    g_lLabelBaseElements = [];
    string sLabel;
    list lTmp;
    integer iLink;
    integer iLinkCount = llGetNumberOfPrims();
    for(iLink = 2; iLink <= iLinkCount; iLink++) {
        lTmp = llParseString2List(llList2String(llGetLinkPrimitiveParams(iLink, [PRIM_NAME]), 0), ["~"], []);
        sLabel = llList2String(lTmp, 0);
        if(sLabel == "MeshLabel") {
            g_iNumFaces = llGetLinkNumberOfSides(iLink);
            g_lLabelLinks += [0];
            llSetLinkPrimitiveParamsFast(iLink,[PRIM_DESC,"Label~notexture~nocolor~nohide~noshiny"]);
        } else if (sLabel == "LabelBase") g_lLabelBaseElements += iLink;
    }
    g_iCharLimit = llGetListLength(g_lLabelLinks) * g_iNumFaces;
    for(iLink=2; iLink <= iLinkCount; iLink++) {
        lTmp = llParseString2List(llList2String(llGetLinkPrimitiveParams(iLink, [PRIM_NAME]), 0), ["~"], []);
        sLabel = llList2String(lTmp, 0);
        if (sLabel == "MeshLabel") {
            integer iLabel = llList2Integer(lTmp, 1);
            integer link = llList2Integer(g_lLabelLinks,iLabel);
            if (link == 0)
                g_lLabelLinks = llListReplaceList(g_lLabelLinks, [iLink], iLabel, iLabel);
            else {
                ok = FALSE;
                llOwnerSay("Warning! Found duplicated label prims: "+sLabel+" with link numbers: "+(string)link+" and "+(string)iLink);
            }
        }
    }
    if (ok == FALSE) {
        if (llSubStringIndex(llGetObjectName(),"Installer") != -1 && llSubStringIndex(llGetObjectName(),"Updater") != -1)
            return 1;
    }
    return ok;
}

SetLabelBaseAlpha()
{
    if (g_iHide) return ;
    integer n;
    integer iLinkElements = llGetListLength(g_lLabelBaseElements);
    for (n = 0; n < iLinkElements; n++) {
        llSetLinkAlpha(llList2Integer(g_lLabelBaseElements,n), (float)g_iShow, ALL_SIDES);
        UpdateGlow(llList2Integer(g_lLabelBaseElements,n), g_iShow);
    }
}

UpdateGlow(integer iLink, integer iAlpha)
{
    integer i;
    if (iAlpha == 0) {
        float fGlow = llList2Float(llGetLinkPrimitiveParams(iLink, [PRIM_GLOW,0]), 0);
        i = llListFindList(g_lGlows, [iLink]);
        if (i !=-1 && fGlow > 0) g_lGlows = llListReplaceList(g_lGlows,[fGlow], i+1, i+1);
        if (i !=-1 && fGlow == 0) g_lGlows = llDeleteSubList(g_lGlows, i, i+1);
        if (i == -1 && fGlow > 0) g_lGlows += [iLink, fGlow];
        llSetLinkPrimitiveParamsFast(iLink, [PRIM_GLOW, ALL_SIDES, 0.0]);  // set no glow;
    } else {
        i = llListFindList(g_lGlows, [iLink]);
        if (i != -1) llSetLinkPrimitiveParamsFast(iLink, [PRIM_GLOW, ALL_SIDES, llList2Float(g_lGlows, i+1)]);
    }
}

SetLabel()
{
    string sText ;
    if (g_iShow) sText = g_sLabelText;
    string sPadding;
    if(g_iScroll==TRUE) {
        while(llStringLength(sPadding) < g_iCharLimit) sPadding += " ";
        g_sScrollText = sPadding + sText;
        llSetTimerEvent(g_fScrollTime);
    } else {
        g_sScrollText = "";
        llSetTimerEvent(0.0);
        //inlined single use CenterJustify function
        while(llStringLength(sPadding + sText + sPadding) < g_iCharLimit) sPadding += " ";
        sText = sPadding + sText;
        integer iCharPosition;
        for(iCharPosition=0; iCharPosition < g_iCharLimit; iCharPosition++)
            RenderString(iCharPosition, llGetSubString(sText, iCharPosition, iCharPosition));
    }
}

Dialog(key kRCPT, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string iMenuType)
{
    key kMenuID = llGenerateKey();
    llMessageLinked(LINK_DIALOG, DIALOG, (string)kRCPT + "|" + sPrompt + "|" + (string)iPage + "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`") + "|" + (string)iAuth, kMenuID);
    integer iIndex = llListFindList(g_lMenuIDs, [kRCPT]);
    if (iIndex != -1) g_lMenuIDs = llListReplaceList(g_lMenuIDs, [kRCPT, kMenuID, iMenuType], iIndex, iIndex + g_iMenuStride - 1);
    else g_lMenuIDs += [kRCPT, kMenuID, iMenuType];
}

MainMenu(key kID, integer iAuth)
{
    list lButtons= [g_sTextMenu, g_sColorMenu, g_sFontMenu];
    if (g_iShow) lButtons += ["☑ Show"];
    else lButtons += ["☐ Show"];

    if (g_iScroll) lButtons += ["☑ Scroll"];
    else lButtons += ["☐ Scroll"];

    string sPrompt = "\nLabel\t"+g_sAppVersion+"\n\nCustomize the %DEVICETYPE%'s label!";
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "main");
}

TextMenu(key kID, integer iAuth)
{
    string sPrompt="\n- Submit the new label in the field below.\n- Submit a few spaces to clear the label.\n- Submit a blank field to go back to " + g_sSubMenu + ".";
    Dialog(kID, sPrompt, [], [], 0, iAuth, "textbox");
}

ColorMenu(key kID, integer iAuth)
{
    string sPrompt = "\n\nSelect a color from the list";
    Dialog(kID, sPrompt, ["colormenu please"], [UPMENU], 0, iAuth, "color");
}

FontMenu(key kID, integer iAuth)
{
    list lButtons=llList2ListStrided(g_lFonts, 0, -1, 2);
    string sPrompt = "\nLabel\n\nSelect the font for the %DEVICETYPE%'s label.";
    Dialog(kID, sPrompt, lButtons, [UPMENU], 0, iAuth, "font");
}

ConfirmDeleteMenu(key kAv, integer iAuth)
{
    string sPrompt = "\nDo you really want to uninstall the "+g_sSubMenu+" App?";
    Dialog(kAv, sPrompt, ["Yes","No","Cancel"], [], 0, iAuth, "rmlabel");
}

UserCommand(integer iAuth, string sStr, key kAv)
{
    string sLowerStr = llToLower(sStr);
     if (sStr == "rm label") {
        if (kAv != g_kWearer && iAuth != CMD_OWNER) llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"%NOACCESS%", kAv);
        else ConfirmDeleteMenu(kAv, iAuth);
    } else if (iAuth == CMD_OWNER) {
        if (sLowerStr == "menu label" || sLowerStr == "label") {
            MainMenu(kAv, iAuth);
            return;
        }
        list lParams = llParseString2List(sStr, [" "], []);
        string sCommand = llToLower(llList2String(lParams, 0));
        string sAction = llToLower(llList2String(lParams, 1));
        string sValue = llToLower(llList2String(lParams, 2));
        if (sCommand == "label") {
            if (sAction == "font") {
                string font = llDumpList2String(llDeleteSubList(lParams,0,1)," ");
                integer iIndex = llListFindList(g_lFonts, [font]);
                if (iIndex != -1) {
                    g_sFontTexture = llList2String(g_lFonts, iIndex + 1);
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "font=" + g_sFontTexture, "");
                } else FontMenu(kAv, iAuth);
            } else if (sAction == "color") {
                string sColor= llDumpList2String(llDeleteSubList(lParams,0,1)," ");
                if (sColor != "") {
                    g_vColor=(vector)sColor;
                    llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"color="+(string)g_vColor, "");
                    SetColor();
                } else ColorMenu(kAv, iAuth);
            } else if (sAction == "on" && sValue == "") {
                g_iShow = TRUE;
                SetLabelBaseAlpha();
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"show="+(string)g_iShow, "");
            } else if (sAction == "off" && sValue == "") {
                g_iShow = FALSE;
                SetLabelBaseAlpha();
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"show="+(string)g_iShow, "");
            } else if (sAction == "scroll") {
                if (sValue == "on") g_iScroll = TRUE;
                else if (sValue == "off") g_iScroll = FALSE;
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken+"scroll="+(string)g_iScroll, "");
            } else {
                g_sLabelText = llStringTrim(llDumpList2String(llDeleteSubList(lParams,0,0)," "),STRING_TRIM);
                llMessageLinked(LINK_SAVE, LM_SETTING_SAVE, g_sSettingToken + "text=" + g_sLabelText, "");
                if (llStringLength(g_sLabelText) > g_iCharLimit) {
                    string sDisplayText = llGetSubString(g_sLabelText, 0, g_iCharLimit-1);
                    llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"Unless your set your label to scroll it will be truncted at "+sDisplayText+".", kAv);
                }
            }
            SetLabel();
        }
    } else if (iAuth >= CMD_TRUSTED && iAuth <= CMD_WEARER) {
        string sCommand = llToLower(llList2String(llParseString2List(sStr, [" "], []), 0));
        if (sLowerStr == "menu label") {
            llMessageLinked(LINK_ROOT, iAuth, "menu "+g_sParentMenu, kAv);
            llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"%NOACCESS%", kAv);
        } else if (sCommand == "label")
            llMessageLinked(LINK_DIALOG, NOTIFY, "0"+"%NOACCESS%", kAv);
    }
}

LoadFonts()
{
    g_lFonts = [];
    integer i;
    for (i = 0; i < llGetInventoryNumber(INVENTORY_TEXTURE); i++) {
        string sName = llGetInventoryName(INVENTORY_TEXTURE, i);
        if (llGetSubString(sName, 0, 4) == "font_")
            g_lFonts += [llGetSubString(sName, 5, -1), (string)llGetInventoryKey(sName)];
    }
    if (llGetListLength(g_lFonts) == 0) {
        // Fall back to original asset uuids (might not be present in the grid's asset server)
        g_lFonts =  ["Solid", "464e8b47-d578-4e24-a671-de7c2f2b7a24",
                     "Outlined", "efeb123d-a014-4586-8012-62086272ccaf"];
    }
    //Debug("New font list: "+llList2CSV(g_lFonts));
}

default
{
    state_entry()
    {
        g_kWearer = llGetOwner();
        LoadFonts();
        Ureps = (float)1 / x;
        Vreps = (float)1 / y;
        LabelsCount();
        if (g_iCharLimit <= 0) {
            llMessageLinked(LINK_SET, MENUNAME_REMOVE, g_sParentMenu + "|" + g_sSubMenu, "");
            llRemoveInventory(llGetScriptName());
        }
    }

    on_rez(integer iNum)
    {
        if (g_kWearer != llGetOwner()) {
            g_sLabelText = "";
            SetLabel();
        }
        llResetScript();
    }

    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
        if (iNum >= CMD_OWNER && iNum <= CMD_WEARER) UserCommand(iNum, sStr, kID);
        else if (iNum == LM_SETTING_RESPONSE) {
            list lParams = llParseString2List(sStr, ["="], []);
            string sToken = llList2String(lParams, 0);
            string sValue = llList2String(lParams, 1);
            integer i = llSubStringIndex(sToken, "_");
            if (llGetSubString(sToken, 0, i) == g_sSettingToken) {
                sToken = llGetSubString(sToken, i + 1, -1);
                if (sToken == "text") g_sLabelText = sValue;
                else if (sToken == "font") g_sFontTexture = sValue;
                else if (sToken == "color") g_vColor = (vector)sValue;
                else if (sToken == "show") g_iShow = (integer)sValue;
                else if (sToken == "scroll") g_iScroll = (integer)sValue;
            } else if (sToken == "settings" && sValue == "sent") {
                SetColor();
                SetLabel();
            }
        } else if (iNum == MENUNAME_REQUEST && sStr == g_sParentMenu)
            llMessageLinked(iSender, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sSubMenu, "");
        else if (iNum == DIALOG_RESPONSE) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            if (iMenuIndex != -1) {
                string sMenuType = llList2String(g_lMenuIDs, iMenuIndex + 1);
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
                list lMenuParams = llParseString2List(sStr, ["|"], []);
                key kAv = llList2Key(lMenuParams, 0);
                string sMessage = llList2String(lMenuParams, 1);
                integer iAuth = llList2Integer(lMenuParams, 3);
                if (sMenuType=="main") {
                    if (sMessage == UPMENU) llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                    else if (sMessage == g_sTextMenu) TextMenu(kAv, iAuth);
                    else if (sMessage == g_sColorMenu) ColorMenu(kAv, iAuth);
                    else if (sMessage == g_sFontMenu) FontMenu(kAv, iAuth);
                    else if (sMessage == "☐ Show") {
                        UserCommand(iAuth, "label on", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☑ Show") {
                        UserCommand(iAuth, "label off", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☐ Scroll") {
                        UserCommand(iAuth, "label scroll on", kAv);
                        MainMenu(kAv, iAuth);
                    } else if (sMessage == "☑ Scroll") {
                        UserCommand(iAuth, "label scroll off", kAv);
                        MainMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "color") {
                    if (sMessage == UPMENU) MainMenu(kAv, iAuth);
                    else {
                        UserCommand(iAuth, "label color "+sMessage, kAv);
                        ColorMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "font") {
                    if (sMessage == UPMENU) MainMenu(kAv, iAuth);
                    else {
                        UserCommand(iAuth, "label font " + sMessage, kAv);
                        FontMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "textbox") {
                    if (sMessage != " ") UserCommand(iAuth, "label " + sMessage, kAv);
                    UserCommand(iAuth, "menu " + g_sSubMenu, kAv);
                } else if (sMenuType == "rmlabel") {
                    if (sMessage == "Yes") {
                        if (g_sScrollText) UserCommand(iAuth, "label scroll off", kAv);
                        llMessageLinked(LINK_ROOT, MENUNAME_REMOVE , g_sParentMenu + "|" + g_sSubMenu, "");
                        llMessageLinked(LINK_DIALOG, NOTIFY, "1"+g_sSubMenu+" App has been removed.", kAv);
                        llRemoveInventory(llGetScriptName());
                    } else llMessageLinked(LINK_DIALOG, NOTIFY, "0"+g_sSubMenu+" App remains installed.", kAv);
                }
            }
        } else if (iNum == DIALOG_TIMEOUT) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex +3);
        } else if (iNum == LINK_UPDATE) {
            if (sStr == "LINK_DIALOG") LINK_DIALOG = iSender;
            else if (sStr == "LINK_RLV") LINK_RLV = iSender;
            else if (sStr == "LINK_SAVE") LINK_SAVE = iSender;
        } else if (iNum == REBOOT && sStr == "reboot") llResetScript();
    }

    timer()
    {
        string sText = llGetSubString(g_sScrollText, g_iSctollPos, -1);
        integer iCharPosition;
        for(iCharPosition=0; iCharPosition < g_iCharLimit; iCharPosition++)
            RenderString(iCharPosition, llGetSubString(sText, iCharPosition, iCharPosition));
        g_iSctollPos++;
        if(g_iSctollPos > llStringLength(g_sScrollText)) g_iSctollPos = 0 ;
    }

    changed(integer iChange)
    {
        if(iChange & CHANGED_LINK)
            if (LabelsCount()) SetLabel();
        if (iChange & CHANGED_COLOR) {
            integer iNewHide = !(integer)llGetAlpha(ALL_SIDES);
            if (g_iHide != iNewHide) {
                g_iHide = iNewHide;
                SetLabelBaseAlpha();
            }
        }
        if (iChange & CHANGED_INVENTORY) LoadFonts();
    }
}
