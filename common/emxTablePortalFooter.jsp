<%-- emxTablePortalFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTablePortalFooter.jsp.rca 1.14 Wed Oct 22 15:48:19 2008 przemek Experimental przemek $
--%>
 
<html>
 
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String timeStamp = emxGetParameter(request, "timeStamp");
if (timeStamp == null || timeStamp.length() == 0 || tableBean.getTableData(timeStamp) == null) {
    response.sendError(response.SC_NO_CONTENT, "Prerequisites are not available");
    return;
   }
try
{ 
    ContextUtil.startTransaction(context, false);

    // Get Table Data from session level Table bean
    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap tableControlMap = tableBean.getControlMap(tableData);
    HashMap requestMap = tableBean.getRequestMap(tableData);

    String paginationParam=(String)tableControlMap.get("pagination");
    int pagination=0;
    if  (paginationParam!= null && paginationParam.trim().length() > 0 && !"null".equals(paginationParam))
    {
        pagination= Integer.parseInt(paginationParam);
    }


    // get the current Index
    int currentIndex = tableBean.getCurrentIndex(tableControlMap);
    
    String bottomActionbar = (String)requestMap.get("bottomActionbar");
    String toolbar = (String)requestMap.get("toolbar");
    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");

    String displayMode = tableBean.getPaginationMode(tableControlMap);

    String sCurrLang=Request.getLanguage(request);
    String sPageText = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Page", "emxFrameworkStringResource", sCurrLang);
    String sOf   = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Of", "emxFrameworkStringResource", sCurrLang);
    String sPaginationOff = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOff", "emxFrameworkStringResource", sCurrLang);
    String sPaginationOn = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOn", "emxFrameworkStringResource", sCurrLang);
    String sNextPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.NextPage", "emxFrameworkStringResource", sCurrLang);
    String sPreviousPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PreviousPage", "emxFrameworkStringResource", sCurrLang);

    Integer iPagination = tableBean.getPagination(tableControlMap);
    int noOfItemsPerPage = iPagination.intValue();

    MapList filteredObjectList = tableBean.getFilteredObjectList(tableData);
    int objectListCount = filteredObjectList.size();

	String inquiryList = (String)requestMap.get("inquiry");
	String programList = (String)requestMap.get("program");
	StringBuffer title = new StringBuffer(50);
	title.append("footer_");
	title.append(XSSUtil.encodeForHTML(context, (String)requestMap.get("table")));
	title.append("_");

	if (inquiryList != null && inquiryList.trim().length() > 0 )
	{
		title.append(XSSUtil.encodeForHTML(context, inquiryList));
	} else if (programList != null && programList.trim().length() > 0 )
	{
		title.append(XSSUtil.encodeForHTML(context, programList));
	}

    int imaxPaginationNoOfItems = tableBean.getMaxPaginationNoOfitems(context);
    String prefPagination = PersonUtil.getPagination(context);  
    
    //find number of items per page    
    //if pagination is off and imaxNumberOfItems per page > 0, set noOfItemsPerPage to the imaxNumberOfItems value
    if(prefPagination != null && "false".equalsIgnoreCase(prefPagination) && imaxPaginationNoOfItems > 0)
    {
        noOfItemsPerPage = imaxPaginationNoOfItems;
    }    

    else if (prefPagination != null && "true".equalsIgnoreCase(prefPagination) && pagination > 0)
    {
       noOfItemsPerPage = pagination;
    }    

    else //get it from Preferences
    {
        String sPagination = PersonUtil.getPaginationRange(context);        
        Integer paginationRange = new Integer(sPagination);
        noOfItemsPerPage = paginationRange.intValue();
    }
%>

<head>
<!-- //XSSOK -->
<title><%=title.toString()%></title>

<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>

<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" src="scripts/emxUIPopups.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js" type="text/javascript"></script>


<script type="text/javascript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIChannelDefault");
	addStyleSheet("emxUIChannelActionbar");
</script>

</head>
<body>
<form name="footerForm" method="post">
<div class="first-row">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td align="right">
<table border="0" cellspacing="0" cellpadding="3">
<tr>
<%

    if (displayMode == null || displayMode.length() == 0 || displayMode.equals("null") )
        displayMode = "multiPage";

    if (displayMode.equals("multiPage"))
    {
        if (currentIndex != 0)
        {
%>
			<!-- //XSSOK -->
			<td class="pagination-left"><a href="javascript:navigatePage('previous' , '')"><img src="images/utilChPaginationLeftArrow.gif" alt="<%=sPreviousPage%>" border="0" title="<%=sPreviousPage%>" /></a></td>
<%
        }
        else
        {
%>
			<!-- //XSSOK -->
			<td class="pagination-left"><img src="images/utilChPaginationLeftArrow.gif" alt="<%=sPreviousPage%>" border="0" title="<%=sPreviousPage%>" /></td>
<%
        }
        int noOfPages = 1;
        int currentPage = 0;

        noOfPages = (tableBean.getNumberOfPages(tableControlMap)).intValue();

        if (noOfPages > 1)
            currentPage = currentIndex / noOfItemsPerPage;

%>
<!-- //XSSOK -->
<td nowrap><%=sPageText%>&#160;</td>
<td>
<select name="menu1" class="pagination" onchange="javascript:navigatePage(document.footerForm.menu1.selectedIndex + 1 , '')">
<%
        for (int i = 0; i < noOfPages; i++)
        {
            if (currentPage == i)
            {
%>
				<option class="pagination" selected="selected"><%=i+1%></option>
<%
            }
            else
            {
%>
				<option class="pagination"><%=i+1%></option>
<%
            }
        }
%>
</select></td>
<!-- //XSSOK -->
<td nowrap>&#160;<%=sOf%> <%=noOfPages%></td>

<%
        if ( objectListCount > (currentIndex + noOfItemsPerPage))
        {
%>
			<!-- //XSSOK -->
			<td><a href="javascript:navigatePage( 'next' , '')"><img src="images/utilChPaginationRightArrow.gif" alt="<%=sNextPage%>" border="0" title="<%=sNextPage%>" /></a></td>
<%
        }
        else
        {
%>
			<!-- //XSSOK -->
			<td><img src="images/utilChPaginationRightArrow.gif" alt="<%=sNextPage%>" border="0" title="<%=sNextPage%>" /></a></td>
<%
        }
%>
       
<%
        if(imaxPaginationNoOfItems > 0) {
            if(prefPagination != null && "true".equalsIgnoreCase(prefPagination)) {
%>               
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-on"><img src="images/utilChPaginationMulti.gif" alt="<%=sPaginationOn%>" border="0" title="<%=sPaginationOn%>" /></td>
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-off"><a href="javascript:navigatePage('1' , 'singlePage')"><img src="images/utilChPaginationSingle.gif" alt="<%=sPaginationOff%>" border="0" title="<%=sPaginationOff%>" /></a></td>
<%
            }
            else if(prefPagination != null && "false".equalsIgnoreCase(prefPagination)) {
%>
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-off"><a href="javascript:navigatePage('1' , 'multiPage')"><img src="images/utilChPaginationMulti.gif" alt="<%=sPaginationOn%>" border="0" title="<%=sPaginationOn%>" /></a></td>
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-on"><img src="images/utilChPaginationSingle.gif" alt="<%=sPaginationOff%>" border="0" title="<%=sPaginationOff%>" /></td>                
<%
            }
            else {
%>
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-on"><img src="images/utilChPaginationMulti.gif" alt="<%=sPaginationOn%>" border="0" title="<%=sPaginationOn%>" /></td>
                <!-- //XSSOK -->
                <td width="22" class="pagination-button-off"><img src="images/utilChPaginationSingle.gif" alt="<%=sPaginationOff%>" border="0" title="<%=sPaginationOff%>" /></td>
<%          
            }
        } else {
%>
            <!-- //XSSOK -->
            <td width="22" class="pagination-button-on"><img src="images/utilChPaginationMulti.gif" alt="<%=sPaginationOn%>" border="0" title="<%=sPaginationOn%>" /></td>
            <!-- //XSSOK -->
            <td width="22" class="pagination-button-off"><a href="javascript:navigatePage('1' , 'singlePage')"><img src="images/utilChPaginationSingle.gif" alt="<%=sPaginationOff%>" border="0" title="<%=sPaginationOff%>" /></a></td>            
<%
        }
    } else {
%>
			<!-- //XSSOK -->
			<td width="22" class="pagination-button-off"><a href="javascript:navigatePage('1' , 'multiPage')"><img src="images/utilChPaginationMulti.gif" alt="<%=sPaginationOn%>" border="0" title="<%=sPaginationOn%>" /></a></td>
			<!-- //XSSOK -->
			<td width="22"  class="pagination-button-on"><img src="images/utilChPaginationSingle.gif" alt="<%=sPaginationOff%>" border="0" title="<%=sPaginationOff%>" /></td>
<%
    }
%>
</tr>
</table>
</td>
</tr>
</table>
</div>
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
</form>

<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableFooter:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}
%>

<%@include file = "emxNavigatorTimerBottom.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>

