<%--  emxPortal.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPortal.jsp.rca 1.8 Tue Oct 28 18:55:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>
<%@include file = "emxPortalBrowserCheck.inc"%>
<%@include file = "emxNavigatorCheckReadAccess.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<html>
<%
String objectId = emxGetParameter(request, "objectId");
//gqh: IR-126307V6R2013
String relId = emxGetParameter(request, "relId");
String pageHeader= "";
String title ="";
if(objectId!=null && !"".equalsIgnoreCase(objectId))
{
pageHeader=UIUtil.getWindowTitleName(context,null,objectId,pageHeader, true);
}

Enumeration en = emxGetParameterNames(request); 
while (en.hasMoreElements()) { 
String strParamName = (String)en.nextElement(); 
String[] strParamValues = emxGetParameterValues(request, strParamName);
for (int i = 0; i < strParamValues.length; i++) { 
//System.out.println(strParamName + "=" + strParamValues[i]); 
} 
}
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");

/*
for(int i=0;i<tableRowIdList.length; i++)
{
	System.out.println("--tableRowIdList11--"+i+"---"+tableRowIdList[i]);	
}*/
String  strtableRowIdList=null;
StringList objectIdList = null;
//String relId = null;
String parentObjId = null;

if(tableRowIdList!=null)
{
	strtableRowIdList=tableRowIdList[0];
	objectIdList = FrameworkUtil.split(strtableRowIdList, "|");
	if(objectIdList.size()>2)
    {
    	   relId=(String)objectIdList.get(0);
		   parentObjId=(String) objectIdList.get(2);
	}
}
else
{
	strtableRowIdList=emxGetParameter(request,"emxTableRowId");
}
if( relId !=null && !relId.equals("null") && relId.trim().length() != 0){
pageHeader=UIUtil.getWindowTitleName(context,relId,objectId,pageHeader);
}


    // Collect all the parameters passed-in and forward them to Tree Display frame.
    StringBuffer sfb = new StringBuffer();
    int paramind = 1;
    Enumeration enumParamNames = emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements()) {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = emxGetParameter(request, paramName);
     // To avoid JS error when potal gets called from Full Text search
		if(paramName.equals("categoryTreeName") || paramName.equalsIgnoreCase("ftsFilters")|| paramName.equalsIgnoreCase("toolbar")){
			continue;
		}
        if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) {
                if(paramind > 1)
                        sfb.append("&");

                sfb.append(XSSUtil.encodeForURL(context,paramName));
                sfb.append("=");
                sfb.append(XSSUtil.encodeForURL(paramValue));
                paramind++;
        }
    }

    String appendParams = sfb.toString();
    
    String toolbar = emxGetParameter(request, "toolbar");

// Code modified for PowerView Enhancements  added 16 Aug 07
    String showPageHeader = emxGetParameter(request, "showPageHeader");    
    String portalDisplayPage = "emxPortalDisplay.jsp?" + appendParams;

	String languageStr = request.getHeader("Accept-Language");
	String editLink = emxGetParameter(request, "editLink");
	String suiteKey = emxGetParameter(request, "suiteKey");
    String categoryTreeName = emxGetParameter(request, "categoryTreeName");
	String sHelpMarker = emxGetParameter(request, "HelpMarker");
    String tipPage = emxGetParameter(request, "TipPage");
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
    String export = emxGetParameter(request, "Export");


	String header = emxGetParameter(request, "header");
	if(header != null && !"".equals(header)) {
		header = UINavigatorUtil.parseHeader(context, pageContext, header, objectId, suiteKey, languageStr);
	} else {
		header = "emxFramework.HomePortal.Header";
		if ( objectId != null && objectId.trim().length() > 0 ) {
			header = "emxFramework.ObjectPortal.Header";
		}
		header = UINavigatorUtil.parseHeader(context, pageContext, header, objectId, "Framework", languageStr);
	}

    String subHeader = emxGetParameter(request, "subHeader");
	if ( (subHeader != null) && (subHeader.trim().length() > 0) ) {
		subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, languageStr);
	}
	if(UIUtil.isNullOrEmpty(header))
		title = pageHeader;
	else
		title = header;

	header = "";
	subHeader = "";
%>

<head>
<title><%=XSSUtil.encodeForHTML(context, pageHeader)%></title>
	<%@include file = "emxUIConstantsInclude.inc"%>
	<%@include file = "../emxStyleDefaultInclude.inc"%>

	<script type="text/javascript">
		addStyleSheet("emxUIDOMLayout");
		addStyleSheet("emxUIToolbar");
		addStyleSheet("emxUIMenu");
	</script>
 <script type="text/javascript">
   //if Portal opened in popup then redirect it into emxNavigatorDialog.jsp

         if(getTopWindow().getWindowOpener() && getTopWindow() == self){
        	 document.write("<scri" + "pt language=\"JavaScript\" type=\"text/javascript\" src=\"../common/scripts/emxUISlideIn.js\"></scr" + "ipt>");
         }
  </script>
	<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
    <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
    <script language="JavaScript" type="text/javascript">
    function setTitle(){
    	if(getTopWindow().document.location.href.indexOf("emxNavigatorDialog.jsp") >= 0){
    		var strTitle = '<%=pageHeader%>';
    		if(strTitle.indexOf("$<APPNAME>") != -1){
	 			getTopWindow().document.title = strTitle.replace("$<APPNAME>", getContentWindow().applicationProductInfo.appName);
 			} else {
 				getTopWindow().document.title = strTitle;
 			}
    	}
    }
    
	    function adjustPortalBody(){
       		//document.getElementById("pageContentDiv").style.top = "0px";	
	    	var phd = document.getElementById("pageHeadDiv");
	    	var dpb = document.getElementById("divPageBody");
			addOrHideHeaderItems();
			var isExtendedHeaderPresent = jQuery(getTopWindow().document).find("#ExtpageHeadDiv").css("display") == "block";
<%
	if(!"false".equalsIgnoreCase(showPageHeader) || toolbar != null || categoryTreeName != null) {
%>
			if(!isExtendedHeaderPresent) {
	    	dpb.style.top = phd.clientHeight + "px";
	} else {
<%
				if(toolbar != null || categoryTreeName != null) {
%>
					dpb.style.top = phd.clientHeight + "px";
<%
				} else {
%>
					dpb.style.top = "0px";
<%
				}
%>
			}
<%
	} else {
%>
	    	dpb.style.top = "0px";
<%
	}
%>
	
	    }
		if(getTopWindow().isMobile || getTopWindow().isPCTouch){
	    		addStyleSheet("emxUIMobile", '../common/mobile/styles/');
		}

    function clearAllFrames(doc) {
        if (!doc) {
            frames[0].objPortal = null;
            frames[0].objContainer = null;
            frames[0].objRow = null;
            doc = document;
        }
        var iframes = doc.querySelectorAll('iframe');
        for (var i = 0; i < iframes.length; i++) {
            clearAllFrames(iframes[i].contentDocument);           
            if (iframes[i].contentWindow.document.onbeforeunload) {
                iframes[i].contentWindow.document.onbeforeunload();
            }
        }
        if( typeof CollectGarbage == "function") {
            CollectGarbage();
        }
      }

    </script>
</head>
	<%
if("false".equalsIgnoreCase(showPageHeader) || (toolbar == null)) {
%>
	<body class="no-footer" onload="adjustPortalBody(); turnOffProgress();setTitle();" onbeforeunload="clearAllFrames();">
<%
} else {
%>
<body class="no-footer" onload="adjustPortalBody(); turnOffProgress();setTitle();" onbeforeunload="clearAllFrames();">
<%
}
%>
<form name="navigatorForm"></form>
<!-- <div id="pageContentDiv"> -->
<%
	String headerdisplay = "";
	String bodytop = "";
	if("false".equalsIgnoreCase(showPageHeader)) {
		headerdisplay = " style='display:none;'";
		bodytop = "style='top: 0px;'";
	}
	
%>	
<div id="pageHeadDiv" class="page-head" <%=headerdisplay%>>
<form method="post">
<%
 if(!"false".equalsIgnoreCase(showPageHeader)) {
%>
<div class="toolbar-subcontainer">
   <table id="contentHeader">
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
       String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
    %>
        <td class="functions">
    	    <table>
              <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
	        </tr></table>
        </td>
        </tr>
        </table>
        </div>
<%
 }
if(categoryTreeName != null || toolbar != null){
%>
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/>
    <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>
    <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, sHelpMarker)%>"/>
    <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>
</jsp:include>
<%} %>
</form>
</div><!-- /#pageHeadDiv -->
        <div id="divPageBody" <%=bodytop%>>
          	<!-- //XSSOK -->
          	<iframe name="portalDisplay" src="<%=portalDisplayPage%>"  width="100%" height="100%"  frameborder="0" border="0"></iframe>      		
		</div>
	<!-- </div>  -->
 <iframe class="hidden-frame" name="hiddenFrame"></iframe>
</body>
<%@include file = "emxNavigatorTimerBottom.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>

