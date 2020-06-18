<%--
  LinkAsSubOrDerivedProcess.jsp

  Performs the action that creates an incident.

  Copyright (c) 2010-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  @quickreview T25 DJH 13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
  @quickreview HAT1 ZUD 17:05:19  :  HL - TSK3278161:	ENOVIA GOV TRM Deprecation of functionalities to clean up
       
 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.requirements.DeleteUtil"%>

<%@page import="java.util.Map"%>
<%@page import="java.util.Random"%>
<%@page import="java.util.Vector"%>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%><html>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    
<%
boolean eFlag = false;
    try {

            String[] tableRowIds = emxGetParameterValues(request,"emxTableRowId");
           //  String sourceObjectIds = ""+ session.getAttribute("sourceIDs");
            String sourceObjectIds = emxGetParameter(request,"sourceID");
            String sourceRowId = sourceObjectIds;
            String mode = emxGetParameter(request, "mode");
            String targetObjectId = null;
            String strRelName = null;
            String strMessage = "";
            Vector selectedCollectionName = new Vector();
            String strStatusMsg = "";
            String strLocale = context.getSession().getLanguage();
            strStatusMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.Error3"); 
            String sLanguage = request.getHeader("Accept-Language");
            String suiteKey = emxGetParameter(request, "suiteKey");
            String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
            
           

            if (!("undefined".equalsIgnoreCase(sourceObjectIds))) {
            	     if(sourceObjectIds != null && sourceObjectIds.indexOf("|") >= 0)
                     {
                         sourceObjectIds = sourceObjectIds.split("[|]")[1];
                     }
            	
             if(sourceObjectIds != null)
             {
                 DomainObject bo = DomainObject.newInstance(context, sourceObjectIds);
                 State curState = bo.getCurrentState(context);
                 String strState = curState.getName();
                 
                 // ++ HAT1 ZUD  : TSK3278161 - R419: Deprecation of functionalities to clean up. ++
                 boolean isModeDerivedReq = mode.equalsIgnoreCase("DerivedRequirement"); 
                 if((strState.equals("Release") && !isModeDerivedReq) || strState.equals("Obsolete"))
                 {
                	if(strState.equals("Obsolete"))
                    	strMessage = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.SourceSelectionObsolete");
                	 else
                    strMessage = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.SourceSelectionReleaseorObsolete");
                	 
                    throw new Exception(strMessage);
                   }
                 // -- HAT1 ZUD  : TSK3278161 - R419: Deprecation of functionalities to clean up. --
              }
            
             if (tableRowIds != null) {
                    Map objectMap = DeleteUtil.getObjectIdsRelIds(tableRowIds);
                    String[] oids = (String[]) objectMap.get("ObjId");
                    for (int i = 0; i < oids.length; i++) {
                        String strRequirementObjects = oids[i];
                        if (!RequirementsUtil.isRequirement(context,strRequirementObjects)) {
                            String errMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Alert.SelectRequirementOnly"); 
                            // emxRequirements.Alert.SelectRequirementOnly
                            // throw new Exception("Please select only Requirements");
                            throw new Exception(errMsg);
                        } else {
                            //map.put("objectId", objId);
                            selectedCollectionName.add(strRequirementObjects);
                        }
                    }
                }

                DomainObject domObj = new DomainObject(sourceObjectIds);
                String strName = domObj.getInfo(context, DomainConstants.SELECT_NAME);
                
                if (mode != null) {
                    if (mode.equalsIgnoreCase("SubRequirement")) {
                    	
                        strRelName = ReqSchemaUtil.getSubRequirementRelationship(context);
                        strMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Status.LinkAsSubRequirement"); 
                        strMessage = FrameworkUtil.findAndReplace(strMessage, "$<name>", strName);
                    } else {
                        strRelName = ReqSchemaUtil.getDerivedRequirementRelationship(context);
                        strMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Status.LinkAsDerivedRequirement"); 
                        strMessage = FrameworkUtil.findAndReplace(strMessage, "$<name>", strName);
                    }
					
                    String xmlMessage = "";
                    for (int j = 0; j < selectedCollectionName.size(); j++) {
                        targetObjectId = (String) selectedCollectionName.elementAt(j);
                        
                        // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++ 
                    	BusinessObject busObj = new BusinessObject(targetObjectId);
                    	busObj.open(context);
                    	String objType = busObj.getTypeName();
                    	busObj.close(context);
                    	
                        if(objType.equalsIgnoreCase("Requirement Proxy"))
                        {
                        	//the object is leaf object.
                        	//throw new Exception("InvalidSpecTreeSelectionReqProxy");
                        	String err = EnoviaResourceBundle.getProperty(context,strStringResourceFile, context.getLocale(), "emxRequirements.Alert.InvalidSpecTreeSelectionReqProxy");
							 if(!"".equals(xmlMessage)){
								 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
				                    		xmlMessage +
				                    		"</data></mxRoot>";
							 }
                           throw new Exception(err + ("".equals(xmlMessage) ? "" : ("|" + xmlMessage)));
                        }
                        // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
                        
                        else if (sourceObjectIds.equalsIgnoreCase(targetObjectId)) {
                            //emxRequirements.Alert.Error8
                            // throw new Exception("For this operation Target and Source objects can not be the same");
                            String err = EnoviaResourceBundle.getProperty(context,strStringResourceFile, context.getLocale(), "emxRequirements.Alert.Error8");
							 if(!"".equals(xmlMessage)){
								 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
				                    		xmlMessage +
				                    		"</data></mxRoot>";
							 }
                            throw new Exception(err + ("".equals(xmlMessage) ? "" : ("|" + xmlMessage)));
                        } else {
                            SpecificationStructure specStructure = new SpecificationStructure();
                            int nValidationCode = specStructure.checkSourceAndTargetReqValidatyForLinking(
                                                                                                          context, 
                                                                                                          sourceObjectIds,
                                                                                                          targetObjectId,
                                                                                                          strRelName);
                            if (nValidationCode == 0) {
                                StringBuffer sbRelSelect = new StringBuffer();
                                MapList excludeList = null;
                                
                                sbRelSelect = sbRelSelect.append(ReqSchemaUtil.getSubRequirementRelationship(context))
                                                          .append(",")
                                                          .append(ReqSchemaUtil.getDerivedRequirementRelationship(context));
                                DomainObject dom = new DomainObject(sourceObjectIds);
                                int sRecurse = 0;
                                StringList objSelects = new StringList(1);
                                objSelects.addElement(DomainConstants.SELECT_ID);
                                StringList excludeIds = new StringList();
                               
                                excludeList = dom.getRelatedObjects(context, sbRelSelect.toString(), ReqSchemaUtil.getRequirementType(context),
                                      true, false, sRecurse, objSelects, null, null, null, null, null, null);
                                    
                                 for (int ii = 0; ii < excludeList.size(); ii++)
                                    {
                                        Map excludeMap = (Map) excludeList.get(ii);
                                        String excludeId = (String) excludeMap.get(DomainConstants.SELECT_ID);
                                        if (excludeId != null)
                                            excludeIds.add(excludeId);
                                    }
                                 
                                 if(excludeIds.contains(targetObjectId))
                                 {
                                     //String errMess = "Target Object cannot be connected to the Parent Object";
									 String errMess = EnoviaResourceBundle.getProperty(context,strStringResourceFile, context.getLocale(), "emxRequirements.Alert.TargetCannotConnectToSource");
									 if(!"".equals(xmlMessage)){
										 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
						                    		xmlMessage +
						                    		"</data></mxRoot>";
									 }
                                     throw new Exception(errMess + ("".equals(xmlMessage) ? "" : ("|" + xmlMessage)));
                                 }
                                 else
                                 {
                                	 try{
                                	 	xmlMessage += SpecificationStructure.insertNodeAtSelected(context, sourceRowId, targetObjectId, null, true, null, strRelName);
                                	 }
                                	 catch(Exception ex)
                                	 {
    									 if(!"".equals(xmlMessage)){
    										 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
    						                    		xmlMessage +
    						                    		"</data></mxRoot>";
    									 }
    									 throw new Exception((ex instanceof FrameworkException ? ex.toString() : ex.getMessage()) + 
    											 					("".equals(xmlMessage) ? "" : ("|" + xmlMessage)));
                                	 }
                                 }
                                 
                                 
                                } else {
									 if(!"".equals(xmlMessage)){
										 xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
						                    		xmlMessage +
						                    		"</data></mxRoot>";
									 }
                                	throw new Exception(strStatusMsg + ("".equals(xmlMessage) ? "" : ("|" + xmlMessage)));
                            }
                        }
                    }
                    xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" fromRMB=\"true\">" + 
                    		xmlMessage +
                    		"</data></mxRoot>";
                    throw new Exception(strMessage + "|" + xmlMessage);
                    
                }
            } else {
                strMessage = EnoviaResourceBundle.getProperty(context,bundle, context.getLocale(), "emxRequirements.Alert.CouldNotFindSourceSelection"); 
                throw new Exception(strMessage);
                //out.print(strMessage);
              }
         } catch (Exception exp) {
         	 eFlag = true;
             out.clear();
             System.out.println(exp);
             out.print(exp instanceof FrameworkException ? exp : exp.getMessage());
             return;
         }
            %>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
</html>
