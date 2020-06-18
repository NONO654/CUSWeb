<%--
  FullSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%--
Review: 
@quickreview OEP QYG XX:XX:XX  IR-185410V6R2013x and IR-182156V6R2013x Code modify in RemoveModels Condition. Handled Exception in other way.
@quickreview T25 OEP 12:12:10  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet
@quickreview T25 OEP 12:12:18  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
@quickreview JX5 LX6 13:01:13  IR-210019 : Remove Context command is not displaying any error message
@quickreview ZUD DJH 13:06:14  IR-233665V6R2014x "When Existing Use Case or Test Case is added, Tree view is not reflected immediately"
@quickreview JX5 QYG 14:01:31  HL RMT Create Derivation links between Requirements
@quickreview ZUD DJH 14:06:26  HL Sequence Order to Tree Order Migration
@quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
@quickreview HAT1 ZUD 15:05:04  : Relationship direction modification for covered and refined requirements.
@quickreview KIE1 ZUD 17:06:30 : IR-509226-3DEXPERIENCER2018x - R419-STP: Adding configuration context command is KO on TRM objects
--%>

 
<%-- Common Includes --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.util.TreeOrderUtil"%>
<%@page import="matrix.db.Context"%> 
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
  	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
    
    
<%
   boolean bIsError = false;
   try
   {
	  String strLocale = context.getSession().getLanguage();
      String strMode = emxGetParameter(request,"mode");
      String strObjId = emxGetParameter(request, "objectId");  
      String strRelName = emxGetParameter(request, "relName");   
      String strRowId[] = emxGetParameterValues(request, "emxTableRowId");

      // Convert any internal relationship name to its display format:
      if (strRelName != null)
      {
         strRelName = PropertyUtil.getSchemaProperty(context, strRelName);
      }

      if (strRowId == null)
      {   
%>
<script language="javascript" type="text/javaScript">
   alert("<emxUtil:i18n localize='i18nId'>emxFramework.IconMail.FindResults.AlertMsg1</emxUtil:i18n>");
</script>
<%
      }

      else
      {
         if (strMode.equalsIgnoreCase("AddExisting"))
         {
            i18nNow i18nNowInstance = new i18nNow();
			String strStatusMsg = "";
			strStatusMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.Error3"); 
			String xmlMessage = "<mxRoot><action>add</action><data ";
			if("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"))){
				xmlMessage += " fromRMB=\"true\" status=\"committed\" >";
			}
			else{
				xmlMessage += " status=\"committed\" >";
			}
			
            String strGotFrom = emxGetParameter(request, "from");

			// Added Try-catch block
			//Added:-28-July-09:OEP:Bug 378042  
			try {
            for (int i = 0; i < strRowId.length; i++)
            {
               String selObjId = strRowId[i];
               if(selObjId.indexOf("|") >= 0){
                   selObjId = strRowId[i].split("[|]")[1];
               }
			   
               if(strObjId.equals(new DomainObject(selObjId).getInfo(context, "id"))) { //workaround for 3dsearch
            	   continue;
               }
               
               SpecificationStructure specStructure = new SpecificationStructure();
               int nValidationCode = specStructure.checkSourceAndTargetReqValidatyForLinking(
                 																			  context, 
 																							  strObjId,
 																							  selObjId,
 																							  strRelName);
                if(nValidationCode == 0)
                {
               // bug 371529
               if ("false".equalsIgnoreCase(strGotFrom))
               {
                  // Create the named relationship to the selected obj from the root obj:
		  // For REQ-SPEC --> REQ
                 String newRelId = RequirementsCommon.connectObjects(context, selObjId, strObjId, strRelName);
               	 xmlMessage += newRelId;
                 if((strRelName.equals(ReqSchemaUtil.getSpecStructureRelationship(context))))
                 {
            	   String[] IDs = newRelId.split(" ", -1);
            	   String RelID = IDs[2];
            	   String []RelIdToFetch = RelID.split("=",-1);
            	   String RelIdForTreeOrder = RelIdToFetch[1];
            	   RelIdForTreeOrder = RelIdForTreeOrder.replace("\"", " ");
            	   DomainRelationship.setAttributeValue(context,RelIdForTreeOrder,ReqSchemaUtil.getTreeOrderAttribute(context),""+TreeOrderUtil.getNextTreeOrderValue());

                 }
               }
               else
               {
                  // Create the named relationship to the root obj from the selected obj:
                 // For Requirement – Use Cases	Requirement – Test Cases Use Case – Sub Use Cases Use Case – Test Cases		  
		  String newRelId = RequirementsCommon.connectObjects(context, strObjId, selObjId, strRelName);
		  xmlMessage += newRelId;
		  if(strRelName.equals(ReqSchemaUtil.getRequirementValidationRelationship(context))||
		     strRelName.equals(ReqSchemaUtil.getRequirementUseCaseRelationship(context)) ||
		     strRelName.equals(ReqSchemaUtil.getSubUseCaseRelationship(context)) ||
		     strRelName.equals(ReqSchemaUtil.getUseCaseValidationRelationship(context)))
           	   {
           		String[] IDs = newRelId.split(" ", -1);
           		String RelID = IDs[2];
           		String []RelIdToFetch = RelID.split("=",-1);
           		String RelIdForTreeOrder = RelIdToFetch[1];
           		RelIdForTreeOrder = RelIdForTreeOrder.replace("\"", " ");
           		DomainRelationship.setAttributeValue(context,RelIdForTreeOrder,ReqSchemaUtil.getTreeOrderAttribute(context),""+TreeOrderUtil.getNextTreeOrderValue());
           	   }
		 }
                }
                else
                {
                    %>
                    <script language="JavaScript">
			 			 alert("<xss:encodeForJavaScript><%=strStatusMsg%></xss:encodeForJavaScript>");
					 </script>
					<%
                }
            }
		}catch (Exception e)
            {
		       bIsError = true;
               session.putValue("error.message", "" + e);
               //emxNavErrorObject.addMessage(e.toString().trim());
               
            }// End of main Try-catck block
          //End::OEP:Bug 378042  
            
			xmlMessage += "</data></mxRoot>";
%>
<script language="javascript" type="text/javaScript">
  //KIE1 ZUD TSK447636 
	if (typeof getTopWindow().getWindowOpener().parent.emxEditableTable != 'undefined' && getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected) {
   		if (getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor || getTopWindow().getWindowOpener().parent.getRequestSetting('isIndentedView') == 'true' ) {
			getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
		}
		else {
			getTopWindow().getWindowOpener().parent.editableTable.loadData();
			getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();
		}
	}
	else
	{
		getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
 	}

 	// ZUD Fix for IR-233665V6R2014x Refresh Structure browser tree
	getTopWindow().getWindowOpener().parent.refreshStructureTree();
	

    
  //window.getTopWindow().closeWindow();
    //KIE1 ZUD TSK447636 
</script>
<%
    }
		  //Ended:OEP:Bug 378042  
		    if (strMode.equalsIgnoreCase("AddToStructure")) {
			String structId = emxGetParameter(request,
				"specStructId");
			String strRelId = structId.split("[|]")[0];
			String xmlMessage = "";

try{			
        	for(int ii = 0; ii < strRowId.length; ii++)
            {
        		String selObjId = strRowId[ii];
        		if(selObjId.equals(structId)){
        			continue; //workaround for 3dsearch
        		}
        		
        		if(selObjId.indexOf("|") >= 0) {
        			selObjId = selObjId.split("[|]")[1];
        		}
        				
                boolean reSeq = true;
                
                try{
	                ContextUtil.startTransaction(context, true);
	                xmlMessage += SpecificationStructure.insertNodeAtSelected(context, structId, selObjId, null, reSeq, null, strRelName);
	                ContextUtil.commitTransaction(context);
                }catch(Exception ex)
                {
                    ContextUtil.abortTransaction(context);
                    throw ex;
                }
            }
}catch (Exception e)
{
    bIsError = true;
    session.putValue("error.message", "" + e);
    //emxNavErrorObject.addMessage(e.toString().trim());
    
 }// End of main Try-catck block
		    xmlMessage = "<mxRoot><action>add</action><data status=\"committed\"" + 
    			("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB")) ? " fromRMB=\"true\"" : "") + 
    			(xmlMessage.indexOf("pasteAboveToRow") > 0 ? " pasteBelowOrAbove=\"true\"" :"") + ">" + 
    			xmlMessage +
    			"</data></mxRoot>";
%>
<script language="javascript" type="text/javaScript">
  //KIE1 ZUD TSK447636 
	if (typeof getTopWindow().getWindowOpener().parent.emxEditableTable != 'undefined' && getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected) {
	    if (getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor || getTopWindow().getWindowOpener().parent.getRequestSetting('isIndentedView') == 'true' ) {
	        getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
	    }
	    else {
	        if(getTopWindow().getWindowOpener().parent.editableTable)
	        {
	            getTopWindow().getWindowOpener().parent.editableTable.loadData();
	            getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();
	        }
	    }
	}
	else
	{
	    getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	}

	
	//zud Fix for IR-233665  Refreshing the top corner tree structure.
	getTopWindow().getWindowOpener().parent.refreshStructureTree();
	  //KIE1 ZUD TSK447636 
</script>
<%
         }

         if (strMode.equalsIgnoreCase("Chooser"))
         {
            String strSearchMode = emxGetParameter(request, "chooserType");
            String fieldNameActual = emxGetParameter(request, "fieldNameActual");
            String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

            // For most webform choosers, default to the object id/name...
            String selObjId = ""; 
            String selObjName = ""; 

            // When choosing a person, use the name/fullname instead...
            if ("PersonChooser".equals(strSearchMode))
            {
               selObjId = strRowId[0].indexOf("|") >= 0 ? strRowId[0].split("[|]")[1] : strRowId[0];
               DomainObject selObject = new DomainObject(selObjId);
               selObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);
               selObjId = selObjName;
               selObjName = PersonUtil.getFullName(context, selObjName);
            }
            else
            {
            	String strShowRevision = emxGetParameter(request,"ShowRevision");
            	String strObjname = "";
            	
        		for (int i = 0; i < strRowId.length; i++)
        		{
        			String strTableRowId = strRowId[i];
        			StringList objectIdList = FrameworkUtil.split(strTableRowId, "|");
        			if (objectIdList.size() == 3)
        			{
        				strTableRowId = (String) objectIdList.get(0);

        			} else if(objectIdList.size() == 4)
        			{
        				strTableRowId = (String) objectIdList.get(1);
        			}
        			DomainObject domObj = new DomainObject(strTableRowId);
        			Map objMap = new HashMap();
        			StringList selectList = new StringList();
        			selectList.addElement(DomainConstants.SELECT_TYPE);
        			selectList.addElement(DomainConstants.SELECT_REVISION);
        			objMap = domObj.getInfo(context, selectList);
        			// Start:IR-027034V6R2011
        			String thisType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
        			String errorMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.error.RequirementOrChapter"); 
        			
        			if(strMode!= null && strMode.equals("forTraceability"))
        			{
        			 		if(thisType.equalsIgnoreCase("Comment") || thisType.equalsIgnoreCase("Requirement Specification"))
        					{
        					    throw new Exception(errorMsg);
        					}
        			}
        			//End:IR-027034V6R2011
        			if (((strShowRevision != null) && (!strShowRevision.equalsIgnoreCase("")) && !("null".equalsIgnoreCase(strShowRevision))) && (strShowRevision.equalsIgnoreCase("true")))
        			{
        				//This is to get obj name & rev.
        				strObjname = FrameworkUtil.getObjectNameWithRevision(context, strTableRowId);
        			} else
        			{
        				//This has to be read from the bean method.
        				strObjname = FrameworkUtil.getObjectName(context, strTableRowId);
        			}
        			if (!"".equals(strObjname) && !"null".equals(strObjname))
        			{
        				if ("".equals(selObjName) || "null".equals(selObjName))
        				{
        					selObjName = strObjname;
        					selObjId = strTableRowId;
        				} else
        				{
        					selObjName = selObjName + "," + strObjname;
        					selObjId = selObjId + "," + strTableRowId;
        				}
        			}
        		}
            }
%>
<script language="javascript" type="text/javaScript">
  //KIE1 ZUD TSK447636 
var win = getTopWindow().getWindowOpener() ? getTopWindow().getWindowOpener() : parent;
   if(win.emxEditableTable)
   {
            var formName="<xss:encodeForJavaScript><%=emxGetParameter(request, "formName")%></xss:encodeForJavaScript>";
            var vfieldNameActual  = win.document.forms[formName].elements["<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>"];
            var vfieldNameDisplay = win.document.forms[formName].elements["<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>"];
            vfieldNameActual.value ="<xss:encodeForJavaScript><%=selObjId%></xss:encodeForJavaScript>" ;
            vfieldNameDisplay.value ="<xss:encodeForJavaScript><%=selObjName%></xss:encodeForJavaScript>" ;
   }
   else
   {
            var vfieldNameActual = win.document.getElementsByName("<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>");
            var vfieldNameDisplay = win.document.getElementsByName("<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>");
            vfieldNameActual[0].value ="<xss:encodeForJavaScript><%=selObjId%></xss:encodeForJavaScript>" ;
            vfieldNameDisplay[0].value ="<xss:encodeForJavaScript><%=selObjName%></xss:encodeForJavaScript>" ;
   }
</script>
<%
         }
         else if(strMode.equalsIgnoreCase("AddModels"))
         {
        	 String strReqIds = emxGetParameter(request, "specStructId");
        	 boolean From = false;
        	 
        	 StringList sl =  FrameworkUtil.split(strReqIds, "|");
        	 for(int i=0;i<sl.size();i++){
        		 
    	    String strParentId = (String) sl.get(i);
    	    if(!(strParentId == null || "null".equalsIgnoreCase(strParentId) || "".equalsIgnoreCase(strParentId)))
    	    	{
    	    			// Model
    	            	 String strModelId[] = emxGetParameterValues(request, "emxTableRowId");
    	            	 for (int ii = 0; ii < strModelId.length; ii++)
    	                 {
    	                    String selModelObjId = strModelId[ii].indexOf("|") >= 0 ? strModelId[ii].split("[|]")[1] : strModelId[ii];
    	                    if(!strParentId.equalsIgnoreCase(selModelObjId))
    	                    	DomainRelationship.connect(context,strParentId,strRelName,selModelObjId,From);
    	                 }
    	    	 }
        	 }
        	 
        	 %>
        	 <script language="javascript" type="text/javaScript">
		   //KIE1 ZUD TSK447636 
        	 if(getTopWindow().getWindowOpener().parent.emxEditableTable)
			    {
 	        	  if(getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor)
				      {
					    getTopWindow().getWindowOpener().parent.refreshSCE();//structure content editor SCE
				      }
				      else
				      {
			        	getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();   // Structure Browser
				      }
			    }				
			    else
			    {
			         // window.parent.getTopWindow().getWindowOpener().parent.reloadTableComponent();  // List Page
					 window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
                  window.getTopWindow().closeWindow();
		    //KIE1 ZUD TSK447636 
			    }	
        	 </script>
        	 <%
         }
         else if(strMode.equalsIgnoreCase("RemoveModels"))
         {
        	 String strReqIds = emxGetParameter(request, "specStructId");
        	 //String rel = "Configuration Context";
        	 boolean From = false;
        	 
        	 StringList sl =  FrameworkUtil.split(strReqIds, "|");
        	 for(int i=0;i<sl.size();i++){
        		 
    	    String strParentId = (String) sl.get(i);
    	    if(!(strParentId == null || "null".equalsIgnoreCase(strParentId) || "".equalsIgnoreCase(strParentId)))
    	    	{
    	    			// Model
    	    			//START:OEP:2013x:IR-185410V6R2013x and IR-182156V6R2013x. Handled Exception
    	            	 String strModelId[] = emxGetParameterValues(request, "emxTableRowId");
    	            	 
    	            	 for (int ii = 0; ii < strModelId.length; ii++)
    	                 {
    	            		 String selModelObjId = strModelId[ii].indexOf("|") >= 0 ? strModelId[ii].split("[|]")[1] : strModelId[ii];
    	            		 try
    	            		 {
 	    	                    
     	                    	MQLCommand _mql = new MQLCommand();
 	    	    				boolean  bSuccess = _mql.executeCommand( context,"print connection bus $1 to $2 relationship $3 select $4 dump;",strParentId,selModelObjId,strRelName,"id");
 	    	    				
 	    	    				if(bSuccess)
 	    	    				{
 	    	    					String strConfigurationContextId = MqlUtil.mqlCommand( context, "print connection bus $1 to $2 relationship $3 select $4 dump;",strParentId,selModelObjId,strRelName,"id");
 	    	    					
 		    	                    ContextUtil.startTransaction(context, true);
 		    	                    DomainRelationship.disconnect(context,strConfigurationContextId,true);
 		    	                    ContextUtil.commitTransaction(context);
 	    	    				}
     	                    }catch(Exception ex)
     	                    {
								//JX5:IR-210019 : Remove Context command is not displaying any error message
     	                    	emxNavErrorObject.addMessage(ex.toString().trim());
     	                    }
     	                   //END:OEP:2013x:IR-185410V6R2013x and IR-182156V6R2013x. Handled Exception
    	                 }
    	    	 }
        	 }
        	 
        	 %>
        	 <script language="javascript" type="text/javaScript">
		   //KIE1 ZUD TSK447636 
        	 if(getTopWindow().getWindowOpener().parent.emxEditableTable)
			    {
 	        	  if(getTopWindow().getWindowOpener().parent.emxEditableTable.isRichTextEditor)
				      {
					    getTopWindow().getWindowOpener().parent.refreshSCE();//structure content editor SCE
				      }
				      else
				      {
			        	getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();   // Structure Browser
				      }
			    }				
			    else
			    {
			         // window.parent.getTopWindow().getWindowOpener().parent.reloadTableComponent();  // List Page
					 window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
                  window.getTopWindow().closeWindow();
		    //KIE1 ZUD TSK447636 
			    }	
        	 </script>
        	 <%
         }
         //JX5 : Derivation Command
         else if(strMode.equalsIgnoreCase("AddDerivationTarget"))
         {
        	 //handles multiple selection
        	 int nbSelObj = strRowId.length;
        	 String selObjId = "";
        	 String idsTarget = "";
        	 
        	 for(int n=0; n < nbSelObj; n++)
        	 {
        		 selObjId = strRowId[n];
        		 if(selObjId.indexOf("|") >= 0){
            		 selObjId = selObjId.split("[|]")[1];
        		 }
        	 // ++ Relationship direction modification for covered and refined requirements.
        		 idsTarget +=  selObjId ;
  			     
  			     if(n < (nbSelObj-1))
  			     {
  			    	idsTarget = idsTarget + "|";
  			     }
        	 // -- Relationship direction modification for covered and refined requirements.
        		 %>
            	 
            	 <script language="javascript" type="text/javaScript">
            	   //KIE1 ZUD TSK447636 
			 getTopWindow().getWindowOpener().getTopWindow().sb.initandDisplayTarget("<%=XSSUtil.encodeForJavaScript(context, selObjId)%>");					
            	 </script>
            	 <%
        	 }
        	 // ++ Relationship direction modification for covered and refined requirements.
        	 %>
        	 <script language="javascript" type="text/javaScript">
			 getTopWindow().getWindowOpener().getTopWindow().sb.reqSpecsCreateRelationShip("<%=XSSUtil.encodeForJavaScript(context, idsTarget)%>");
        	 </script>
        	 <%
        	 // -- Relationship direction modification for covered and refined requirements.
         }
       //JX5 End : Derivation Cmd
        	 
      }
      
   }
   catch (Exception e)
   {
      bIsError = true;
      session.putValue("error.message", "" + e);
      //emxNavErrorObject.addMessage(e.toString().trim());
   }// End of main Try-catck block
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" type="text/javaScript">
//Added: 29-July-09:OEP:Bug 378042 
  //KIE1 ZUD TSK447636 
	if(getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow() != getTopWindow())
		window.getTopWindow().closeWindow();
//Ended:OEP:Bug 378042 	
</script>

