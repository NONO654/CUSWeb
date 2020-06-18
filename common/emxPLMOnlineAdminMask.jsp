<%--  emxComponentsPeopleQueryFS.jsp -- 

--%>

<%@ page import="java.util.List"%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../components/emxComponentsFramesetUtil.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%
    initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);

	framesetObject fs = new framesetObject();
	
	// Specify URL to come in middle of frameset
	String contentURL = "emxPLMOnlineAdminMaskQueryContent.jsp?"+emxGetQueryString(request); 

	// Marker to pass into Help Pages, icon launches new window with help frameset inside
	String HelpMarker = "emxHelpInfoCreateDialogFS";
	
	// Role based access
	String roleList = "role_GlobalUser";
	//String pageHeading = "Query for Mask";
	String pageHeading = getSafeNLS("Access.Mask.Query");
	String submitQuery = getSafeNLS("Access.Query");

	//initialize frameset
	//(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
	fs.initFrameset(pageHeading,
				  HelpMarker,
				  contentURL,
				  false,
				  false,
				  false,
				  false);
	//create footer link
	//(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
	fs.createFooterLink(submitQuery,"submitQuery()",roleList,false,true,"emxUIButtonDone.gif",0);
	//fs.createFooterLink("","window.close()",roleList,false,true,"emxUIButtonCancel.gif",0);

	fs.writePage(out);

%>
