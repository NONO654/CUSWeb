<%--  emxInfoCustomTableFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--

Description : This jsp page sets the footer for Custom Table

--%>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>

<%@include file = "MCADTopInclude.inc"%>
<%@include file = "emxInfoCustomTableInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

Context context								= integSessionData.getClonedContext(session);

%>



<%
String sTarget = emxGetParameter(request, "custTargetLocation");
String topActionbar = emxGetParameter(request, "custTopActionbar");
String bottomActionbar = emxGetParameter(request, "custBottomActionbar");
String timeStamp = emxGetParameter(request, "timeStamp");
String reload = emxGetParameter(request, "reload");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String objectId = emxGetParameter(request, "objectId");
String relId = emxGetParameter(request, "relId");
String sortColumnName = emxGetParameter(request, "custSortColumnName");
String sortDirection = emxGetParameter(request, "custSortDirection");
String selection = emxGetParameter(request, "custSelection");
String pagination = emxGetParameter(request, "custPagination");
String sPage = emxGetParameter(request, "custPageNo");
String sHeaderRepeat = emxGetParameter(request, "custHeaderRepeat");
String sCurrLang=request.getHeader("Accept-Language");
String sPageText = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Page", "emxFrameworkStringResource", sCurrLang);
String sOf   = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Of", "emxFrameworkStringResource", sCurrLang);
String sPaginationOff = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOff", "emxFrameworkStringResource", sCurrLang);
String sPaginationOn = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOn", "emxFrameworkStringResource", sCurrLang);
String sNextPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.NextPage", "emxFrameworkStringResource", sCurrLang);
String sPreviousPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PreviousPage", "emxFrameworkStringResource", sCurrLang);
String strCancel = UINavigatorUtil.getI18nString("mcadIntegration.Server.ButtonName.Close","iefStringResource",sCurrLang);

int currentIndex = 0;

if (session.getAttribute("CurrentIndex" + timeStamp) != null)
currentIndex = ((Integer)session.getAttribute("CurrentIndex" + timeStamp)).intValue();

String displayMode = "";

if (sPage != null && sPage.equals("1"))
currentIndex = 0;

CustomMapList boList = (CustomMapList)session.getAttribute("TableData" + timeStamp);

if (pagination == null || pagination.trim().length() == 0 || pagination.equals("null") )
	pagination = "15";

displayMode = emxGetParameter(request, "custDisplayMode");

int noOfItemsPerPage = Integer.parseInt(pagination);

if (noOfItemsPerPage == 0 && boList != null)
{
    noOfItemsPerPage = boList.size();
}

%>
<head>

<title>Action Bar</title>

<meta http-equiv="imagetoolbar" content="no">
<%
if(sTarget != null &&  !sTarget.equals(""))
{
	if(sTarget.equals("content"))	
	{
	
%>
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		
	
<%       	
	}
	else
	{
%>
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUISearch.css" />
	       
<%	
	}
	
} //end of if( sTarget ...)
else
{
%>    	
	<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
	<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />
		
<%    	
}

%>    

<script language="javascript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIActionbar.js" type="text/javascript"></script>

<script language="JavaScript">

// function navigatePage (page, displayMode)
function navigatePage (page , displayMode)
{
	var pageUrl = "emxInfoCustomTableBody.jsp?custPageNo=" + page + "&custDisplayMode=" + displayMode;
	parent.listDisplay.document.emxTableForm.action = pageUrl;
	parent.listDisplay.document.emxTableForm.target = "listDisplay";
	parent.listDisplay.document.emxTableForm.submit();
}

</script>

</head>
<body>
<form name=footerForm method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td width="99%"></td>
</tr>
</table>
<%
int noOfPages = 1;
int currentPage = 0;

if (boList != null)
{
    noOfPages = boList.size() / noOfItemsPerPage;
    if ((boList.size() % noOfItemsPerPage) !=0)
        noOfPages++;
}

currentPage = currentIndex / noOfItemsPerPage;

if( noOfPages > 1) //display the pagination control only if the no of pages > 1
{
	String leftPgImage = "../common/images/utilPaginationLeft.gif";
	String rightPgImage = "../common/images/utilPaginationRight.gif";
	String bgPgImage = "../common/images/utilPaginationBG.gif";
	String trClass = "";

	//display differently for Unix
	if (( userAgent.toLowerCase().indexOf("sunos") > -1 ||    userAgent.toLowerCase().indexOf("x11") > -1 )){
		leftPgImage = "../common/images/utilSpacer.gif";
		rightPgImage = "../common/images/utilSpacer.gif";
		bgPgImage = "../common/images/utilSpacer.gif";
		trClass = " class=\"even\"";
	}

%> 
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
	<tr>
	<td width="99%">

	<table border="0" width="100%" cellspacing="2" cellpadding="4">
	<tr>
	<td width="60%"><img src="../common/images/utilSpacer.gif" border="0" width="5" height="20" alt=""></td>
	<td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="28" alt=""></td>
	<td align="right">
	<!--XSSOK-->
	<table border="0" cellspacing="0" cellpadding="0" background=<%=bgPgImage%>>
	<!--XSSOK-->
	<tr  <%=trClass%>>
	<!--XSSOK-->
	<td><img src=<%=leftPgImage%>></td>
	<td><img src="../common/images/utilSpacer.gif" width="6" height="1"></td>

<%  
	if (displayMode == null || displayMode.length() == 0 || displayMode.equals("null") )
		displayMode = "multiPage";
	if (displayMode.equals("multiPage"))
	{
		if (currentIndex != 0)
		{
%>
            <!--XSSOK-->
			<td><a href="javascript:navigatePage('previous' , '')"><img src="../common/images/buttonPrevPage.gif" border="0" alt="<%=sPreviousPage%>" width="16" height="16"></a></td>
<%
		}
		else
		{
%>
            <!--XSSOK-->
			<td><img src="../common/images/buttonPrevPageDisabled.gif" border="0" alt="<%=sPreviousPage%>" width="16" height="16"></td>
<%
		}
%>

		<td><img src="../common/images/utilSpacer.gif" width="7"></td>
		<!--XSSOK-->
		<td><%=sPageText%>&#160;</td>
		<td><select name="menu1" class="pagination" onchange="javascript:navigatePage(document.footerForm.menu1.selectedIndex + 1 , '')">
<%
		for (int i = 0; i < noOfPages; i++)
		{
			if (currentPage == i)
			{
%>
				<option class="pagination" selected><%=i+1%></option>
<%			}
			else
			{
%>
				<option class="pagination"><%=i+1%></option>
<%			}
		} //end for
%>
		</select></td>
		<!--XSSOK-->
		<td nowrap>&#160;<%=sOf%> <%=noOfPages%></td>
		<td><img src="../common/images/utilSpacer.gif" width="9" height="8"></td>
<%
		if ( boList != null && boList.size() > (currentIndex + noOfItemsPerPage))
		{
%>
            <!--XSSOK-->
			<td><a href="javascript:navigatePage( 'next' , '')"><img src="../common/images/buttonNextPage.gif" border="0" alt="<%=sNextPage%>" width="16" height="16"></a></td>
<%
		}
		else
		{
%>
            <!--XSSOK-->
			<td><img src="../common/images/buttonNextPageDisabled.gif" border="0" alt="<%=sNextPage%>" width="16" height="16"></a></td>
<%
		}
%>
		<td><img src="../common/images/utilSpacer.gif" width="9" height="8"></td>
		<td nowrap="nowrap">
		<!--XSSOK-->
		<img src="../common/images/buttonMultiPageDown.gif" border="0" alt="<%=sPaginationOn%>"><a href="javascript:navigatePage( '1' , 'singlePage')"><img src="../common/images/buttonSinglePageUp.gif" border="0" alt="<%=sPaginationOff%>"></a>
		</td>
<%
	} //end of if display is multi page 
	else {
%>
		<td nowrap="nowrap">
		<!--XSSOK-->
		<a href="javascript:navigatePage('1' , 'multiPage')"><img src="../common/images/buttonMultiPageUp.gif" border="0" alt="<%=sPaginationOn%>"></a><img src="../common/images/buttonSinglePageDown.gif" border="0" alt="<%=sPaginationOff%>">
		</td>
<%	
	}
%>
	</td>
	<td><img src="../common/images/utilSpacer.gif" width="6" height="1"></td>
	<!--XSSOK-->
	<td><img src=<%=rightPgImage%>></td>
	</tr>
	</table>
	</td>
	</tr>
	</table>
	</td>
<%
    if(sTarget!= null && sTarget.equals("popup"))
	{	
%>
        <td><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0"></a></td>
		<!--XSSOK-->
		<td valign="middle"><a href="javascript:parent.window.close()"><%=strCancel%></a></td>
<%
    }else {
%>
        <td><img src="../common/images/utilSpacer.gif" alt="" width="4"></td>
<%
	}
%>
	</tr>
	</table>

<%
} //End of if(noOfPages >1)  
else{
%>
	<table border="0" cellspacing="2" cellpadding="0" align="right">
	<tr>
	
<%
      if(sTarget!= null && sTarget.equals("popup"))
	  {
%>
        <td align="right" valign="bottom"><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0"></a></td>
		<!--XSSOK-->
		<td align="left" valign="middle"><a href="javascript:parent.window.close()"><%=strCancel%></a></td>
<% 
	  } else {
%>
        <td><img src="../common/images/utilSpacer.gif" alt="" width="4"></td>
<%
	  }
%>	
	</tr>
	</table>
<%
}
%>

<input type="hidden" name="custTopActionBar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custBottomActionBar" value="<xss:encodeForHTMLAttribute><%=bottomActionbar%></xss:encodeForHTMLAttribute>">
<!--XSSOK-->
<input type="hidden" name="custPagination" value="<%=noOfItemsPerPage%>">
<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custSortColumnName" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custReSortKey" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custPageNo" value="<xss:encodeForHTMLAttribute><%=sPage%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custSelection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custDisplayMode" value="<xss:encodeForHTMLAttribute><%=displayMode%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="custHeaderRepeat" value="<xss:encodeForHTMLAttribute><%=sHeaderRepeat%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
</form>

<script language="JavaScript">

// This variable positions the action item list from the top os the frame
var actionItemTopPos = 10;
var actionItemLeftPos = 10;
var visibleLinks = 2;

</script>

<%
if ( !(bottomActionbar == null) && !(bottomActionbar.equals("")) && !(bottomActionbar.equalsIgnoreCase("null")) )
{
%>
<jsp:include page = "emxInfoActionBar.jsp" flush="true">
<jsp:param name="actionBarName" value="<%=XSSUtil.encodeForHTML(context,bottomActionbar)%>"/>
</jsp:include>
<%
}
%>

</body>
</html>
