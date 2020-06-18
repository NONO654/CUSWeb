<%-- 
   C3DMeetingAttachmentsTableFooter.jsp

   This file is copy of emxTableFooter.jsp, its customized for AutoVue Integration Meeting Support HL.
   This JSP is modified to show the Submit/Cancel buttons at the end of the table.
   
   Copyright (c) 1992-2013 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableFooter.jsp.rca 1.42 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%


String timeStamp = emxGetParameter(request, "timeStamp");
//Added for BUG:377256
if (timeStamp == null || timeStamp.length() == 0 || tableBean.getTableData(timeStamp) == null) {
 response.sendError(response.SC_NO_CONTENT, "Prerequisites are not available");
 return;
}

try {

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

    String topActionbar = (String)requestMap.get("topActionbar");
    String bottomActionbar = (String)requestMap.get("bottomActionbar");
    String toolbar = (String)requestMap.get("toolbar");
    
	//[C3D:START]
	//Not required, hence commented.
	//String SubmitURL = (String)requestMap.get("SubmitURL");
	//String cancelURL = (String)requestMap.get("CancelURL");
	//[C3D:END]
	
	String SubmitButton = "true";
    String CancelButton = "true";		//(String)requestMap.get("CancelButton");

    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");
    String suiteKey = (String)requestMap.get("suiteKey");
    suiteKey="Framework";
	String style = (String)requestMap.get("Style");
    String inquiryList = (String)requestMap.get("inquiry");
    String programList = (String)requestMap.get("program");
    //String title_prefix = UINavigatorUtil.getI18nString("emxFramework.WindowTitle.Footer", "emxFrameworkStringResource", Request.getLanguage(request));
    String title_prefix = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.WindowTitle.Footer", Request.getLanguage(request));
    String title = title_prefix + (String)requestMap.get("table") + "_";

    if (inquiryList != null && inquiryList.trim().length() > 0 )
    {
        title += inquiryList;
    } else if (programList != null && programList.trim().length() > 0 )
    {
        title += programList;
    }

    String sPage = emxGetParameter(request, "page");
    String displayMode = tableBean.getPaginationMode(tableControlMap);

    String sCurrLang=Request.getLanguage(request);
	//String sPageText = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Page", //"emxFrameworkStringResource", sCurrLang);
	String sPageText = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.Page", sCurrLang);
 
    //String sOf   = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Of", "emxFrameworkStringResource", //sCurrLang);
    String sOf   = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.Of", sCurrLang);
   
   // String sPaginationOff = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOff", //"emxFrameworkStringResource", sCurrLang);
   String sPaginationOff = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.PaginationOff", sCurrLang);
    
	//String sPaginationOn = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PaginationOn", //"emxFrameworkStringResource", sCurrLang);
	String sPaginationOn = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.PaginationOn", sCurrLang);
   
   // String sNextPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.NextPage", //"emxFrameworkStringResource", sCurrLang);
   String sNextPage = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.NextPage", sCurrLang);

    //String sPreviousPage = UINavigatorUtil.getI18nString("emxFramework.TableComponent.PreviousPage", //"emxFrameworkStringResource", sCurrLang);
String sPreviousPage = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.TableComponent.PreviousPage", sCurrLang);
   
	Integer iPagination = tableBean.getPagination(tableControlMap);
    int noOfItemsPerPage = iPagination.intValue();

    MapList filteredObjectList = tableBean.getFilteredObjectList(tableData);
    int objectListCount = 0;
    if(filteredObjectList != null){
    	objectListCount = filteredObjectList.size();
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

        boolean showButtons = false;
        if( (SubmitButton != null && SubmitButton.equalsIgnoreCase("true")) || (CancelButton != null && CancelButton.equalsIgnoreCase("true")) )
		{
        	showButtons = true;
        }
%>
<form name='footerForm' method="post">
<table>
<tr>
<%
if(!showButtons) {
%>
    <td class="functions"></td>
<%
}
%>

<td class="pagination">
<table class="pagination">
	    <tr>
<%
    if (displayMode == null || displayMode.length() == 0 || displayMode.equals("null") )
    {
        displayMode = "multiPage";
    }

    if (displayMode.equals("multiPage"))
    {
        if (currentIndex != 0)
        {
%>
            <td><a href="javascript:navigatePage('previous' , '')"><img src="images/buttonPrevPage.gif" border="0" alt="<%=sPreviousPage%>" width="16" height="16" title="<%=sPreviousPage%>"></a></td>
<%
        }
        else
        {
%>
            <td><img src="images/buttonPrevPageDisabled.gif" border="0" alt="<%=sPreviousPage%>" width="16" height="16" title="<%=sPreviousPage%>"></td>
<%
        }
        int noOfPages = 1;
        int currentPage = 0;

        noOfPages = (tableBean.getNumberOfPages(tableControlMap)).intValue();

        if (noOfPages > 1)
        {
            currentPage = currentIndex / noOfItemsPerPage;
        }
%>
            <td nowrap><%=sPageText%>&#160;</td>
            <td><select name="menu1" class="pagination" onchange="javascript:navigatePage(document.footerForm.menu1.selectedIndex + 1 , '')">
<%
        for (int i = 0; i < noOfPages; i++)
        {
            if (currentPage == i)
            {
%>
                <option class="pagination" selected><%=i+1%></option>
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
            <td nowrap="nowrap">&#160;<%=sOf%> <%=noOfPages%></td>
<%
        if ( objectListCount > (currentIndex + noOfItemsPerPage))
        {
%>
            <td><a href="javascript:navigatePage( 'next' , '')"><img src="images/buttonNextPage.gif" border="0" alt="<%=sNextPage%>" width="16" height="16" title="<%=sNextPage%>"></a></td>
<%
        }
        else
        {
%>
         <td><img src="images/buttonNextPageDisabled.gif" border="0" alt="<%=sNextPage%>" width="16" height="16" title="<%=sNextPage%>"></a></td>
<%
        }
%>
         <td nowrap="nowrap">
<%
        if(imaxPaginationNoOfItems > 0)
        {
//            if (noOfItemsPerPage < imaxPaginationNoOfItems  && prefPagination != null && "false".equalsIgnoreCase(prefPagination) )
            if(prefPagination != null && "true".equalsIgnoreCase(prefPagination))
            {
%>
         <img src="images/buttonMultiPageDown.gif" border="0" alt="<%=sPaginationOn%>" title="<%=sPaginationOn%>"><a href="javascript:navigatePage( '1' , 'singlePage')"><img src="images/buttonSinglePageUp.gif" border="0" alt="<%=sPaginationOff%>" title="<%=sPaginationOff%>"></a>
<%
            } else if(prefPagination != null && "false".equalsIgnoreCase(prefPagination)) {
%>
         <a href="javascript:navigatePage( '1' , 'multiPage')"><img src="images/buttonMultiPageUp.gif" border="0" alt="<%=sPaginationOn%>" title="<%=sPaginationOn%>"></a><img src="images/buttonSinglePageDown.gif" border="0" alt="<%=sPaginationOff%>" title="<%=sPaginationOff%>">
<%
            } else {
%>
         <img src="images/buttonMultiPageDown.gif" border="0" alt="<%=sPaginationOn%>" title="<%=sPaginationOn%>"><img src="images/buttonSinglePageUp.gif" border="0" alt="<%=sPaginationOff%>" title="<%=sPaginationOff%>">
<%
            }
        } else {
%>
         <img src="images/buttonMultiPageDown.gif" border="0" alt="<%=sPaginationOn%>" title="<%=sPaginationOn%>"><a href="javascript:navigatePage( '1' , 'singlePage')"><img src="images/buttonSinglePageUp.gif" border="0" alt="<%=sPaginationOff%>" title="<%=sPaginationOff%>"></a>
<%
        }
    } else {
%>
        <td nowrap="nowrap">
         <a href="javascript:navigatePage('1' , 'multiPage')"><img src="images/buttonMultiPageUp.gif" border="0" alt="<%=sPaginationOn%>" title="<%=sPaginationOn%>"></a><img src="images/buttonSinglePageDown.gif" border="0" alt="<%=sPaginationOff%>" title="<%=sPaginationOff%>">
<%
    }
%>
        </td>
       </tr>
     </table>
</td>
<%
if(showButtons) {
%>
<td class="buttons">
<table border="0" cellspacing="0" cellpadding="0">
<tr>
<%
	if(suiteKey == null || "".equals(suiteKey) || "null".equalsIgnoreCase(suiteKey)) {
        suiteKey = "Framework";
    }
    
	//if (SubmitURL != null && SubmitURL.length() > 0)
	if (SubmitButton != null && SubmitButton.equalsIgnoreCase("true"))
    {
        String SubmitLabel = (String)requestMap.get("SubmitLabel");
        //String CancelLabel = (String)requestMap.get("CancelLabel");
        if(SubmitLabel != null && SubmitLabel.length() > 0)
        {
            //SubmitLabel = UINavigatorUtil.getI18NstringForSuite(suiteKey, SubmitLabel, Request.getLanguage(request));
			SubmitLabel = EnoviaResourceBundle.getProperty(context, suiteKey, SubmitLabel, Request.getLanguage(request));
        }else {
            //SubmitLabel = UINavigatorUtil.getI18nString("emxFramework.Button.Submit", "emxFrameworkStringResource", //Request.getLanguage(request));
			SubmitLabel = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.Button.Submit", Request.getLanguage(request));
        }
        //String strPleaseSelect = UINavigatorUtil.getI18nString("emxFramework.Common.PleaseSelectitem", //"emxFrameworkStringResource", Request.getLanguage(request));
		String strPleaseSelect = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.Common.PleaseSelectitem", Request.getLanguage(request));
%>
<td>&nbsp;&nbsp;</td>
<%
	//String strNext = UINavigatorUtil.getI18nString("emxFramework.Button.Next", "emxFrameworkStringResource", Request.getLanguage(request));
String strNext = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.Button.Next", Request.getLanguage(request));
	if(SubmitLabel!=null && strNext!=null && SubmitLabel.equalsIgnoreCase(strNext))
	{
%>
<td><a href="#" onClick="javascript:LaunchAVAppletForSelectedDocument()"><img border="0" alt="<%= XSSUtil.encodeForHTMLAttribute(context,SubmitLabel) %>" src="images/buttonNextPage.gif"></a></td><td nowrap><a class="button" href="#" onClick="javascript:LaunchAVAppletForSelectedDocument()"><xss:encodeForHTML><%=SubmitLabel%></xss:encodeForHTML></a></td>
<%
		    
	}
	else
	{
%>
<td><a href="#" onClick="javascript:LaunchAVAppletForSelectedDocument()"><img border="0" alt="<%= XSSUtil.encodeForHTMLAttribute(context,SubmitLabel) %>" src="images/buttonDialogDone.gif"></a></td><td nowrap><a class="button" href="#" onClick="javascript:LaunchAVAppletForSelectedDocument()"><xss:encodeForHTML><%=SubmitLabel%></xss:encodeForHTML></a></td>
<%
    	}
    }

    if (CancelButton != null && CancelButton.equalsIgnoreCase("true"))
    {
        String CancelLabel = (String)requestMap.get("CancelLabel");

        if (CancelLabel != null && CancelLabel.length() > 0)
        {
            //CancelLabel = UINavigatorUtil.getI18NstringForSuite(suiteKey, CancelLabel, Request.getLanguage(request));
			CancelLabel = EnoviaResourceBundle.getProperty(context, suiteKey, CancelLabel, Request.getLanguage(request));
        } else {
            //CancelLabel = UINavigatorUtil.getI18nString("emxFramework.Button.Cancel", "emxFrameworkStringResource", Request.getLanguage(request));
			CancelLabel = EnoviaResourceBundle.getProperty(context, suiteKey,"emxFramework.Button.Cancel", Request.getLanguage(request));
        }
%>
<td>&nbsp;&nbsp;</td>
<td><a href="javascript:CloseDocSelectionPage()"><img border="0" alt="<%=CancelLabel%>" src="images/buttonDialogCancel.gif"></a></td><td nowrap><a class="button" href="javascript:CloseDocSelectionPage()"><%=CancelLabel%></a></td>
<%
    }
%>

</tr>
</table>
</td>
<%
}
%>
</tr>
</table>

<input type="hidden" name="timeStamp" value="<%=timeStamp%>">
</form>

<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
} finally {
    ContextUtil.commitTransaction(context);
}
%>
