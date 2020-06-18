<%--  emxpartSpecProcessConnect.jsp   - The Processing
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%><jsp:useBean id="specId" class="com.matrixone.apps.engineering.PartDefinition" scope="page" />
<%

 String POLICY_ECO = PropertyUtil.getSchemaProperty(context,"policy_ECO");
 String POLICY_ECR = PropertyUtil.getSchemaProperty(context,"policy_ECR");
 String RELATIONSHIP_AFFECTED_ITEM = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");


  DomainObject dobjId = DomainObject.newInstance(context);
  String sbusId = (String)session.getAttribute("objectId");
  
  if(sbusId == null){
	  sbusId = emxGetParameter(request,"objectId");

  }
  String[] selectedTypes = emxGetParameterValues(request,"selectedType");
  String strObjId = "" ;

  
  if(selectedTypes == null ){
	  
	  String[] sTempArr = emxGetParameterValues(request,"emxTableRowId");
	  selectedTypes = new String[sTempArr.length];
      for(int j = 0; j < sTempArr.length;j++) {
          
          strObjId = (String)((StringList) FrameworkUtil.split(sTempArr[j] , "|")).get(0);
          selectedTypes[j] = strObjId ; 
     }
  }
//added below code for the bug 309317
  StringList stList = new StringList();

  if(selectedTypes != null ) { 

	  for(int j = 0; j < selectedTypes.length;j++)
	  {
	        DomainObject mepObj = new DomainObject(selectedTypes[j]);
	        String sType = mepObj.getType(context);
	        String sName = mepObj.getName(context);
	        stList.add(sType.trim()+sName.trim());//checking both type and name..
	  }
  }
  
  

  boolean bCheckSameSpec= false;
  Iterator itr1 = stList.iterator();
  Iterator itr2 = stList.iterator();
  int count=0;
		 while (itr1.hasNext())
        {
            String strSpecTypeAndName = (String) itr1.next();//getting type and name
            while (itr2.hasNext())
            {
               String key = (String) itr2.next();

                if (key.trim().equals(strSpecTypeAndName.trim()))
                {
                    count++;
                }
            }//while

			if(count>1)
			{
				bCheckSameSpec= true;
				break;
			}
			else
			{
				count=0;
			}

         } // while()

if(bCheckSameSpec)
{
%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<script language="javascript">

	alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.AddExistingSpecification.NoMorethanSameSpecification </emxUtil:i18nScript> ");
	
	var fullSearchReference = findFrame(getTopWindow(), "structure_browser");
	fullSearchReference.setSubmitURLRequestCompleted();
	
</script>
<%
}
else
{
	  //ended below code for the bug 309317
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String relType = emxGetParameter(request,"changeType");
 
  String connectFromContextObj = emxGetParameter(request,"connectFromContextObj");

  if(connectFromContextObj == null || "null".equals(connectFromContextObj)) {
    connectFromContextObj ="";
  }

  if(selectedTypes != null)
  {
    String changeType = emxGetParameter(request,"changeType");
    changeType = PropertyUtil.getSchemaProperty(context, changeType);//Modified for converting JSP to Common components 
 
    String sFieldName = emxGetParameter(request,"FieldName");
    String sAttributearray = emxGetParameter(request,"attributeArray");

    if(sFieldName == null ){
    	sFieldName = "" ; 
    }
    
    if(sAttributearray  == null ){
    	sAttributearray = "" ;
    }
    
    try
    {
    	
     	
      StringTokenizer tokenField = new StringTokenizer(sFieldName,"|",false);
      StringTokenizer tokenAttr = new StringTokenizer(sAttributearray,"|",false);
      HashMap map = null;
      
      
      while(tokenField.hasMoreTokens())
      {

        String sFName = tokenField.nextToken().trim();
        if (sFName.equals("")) {
          continue;
        }

        String sAttr = "";

        // if a field is left blank hasMoreTokens will fail and an exception will be raised
        // hence the following check. If there are
        if(tokenAttr.hasMoreTokens()) {
          if (map == null) {
            map = new HashMap();
          }
          sAttr = tokenAttr.nextToken().trim();
          map.put(sFName,sAttr);
        }
      }

      specId.setId(sbusId);

      for(int i = 0; i < selectedTypes.length;i++)
      {
        dobjId.setId(selectedTypes[i]);

        DomainRelationship connection = DomainRelationship.newInstance(context);


        SelectList sListSelStmts = dobjId.getObjectSelectList(9);
        sListSelStmts.addElement(DomainObject.SELECT_ID);
        sListSelStmts.addElement(DomainObject.SELECT_TYPE);
        sListSelStmts.addElement(DomainObject.SELECT_NAME);
		sListSelStmts.addElement(DomainObject.SELECT_POLICY);
        sListSelStmts.addVault();
        Map objMap = dobjId.getInfo(context,sListSelStmts);
        String type = (String) objMap.get("type");
		//bug #342758
		String strPolicy = (String) objMap.get(DomainObject.SELECT_POLICY);
//bug #342758
		
		
		
        
        String vault = (String) objMap.get("vault");
        Vault mxvault = new Vault(vault);
        /* String typeCADDrawing = PropertyUtil.getSchemaProperty(context,"type_CADDrawing");
        String typeCADModel = PropertyUtil.getSchemaProperty(context,"type_CADModel");
        String typeDrawingPrint = PropertyUtil.getSchemaProperty(context,"type_DrawingPrint");
        String typeMarkup = PropertyUtil.getSchemaProperty(context,"type_Markup");
        // Get the base type
        String relSpec = PropertyUtil.getSchemaProperty(context,"relationship_PartSpecification");
        String relMarkup = PropertyUtil.getSchemaProperty(context,"relationship_Markup"); */


        if (connectFromContextObj.equalsIgnoreCase("true")) {
        connection = DomainRelationship.connect(context,specId,changeType,dobjId);
        }
        else {
		if((dobjId.isKindOf(context, DomainConstants.TYPE_ECR) && POLICY_ECR.equals(strPolicy)) || (dobjId.isKindOf(context, DomainConstants.TYPE_ECO) && POLICY_ECO.equals(strPolicy))) {
        connection = DomainRelationship.connect(context,dobjId,RELATIONSHIP_AFFECTED_ITEM,specId);
		}
		//for bug for 342758 Ends
		else{	
		
        connection = DomainRelationship.connect(context,dobjId,changeType,specId);
		
		}
        }

        if (map != null) {
          connection.setAttributeValues(context,map);
        }
      } // end of for loop

      }
        catch(Exception e)
      {
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
     // throw e;
      session.putValue("error.message", e.toString());
      }

  }  // if ends for selectedTypes
    //added below code for the bug 309317
	session.removeAttribute("objectId");
	session.removeAttribute("partType");
	session.removeAttribute("relType");
	session.removeAttribute("connectFromContextObj");
	session.removeAttribute("selType");
	session.removeAttribute("revPattern");
	session.removeAttribute("Name");
	session.removeAttribute("txtOriginator");
	session.removeAttribute("txtOwner");
	session.removeAttribute("Rev");
	session.removeAttribute("queryLimit");
	 //ended below code for the bug 309317
  request.setAttribute ("sourcePage", "ProcessConnect");
  String url="emxengchgECRProcessSearch.jsp?busId="+sbusId;
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
 window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;
 getTopWindow().closeWindow();
</script>

<%
}
%>
<%@include file = "emxDesignBottomInclude.inc"%>
