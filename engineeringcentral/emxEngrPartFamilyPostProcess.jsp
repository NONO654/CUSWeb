<%--  emxEngrPartFamilyPostProcess.jsp  -  Process Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script type="text/javascript" src="../common/scripts/emxUICore.js "></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js "></script>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
  String objectId = emxGetParameter(request,"objectId");
  String calledMethod = emxGetParameter(request,"calledMethod");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  int count = selectedItems.length;
  String selectedId = "";
  MQLCommand mqlCommand = new MQLCommand();
  mqlCommand.open(context);
  for (int i=0; i < count ;i++)
  {
      selectedId = selectedItems[i];
      //if this is coming from the Full Text Search, have to parse out |objectId|relId|
       StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
       if ( strTokens.hasMoreTokens())
       {
           selectedId = strTokens.nextToken();
       }
       // Logic for Part Family Add Existing Feature
       if(calledMethod.equals("partFamilyAddExisting"))
       {
           PartFamily partFamily = (PartFamily)DomainObject.newInstance(context,
           DomainConstants.TYPE_PART_FAMILY,DomainConstants.ENGINEERING);
           partFamily.setId(objectId);
           try
           {
                mqlCommand.executeCommand(context, "set transaction savepoint $1","PartFamily");
                partFamily.addPart(context, selectedId);
           }
           catch(Exception e)
           {
                mqlCommand.executeCommand(context, "abort transaction $1","PartFamily");
                String sError = e.toString();
                emxNavErrorObject.addMessage(sError);
                break;
                //throw new FrameworkException(sError);
           }
       }
   }
   mqlCommand.close(context);
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" type="text/javaScript">//<![CDATA[
//XSSOK                                                                
var calledMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
if(calledMethod == "partFamilyAddExisting")
{
	//XSSOK
    <%=XSSUtil.encodeForJavaScript(context,calledMethod)%>();
}

function partFamilyAddExisting()
{
	//XSSOK
    updateCountAndRefreshTree("<%=appDirectory%>", getTopWindow().getWindowOpener().getTopWindow());
    getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().closeWindow();
}
</script>
