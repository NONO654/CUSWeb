<%-- emxProgramCentralResourceLoadingDialog.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceLoadingDialog.jsp.rca 1.14 Wed Oct 22 15:49:40 2008 przemek Experimental przemek $";

--%>

<%@include file = "emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%-- @include file = "emxprojectCalendarInclude.inc" --%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "emxProgramCentralVaultSupport.inc" %>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
  <script language="javascript" type="text/javascript" src="emxProgramUtil.js"></script>

<script language="javascript">

function submitFormCreate()
{
	//Added:30-Sep-2010:vf2:R2012
  var frameobj = findFrame(getTopWindow(), 'pagecontent');
  var str = frameobj.document.forms[0].start.value;
  var etr = frameobj.document.forms[0].end.value;
  for (i=0;i<frameobj.document.forms[0].selected.length;i++){
  if (frameobj.document.forms[0].selected[i].checked==true)
    sel = frameobj.document.forms[0].selected[i].value;
  }

    var StrMsVal = frameobj.document.forms[0].start_msvalue.value;
    var EtrMsVal = frameobj.document.forms[0].end_msvalue.value;

  if((str=="" || etr == "") || ((StrMsVal=="" || EtrMsVal=="") || (EtrMsVal < StrMsVal)))
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ResourceLoading.ValidDateRange</emxUtil:i18nScript>");
  }else{

   if (frameobj.document.progress)
   {
	   frameobj.document.progress.src = "../common/images/utilSpacer.gif";
   }
     f = document.PersonSearch;
   //End:30-Sep-2010:vf2:R2012
     //f.action = f.action+"&start="+str+"&end="+etr+"&initial="+sel+"&start_msvalue="+StrMsVal+"&end_msvalue="+EtrMsVal;
     f.action = f.action+"&initial="+sel;

     

     startProgressBar(true);
     f.submit();

}
}

</script>

</head>

<%

  String sStart =      emxGetParameter(request,"start");
  String sEnd =      emxGetParameter(request,"end");
  String sStartDtHidden =      emxGetParameter(request,"start_msvalue");
  String sEndDtHidden   =      emxGetParameter(request,"end_msvalue");
  if(sStart==null)
  sStart="";
  if(sEnd==null)
  sEnd="";
  if(sStartDtHidden==null)
  sStartDtHidden="";
  if(sEndDtHidden==null)
  sEndDtHidden="";
  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();

  if(sStart!=null && !"null".equals(sStart) && !"".equals(sStart))
  {
    sStart = eMatrixDateFormat.getFormattedDisplayDate(sStart,clientTZOffset,request.getLocale());
  }
  if(sEnd!=null && !"null".equals(sEnd) && !"".equals(sEnd))
  {
    sEnd = eMatrixDateFormat.getFormattedDisplayDate(sEnd,clientTZOffset,request.getLocale());
  }
  String optionSelected = emxGetParameter(request,"selected");
  if(optionSelected == null || "null".equals(optionSelected) || "".equals(optionSelected))
  {
    optionSelected = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.ResourceLoading.Default");
  }

  String sWeekly="";
  String sMonthly="";
  String sQuarterly="";

  if(optionSelected.equals("Weekly"))
  {
    sWeekly = "checked";
  }
  else if(optionSelected.equals("Monthly"))
  {
    sMonthly = "checked";
  }
  else if (optionSelected.equals("Quarterly"))
  {
    sQuarterly = "checked";
  }


  String objectId =      emxGetParameter(request,"objectId");
  objectId = XSSUtil.encodeURLForServer(context, objectId);
  String spage = "emxProgramCentralResourceLoadingFS.jsp";
  String type = emxGetParameter(request,"type");
  //if(type!=null && type.equalsIgnoreCase("summary"))
  //{
     //spage="emxProgramCentralResourceLoadingPersonFS.jsp";
  //}
  //String[] emxTableRowId =      emxGetParameterValues(request,"emxTableRowId");

  String Directory =     appDirectory;
  //Modified for Bug#312083 - Begin
 /* String hiddenParams = "";
     if(emxTableRowId !=null)
     {
     for(int k=0;k<emxTableRowId.length;k++){
       String itemId = emxTableRowId[k];
       if(k==emxTableRowId.length-1){
         hiddenParams += itemId;
       }
       else{
         hiddenParams += itemId + ",";
       }
     }
     spage = spage + "?emxTableRowId="+hiddenParams+"&objectId="+objectId;
}*/
spage = spage +"?objectId="+objectId;
//Modified for Bug#312083 - End
//Modified for Bug#054677 - 210 VM3-Start (Replaced Post method by Get)
%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
<html>
<body>
    <!-- content begins here -->
    <form name = "PersonSearch" method = "Get" action = "<%=spage%>" target="_parent" onSubmit="doSubmit();return false">
      <table border="0" width="100%" cellpadding="0" cellspacing="0" class="formBG">
        <tr>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td width="10"><img src="images/utilSpace.gif" width="10" height="1" /></td>
          <td>
            <!-- Begin form field table -->
              <table border="0" width="100%">
                <tr>
                  <td width="30%" class="label"><input type="radio" name="selected" value="Weekly" <%=sWeekly%> />
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Weekly</emxUtil:i18n>
                  </td>
                </tr>
                <tr>
                  <td width="30%" class="label"><input type="radio" name="selected" value="Monthly" <%=sMonthly%> />
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Monthly</emxUtil:i18n>
                  </td>
                </tr>
                <tr>
                  <td width="30%" class="label"><input type="radio" name="selected" value="Quarterly" <%=sQuarterly%> />
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Quarterly</emxUtil:i18n>
                  </td>
                </tr>
                <tr>
                  <td width="70%" class="label" colspan="1">
                  <table  width="70%"><tr><td class="labelRequired" >
                  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.DateRange</emxUtil:i18n>
                  </td>
            <td nowrap>
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.From</emxUtil:i18n>
          <%--xssok --%>   <input type="text" onfocus="this.blur()" name="start" size="20" value="<%=sStart%>" />&nbsp;
            <a href="javascript:showCalendar('PersonSearch', 'start','');">
            <img src="../common/images/iconSmallCalendar.gif" border="0" />
        <%--xssok --%>    <input type="hidden" name="start_msvalue" value="<%=XSSUtil.encodeForHTMLAttribute(context,sStartDtHidden)%>" />
            </a>
            </td>
            <td nowrap>
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.To</emxUtil:i18n>&nbsp;
         <%--xssok --%>   <input type="text" onfocus="this.blur()" name="end" size="20" value="<%=sEnd%>" />&nbsp;
            <a href="javascript:showCalendar('PersonSearch', 'end','');">
            <img src="../common/images/iconSmallCalendar.gif" border="0" />
          <%--xssok --%>  <input type="hidden" name="end_msvalue" value="<%=XSSUtil.encodeForHTMLAttribute(context,sEndDtHidden)%>" />
            </a>
            </td>
                     </tr>
              </table>
            <!-- End form field table -->
          </td>
        </tr>
      </table>
    </td>
    </tr>
    </table>

    </form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
</html>

