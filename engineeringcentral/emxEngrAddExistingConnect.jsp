<%--  emxEngrAddExistingConnect.jsp   - The Processing page for ECR connections.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="com.matrixone.apps.engineering.ECO,com.matrixone.apps.engineering.ECR"%>
<%
  DomainObject fromObj = new DomainObject();
  DomainObject toObj = new DomainObject();

  String objectId          = emxGetParameter(request,"objectId");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  String relType          = emxGetParameter(request,"srcDestRelName");
  
  //added for the bug 349089 starts
  String sfields         = emxGetParameter(request,"field");
  String PERSON_REQUEST_ACCESS_GRANTOR = PropertyUtil.getSchemaProperty(context,"person_RequestAccessGrantor");
  String strAffectedItemRel = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
  
  if(sfields!=null && sfields.length()>0)
		{
	if (sfields.indexOf(":") != -1)
	{
		sfields = sfields.substring(sfields.indexOf("=")+1,sfields.indexOf(":"));
	}
	else
	{
		sfields = sfields.substring(sfields.indexOf("=")+1);
	}
		}
  //added for the bug 349089 ends
  
  // isTo is set to TRUE when the search results contain the TO side of the relationship
  String isTo            = emxGetParameter(request,"isTo");
  
  DomainObject doAI = new DomainObject(objectId);
  boolean bpart = doAI.isKindOf(context, DomainConstants.TYPE_PART);

  String errorMessage = "";

  if(selectedItems != null)
  {
    try
    {
      if (isTo.equalsIgnoreCase("true"))
      {
          fromObj.setId(objectId);
      }
      else
      {
      	  toObj.setId(objectId);
      }
      if (relType != null && !"".equals(relType) && !"null".equals(relType)) 
      {
          relType = PropertyUtil.getSchemaProperty(context,relType);

          if (relType.equals(strAffectedItemRel))
          {
			String strSelectedId = selectedItems[0];

			  StringTokenizer strTokens = new StringTokenizer(strSelectedId,"|");
              if ( strTokens.hasMoreTokens())
              {
				  strSelectedId = strTokens.nextToken();
              }

			DomainObject doChange = new DomainObject(strSelectedId);

			String [] affectedItemsList = new String[1];
			affectedItemsList[0] = objectId;

			         if (doChange.isKindOf(context, DomainConstants.TYPE_ECR))
              {
		ECR ecrTarget = new ECR(strSelectedId);
		ecrTarget.connectAffectedItems(context, affectedItemsList);

		      	 	}
			else if (doChange.isKindOf(context, DomainConstants.TYPE_ECO))
                  {
		ECO ecoTarget = new ECO(strSelectedId);
		ecoTarget.connectAffectedItems(context, affectedItemsList);

                  }

			      	 	}
			      	 	else
			      	 	{
			  String selectedId = "";
			  DomainObject doChange = new DomainObject();
	
	try{
	                  ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"), DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING); //373097
	  
	  
			  for (int i=0; i < selectedItems.length ;i++)
			      		{
				  selectedId = selectedItems[i];
				  //if this is coming from the Full Text Search, have to parse out |objectId|relId|
				  StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
				  if ( strTokens.hasMoreTokens())
			      		{
					  selectedId = strTokens.nextToken();
              }

              if (isTo.equalsIgnoreCase("true"))
              {
                  toObj.setId(selectedId);
              }
              else
              {
                  fromObj.setId(selectedId);              
              }
            DomainRelationship rel = DomainRelationship.connect(context, fromObj, relType, toObj);

	     	}
	     	
	     	}
		              finally{
		                  ContextUtil.popContext(context); //373097
                 		 }
          }
      }
      if (!"".equals(errorMessage))
      {
    	  session.putValue("error.message",errorMessage);
      }
    
    }
    catch(Exception e)
    {
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
      session.putValue("error.message",e.getMessage());
    }
  }  // if ends for selectedTypes


%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
  //refresh the calling structure browser and close the search window
  //top.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
  getTopWindow().closeWindow();
</script>

<%@include file = "emxDesignBottomInclude.inc"%>

