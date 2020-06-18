<%--  emxEngrSearchDeleteProcess.jsp   -  This page deletes the selected objectIds in the common search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%@ page import =  "com.matrixone.apps.common.CommonDocument" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
  // get parameters originally passed to emxTable so we can rebuild the URL
  //
  boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
  String errorMessage = "";
  String EMPTY_SPACE = "";
  //Start: 375954
  StringBuffer itemList = new StringBuffer();
  itemList.append("<mxRoot>");
  itemList.append("<action>remove</action>");
  //End: 375954
  String timeStamp = emxGetParameter(request, "timeStamp");
  boolean processFailed = false;
  String languageStr = emxGetParameter(request, "languageStr");
  String jsTreeID    = emxGetParameter(request, "jsTreeID");
  //Start: 375954
  String struiType =  emxGetParameter(request,"uiType");
//End: 375954
  if(jsTreeID==null || "null".equals(jsTreeID)){
    jsTreeID="";
  }

  String initSource  = emxGetParameter(request, "initSource");
  if(initSource==null){
        initSource="";
  }

  String suiteKey    = (String)emxGetParameter(request, "suiteKey");
  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteEngineeringCentral";
  }
   try
   {
   String checkBoxId[]  =  (String[]) session.getAttribute("emxTableRowId");
   //Start: 375954
   Map levelIdMap         = null;
   if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
  	levelIdMap         =  (Map) session.getAttribute("emxTableRowLevelId");
   }
   //End: 375954
   session.removeAttribute("emxTableRowId");
   //Start: 375954
   if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
       session.removeAttribute("emxTableRowLevelId");
      }
   //End: 375954
  String TYPE_DOCUMENTS     = PropertyUtil.getSchemaProperty(context,DomainObject.SYMBOLIC_type_DOCUMENTS);
  String TYPE_KINDOF_DOCUMENTS = "type.kindof["+TYPE_DOCUMENTS+"]";

        boolean accessFlag = false;

        StringList objectSelects = new StringList(2);
        objectSelects.addElement(DomainObject.SELECT_ID);
        objectSelects.addElement(TYPE_KINDOF_DOCUMENTS);
        objectSelects.addElement("current.access[delete]");
        MapList deleteAccessList = DomainObject.getInfo(context, checkBoxId, objectSelects);
        Iterator deleteAccessItr = deleteAccessList.iterator();
        DomainObject dom = new DomainObject();
        Vector finalObjects = new Vector();
        Vector finalDocuments = new Vector();
        while(deleteAccessItr.hasNext()) {
            Map accessMap = (Map)deleteAccessItr.next();
            String deleteAccess = (String)accessMap.get("current.access[delete]");
            String domObjectId = (String)accessMap.get(DomainObject.SELECT_ID);
            String isDocumentType = (String)accessMap.get(TYPE_KINDOF_DOCUMENTS);

            if("true".equalsIgnoreCase(deleteAccess)) {
                if ("TRUE".equalsIgnoreCase(isDocumentType))
                {
                    finalDocuments.addElement(domObjectId);
                }
                else
                {
                    finalObjects.addElement(domObjectId);
                }
            } else {
                accessFlag = true;
                dom.setId(domObjectId);
                dom.open(context);
                errorMessage += " "+dom.getTypeName()+" "+dom.getName()+" "+dom.getRevision()+",";
                dom.close(context);
            }
        }

        if(accessFlag) {
        	
        	//Multitenant
        	//errorMessage = i18nNow.getI18nString("emxEngineeringCentral.NoDeleteAccess", "emxEngineeringCentralStringResource", languageStr)+errorMessage.substring(0,errorMessage.length()-1);
        	errorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.NoDeleteAccess")+errorMessage.substring(0,errorMessage.length()-1);
        	throw new Exception(errorMessage);
        }
        int size = finalObjects.size();
		String []deleteArray;
        String []tempdeleteArray;
        if(isMBOMInstalled){
            if(size > 0) {
			deleteArray = new String[size];
			tempdeleteArray = new String[size];

            for(int k=0; k<size; k++) {
              //deleteArray[k]=(String)finalObjects.elementAt(k);
			  tempdeleteArray[k]=(String)finalObjects.elementAt(k);
	  		  DomainObject domDelObj = new DomainObject(tempdeleteArray[k]);
			  //Added for Incedent 339219 - start
			  //delete MCO
			  //To check the TYPE to be deleted (whether MCO or other types)
			  String strDelType = domDelObj.getInfo(context,DomainObject.SELECT_TYPE); 
			  boolean Test= true;
			  //Getting MCO name 
			  String strDelMCOName = domDelObj.getInfo(context,DomainObject.SELECT_NAME);
			  if(strDelType.equals(EngineeringConstants.TYPE_MCO))
			  {%>
				  <script language="javascript">
				  //XSSOK
				  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MCO.DeleteConfirmMsg1</emxUtil:i18nScript>"+" <%=strDelType%> "+"<%=strDelMCOName%>"+" <emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MCO.DeleteConfirmMsg2</emxUtil:i18nScript>");
				  
				  </script>
				<%
				String strChangeAuthId= domDelObj.getInfo(context,EngineeringConstants.RELATIONSHIP+"["+EngineeringConstants.RELATIONSHIP_MCO_CHANGE_AUTHORITY+ EngineeringConstants.SELECT_RIGHTBRACE + EngineeringConstants.DOT + EngineeringConstants.SELECT_FROM + EngineeringConstants.DOT + DomainConstants.SELECT_ID);
				if(strChangeAuthId!=null)
				{ 
				%>
				 <script language="javascript">
				 //XSSOK
				  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MCO.Delete</emxUtil:i18nScript>"+" <%=strDelType%> "+"<%=strDelMCOName%>");
				</script> 
				<%
				}
				// if MCO is not created through ECO release
				else 
				{
				  //Getting the curren State Of MCO
				  String strMCOState= domDelObj.getInfo(context,DomainObject.SELECT_CURRENT);
                  // To allow deletion only in Create State of MCO
				  if(strMCOState.equals(EngineeringConstants.STATE_MCO_CREATE))
				  {
					 deleteArray[k]=(String)tempdeleteArray[k];
					 String strAffPartMasterId= ""; 
				     //Getting list of Part Master id connected with MBOM Change Relationship
					 StringList strListAffPartMasterId= domDelObj.getInfoList(context,EngineeringConstants.RELATIONSHIP+"["+EngineeringConstants.RELATIONSHIP_MBOM_CHANGE+EngineeringConstants.SELECT_RIGHTBRACE + EngineeringConstants.DOT+EngineeringConstants.SELECT_TO+ EngineeringConstants.DOT+DomainConstants.SELECT_ID);
					 // if the MCO has Affected Part Master
					 if(strListAffPartMasterId.size()>0)
					 {
						 Iterator strListAffPartMasterIdItr = strListAffPartMasterId.iterator();
						 while (strListAffPartMasterIdItr.hasNext())
						 {
							//Getting Part Master Id
							strAffPartMasterId= (String)strListAffPartMasterIdItr.next();
							//Getting Plant Id
							String strPlantID = domDelObj.getInfo(context,EngineeringConstants.SELECT_PLANT_ID);
							if(strAffPartMasterId!=null)
							{
								//creating DomainObject for the Affected Part Master
								DomainObject partMasterObj = new DomainObject(strAffPartMasterId);
								
								//Creating relSelect
								StringList slRelSelList = new StringList(1);
								slRelSelList.add(DomainObject.SELECT_RELATIONSHIP_ID);
								slRelSelList.add(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE + EngineeringConstants.ATTRIBUTE_MCO_IN + EngineeringConstants.SELECT_RIGHTBRACE);
								slRelSelList.add(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE + EngineeringConstants.ATTRIBUTE_MCO_OUT + EngineeringConstants.SELECT_RIGHTBRACE);
								slRelSelList.add(EngineeringConstants.SELECT_SEQUENCE);
								
								//creating relwhere based on MCO-Out/MCO-in attribute
								StringBuffer whrClause = new StringBuffer();
								whrClause.append(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE + EngineeringConstants.ATTRIBUTE_MCO_IN + EngineeringConstants.SELECT_RIGHTBRACE +" == '"+ strDelMCOName + "'");
								whrClause.append("||");
								whrClause.append(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE + EngineeringConstants.ATTRIBUTE_MCO_OUT + EngineeringConstants.SELECT_RIGHTBRACE+" == '"+ strDelMCOName + "'");
								// creating relPattern to get MBOM/Part Revision relationship 
								String relPattern = EngineeringConstants.RELATIONSHIP_PART_REVISION+","+
													EngineeringConstants.RELATIONSHIP_MBOM;
								String objPattern = DomainObject.TYPE_PART+","+
													EngineeringConstants.TYPE_PART_MASTER;								
								
								//get relatedobjects(PartRev and MBOM Relationships) of PartMaster to be delated
								MapList mpList = partMasterObj.getRelatedObjects(context,
																relPattern,				// relationship pattern
																objPattern,				// object pattern
																null,					// object selects
																slRelSelList,           // relationship selects
																false,                  // to direction
																true,                   // from direction
																(short)1,               // recursion level
																null,                   // object where clause
																whrClause.toString());  // rel where clause

								Iterator mpListItr = mpList.iterator();
								while (mpListItr.hasNext()) 
								{
									Map mpRelId = (Map) mpListItr.next();
									//relationhip id to be disconnected
									String strRelId				= (String) mpRelId.get(DomainObject.SELECT_RELATIONSHIP_ID);
									String strRelName			= (String) mpRelId.get(EngineeringConstants.RELATIONSHIP);
									String strCurrentSeqToDel	= (String) mpRelId.get(EngineeringConstants.SELECT_SEQUENCE);

									String strMCOIn = (String) mpRelId.get(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE + EngineeringConstants.ATTRIBUTE_MCO_IN + EngineeringConstants.SELECT_RIGHTBRACE);
									String strMCOOut =(String) mpRelId.get(EngineeringConstants.SELECT_ATTRIBUTE_LEFTBRACE+ EngineeringConstants.ATTRIBUTE_MCO_OUT + EngineeringConstants.SELECT_RIGHTBRACE);

									//PartMaster pm = new PartMaster();	
									java.lang.Class clazz = java.lang.Class.forName("com.matrixone.apps.mbom.PartMaster");
   									com.matrixone.apps.engineering.IPartMaster pm =(com.matrixone.apps.engineering.IPartMaster) clazz.newInstance();
									DomainRelationship domRelSeq = null;
									
									// If Relationship id Part Revision
									if(strRelName.equals(EngineeringConstants.RELATIONSHIP_PART_REVISION))
									{
										if(strMCOIn.equals(strDelMCOName))
										{
											pm.deletePartRevSeq(context,strRelId ,strPlantID, strCurrentSeqToDel );
										}
									}// end if(strRelName.equals(MBOMConstants.RELATIONSHIP_PART_REVISION))
									
									// If Relationship id MBOM
									if(strRelName.equals(EngineeringConstants.RELATIONSHIP_MBOM))
									{
										if(strMCOOut.equals(strDelMCOName))
										{
											domRelSeq = new DomainRelationship(strRelId);
											domRelSeq.setAttributeValue(context,EngineeringConstants.ATTRIBUTE_MCO_OUT,"");
										}
										if(strMCOIn.equals(strDelMCOName))
										{
											pm.deleteMBOMRevSeq(context,strRelId ,strPlantID, strCurrentSeqToDel);	
										}
									}//end if(strRelName.equals(MBOMConstants.RELATIONSHIP_MBOM))			
						        }// end while (mpListItr.hasNext())			
							 }//end if(strAffPartMasterId!=null)
					      }// end while (strListAffPartMasterIdItr.hasNext())
				      }// end if(strListAffPartMasterId.size()>0)
					 
				   }// end if(strMCOState.equals(MBOMConstants.STATE_MCO_CREATE))
				   else
				   {%>
						<script language="javascript">
						//XSSOK
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MCO.DeleteInCreate</emxUtil:i18nScript>"+" <%=strDelType%> "+"<%=strDelMCOName%>");
						</script>
					
				 <%}
			    }// end else
							  
              }// end if(strDelType.equals(MBOMConstants.TYPE_MCO)) 
			  else // If type is other than MCO
			  {
				  deleteArray[k]=(String)finalObjects.elementAt(k);
			  }
           }
		   for(int d=0; d<size; d++)
		   {
			  if(deleteArray[d] != null)
			  {
                DomainObject test = new DomainObject(deleteArray[d]);
                String id = deleteArray[d];
		
				//Start: 375954
				if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
		              String item  =  "<item id='"+(String)levelIdMap.get(id)+"'/>";
		              itemList.append(item);
		             }
				//End: 375954
			   }
			   else
			   {
				   continue;
			   }

			}// end for(int d=0; d<size; d++)
          //Added for Incedent 339219 - end
          DomainObject.deleteObjects(context, deleteArray);	
        }
        }else{
	        if (size > 0)
	        {
	            deleteArray = new String[size];
	            tempdeleteArray = new String[size];
	            for(int k=0; k<size; k++) {
	              deleteArray[k]=(String)finalObjects.elementAt(k);
	              String id = deleteArray[k];
	              //Start: 375954
	              if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
	                  String item  =  "<item id='"+(String)levelIdMap.get(id)+"'/>";
	                  itemList.append(item);
	                 }
	             //End: 375954
	            }
	
	            DomainObject.deleteObjects(context, deleteArray);
	        }
        }
        
        //delete documents
        size = finalDocuments.size();
        if (size > 0)
        {
            deleteArray = new String[size];
            for(int k=0; k<size; k++) {
              deleteArray[k]=(String)finalDocuments.elementAt(k);
              String id = deleteArray[k];
			  //Start: 375954
              if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
              String item  =  "<item id='"+(String)levelIdMap.get(id)+"'/>";
              itemList.append(item);
              }
             //End: 375954
            }
            CommonDocument.deleteDocuments(context, deleteArray);
        }
                
        if( errorMessage!= null && !errorMessage.equals("")) {
           session.putValue("error.message", errorMessage);
        }

  }catch(Exception ex) {
	  processFailed = true;
      String msg = ex.toString();
      int startIndex = msg.indexOf("Message:");
      if (startIndex != -1)
      {
        startIndex = startIndex + 8;
        int endIndex = msg.indexOf("Severity:");
        if (endIndex == -1)
        {
          endIndex = msg.length();
        }
        msg = msg.substring(startIndex, endIndex);
        
        if(msg.indexOf("System Error: #5000001:") != -1){
    		msg = msg.replace("System Error: #5000001:", "");
    	}
        
    	if(msg.indexOf("java.lang.Exception:") != -1){
    		msg = msg.replace("java.lang.Exception:", "");
    	}
        
    	session.putValue("error.message", msg);
      }
      else
      {
    	startIndex = msg.indexOf("java.lang.Exception:");
    	if(startIndex != -1){
    		String[] message=msg.split(":");
    		msg = msg.replace("java.lang.Exception:", "");
    	}
        session.putValue("error.message", msg);
      }
  } 
// For IR-538444-3DEXPERIENCER2018x - emxNavigator.Home.ContentPage is removed from emxSystem.properties
//      String sCommonDir  = FrameworkProperties.getProperty(context, "eServiceSuiteFramework.CommonDirectory");
//      String sDefaultPage = FrameworkProperties.getProperty(context, "emxNavigator.Home.ContentPage");
	 //Start: 375954
     if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
     itemList.append("</mxRoot>");  
     }
     //End: 375954
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
//XSSOK
	var processFailed = <%=processFailed%>;
	if(!processFailed){
		 //Start: 375954
	   if(parent.removedeletedRows) {
	   	var responseXML  = "<xss:encodeForJavaScript><%=itemList.toString()%></xss:encodeForJavaScript>";
  	  		parent.removedeletedRows(responseXML);
  	   }//End: 375954
  	   else{
		getTopWindow().closeWindow();
		getTopWindow().location.href = getTopWindow().location.href;
  	   }//End
  }//End of if loop
</script>

