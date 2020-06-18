<%--  emxTypeChooser.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%!
static public String getStringCommaDelimited(TreeMap treeMap){
 java.util.Set exportSet = treeMap.keySet();
 Iterator exportIterator = exportSet.iterator();

 String typelist = "";
 StringBuffer typeListBuf = new StringBuffer();

 while(exportIterator.hasNext()){
    typeListBuf.append("\"" + (String)exportIterator.next() + "\",");
 }

 typelist = typeListBuf.toString();
if(typelist.length() > 0)
 typelist=typelist.substring(0,typelist.length()-1);
 else
 typelist="";
 return typelist;
}
%>

<%

String sPropertyKey="";
boolean bHideIcons = false;
boolean bShowMultiSelect = false;
boolean bSelectAbstractTypes = false;
boolean bObserveHidden = true;
boolean bReloadOpener = false;

String ExcludedList = emxGetParameter(request,"ExclusionList");
String IncludedList = emxGetParameter(request,"InclusionList");
String ObserveHidden = emxGetParameter(request,"ObserveHidden");
String FormFieldName = emxGetParameter(request,"fieldNameActual");
String FormFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
String FormName = emxGetParameter(request,"formName");
String FrameName = emxGetParameter(request,"frameName");
String SelectType = emxGetParameter(request,"SelectType");
String ShowIcons = emxGetParameter(request,"ShowIcons");
String SelectAbstractTypes = emxGetParameter(request,"SelectAbstractTypes");
String ReloadOpener = emxGetParameter(request,"ReloadOpener");
String languageStr = request.getHeader("Accept-Language");
String sHelpMarker=emxGetParameter(request, "HelpMarker");
String suiteDir=emxGetParameter(request, "SuiteDirectory");
String CallbackFunction = emxGetParameter(request,"callbackFunction");
String suiteKey=emxGetParameter(request, "SuiteKey");
String fromPage = emxGetParameter(request, "fromPage");


if (FormName == null || FormName.length() == 0) {
        FormName = "0";
} else {
        FormName = "\"" + XSSUtil.encodeForJavaScript(context, FormName) + "\"";
}
if(IncludedList != null)
{
    IncludedList=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(IncludedList);
}else{
    IncludedList = "";
}
if(ExcludedList != null)
{
    ExcludedList=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(ExcludedList);
}else{
    ExcludedList = "";
}

if(ShowIcons != null && ShowIcons.equalsIgnoreCase("false"))
{
    bHideIcons = true;
}

if(SelectType != null && SelectType.equalsIgnoreCase("multiselect"))
{
   bShowMultiSelect=true;
}

if(SelectAbstractTypes !=null && SelectAbstractTypes.equalsIgnoreCase("true"))
{
   bSelectAbstractTypes=true;
}

if(ReloadOpener !=null && ReloadOpener.equalsIgnoreCase("true"))
{
   bReloadOpener=true;
}

if(ObserveHidden != null && ObserveHidden.equalsIgnoreCase("false"))
{
   bObserveHidden=false;
}

String I18NResourceBundle = "emxFrameworkStringResource";
String strCancel = UINavigatorUtil.getI18nString("emxFramework.Button.Cancel",I18NResourceBundle,languageStr);
String strSelect = UINavigatorUtil.getI18nString("emxFramework.IconMail.Common.Select",I18NResourceBundle,languageStr);
String sSelectMessage = UINavigatorUtil.getI18nString("emxFramework.TypeChooser.Selectatype", I18NResourceBundle , languageStr);
String strRefinementSep =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.RefinementSeparator");
String pageHeading = UINavigatorUtil.getI18nString("emxFramework.TypeChooser.SelectType", I18NResourceBundle , languageStr);

String finalTypeList="";
String finalTypeExclList="";
String sComma=",";
Vector excludedListVector = new Vector();
Vector includedListVector = new Vector();
String PropertyFileTypeList="";
String PropertyFileTypeIncList = "";
String PropertyFileTypeExclList = "";
TreeMap treemapTypeList = new TreeMap();
TreeMap treemapTypeExclList = new TreeMap();

//IF NO INCLUDED OR EXCLUDED LIST IS PASSED< THEN WE DISPLAY ALL OF THE TYPES
//ELSE WE DIPLAY ALL EXCEPT THE EXCLUDED LIST OR JUST THE INCLUDED LIST
//IF OVERSEVEHIDDEN PARAMETER IS PASSED< THEN WE DO NOT DISPLAY ANY OF THE
//HIDDEN TYPES IRRESPECTIVE IF EXCLUDED OR INCLUDED LIST IS PASSED IN.IF BOTH
//EXCLUDED LIST AND INCLUDED LIST IS PASSED IN< THEN WE THROW AN EXCEPTION

try {
    ContextUtil.startTransaction(context, false);

    if(ExcludedList.length() == 0 && IncludedList.length() == 0)
    {
       sPropertyKey="All";
    }else if(IncludedList.length()>0 && (ExcludedList.length() == 0)){
        sPropertyKey="Include";

        try{
         PropertyFileTypeList = EnoviaResourceBundle.getProperty(context,IncludedList);
        } catch (Exception ex) {
         PropertyFileTypeList = IncludedList;
        }

        if(PropertyFileTypeList == null)
        {
           PropertyFileTypeList = IncludedList;
        }

    }else if(ExcludedList.length()>0 && IncludedList.length() == 0){
        sPropertyKey="Exclude";

        try{
         PropertyFileTypeList = EnoviaResourceBundle.getProperty(context,ExcludedList);
        } catch (Exception ex) {
         PropertyFileTypeList = ExcludedList;
        }

        if(PropertyFileTypeList == null)
        {
          PropertyFileTypeList = ExcludedList;
        }

        StringTokenizer excludeTokenizer = new StringTokenizer(PropertyFileTypeList, sComma);
        while (excludeTokenizer.hasMoreTokens())
        {
            String eachType=excludeTokenizer.nextToken().trim();
            if (eachType != null && eachType.length()>0)
            {
                //String realName=Framework.getPropertyValue(session,eachType);
                String realName = PropertyUtil.getSchemaProperty( context,eachType);

                if (realName == null)
                {
                    excludedListVector.addElement(eachType);
                }else{
                    excludedListVector.addElement(realName);
                }
            }
        }
    }else if((ExcludedList.length() > 0 && IncludedList.length() > 0)){
        sPropertyKey = "IncludeAndExclude";
        //Inclusion
        try{
            PropertyFileTypeIncList = EnoviaResourceBundle.getProperty(context,IncludedList);
        } catch (Exception ex) {
            PropertyFileTypeIncList = IncludedList;
        }

        if(PropertyFileTypeIncList == null)
        {
            PropertyFileTypeIncList = IncludedList;
        }        
        //Exclusion
        try{
            PropertyFileTypeExclList = EnoviaResourceBundle.getProperty(context,ExcludedList);
        } catch (Exception ex) {
            PropertyFileTypeExclList = ExcludedList;
        }

        if(PropertyFileTypeExclList == null)
        {
            PropertyFileTypeExclList = ExcludedList;
        }        
    }

    if (suiteDir == null || suiteDir.trim().length() == 0)
    {
        suiteDir = "common";
    }

    if (sHelpMarker == null || sHelpMarker.trim().length() == 0)
    {
        sHelpMarker = "emxhelptypechooser";
    }

    if(sPropertyKey==null  || sPropertyKey.equals(""))
    {
        sPropertyKey="All";
    }

    if(sPropertyKey.equalsIgnoreCase("Include") && PropertyFileTypeList != null && !"".equals(PropertyFileTypeList)){
        treemapTypeList = UINavigatorUtil.getInclusionListTypes(context,PropertyFileTypeList,languageStr,bObserveHidden);
    }else if(sPropertyKey.equalsIgnoreCase("Exclude")){
        treemapTypeList = UINavigatorUtil.getTopLevelMatrixTypes(context,excludedListVector,languageStr,bObserveHidden);
    }else if(sPropertyKey.equalsIgnoreCase("IncludeAndExclude")){
        treemapTypeList = UINavigatorUtil.getInclusionListTypes(context,PropertyFileTypeIncList,languageStr,bObserveHidden);
        treemapTypeExclList = UINavigatorUtil.getInclusionListTypes(context,PropertyFileTypeExclList,languageStr,bObserveHidden);
    }else {    
        Vector excludeVector = null;
        String generalExclude = EnoviaResourceBundle.getProperty(context, "emxFramework.Types.ExclusionList");
        if(generalExclude != null && !"".equals(generalExclude)) {
                StringTokenizer excludeTok = new StringTokenizer(generalExclude, sComma);
                excludeVector = new Vector();
                while (excludeTok.hasMoreTokens())
                {
                    String strexType=excludeTok.nextToken().trim();
                    if (strexType != null && strexType.length()>0)
                    {
                        String realName = PropertyUtil.getSchemaProperty( context,strexType);

                        if (realName == null)
                        {
                            excludeVector.addElement(strexType);
                        }else{
                            excludeVector.addElement(realName);
                        }
                    }
                }
        }
        treemapTypeList = UINavigatorUtil.getTopLevelMatrixTypes(context,excludeVector,languageStr,bObserveHidden);
    }
	if(sPropertyKey.equalsIgnoreCase("IncludeAndExclude")){
	    finalTypeExclList = getStringCommaDelimited(treemapTypeExclList);	    
	}
    finalTypeList = getStringCommaDelimited(treemapTypeList);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("Type Chooser:" + ex.toString().trim());
} finally {
    ContextUtil.commitTransaction(context);
}

%>

<html>
<head>
<title><%=pageHeading%></title><!-- XSSOK -->
<%@include file="../common/emxUIConstantsInclude.inc" %>
<script language="javascript" src="../emxUIFilterUtility.js"></script>
<script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>

<script language="javascript" src="scripts/emxUICoreMenu.js"></script>
<script language="javascript" src="scripts/emxUIToolbar.js"></script>
<script language="javascript" src="scripts/emxUIDOMTypeChooser.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIDialog");
	addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIDOMTypeChooser");
    if(Browser.MOBILE){
    	addStyleSheet("emxUIMobile", "mobile/styles/");	
    }
</script>
<script language="JavaScript" type="text/javascript">
	function setdivPageBodyTopPos(){
		var divPageBody = document.getElementById("divPageBody");
		if(divPageBody){
			toppos = jQuery('#pageHeadDiv').height();
			divPageBody.style.top = toppos + "px";
		}
	}
	
    //XSSOK
    var txtType,txtTypeDisp;
    //XSSOK
    var bAbstractSelect =<%=bSelectAbstractTypes%>;
    //XSSOK
    var bMultiSelect = <%=bShowMultiSelect%>;
    //XSSOK
    var bShowIcons = !<%=bHideIcons%>;
    //XSSOK
    var bReload = <%=bReloadOpener%>
    //XSSOK
    var arrTypes = new Array(<%=finalTypeList%>);
    //XSSOK
    var excludeTypes = new Array(<%=finalTypeExclList%>);
  
  	var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<xss:encodeForJavaScript><%=FrameName%></xss:encodeForJavaScript>");   
    
<% 
	if(CallbackFunction != null && CallbackFunction.trim().length() > 0)
	{ 
%>
		if(targetFrame!=null)
		{
    
    	 //Modified for Search Component Consolidated View Feature
    	 
			var callbackFunction = null;
        
			if(targetFrame.document)
			{
       			callbackFunction = targetFrame.<%=XSSUtil.encodeForJavaScript(context, CallbackFunction)%>;       		
			} 
			else if(targetFrame.contentWindow)
			{
       			callbackFunction = targetFrame.contentWindow.<%=XSSUtil.encodeForJavaScript(context, CallbackFunction)%>;   
       			targetFrame = targetFrame.contentWindow;  		    		
			}
       
        //Ended for Search Component Consolidated View Feature       
        
    } 
	else
    {
        var callbackFunction = getWindowOpener().<%= XSSUtil.encodeForJavaScript(context, CallbackFunction) %>;
    }

    <% } %>
    
    
    if(targetFrame !=null){
      //XSSOK
      objForm = emxUICore.getNamedForm(targetFrame,<%=FormName%>);
      txtType=objForm.elements["<%=XSSUtil.encodeForHTML(context, FormFieldName)%>"];
      txtTypeDisp=objForm.elements["<%=XSSUtil.encodeForHTML(context, FormFieldNameDisplay)%>"];
    } else if("CustomToolbarSlidein" == '<%=XSSUtil.encodeForJavaScript(context, fromPage)%>'){
    	var formFieldName = '<%=XSSUtil.encodeForHTML(context, FormFieldName)%>';
    	var formFieldDisplay = '<%=XSSUtil.encodeForHTML(context, FormFieldNameDisplay)%>';
    	//XSSOK
    	objForm = emxUICore.getNamedForm(getWindowOpener(),<%=FormName%>);
    	txtType = getTopWindow().getWindowOpener().getTopWindow().document.getElementById(formFieldName);
        txtTypeDisp = getTopWindow().getWindowOpener().getTopWindow().document.getElementById(formFieldDisplay);
    }else{
      setTimeout(function(){
      var aFrame =findFrame(getTopWindow().getWindowOpener(), "windowShadeFrame");
      if(aFrame&& aFrame.location.href.indexOf("emxFullSearch.jsp")>-1 ){
      	//XSSOK
      	objForm = emxUICore.getNamedForm(aFrame,<%=FormName%>);     
      }else{
      //XSSOK
      objForm = emxUICore.getNamedForm(getWindowOpener(),<%=FormName%>);
      }      
      txtType = objForm.elements["<%=XSSUtil.encodeForHTML(context, FormFieldName)%>"];
      txtTypeDisp = objForm.elements["<%=XSSUtil.encodeForHTML(context, FormFieldNameDisplay)%>"];
      },1500);
    }

    var COMMON_HELP = "<emxUtil:i18n localize="i18nId">emxFramework.Common.Help</emxUtil:i18n>";
    var HELP_MARKER = "<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>";
    var SUITE_DIR = "<xss:encodeForJavaScript><%=suiteDir%></xss:encodeForJavaScript>";
    var LANGUAGE_STRING = "<%=langStr%>";
    var LANGUAGE_ONLINE_STR = "<%=langOnlineStr%>";
    var SUITE_KEY = "<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>";
    var OBSERVE_HIDDEN = "<xss:encodeForJavaScript><%=bObserveHidden%></xss:encodeForJavaScript>";
    //XSSOK
    var SELECT_TYPE_MSG = "<%=sSelectMessage%>";
    var STR_REFINEMENT_SEPARATOR = "<%=strRefinementSep%>";

</script>
<script language="JavaScript" src="scripts/emxUITypeChooserUtils.js" type="text/javascript"></script>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</head>
<body class='dialog' onload="doLoad(); setdivPageBodyTopPos(); turnOffProgress()">
    <!-- preload images -->
    <div style="display:none">
        <img src="images/utilTreeLineVert.gif" />
        <img src="images/utilTreeLineNodeClosed.gif" />
        <img src="images/utilTreeLineNode.gif" />
        <img src="images/utilTreeLineLastClosed.gif" />
        <img src="images/utilTreeLineLast.gif" />
        <img src="images/utilSpacer.gif" />
        <img src="images/iconStatusLoading.gif" />
    </div>
<div id="pageHeadDiv">
   <table>
     <tr>
   <td class="page-title">
      <h2><%=pageHeading%></h2>
    </td>
<%
         String progressImage = "../common/images/utilProgressBlue.gif";
         String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
        <td class="functions">
            <table><tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
            </tr></table>
        </td>
        </tr>
      </table>

   
                <div class="toolbar-container"><div class="toolbar-frame" id="divToolbar"><div class="toolbar  toolbar-filter">
  <table border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><select name="selFilter" id="selFilter" size="1">
                <option value="1" SELECTED><emxUtil:i18nScript localize="i18nId">emxFramework.TypeChooser.selFilter.BeginsWith</emxUtil:i18nScript></option>
                <option value="2"><emxUtil:i18nScript localize="i18nId">emxFramework.TypeChooser.selFilter.EndsWith</emxUtil:i18nScript></option>
                <option value="3"><emxUtil:i18nScript localize="i18nId">emxFramework.TypeChooser.selFilter.Contains</emxUtil:i18nScript></option>
                <option value="4"><emxUtil:i18nScript localize="i18nId">emxFramework.TypeChooser.selFilter.Equals</emxUtil:i18nScript></option>
</select></td>
      <td>
      <%
      String caseStatus=MqlUtil.mqlCommand(context,"print system $1" , "casesensitive");
      %>
	  <!-- //XSSOK -->
	  <input type="hidden" name="hiddenCaseSensitive" id="hiddenCaseSensitive" value='<%=caseStatus.equals("CaseSensitive=On") %>' />
      &nbsp;&nbsp;<input type="text" name="txtFilter" id="txtFilter" value="*" size="12" onkeypress="if (event.keyCode == 13) doFilter();" /></td>
      <td>&nbsp;&nbsp;<input type="checkbox" id="chkTopLevelOnly" value="true" checked="checked" /></td>
      <td nowrap="nowrap">&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.TypeChooser.TopLevelOnly</emxUtil:i18n>&nbsp;&nbsp;</td>
      <td><input type="button" id="btnFilter" value="<emxUtil:i18n localize="i18nId">emxFramework.History.Filter</emxUtil:i18n>" onclick="objTypeChooser.applyFilter()" /></td>
    </tr>
  </table>      </div></div></div>
        </div>
        <div id="divPageBody">
                <div id="divTree" class="listing"></div>
        </div>

        <div id="divPageFoot">
				<table>
				<tr>
				<td class="functions">
				</td>
				<td class="buttons">                
                        <table>
                          <tr>
                            <!-- //XSSOK -->
							<td><a class="footericon" href="javascript:doDone()"><img src="../common/images/buttonDialogDone.gif" border="0" alt="<%=strSelect%>" /></a></td>
                            <!-- //XSSOK -->
							<td><a href="javascript:doDone()" class="button"><button class="btn-primary" type="button"><%=strSelect%></button></a></td>
                            <!-- //XSSOK -->
							<td><a class="footericon" href="javascript:doCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<%=strCancel%>" /></a></td>
                            <!-- //XSSOK -->
							<td><a href="javascript:doCancel()" class="button"><button class="btn-default" type="button"><%=strCancel%></button></a></td>
                          </tr>
                        </table>
                </td>
                </tr>
                </table>
                </div>
        <div id="divScreen"></div>
</body>
</html>
