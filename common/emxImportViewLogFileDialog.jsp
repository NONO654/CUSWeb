<!--  emxImportviewLogFileDialog.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxImportViewLogFileDialog.jsp.rca 1.1.4.4 Wed Oct 22 15:48:23 2008 przemek Experimental przemek $
-->

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language="javascript">

 function submit()
 {
     var jobid = document.frmviewLogFile.jobid.value;
     var fileName = document.frmviewLogFile.fileName.value;
   if(document.frmviewLogFile.frmType[0].checked==true)
   {

    
    var callURL = "../common/emxImportLogFileView.jsp?jobid="+jobid +"&fileName="+fileName;
      showModalDialog(callURL,575,575, true);

   }
    else
   if(document.frmviewLogFile.frmType[1].checked==true)
   {
     var callURL = "../common/emxImportLogFileDownLoad.jsp?jobid="+jobid +"&fileName="+fileName;
      showModalDialog(callURL,575,575);
   }
 }
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
String fileName = "";
String jobId      = emxGetParameter(request,"objectId");
Job job = new Job(jobId);
MapList mapList = job.getAllFiles(context);
System.out.println("mapList = " + mapList);
if(mapList==null && mapList.size() == 0)
{
     // Handle the condition wherein the file is not checked
}
else
{
    fileName = (String)((Map)mapList.get(0)).get("1");
}
String isReturn = emxGetParameter(request,"isReturn");
MapList list = new MapList ();
if("true".equals(isReturn))
 {
  list = (MapList) session.getAttribute("jobs");    
 }
  else
 {
  session.setAttribute("jobs",list);
 }
%>


 <form name="frmviewLogFile" method="post" onSubmit="submit();"  target="_parent">
 <input type="hidden" name="jobid" value="<xss:encodeForHTMLAttribute><%=jobId%></xss:encodeForHTMLAttribute>"/>
  <!-- //XSSOK -->
  <input type="hidden" name="fileName" value="<%=fileName%>" />

 <table width="100%" border="0" cellspacing="3" cellpadding="2">
 <tr>
    <td  class="field"><input type="radio" name="frmType" value = "one" checked /><img border="0" src="../common/images/iconActionCheckOut.gif" /><emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.label.ViewLog</emxUtil:i18n>
    </td>
  </tr>
 <tr>
    <td  class="field"><input type="radio" name="frmType" value = "two" /><img border="0" src="../common/images/iconActionDownload.gif" /><emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.label.Download/Save-as</emxUtil:i18n></td>
  </tr>
  </table>
  </form>
  
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
