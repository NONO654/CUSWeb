 <%--  emxEngrEBOMMarkupConnectChangeContext.jsp   - The Processing page for ECR connections.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String RELATIONSHIP_PROPOSED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_ProposedMarkup");
  String RELATIONSHIP_APPLIED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
  String RELATIONSHIP_AFFECTED_ITEM = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
  
  DomainObject markupObj = DomainObject.newInstance(context);
  DomainObject changeObj = DomainObject.newInstance(context);
  DomainObject partObj = DomainObject.newInstance(context);

  String relType = "";
  String markupId = emxGetParameter(request,"objectId");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  String language = request.getHeader("Accept-Language");
  String errorMessage = "";
  String partId = "";
  
  if(selectedItems != null)
  {
    try
    {
      markupObj.setId(markupId);
            
      //get part for this markup-can only be connected to one part
      partId = markupObj.getInfo(context, DomainConstants.SELECT_REL_EBOMMARKUP_ID);
      partObj.setId(partId);
      
      //get all change context for this part
      Pattern relPattern = new Pattern(null);
      //relPattern.addPattern(DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION);
     // relPattern.addPattern(DomainConstants.RELATIONSHIP_NEW_PART_PART_REVISION);
      relPattern.addPattern(RELATIONSHIP_AFFECTED_ITEM);
      SelectList objSelects = new SelectList(1);
      objSelects.add(DomainConstants.SELECT_ID);
      //V6R2011
      //MapList changeObjList = partObj.expandSelect(context,
        ///                                      relPattern.getPattern(),   // relationship pattern
           //                                   "*",                 // object pattern
             ///                                 objSelects,          // object selects
                //                              null,                // relationship selects
                  //                            true,                // to direction
                    //                          false,               // from direction
                      //                        (short) 1,           // recursion level
                        //                      null,                // object where clause
                          //                    null,                // relationship where clause
                            //                  null,                // cached list
                              //                false);              // use cache
      
        matrix.util.StringList relSele=new matrix.util.StringList();
		MapList changeObjList = FrameworkUtil.toMapList(partObj.getExpansionIterator(context, relPattern.getPattern(), "*",
		        objSelects, relSele, true, false, (short)1,
                null, null, (short)0,
                false, false, (short)0, false),
                (short)0, null, null, null, null);
        
        //V6R2011
      StringList changeList = new StringList(25);
      Iterator itr = changeObjList.iterator();
      Map mapObject = null;
      while (itr.hasNext())
      {
          mapObject = (Map)itr.next();
          changeList.addElement((String)mapObject.get(DomainConstants.SELECT_ID));
      }
      
      String selectedId = "";
      //should only be single select
      for (int i=0; i < selectedItems.length ;i++)
      {
          selectedId = selectedItems[i];
          //if this is coming from the Full Text Search, have to parse out |objectId|relId|
          StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
          if ( strTokens.hasMoreTokens())
          {
              selectedId = strTokens.nextToken();
          }
          
          changeObj.setId(selectedId);
          
          // if the part is not already an affected item for this change context, add it
		  if (!changeList.contains(selectedId))
          {
            // String policyName = changeObj.getInfo(context, DomainConstants.SELECT_POLICY);
             //String policyClassification = FrameworkUtil.getPolicyClassification(context, policyName);  
             //boolean dynamicApproval = false;                  
            // if ("DynamicApproval".equals(policyClassification))
             //{
             //    dynamicApproval = true;
            // }
             String[] affectedItems = {partId};
             
           //  if (!dynamicApproval)	 // Static Approval
            // {               
           	  //   HashMap programMap = new HashMap();
                 //following parameters expected by connect methods         
             //    HashMap reqMap = new HashMap();
              //   String[] parentOIDMap = {selectedId};
             //    reqMap.put("parentOID", parentOIDMap);
             //    reqMap.put("emxTableRowId",affectedItems);
             //    programMap.put("reqMap",reqMap);
             //    String[] args = JPO.packArgs(programMap);
          	//	 if (changeObj.isKindOf(context, DomainConstants.TYPE_ECR))
             //    {
          	//	      errorMessage = (String) JPO.invoke(context, "emxECR", null, "connectAffectedItemsforStaticApprovalPolicy", args, String.class);     
             //    }
             //    else if (changeObj.isKindOf(context, DomainConstants.TYPE_ECO))
             //    {
             //  	      errorMessage = (String) JPO.invoke(context, "emxECO", null, "connectAffectedItemsforStaticApprovalPolicy", args, String.class);
              //   }
              //   else //not a valid Engineering Central Change type
               //  {
               //       errorMessage = i18nStringNow("emxEngineeringCentral.EBOMMarkup.InvalidChangeType", language);
               //  }
            // }
            // else	//Dynamic Approval 
            // { 
                 relType = RELATIONSHIP_AFFECTED_ITEM;
                 if (relType != null && !"".equals(relType) && !"null".equals(relType)) 
                 {
                     DomainRelationship rel = DomainRelationship.connect(context, changeObj, relType, partObj);
                 }
             //}
          }
          
          // connect the markup to the change context
          if ("".equals(errorMessage))
          {
              if (changeObj.isKindOf(context, changeObj.TYPE_ECR))
              {
                  relType = RELATIONSHIP_PROPOSED_MARKUP;          
              }
              else if (changeObj.isKindOf(context, changeObj.TYPE_ECO))
              {
                  relType = RELATIONSHIP_APPLIED_MARKUP;
              }
              else
              {
                  errorMessage = com.matrixone.apps.engineering.EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.EBOMMarkup.InvalidChangeType", language);
              }
      
              DomainRelationship rel = DomainRelationship.connect(context, changeObj, relType, markupObj);
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
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
  //refresh the calling structure browser and close the search window
  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
  getTopWindow().closeWindow();
</script>

<%@include file = "emxDesignBottomInclude.inc"%>
