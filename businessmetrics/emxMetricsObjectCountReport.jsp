<%-- emxMetricsObjectCountReport.jsp
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxMetricsObjectCountReport.jsp.rca 1.11 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@ include file="emxMetricsConstantsInclude.inc"%>

<%
    String useTypeChooser        = emxGetParameter(request, "useTypeChooser");
    String typeSelection         = emxGetParameter(request, "SelectType");
    String editable              = emxGetParameter(request, "editable");
    String InclusionList         = emxGetParameter(request, "InclusionList");
    String ExclusionList         = emxGetParameter(request, "ExclusionList");
    String SelectAbstractTypes   = emxGetParameter(request,"SelectAbstractTypes");
    String languageStr           = request.getHeader("Accept-Language");
    String strBundle             = "emxMetricsStringResource";
    String strDateUnit           = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.DateUnit");
    String strWeek               = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Week");
    String strMonth              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Month");
    String strQuarter            = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Quarter");
    String strYear               = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Year");
    String strDisplayFormat      = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.DisplayFormat");
    String strGroupBy            = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.GroupBy");
    String strSubGroup           = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.SubGroup");
    String requiredText          = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",context.getLocale(), "emxFramework.Commom.RequiredText");
    String strTabular            = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.TabularFormat");
    String strBarChart           = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.BarChart");
    String strStackBarChart      = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.StackBarChart");
    String strLineChart          = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.LineChart");
    String strAxisLabels         = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.ChartOptions.XAxisLabels");        
    String strHorizontal         = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.ChartOptions.XAxisLabels.Horizontal");
    String strVertical           = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.ChartOptions.XAxisLabels.Vertical");
    String strRenderOptions      = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.ChartOptions.RenderOptions");
    String str3D                 = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.ChartOptions.3D");

    StringList vaultList         = new StringList();
    boolean isTypeFieldEditable  = true;
    boolean showAdvancedLink     = true;
    String typeChooserURL        = "";
    String vaultDefaultSelection = "";
    String contextVault          = "";
    String translatedTypeNames   = "";
    String lastSearchedTypes     = "";
    String strContainedIn = "";
    String strActualContainedIn = "";
    String strContainedInType="";
    String strContainedInRev="";
    String strShowPercentage  = emxGetParameter(request,"showPercentage");

    try{
        ContextUtil.startTransaction(context, false);
        if(!"false".equalsIgnoreCase(useTypeChooser) && !"true".equalsIgnoreCase(editable)) {
            isTypeFieldEditable = false;
        }
        typeChooserURL = "../common/emxTypeChooser.jsp?callbackFunction=updateAttributes&formName=MetricsObjectCountReportForm&frameName=metricsReportContent&fieldNameActual=txtTypeActual&fieldNameDisplay=txtTypeDisplay";
        typeChooserURL += "&SelectType=" + XSSUtil.encodeForURL(context, typeSelection);

        //Allow type chooser to use abstract types?
        if(SelectAbstractTypes != null && "false".equals(SelectAbstractTypes.toLowerCase())) {
            SelectAbstractTypes = "false";
        }else{
            SelectAbstractTypes = "true";
        }
        typeChooserURL += "&SelectAbstractTypes=" + SelectAbstractTypes;

        if(InclusionList != null && InclusionList.trim().length() > 0) {
            typeChooserURL += "&InclusionList=" + XSSUtil.encodeForURL(context, InclusionList);
        } else if(ExclusionList != null && ExclusionList.trim().length() > 0) {
            typeChooserURL += "&ExclusionList=" + XSSUtil.encodeForURL(context, ExclusionList);
        } else {
            typeChooserURL += "&InclusionList=emxMetrics.MetricsReports.Types";
            //Added for Note Type Feature 
            //typeChooserURL += "&InclusionList=emxFramework.GenericSearch.Types";
        }

        //vaultList = FrameworkUtil.split(OrganizationUtil.getAllVaults(context, PersonUtil.getUserCompanyId(context), true),",");
        vaultDefaultSelection = PersonUtil.getSearchDefaultSelection(context);
        if(vaultDefaultSelection == null || "".equals(vaultDefaultSelection)) {
            vaultDefaultSelection = EnoviaResourceBundle.getProperty(context, "emxFramework.DefaultSearchVaults");
        }  
   strContainedIn = emxGetParameter(request, "txtContainedIn");
   strActualContainedIn = emxGetParameter(request, "txtActualContainedIn");

if ((strContainedIn == null) || "null".equalsIgnoreCase(strContainedIn)||"".equals(strContainedIn))
 {
  strContainedIn = "";
 }
if ((strActualContainedIn == null) || "null".equalsIgnoreCase(strActualContainedIn))
{
  strActualContainedIn = "";
 }
//Contained Object Type Name and Rev Information
    strContainedInType = emxGetParameter(request, "txtContainedInType");

    if ((strContainedInType == null) || "null".equalsIgnoreCase(strContainedInType))
     {
          strContainedInType = "";
     }
    
	strContainedInRev = emxGetParameter(request, "txtContainedInRev");

    if ((strContainedInRev == null) || "null".equalsIgnoreCase(strContainedInRev))
     {
          strContainedInRev = "";
     }
    }catch (Exception ex){
        ContextUtil.abortTransaction(context);
        if(ex.toString() != null && (ex.toString().trim()).length()>0){
            emxNavErrorObject.addMessage("emxMetricsObjectCountDialog :" + ex.toString().trim());
        }
    }
    finally{
        ContextUtil.commitTransaction(context);
    }
%>

<head>
<title></title>
    <script type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
    <script type="text/javascript" src="emxMetrics.js"></script>
    <script type="text/javascript" src="emxMetricsObjectCountUtils.js"></script>
    <script type="text/javascript" language="JavaScript">       
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIMenu");
        addStyleSheet("emxUIForm");
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIList");
        addStyleSheet("emxUIContainedInSearch");
    </script>
</head>

<body onload="getTopWindow().loadReport(); setTimeout('doLoad()',100); turnOffProgress();">
    <form method="post" name="MetricsObjectCountReportForm" id="MetricsObjectCountReportForm">
        <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
            <tr><td class="requiredNotice" align="center" nowrap ><%=requiredText%></td></tr>
        </table>
        <table border="0" cellpadding="5" cellspacing="2" width="100%">
            <tr>
              <td class="labelRequired" width="150" align="left"><emxUtil:i18n localize="i18nId">emxFramework.Common.Type</emxUtil:i18n></td>

              <td class="inputField">
                  <input type="text" name="txtTypeDisplay" id="txtTypeDisplay" value="<%=translatedTypeNames%>" size="20" readonly="readonly" onChange="updateType(this.value);" title="<%=translatedTypeNames%>" />
                  <input type="hidden" name="txtTypeActual" id="txtTypeActual" value="<%=lastSearchedTypes%>" />
                  <input name="button" type="button" value="..." onclick="javascript:getTopWindow().showChooser('<%=typeChooserURL.toString()%>', 500, 500)" />
              </td>
            </tr>
            <tr>
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></td>
                <td class="inputField">
                    <input type="text" size="20" value="*" name="txtName" id="txtName" />
                </td>
            </tr>
            <tr>
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Revision</emxUtil:i18n></td>
                <td class="inputField">
                    <input type="text" name="txtRev" id="txtRev" value="*" />
                    <input type="checkbox" name="latestRevision" onclick="javascript:disableRevision()" /><emxUtil:i18n localize="i18nId">emxFramework.GlobalSearch.LatestRevisionOnly</emxUtil:i18n>
                </td>
            </tr>
            <tr>
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Vault</emxUtil:i18n>&nbsp;</td>
                <td class="inputField">
                    <table border="0" cellspacing="1" cellpadding="2">
                        <tr>
<%
                            String checked = "";
                            if (  PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) )
                            {
                                checked = "checked";
                            }
%>
							<!-- //XSSOK -->
                            <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=checked%> />
                            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.UserDefaultVault</emxUtil:i18n>&nbsp;
                            </td>
                        </tr>
                        <tr>
<%
                            checked = "";
                            if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) )
                            {
                                checked = "checked";
                            }
%>
							<!-- //XSSOK -->
                           <td><input name="vaultSelction" type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=checked%> />
                               <emxUtil:i18n localize="i18nId">emxFramework.Preferences.LocalVaults</emxUtil:i18n>&nbsp;
                           </td>
                        </tr>
                        <tr>
<%
                            checked = "";
                            String vaults = "";
                            String selVault = "";
                            String selDisplayVault = "";
                            String vaultSelected = vaultDefaultSelection;
                            if (!PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) &&
                               !PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) &&
                               !PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
                            {
                                checked = "checked";
                                selDisplayVault = i18nNow.getI18NVaultNames(context, vaultDefaultSelection, languageStr);
                            }else{
                                vaultSelected = "";
                            }
%>
							<!-- //XSSOK -->
                            <td><input type="radio" name="vaultSelction" value="SELECTED_VAULT" <%=checked%> />
                                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.SelectedVaults</emxUtil:i18n>&nbsp;
                                <input type="text" name="vaultsDisplay" value="<%=selDisplayVault%>" size="15" readonly="readonly" onfocus="this.title=this.value;" onmouseover="this.title=this.value;" title="<%=selDisplayVault%>" />
                                <input name="btnType" type="button" value="..." onclick="javascript:setSelectedVaultOption()" />
                                <input type="hidden" name="vaults" value="<%=vaultDefaultSelection%>" size="15" />
                                &nbsp;
                                <a class="dialogClear" href="#" onclick="javascript:clearVault()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
                            </td>
                        </tr>
                        <tr>
<%
                            checked = "";
                            if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) )
                            {
                                checked = "checked";
                            }
%>
							<!-- //XSSOK -->
                            <td><input type="radio" name="vaultSelction" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%> />
                                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.AllVaults</emxUtil:i18n>&nbsp;
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr> 
<%
//Added for Note Type Feature 
InclusionList = "emxFramework.ContextSearch.ContainedIn.Types";
%>
<!  Added for Note Type feature >
                <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.ContainedIn</emxUtil:i18n></td>
                <td class="inputField">
<!--                    <input type="text" size="20" name="txtContainedIn" readonly="readonly" value="" />-->
   <input type="text" name="txtContainedIn" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strContainedIn%></xss:encodeForHTMLAttribute>" />
   <input name="button" type="button" value="..." onclick="javascript:showAffectedItemSelector()" />

   <a class="dialogClear" href="#" onclick="javascript:clearContainedIn()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
   <iframe name="hiddenFrm" id="hiddenFrm" frameborder="0"  style="position:absolute;display:none;" src="javascript:false;" scrolling="no"></iframe>
   <input type="hidden" name="txtActualContainedIn" value="<xss:encodeForHTMLAttribute><%=strActualContainedIn%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="txtContainedInType" value="<xss:encodeForHTMLAttribute><%=strContainedInType%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="txtContainedInRev" value="<xss:encodeForHTMLAttribute><%=strContainedInRev%></xss:encodeForHTMLAttribute>" />
               &nbsp;
&nbsp;<img src="../common/images/iconActionHelp.gif" border="0" style="cursor: pointer" id="imgTag" ></img>
    </td>
          </tr>

            <tr>
                <td class="labelRequired" width="150"><%=strGroupBy%></td>
                <td nowrap class="inputField">
                    <table>
                        <tr>
                            <td>
                                <div id="grpBydiv" style="visibility:visible;z-Index:1">
                                    <select name="lstGroupBy" id="lstGroupBy" onChange="javascript:updateSubgroup();">
                                    </select>
                                </div>
                                </td>
                            <td>&nbsp;&nbsp;</td>
                            <td><b><%=strSubGroup%></b></td>
                            <td>
                                <div id="subGrpBydiv" style="visibility:visible;z-Index:1">
                                    <select name="lstSubgroup" id="lstSubgroup">
                                    </select>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td width="150" class="labelRequired"><div id="dlabelDir"><%=strDateUnit%></div></td>
                <td class="inputField">
                    <div id="dlabelDirVal">
                        <table>
                            <tr>
                                <td>
                                    <input type="radio" name="optDateUnit" value="W" disabled />
                                    <%=strWeek%>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="radio" name="optDateUnit" value="M" disabled />
                                    <%=strMonth%>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="radio" name="optDateUnit" value="Q" disabled />
                                    <%=strQuarter%>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="radio" name="optDateUnit" value="Y" disabled />
                                    <%=strYear%>
                                </td>
                            </tr>
                        </table>
                    </div> 
                </td>
            </tr>
            <tr>
                <td width="150" class="labelRequired"><%=strDisplayFormat%></td>
                <td class="inputField">
                    <select name="chartType">
                        <option value="Tabular" selected><%=strTabular%></option>
                        <option value="BarChart"><%=strBarChart%></option>
                        <option value="StackBarChart"><%=strStackBarChart%></option>
                        <option value="LineChart"><%=strLineChart%></option>
                    </select>
                </td>
            </tr>
            <tr id="labeldirectionrow">
                <td width="150" class="label"><div id="dlabelDir"><%=strAxisLabels%></div></td>
                <td class="inputField">
                    <div id="dDirVal">
                    <table>
                        <tr>
                            <td>
                                <input type="radio" name="labelDirection" value="Vertical" checked />
                                <%=strVertical%>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="radio" name="labelDirection" value="Horizontal" />
                                <%=strHorizontal%>
                            </td>
                        </tr>
                    </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td width="150" class="label"><%=strRenderOptions%></td>
                <td class="inputField">
                    <table>
                        <tr>
                            <td>
                                <input type="checkbox" name="draw3D" onclick="javascript:set3DValue()" />
                                <%=str3D%>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <table border="0" cellpadding="5" cellspacing="2" width="100%">
            <tr>
                <td>&nbsp;</td>
            </tr>
        </table>
<% 
        if(showAdvancedLink){ 
%>
            <table border="0" cellpadding="5" cellspacing="2" width="100%">
                <tr>
                    <td width="150"><img src="../common/images/utilSearchPlus.gif" width="15" height="15" align="texttop" border="0" id="imgMore" /><a href="#" onclick="javascript:toggleMore();return false;"><emxUtil:i18n localize="i18nId">emxFramework.Common.More</emxUtil:i18n></a></td>
                    <td>&nbsp;</td>
                </tr>
            </table>
<% 
           }
String containedInStr = "emxFramework.Common.ContainedIn";
%>
            <script type="text/javascript" language="JavaScript">
            var floatingDiv=null;
            var hiddenIFrame=null;
    function showAffectedItemSelector(){
      var sURL= "../common/emxSearch.jsp?formName=MetricsObjectCountReportForm&containedInFlag=false&defaultSearch=AEFContainedInSearch";
      sURL = sURL + "&frameName=metricsReportContent&fieldNameActual=txtActualContainedIn";
      sURL = sURL + "&fieldNameDisplay=txtContainedIn&searchmode=chooser&suiteKey=Components";
      //XSSOK
      sURL = sURL + "&InclusionList=<%=XSSUtil.encodeForURL(context, InclusionList)%>&SubmitURL=../common/emxObjectSelect.jsp&CancelButton=true&title=<%=containedInStr%>&containedInFieldType=txtContainedInType&containedInFieldRev=txtContainedInRev";
      sURL = sURL + "&selection=Single&showToolbar=false";
      showModalDialog(sURL,700,600);
    }
</script>

        <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
        <!-- the following div MUST come just before closing form tag -->
        <div id="divMore" style="display:none"></div>
    </form>
            <div id = "showPercentage" style = "visibility:hidden "><xss:encodeForHTML><%=strShowPercentage%></xss:encodeForHTML></div>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
