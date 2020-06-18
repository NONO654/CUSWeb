//=================================================================
// JavaScript emxDynamicStyleSheetDefinitions.js
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================
// emxDynamicStyleSheetDefinitions.js
//-----------------------------------------------------------------

function getURLParam(url, paramName)
{
    var ret = null;
    var index = url.indexOf(paramName);
    if (index != -1)
    {
        var index2 = url.indexOf("&", index);
        if (index2 == -1)
        {
            //param is at end of URL
            ret = url.substring((index+paramName.length+1));
        }
        else
        {
            ret = url.substring((index+paramName.length+1), index2);
        }
        ret = ret.replace(/%20/gi, ' ');
    }
    return ret;
}
function addStyle(styleName, styleDef)
{
    var found = false;
    var cssRules = null;
    if (document.styleSheets[0]['rules'])  //IE
    {
        cssRules = 'rules';
    }
    else if (document.styleSheets[0]['cssRules'])  //FF
    {
        cssRules = 'cssRules';
    }
    for (var j = 0; j < document.styleSheets[0][cssRules].length; j++)
    {
        var existingStyle = document.styleSheets[0][cssRules][j].selectorText;
        if (existingStyle != null && existingStyle.indexOf(styleName) != -1)
        {
            found = true;
            break;
        }
    }
    if (!found)
    {
        var styleClass =  'div#mx_divBody div#mx_divTree div#mx_divTreeBody table tr th.' + styleName;
        var styleClass2 = 'div#mx_divBody div#mx_divTree div#mx_divTreeBody table tr td.' + styleName;
        var styleClass3 = 'div#mx_divBody div#mx_divTable div#mx_divTableBody table tr th.' + styleName;
        var styleClass4 = 'div#mx_divBody div#mx_divTable div#mx_divTableBody table tr td.' + styleName;
        var styleClass5 = 'div#mx_divBody div#mx_divTree div#mx_divTreeBody table tr td.' + styleName + ' table tr td';
        var styleClass6 = 'div#mx_divBody div#mx_divTable div#mx_divTableBody table tr td.' + styleName + ' table tr td';

        try
        {
            var sheet = document.styleSheets[0];
            if (sheet.addRule) // IE
            {
                sheet.addRule(styleClass, styleDef);
                sheet.addRule(styleClass2, styleDef);
                sheet.addRule(styleClass3, styleDef);
                sheet.addRule(styleClass4, styleDef);
                sheet.addRule(styleClass5, styleDef);
                sheet.addRule(styleClass6, styleDef);
            }
            else if (sheet.insertRule)  // firefox
            {
                sheet.insertRule(styleClass + ' {' + styleDef + '}', sheet.cssRules.length);
                sheet.insertRule(styleClass2 + ' {' + styleDef + '}', sheet.cssRules.length);
                sheet.insertRule(styleClass3 + ' {' + styleDef + '}', sheet.cssRules.length);
                sheet.insertRule(styleClass4 + ' {' + styleDef + '}', sheet.cssRules.length);
                sheet.insertRule(styleClass5 + ' {' + styleDef + '}', sheet.cssRules.length);
                sheet.insertRule(styleClass6 + ' {' + styleDef + '}', sheet.cssRules.length);
            }
        }
        catch(err)
        {
            //alert(err);
        }
    }
}
function addDisplayStyle(url, urlParam)
{
    try
    {
        var styleInfo = getURLParam(url, urlParam);
        if (styleInfo != null && styleInfo != '')
        {
            //decode 
            styleInfo = decodeURIComponent(styleInfo);
            var list = styleInfo.split('|');
            for (i=0; i < list.length; i=i+3)
            {
                var styleDef2 = list[i+2];
                var index = styleDef2.indexOf(':');
                if (index != -1)
                {
                    //def. is an adhoc style definition
                    var styleName = list[i];
                    styleName = 'dynamic-style' + i;
                    addStyle(styleName, styleDef2);
                }
            }
        }
    }
    catch(err)
    {
        //alert(err);
    }
}

var styleDef = 'background-color: yellow; font-style: italic;';
addStyle('dynamic-filter', styleDef);

var url = window.frames.location.href;
addDisplayStyle(url, 'cellRelationshipStyle');
addDisplayStyle(url, 'cellValueStyle');
