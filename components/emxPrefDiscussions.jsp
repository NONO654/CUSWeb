<%--  emxPrefDiscussions.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefDiscussions.jsp.rca 1.3.2.5 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $
--%>

<HTML>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
       addStyleSheet("emxUIDefault");
       addStyleSheet("emxUIForm");

       function doLoad() {
         if (document.forms[0].elements.length > 0) {
           var objElement = document.forms[0].elements[0];

           if (objElement.focus) objElement.focus();
           if (objElement.select) objElement.select();
         }
       }
    </SCRIPT>
  </HEAD>

<%  String sViewLabel = i18nNow.getI18nString("emxComponents.Preferences.View","emxComponentsStringResource", request.getHeader("Accept-Language"));%>
<%  String sSortLabel = i18nNow.getI18nString("emxComponents.Preferences.Sort","emxComponentsStringResource", request.getHeader("Accept-Language"));%>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose();" action="emxPrefDiscussionsProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
           <%=XSSUtil.encodeForHTML(context, sViewLabel)%>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    try
    {
		ContextUtil.startTransaction(context, false);
		// Get Currency choices
		
		String sFlat = i18nNow.getI18nString("emxComponents.Discussion.Flat","emxComponentsStringResource", request.getHeader("Accept-Language"));
		String sThreaded = i18nNow.getI18nString("emxComponents.Discussion.Threaded","emxComponentsStringResource", request.getHeader("Accept-Language"));
		
		String sDiscussionView = PersonUtil.getDiscussionView(context);

		if(sDiscussionView == null || sDiscussionView.trim().length()== 0)
		{
			sDiscussionView = "Flat";
		}

		String discussionFlatSelected="";
        String discussionThreadedSelected="";

		if ("Flat".equals(sDiscussionView))
		{
			discussionFlatSelected = "checked";
		}
		else if ("Threaded".equals(sDiscussionView))
		{
			discussionThreadedSelected = "checked";
		}
	
%>
		<TR>
		<TD>
		<!-- //XSSOK -->
			<INPUT type="radio" name="view" id = "view" value="Flat" <%=discussionFlatSelected%> />
			<%=XSSUtil.encodeForHTML(context, sFlat)%>
		</TD>
		</TR>
		<TR>
		<TD>
		<!-- //XSSOK -->
			<INPUT type="radio" name="view" id = "view" value="Threaded"  <%=discussionThreadedSelected%> />
			<%=XSSUtil.encodeForHTML(context, sThreaded)%>
		</TD>
		</TR>
<%
	}catch (Exception ex)
	{
		ContextUtil.abortTransaction(context);
	}
%>
            </TABLE>
          </TD>
        </TR>      
      </TABLE>
	  <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%" id="test">
        <TR>
          <TD width="150" class="label">
           <%=XSSUtil.encodeForHTML(context, sSortLabel)%>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    try
    {
		ContextUtil.startTransaction(context, false);
		// Get Currency choices
		String sAcending = i18nNow.getI18nString("emxComponents.Discussion.Ascending","emxComponentsStringResource", request.getHeader("Accept-Language"));
		String sDescending = i18nNow.getI18nString("emxComponents.Discussion.Descending","emxComponentsStringResource", request.getHeader("Accept-Language"));
		
		String sDiscussionSort = PersonUtil.getDiscussionSort(context);
		if(sDiscussionSort == null || sDiscussionSort.trim().length()== 0)
		{
			sDiscussionSort = "Ascending";
		}

		String discussionAscSelected="";
        String discussionDscSelected="";

		if ("Ascending".equals(sDiscussionSort))
		{
			discussionAscSelected = "checked";
		}
		else if ("Descending".equals(sDiscussionSort))
		{
			discussionDscSelected = "checked";
		}
%>
<TR>
		<TD>
		<!-- //XSSOK -->
			<INPUT type="radio" name="sort" id = "sort" value="Ascending" <%=discussionAscSelected%> />
			<%=XSSUtil.encodeForHTML(context, sAcending)%>
		</TD>
		</TR>
		<TR>
		<TD>
		<!-- //XSSOK -->
			<INPUT type="radio" name="sort" id = "sort" value="Descending" <%=discussionDscSelected%> />
			<%=XSSUtil.encodeForHTML(context, sDescending)%>
		</TD>
		</TR>
<%
	}catch (Exception ex)
	{
		ContextUtil.abortTransaction(context);
	}
%>
            </TABLE>
          </TD>
        </TR>
          
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>
