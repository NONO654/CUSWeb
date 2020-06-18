<%-- emxengchgECOConnectECRProcess.jsp - Used to connect to ECR(s)
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<%

String sMode = emxGetParameter(request, "mode");
if(sMode!= null && sMode.equalsIgnoreCase("ECOCreate")){
    String strObjectId = emxGetParameter(request, "objectId");
    String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
    String sObjNameList =  "";
    String sObjIDList =  "";
    matrix.util.StringList objIdList = new matrix.util.StringList();
    StringTokenizer strTokenizer= null;
    DomainObject objContext = null;
    for(int i=0;i<strContextObjectId.length;i++){
	    strTokenizer = new StringTokenizer(strContextObjectId[i] , "|");
	    objIdList.addElement(strTokenizer.nextToken());
    }
    StringList selectable = new StringList(com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
    selectable.add(com.matrixone.apps.domain.DomainConstants.SELECT_ID);
    com.matrixone.apps.domain.util.MapList lst = DomainObject.getInfo(context,(String[])objIdList.toArray(new String[objIdList.size()]),selectable);
    for(int j=0;j<lst.size();j++){
        Map mp = (Map)lst.get(j);
        sObjIDList+= mp.get(DomainConstants.SELECT_ID)+"|";
        sObjNameList+= mp.get(DomainConstants.SELECT_NAME)+",";
    }
    sObjIDList = sObjIDList.substring(0,sObjIDList.length()-1);
    sObjNameList = sObjNameList.substring(0,sObjNameList.length()-1);
    %>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript">
    //XSSOK
    getTopWindow().getWindowOpener().document.emxCreateForm.RelatedECRDisplay.value = "<%=sObjNameList%>";
  //XSSOK
    getTopWindow().getWindowOpener().document.emxCreateForm.RelatedECR.value = "<%=sObjIDList%>";
    getTopWindow().closeWindow();
    </script>
    <%
}else {
  ECR ecrObj = (ECR)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ECR,DomainConstants.ENGINEERING);
  ECO ecoObj = (ECO)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ECO,DomainConstants.ENGINEERING);
  DomainRelationship domainRelationship = DomainRelationship.newInstance(context);

  String objectId = emxGetParameter(request, "objectId");
  String sError = "";

  String [] selectedECRs = emxGetParameterValues(request, "selectedECR");
  String relType = PropertyUtil.getSchemaProperty(context , "relationship_ECOChangeRequestInput");

  // connect specified ECR to the ECO with specified relationship

  if(selectedECRs != null)
  {

%>
    <%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
    try
    {
       int nObjects = selectedECRs.length;
       // set Id for the ECO object
       ecoObj.setId(objectId);
       for(int i=0; i < nObjects; i++)
       {
          ecrObj.setId(selectedECRs[i]);
		  DomainRelationship.connect(context, ecoObj, relType, ecrObj);
       }

    }
    catch(Exception Ex)
    {
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
    sError = Ex.toString();
    // System.out.println("error:   " + sError);
    throw Ex;
    }
%>
    <%@include file = "emxEngrCommitTransaction.inc"%>

<%
  }  // if ends for selectedECRs
  }
%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
<% if(sMode== null || !sMode.equalsIgnoreCase("ECOCreate")){ %>
	  parent.window.getWindowOpener().parent.location.href =parent.window.getWindowOpener().parent.location.href;
	  parent.closeWindow();
	  <%}%>
</script>

