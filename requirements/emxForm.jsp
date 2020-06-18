<%--  emxForm.jsp - Handling of FORM - EDIT and VIEW modes

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

changes:
1. fix file include and javascript references
2. add purgeEditFormData() and saveChanges() javascript function.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
are added under respective scriplet--%>
<%-- @quickreview T25 DJH 12:12:12 - Solved compile error--%>
<%-- @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included--%>
<%-- @quickreview HAT1 ZUD IR-335960-3DEXPERIENCER2015x	Requirement : Reserve/Unreserve function freeze with a big structure --%> 
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.--%>
<html>
<head>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxFormConstantsInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%> 

<%
HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String querystring = request.getQueryString();
String HelpMarker = emxGetParameter(request, "HelpMarker");
String actionBar = emxGetParameter(request, "actionBarName");
String tipPage = emxGetParameter(request, "TipPage");
String appendURL = (String) requestMap.get("appendURL");
String mode = emxGetParameter(request, "mode");
String targetLocation = emxGetParameter(request, "targetLocation");
if(appendURL != null && !"".equalsIgnoreCase(appendURL)) {
	requestMap = UINavigatorUtil.appendURLParams(context, requestMap, "Form");
	StringBuffer paramlist = new StringBuffer();
	Iterator itr = requestMap.keySet().iterator();
	int i = 0;
	while(itr.hasNext()){
	    String key = (String)itr.next();
	    if(i > 0) {
	    	paramlist.append("&");
	    }
	    try {
	    paramlist.append(key).append("=").append((String)requestMap.get(key));
	    i++;
	    }catch(Exception e){

	    }
	}
	querystring = paramlist.toString();
}
String portalMode = (String) requestMap.get("portalMode");//emxGetParameter(request, "portalMode");
String objectId = (String) requestMap.get("objectId");//emxGetParameter(request, "objectId");
String relId = (String) requestMap.get("relId");//emxGetParameter(request, "relId");
String header = (String) requestMap.get("formHeader");//emxGetParameter(request, "formHeader");
String subHeader = (String) requestMap.get("subHeader");//emxGetParameter(request, "formHeader");
String originalHeader=(String) requestMap.get("formHeader");//emxGetParameter(request, "formHeader");

// iNoOfToolbars is used to decide the  frame size for the Header
String strTitle="";
String toolbar = (String) requestMap.get("toolbar");//emxGetParameter(request, "toolbar");
int iNoOfToolbars = 1;
if ( (toolbar != null) || (!"null".equalsIgnoreCase(toolbar)))
{
    matrix.util.StringList strList = com.matrixone.apps.domain.util.FrameworkUtil.split(toolbar,",");

    iNoOfToolbars = strList.size();

    if(iNoOfToolbars == 0)
    {
        iNoOfToolbars = 1;
    }
}

String form = (String) requestMap.get("form");//emxGetParameter(request, "form");
String timeStamp = (String) requestMap.get("timestamp");//emxGetParameter(request, "timestamp");
String suiteKey = (String) requestMap.get("suiteKey");//emxGetParameter(request, "suiteKey");
String registeredSuite = suiteKey;
String findMxLink = (String) requestMap.get("findMxLink");//emxGetParameter(request, "findMxLink");

//This Param will use an alternative stylesheet for displaying the page
String altCSS = (String) requestMap.get("altCSS");//emxGetParameter(request, "altCSS");

// The objectId , relId from the emxTable.jsp is passd as "emxTableRowId"
String tableRowIdList[] = Request.getParameterValues(request, "emxTableRowId");
String frmLanguage = request.getHeader("Accept-Language");

//String tableRowId = "";
String parsedHeader = "";
StringBuffer appendParams = new StringBuffer(100);

if (timeStamp == null || timeStamp.trim().length() == 0)
{
    timeStamp = UIComponent.getTimeStamp();
}

if (querystring != null)
{
    appendParams.append(FrameworkUtil.encodeURLParamValues(querystring));
}

String rowID = "";
try {
    ContextUtil.startTransaction(context, false);
    Vector userRoleList = PersonUtil.getAssignments(context);

    // If the From is invoked from the emxTable page, then
    // the object id will be in the format of - "relId|busId,relId2|busId2.."
    // Get the first parameter and then parse it to get objectId
    // HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
    
	if (tableRowIdList != null && tableRowIdList.length > 0)
    {
        for (int ii = 0; ii < tableRowIdList.length; ii++)
        {
            String[] tokens = tableRowIdList[ii].trim().split("[|]");

            // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.++ 
            String ObjID = (tokens.length > 1)?tokens[1]:tokens[0];
            BusinessObject busObj = new BusinessObject(ObjID);
            
        	busObj.open(context);
        	String objType = busObj.getTypeName();
        	busObj.close(context);
        	boolean isReqProxy = false;
            if(objType.equalsIgnoreCase("Requirement Proxy"))
            {
            	//No Lock for "Requirement Proxy".
            	isReqProxy = true;
            }
            // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
                        
            if (ii == 0 && !isReqProxy)
            {
                if (tokens.length > 1)
                {
                    relId = tokens[0];
                    objectId = tokens[1];

                    appendParams.insert(0, "relId=" + relId + "&");
                }
                else if (tokens.length == 1)
                {
                    objectId = tokens[0];
                }
                // Prepend the objectId parameter to the request params:
                appendParams.insert(0, "objectId=" + objectId + "&");

                // Start appending the rowIds as a comma-separated string:
                // appendParams.append("&rowIds=");
                // appendParams.append(objectId);
                // HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
                rowID +=objectId; 
            }
            else if(!isReqProxy)
            {
               // appendParams.append(",");
               // appendParams.append(tokens[1]);
               // HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
               rowID+= "," + tokens[1];
            }
        }
    }

    if ( (form == null) || (form.equals("")))
        emxNavErrorObject.addMessage(MSG_INVALID_FORM_NAME);

    // ++ HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
    long number = new Random(System.currentTimeMillis()).nextLong();
	String key = "RMTSpecTreeReserveUnreserveForm" + System.currentTimeMillis() + "_" + number;
	session.setAttribute(key, rowID);
	appendParams.append("&key="+key);
    // -- HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 

    parsedHeader = UIForm.getFormHeaderString(context, pageContext, header, objectId, suiteKey, frmLanguage);
    if( mode != null && !"".equals(mode) && !"null".equals(mode) && mode.compareToIgnoreCase("edit")==0){
    strTitle = UIUtil.getWindowTitleName(context, null,objectId,EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.WindowTitle.Edit")); 
    }
    else{
    strTitle = UIUtil.getWindowTitleName(context, null,objectId, null);
    }
    if ( altCSS != null && !"".equals(altCSS) && !"null".equals(altCSS)){
      appendParams.append("&altCSS=");
      appendParams.append(altCSS);
    }
    appendParams.append("&originalHeader=");
    appendParams.append(originalHeader);
    appendParams.append("&parsedHeader=");
    appendParams.append(com.matrixone.apps.domain.util.XSSUtil.encodeForURL(parsedHeader));
    appendParams.append("&timeStamp=");
    appendParams.append(timeStamp);
    appendParams.append("&findMxLink=");
    appendParams.append(findMxLink);

    if(!"edit".equalsIgnoreCase(mode)){
        appendParams.append("&submitMethod=");
        appendParams.append(request.getMethod());
    }

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

String viewDisplayURL = "";
String editDisplayURL = "";
	if("slidein".equals(targetLocation)){
		editDisplayURL = "../common/emxFormEditDisplaySlidein.jsp?" + appendParams.toString() + "&portalMode=" + portalMode;
        viewDisplayURL = "../common/emxFormViewDisplaySlidein.jsp?" + appendParams.toString();
	}else{
		editDisplayURL = "../common/emxFormEditDisplay.jsp?" + appendParams.toString() + "&portalMode=" + portalMode;
		viewDisplayURL = "../common/emxFormViewDisplay.jsp?" + appendParams.toString();
	}
	
String editFooterURL = "emxFormEditFooter.jsp?" + appendParams.toString();
String slideinviewFooterURL = "../common/emxFormViewFooterSlidein.jsp?" + appendParams.toString();
String portaleditFooterURL = "../common/emxFormPortalEditFooter.jsp?" + appendParams.toString();

String bodyUrl = "";
String footerURL = "";
if("slidein".equals(targetLocation) && !"edit".equalsIgnoreCase(mode)){
	footerURL = slideinviewFooterURL;
}else{
	footerURL = editFooterURL;
}

String bodyframe = "";
String hiddenFramename = "";
if ( (mode != null) && mode.equalsIgnoreCase("edit")) {
	bodyUrl = editDisplayURL;
	bodyframe = "formEditDisplay";
	hiddenFramename = "formEditHidden";
} else {
	bodyUrl = viewDisplayURL;
	bodyframe = "formViewDisplay";
	hiddenFramename = "formViewHidden";
}
header = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, frmLanguage);
if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
	subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, frmLanguage);
}

String printerFriendly = emxGetParameter(request, "PrinterFriendly");
String export = emxGetParameter(request, "Export");
String editLink = emxGetParameter(request, "editLink");
if ( (mode != null) && mode.equalsIgnoreCase("edit")) {
	editLink = "false";
	printerFriendly = "false";
	export = "false";
}

%>
<title><xss:encodeForHTML><%=strTitle%></xss:encodeForHTML></title>
	<script type="text/javascript">
	    var numtoolbars = <%=iNoOfToolbars%>;
	</script>
  <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIDOMLayout");
<%
	if ( (mode != null) && mode.equalsIgnoreCase("edit")) {
%>
		addStyleSheet("emxUIDialog");
<%
	}

	if(portalMode != null && "true".equals(portalMode)) {
%>
		addStyleSheet("emxUIChannelDefault");
		addStyleSheet("emxUIChannelActionbar");
<%
	}
%>
	addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
</script>
<script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<link rel="stylesheet" type="text/css" href="../webapps/UIKIT/UIKIT.css">
<script language="javascript">
	var popup = 'true';
	function submitPage(targetLocation)
	{
		if(targetLocation != "slidein"){
	    	//parent.formEditDisplay.document.forms["editDataForm"].isPopup.value = popup;
	        this.formEditDisplay.document.forms["editDataForm"].isPopup.value = popup;
	    }
		saveChanges(targetLocation);
	}
	function loadpage()
	{
        // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
        // HAT1 TODO rectification.
		if(<%= rowID.equalsIgnoreCase("") %>)
		{
			alert("Incorrect selection: 'Requirement Proxy' does not support Lock or Unlock.")
			getTopWindow().closeWindow();
			return;
		}
        // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 

		var toppage = getTopWindow().document.location.href;
		if(toppage.indexOf("emxForm.jsp") < 0)
		{
			popup = 'false';
			//parent.formEditDisplay.document.forms[0].isPopup.value = 'false';
			//parent.frames[1].document.forms[0].isPopup.value = 'false';
			var cnlImg = document.getElementById('cancelImage');
			var cnlTxt = document.getElementById('cancelText');
			if(cnlTxt && cnlImg){
	            cnlTxt.innerHTML = "";
	            cnlImg.innerHTML = "";
			}
		}
	}
	function purgeEditFormData(timeStamp){
	    //querystring
	    var qString = location.search;
	    var msg = trimString(emxUICore.getData('../common/emxFormEditCancelProcess.jsp'+ qString));
		msg = fastTrim(msg);
	    if(msg.length > 0){
	        //<script??
	        if(msg.indexOf("<script")>-1){
	            var myFrame = findFrame(getTopWindow(),"formEditHidden");
	            if(myFrame){
	                myFrame.document.open();
	                myFrame.document.write(msg);
	                myFrame.document.close();
	            }
	        }else if(msg != '<!DOCTYPE html>'){
	            alert(msg);
	        }
	    }
	}

	function saveChanges()
	{
	    if(canSubmit)
	    {
	        if (parent.searchPane)
	        {
	            // The "editDataForm" will be inside the frame "searchPane",
	            // if "emxFormEditDisplay.jsp" is used in the context of "emxCommonSearch.jsp".
	            if(getTopWindow().doSearch)
	            {
	                getTopWindow().doSearch();
	            }
	        }
	        else if (parent.searchContent)
	        {
	            //This will happen when "emxFormEditDisplay.jsp" is used with searchmode globalsearch
	            var bodyFrame = findFrame(getTopWindow(),"searchFoot");
	            if(bodyFrame && bodyFrame.doFind)
	            {
	                bodyFrame.doFind();
	            }
	        }
	        else
	        {
	            // The "editDataForm" will be inside the frame "formEditDisplay",
	            // if "emxFormEditDisplay.jsp" is used in the context of "emxForm.jsp".

	            if (validateForm()) {
	                //clear unload methods
	                //!!IMPORTANT!! unload events must be cancelled for everything except powerviews
	                //unload events are calling purgeEditFormData()
	                //this is being called directly from emxFormEditProcess.jsp and needs to happen
	                //BEFORE closing a dialog
	                
	                try{
			 //KIE1 ZUD TSK447636 
	                if(getTopWindow().getWindowOpener() != null){
	                    if(getTopWindow().getWindowOpener().document.location.href.indexOf("emxFormViewHeader.jsp")>-1) {
	                        parent.formEditDisplay.document.getElementById("sessionRemove").value = "false";
	                    	}
	               		}
	                } catch (e) {
	                // do nothing 
	                }
	                if(getTopWindow().location.href.indexOf("emxForm.jsp") > -1){
	                    parent.formEditDisplay.document.body.onunload = function(){};
	                    parent.formEditDisplay.document.body.onbeforeunload = function(){};
	                }
	                var target = "formEditHidden";
	                /*
	                var formName=parent.formEditDisplay.document.forms["editDataForm"];
	                formName.target = target;               
	                var timeStamp=parent.formEditDisplay.document.getElementById("timeStamp").value;
	                var mode=parent.formEditDisplay.document.getElementById("mode").value;
	                var uiType=parent.formEditDisplay.document.getElementById("uiType").value;
	                */
	                var formName=this.formEditDisplay.document.forms["editDataForm"];
	                formName.target = target;               
	                var timeStamp=this.formEditDisplay.document.getElementById("timeStamp").value;
	                var mode=this.formEditDisplay.document.getElementById("mode").value;
	                var uiType=this.formEditDisplay.document.getElementById("uiType").value;
	                
	                if (validatemxLinks(formName, mode, uiType, timeStamp))
	                {
	                    setFormSubmitAction(false);
	                    turnOnProgress();
	                    document.body.style.cursor = "wait";
	                    //parent.formEditDisplay.document.body.style.cursor = "wait";
	                    this.formEditDisplay.document.body.style.cursor = "wait";
	                    var url = "../requirements/emxFormEditProcess.jsp";
	                    //parent.formEditDisplay.document.forms["editDataForm"].action = url;
	                    //parent.formEditDisplay.document.forms["editDataForm"].submit();
	                    this.formEditDisplay.document.forms["editDataForm"].action = url;
	                    this.formEditDisplay.document.forms["editDataForm"].submit(); 
	            }
	           }else
	            {
	                    setFormSubmitAction(true);
	            }
	        }
	    }
	    else
	    {
	        return;
	    }
	}
<%
	if ( (mode != null) && mode.equalsIgnoreCase("edit")) {
%>
	emxUICore.addEventHandler(window, "load", loadpage);
<%
	}
%>
turnOffProgress();
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</head>
<%
if ( (mode != null) && mode.equalsIgnoreCase("edit") || "slidein".equals(targetLocation)) {
%>
	<body class="dialog" onload="JavaScript:loadFrames('<xss:encodeForJavaScript><%=footerURL%></xss:encodeForJavaScript>');turnOffProgress();">
<%
}else{%>
	<body class="no-footer" onload="turnOffProgress();" onunload="JavaScript:purgeViewFormData('<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>')">
<%}
%>
<form method="post">
<div id="pageHeadDiv">
   <table>
     <tr>
   <td class="page-title">
      <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
<%
      if(subHeader != null && !"".equals(subHeader)) {
%>
        <h3><xss:encodeForHTML><%=subHeader%></xss:encodeForHTML></h3>
<%
        }
%>
    </td>
<%
         String progressImage = "../common/images/utilProgressBlue.gif";
         String processingText = UINavigatorUtil.getProcessingText(context, frmLanguage);
 %>
        <td class="functions">
            <table><tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><xss:encodeForHTMLAttribute><%=processingText%></xss:encodeForHTMLAttribute></div></td>
            </tr></table>
        </td>
        </tr>
      </table>

<jsp:include page = "../common/emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value=""/>
    <jsp:param name="objectId" value="<%=objectId%>"/> 
    <jsp:param name="relId" value="<%=relId%>"/>
    <jsp:param name="parentOID" value="<%=objectId%>"/>
    <jsp:param name="timeStamp" value="<%=timeStamp%>"/>
    <jsp:param name="header" value="<%=header%>"/>
    <jsp:param name="uiType" value="form"/>
    <jsp:param name="form" value="<%=form%>"/>
    <jsp:param name="helpMarker" value="<%=HelpMarker%>"/>
    <jsp:param name="suiteKey" value="<%=registeredSuite%>"/>
    <jsp:param name="findMxLink" value="<%=findMxLink%>"/>
	<jsp:param name="topActionbar" value="<%=actionBar%>"/>
	<jsp:param name="tipPage" value="<%=tipPage%>"/>
    <jsp:param name="editLink" value="<%=editLink%>"/>
    <jsp:param name="PrinterFriendly" value="<%=printerFriendly%>"/>
    <jsp:param name="export" value="<%=export%>"/>
    <jsp:param name="mode" value="<%=mode%>"/>
    <jsp:param name="targetLocation" value="<%=targetLocation%>"/>
</jsp:include>
</div>
        <div id="divPageBody">
            <div>
          		<iframe name="<xss:encodeForHTMLAttribute><%=bodyframe%></xss:encodeForHTMLAttribute>" src="<xss:encodeForHTMLAttribute><%=bodyUrl%></xss:encodeForHTMLAttribute>" width="99%" height="99%"  frameborder="0" border="0"></iframe>
            	<iframe class="hidden-frame" name="<xss:encodeForHTMLAttribute><%=hiddenFramename%></xss:encodeForHTMLAttribute>" src="../common/emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>
			</div>
		</div>
<%
if ( (mode != null) && mode.equalsIgnoreCase("edit") || "slidein".equals(targetLocation)) {
%>
        <div id="divPageFoot">
		</div>
<%
	}
%>
</form>
</body>
</html>
