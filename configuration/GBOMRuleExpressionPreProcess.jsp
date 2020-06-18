
<%--  GBOMRuleExpressionPreProcess.jsp-- Will redirect to GBOMRuleExpressionDialog.jsp with proper params
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>

<%@include file= "../common/emxNavigatorInclude.inc"%>
<%@include file= "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%	
		try {
                String jsTreeID = emxGetParameter(request, "jsTreeID");
                String suiteKey = emxGetParameter(request, "suiteKey");
                String initSource = emxGetParameter(request, "initSource");
                String objectId = emxGetParameter(request, "objectId");
                String gbomName = emxGetParameter(request, "partName");
                String gbomType = emxGetParameter(request, "gbomType");
                String ruleType = emxGetParameter(request, "ruleExcludeOrInclude");
	            String strRelId = emxGetParameter(request, "relId");
	            String iRuleId= emxGetParameter(request, "iRuleId");
	            String lfeatureId= emxGetParameter(request, "lfeatureId");
				String strCtxPdtId = emxGetParameter(request,"productID");
				 String strExpression = emxGetParameter(request, "Expression");
				
				
                String Directory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.Directory");
                framesetObject fs = new framesetObject();
                fs.setDirectory(Directory);
                fs.setObjectId(objectId);
                fs.setStringResourceFile("emxConfigurationStringResource");

                if (initSource == null) {
                    initSource = "";
                }
                
               // add these parameters to each content URL, and any others the App needs
                String contentURL = "GBOMRuleExpressionDialog.jsp";
                contentURL += "?suiteKey=" + suiteKey + "&initSource="+"&Expression="+strExpression
                        + initSource + "&jsTreeID=" + jsTreeID+"&objectId=" + objectId + "&relId=" + strRelId+"&productID="+strCtxPdtId+"&iRuleId="+iRuleId+"&gbomName="+gbomName+"&gbomType="+gbomType+"&ruleType="+ruleType+"&lfeatureId="+lfeatureId;
				
                // Page Heading & Help Page
                String PageHeading = "emxProduct.Heading.InclusionRuleExpression";
                String HelpMarker = "emxhelpinclusionruleedit";

                fs.initFrameset(PageHeading, HelpMarker, contentURL, false,
                        true, false, false);
                fs.writePage(out);

   		 }catch (Exception exception) {
   			throw new FrameworkException(exception);
     	 }

        %>


