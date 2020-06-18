<%--  emxAffectedItemCreateRaiseECR.jsp   - The Processing page for Creation of ECRs by a Customer
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>

<%

  ECR ecrId = (ECR)DomainObject.newInstance(context,
                  DomainConstants.TYPE_ECR,DomainConstants.ENGINEERING);
  String sRelType = "";
  String sECRType = PropertyUtil.getSchemaProperty(context, "type_ECR");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  String selectedType = "";
  //if this is coming from the Full Text Search, have to parse out |objectId|relId|
  int loop = 0;
  StringTokenizer strTokens = new StringTokenizer(selectedItems[loop],"|");
  if ( strTokens.hasMoreTokens())
  {
      selectedType = strTokens.nextToken();
  }

  String []selectedParts = ( String [] )session.getAttribute("selectedParts");

  String partObjectId         = emxGetParameter(request, "objectId");
  String objectId             = "";
   boolean ignoreFlag          = false;

  String strPartId = "";
  String strPartName = "";
  StringList selectList = new StringList();
  selectList.addElement(DomainObject.SELECT_ID);
  StringList relSelects = new StringList();
 
  
%>
   <%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
    try
    {
	  objectId = selectedType;
	  ecrId.setId(objectId);
	  String relationshipId="";

	  String relPattern = PropertyUtil.getSchemaProperty(context, "relationship_AffectedItem");
      //String relStaticPattern = PropertyUtil.getSchemaProperty(context, "relationship_RequestPartRevision");

      for(int i=0; i < selectedParts.length; i++){
          StringTokenizer st = new StringTokenizer(selectedParts[i], "|");
          strPartId = st.nextToken().trim();
		  DomainObject doPart = new DomainObject(strPartId);
		  StringList busSelect = new StringList(2);
		  busSelect.add(DomainConstants.SELECT_ID);
		  StringList relSelect = new StringList(1);
		  relSelect.add(DomainConstants.SELECT_RELATIONSHIP_ID);
		  String busWhere = "id=="+objectId;
          DomainObject ECRObject=new DomainObject(objectId);
		  String ECRPolicy=null;
		  ECRPolicy= ECRObject.getInfo(context,DomainConstants.SELECT_POLICY); 
		 // String strECPolicy = PropertyUtil.getSchemaProperty(context,"policy_ECRStandard");
		  MapList mlECR = null;
		  mlECR  = doPart.getRelatedObjects(context, relPattern, DomainConstants.TYPE_ECR, busSelect,relSelect , true, false, (short)1, busWhere,null);
		  if(mlECR.size() == 0 && ECRPolicy!=null) 
		  {
              //if(ECRPolicy.equalsIgnoreCase(strECPolicy))
		      //{
		      //  DomainRelationship.connect(context,ecrId,relStaticPattern, doPart);
		      //}
		     // else
		      //{
		   		DomainRelationship.connect(context,ecrId,relPattern, doPart);
		     // }
		  }
		  else
		  {
                          //Modified for IR-097616V6R2012
			  strPartName = strPartName + " " + doPart.getName(context);
			  ignoreFlag = true;
		  }
		}
	   }
    catch(Exception e)
    {
%>
    <%@include file = "emxEngrAbortTransaction.inc"%>
<%

    throw e;
  }
%>
  <%@include file = "emxEngrCommitTransaction.inc"%>


<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
<%
  if(ignoreFlag==true)
  {
%>
  alert("<emxUtil:i18n localize='i18nId'>emxEngineeringCentral.RaiseECR.AlertItemsAlreadyRaised1</emxUtil:i18n> \n\n <xss:encodeForJavaScript><%=strPartName%></xss:encodeForJavaScript>");

<%
  }
%>
  //top.getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
  getTopWindow().closeWindow();
</script>

