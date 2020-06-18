<%--  emxPrefDate.jsp -
   Copyright (c) 1992- 2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefDate.jsp.rca 1.7 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="java.text.*"%>

<%
    try
    {
        ContextUtil.startTransaction(context, false);

        String strAsEntered = UINavigatorUtil.getI18nString("emxFramework.Common.Default", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
        ArrayList DateFormatChoices = new ArrayList();

        Calendar cal = Calendar.getInstance();
        Date currentTime = cal.getTime();

        int iDateFormat = DateFormat.FULL;
        DateFormat outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        String displayDateTimeStr = outDateFrmt.format(currentTime);
        DateFormatChoices.add(displayDateTimeStr);

        iDateFormat = DateFormat.LONG;
        outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        displayDateTimeStr = outDateFrmt.format(currentTime);
        DateFormatChoices.add(displayDateTimeStr);

        iDateFormat = DateFormat.MEDIUM;
        outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        displayDateTimeStr = outDateFrmt.format(currentTime);
        DateFormatChoices.add(displayDateTimeStr);

        iDateFormat = DateFormat.SHORT;
        outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        displayDateTimeStr = outDateFrmt.format(currentTime);
        DateFormatChoices.add(displayDateTimeStr);

        int iDateFormatDefault = PersonUtil.getDateFormat(context);
        String sTimeDisplay = PersonUtil.getTimeDisplay(context);

        if ( sTimeDisplay != null && sTimeDisplay.equalsIgnoreCase("on") )
        {
            sTimeDisplay = "checked";
        } else {
            sTimeDisplay = "";
        }

%>
<HEAD>
<TITLE></TITLE>
<SCRIPT language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"> </SCRIPT>
<SCRIPT language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript"></SCRIPT>

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
<BODY onload="doLoad(), turnOffProgress()">
<FORM method="post" action="emxPrefDateProcessing.jsp">
<TABLE border="0" cellpadding="5" cellspacing="2" width="100%">
<TR>
    <TD width="150" class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.Preferences.DateFormat</emxUtil:i18n>
    </TD>
    <TD class="inputField">
        <SELECT name="DateFormat" id="DateFormat">
<%
    if (iDateFormatDefault == -1)
    {
%><OPTION value="-1" selected><%=strAsEntered%></OPTION><%
    } else {
%><OPTION value="-1"><%=strAsEntered%></OPTION><%
    }

    // for each Short Date Format choice
    for (int i = 0; i < DateFormatChoices.size(); i++)
    {
        // get choice
        String choice = (String)DateFormatChoices.get(i);

        // if choice is equal to default then mark it selected
        if (i == iDateFormatDefault)
        {
%><OPTION value="<%=i%>" selected><%=choice%></OPTION><%
        }
        else
        {
%><OPTION value="<%=i%>"><%=choice%></OPTION><%
        }
    }
%>
        </SELECT>
    </TD>
    </TR>
    <TR>
    <TD>&nbsp;</TD>
    <TD>&nbsp;</TD>
    </TR>
    <TR>
        <TD width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Preferences.DisplayTime</emxUtil:i18n></TD>
        <!-- //XSSOK -->
        <td class="inputField"><input type="checkbox" name="TimeDisplay" <%=sTimeDisplay%> /></td>
    </tr>


<%
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>


