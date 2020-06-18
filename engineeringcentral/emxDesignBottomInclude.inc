<%--  emxDesignBottomInclude.jsp   -  Bottom Include File for all jsp pages is Engineering Central Suite
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">
  
try{
  //Modified for Bug no 335660 & 335693 5/14/2007 6:55 PM Begin
    if (getTopWindow().getWindowOpener() != null && !getTopWindow().getWindowOpener().closed)
    {
        //if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().modalDialog)
        if(getTopWindow().getWindowOpener() && ( getTopWindow().getWindowOpener().getTopWindow().modalDialog && getTopWindow().getWindowOpener().getTopWindow().modalDialog.contentWindow!=null))
        {
        if(!(getTopWindow().getWindowOpener().getTopWindow().modalDialog.contentWindow.closed))
      {
            getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
      }
        }
    }
//Modified for Bug no 335660 & 335693 5/14/2007 6:55 PM End
    }catch(e){
        //alert if anything other than permission denied
        //if(-2146828218 != e.number){
        //Added the if condition for IR-041534V6R2011 -Start
        if(e.description.search(/Denied/i) == -1)
		{
		//Added the if condition for IR-041534V6R2011 -End
    		if(-2147418094 != e.number){
				alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ExceptionInScript</emxUtil:i18n>"
               	+ "<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ErrorName</emxUtil:i18n>" + e.name
               	+ "."+ "<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ErrorDescription</emxUtil:i18n>" + e.description
     			+ "."+ "<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ErrorNumber</emxUtil:i18n>"+ e.number
                + "."+ "<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ErrorMessage</emxUtil:i18n>"+ e.message);
			}
		}// IR-041534V6R2011
    }

</script>

<%
  String MQLNoticeFlag = (String)request.getAttribute("MQLNoticeFlag");

  if ( (MQLNoticeFlag != null) && (MQLNoticeFlag.equals("true")) )
  {
%>
<%@include file = "../components/emxMQLNotice.inc"%>
<%
  }
%> 
