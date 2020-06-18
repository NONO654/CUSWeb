<%--  emxLibraryCentralClassificationIntermediate.jsp  -
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="../emxUICommonAppInclude.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<%
    try
    {
        String objectId                 = emxGetParameter(request,"objectId");
        String parentOId                = emxGetParameter(request,"parentOID");
        String tableRowIdList[]         = emxGetParameterValues(request, "emxTableRowId");
        String classificationMode       = emxGetParameter(request,"classificationMode");
        StringBuffer contentURL         = new StringBuffer();
        String selectedClassIds         = getTableRowIDsString(tableRowIdList);
		String languageStr              = request.getHeader("Accept-Language");

        if (classificationMode == null || "null".equals(classificationMode)) {
          classificationMode = "";
        }
		if(classificationMode.equals("editAttributes"))
        {        	 
        	String result = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", true, objectId, "type.kindof[Part]");        	
        	if("TRUE".equalsIgnoreCase(result)){
        		try{
        		  ComponentsUtil.checkLicenseReserved(context,LibraryCentralConstants.LBC_ENG_PRODUCT_TRIGRAM);  
        		}        		
        		catch(Exception e)
        		{
					String errMsg = e.getMessage();
        			String strLicense = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(languageStr), "emxFramework.Login.License.Error");
        			String strRequiredStr = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(languageStr), "emxFramework.Default.Location_Status");
        			errMsg = errMsg + "\n" + strRequiredStr + " " + strLicense + ": CCM , PDE";
        			%>
        			<script language="javascript">
        			alert("<%=XSSUtil.encodeForJavaScript(context, errMsg)%>");        			
        			</script>
        			<%	return;
        		}
        		
        	}
        }
        if(! classificationMode.equals("removeClassification")) {
            String webFormName          = emxGetParameter(request,"form");
            String formHeader           = emxGetParameter(request,"formHeader");
            String helpMarker           = emxGetParameter(request,"HelpMarker");
            contentURL.append("../common/emxForm.jsp?mode=edit&form=");
            contentURL.append(webFormName);
            contentURL.append("&formHeader=");
            contentURL.append(formHeader);
            contentURL.append("&classificationMode=");
            contentURL.append(classificationMode);
            contentURL.append("&objectId=");
            contentURL.append(objectId);
            contentURL.append("&parentOID=");
            contentURL.append(parentOId);
            contentURL.append("&HelpMarker=");
            contentURL.append(helpMarker);
            contentURL.append("&formFieldsOnly=");
            contentURL.append(emxGetParameter(request,"formFieldsOnly"));
            contentURL.append("&suiteKey=");
            contentURL.append(emxGetParameter(request,"suiteKey"));
            contentURL.append("&StringResourceFileId=");
            contentURL.append(emxGetParameter(request,"StringResourceFileId"));
            contentURL.append("&SuiteDirectory=");
            contentURL.append(emxGetParameter(request,"SuiteDirectory"));
            contentURL.append("&selectedClassIds=");
            contentURL.append(selectedClassIds);
            contentURL.append("&postProcessURL=../documentcentral/emxLibraryCentralClassificationPostProcess.jsp?selectedClassIds=");
            contentURL.append(selectedClassIds);
            
            String selectedClassType = "";
            String selectedClassName = "";
            String canDisconnect = "true";
            
            if(classificationMode.equals("reClassification")){
                String selectedClassIdDetail = MqlUtil.mqlCommand(context,"print bus $1 select $2 $3 $4 dump $5", selectedClassIds, "current.access[fromdisconnect]", "type", "name", "|");
                String[] selectedClassIdDetails = selectedClassIdDetail.split("\\|");
                if(selectedClassIdDetails[0].equalsIgnoreCase("false") ){
                    canDisconnect = "falseOnReclassify";
                    selectedClassType = selectedClassIdDetails[1];
                    selectedClassName = selectedClassIdDetails[2];
                }
            }
            if(canDisconnect.equalsIgnoreCase("falseOnReclassify")){
%>
                    <script>
                        alert("<emxUtil:i18nScript localize="i18nId">emxLibraryCentral.Message.ObjectsNotReclassifiedNoFromDisconnectAccess</emxUtil:i18nScript>" +
                                "\n" + "<xss:encodeForJavaScript><%=selectedClassType%></xss:encodeForJavaScript>" +" "+"<xss:encodeForJavaScript><%=selectedClassName%></xss:encodeForJavaScript>");
                    </script>
<%
            }else{
%>
                    <script>
                        getTopWindow().showSlideInDialog("<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>",true);
                    </script>
<%                  
            }    
        } else {

            boolean isGoingToLoseAttributes = com.matrixone.apps.classification.Classification.checkIfItLosesAttributeOnRemovalOfClassification(context,selectedClassIds,objectId);
            contentURL.append("../documentcentral/emxLibraryCentralRemoveClassificationProcess.jsp?");
            contentURL.append("objectId=");
            contentURL.append(objectId);
            contentURL.append("&parentOID=");
            contentURL.append(parentOId);
            contentURL.append("&selectedClassIds=");
            contentURL.append(selectedClassIds);
            String strForwardPageUrl="emxLibraryCentralRemoveClassificationProcess.jsp";
%>
			<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTML(context,strForwardPageUrl)%>">
			<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
			<input type="hidden" name="objectId" value="<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>"/>
			<input type="hidden" name="parentOID" value="<xss:encodeForJavaScript><%=parentOId%></xss:encodeForJavaScript>"/>
			<input type="hidden" name="selectedClassIds" value="<xss:encodeForJavaScript><%=selectedClassIds%></xss:encodeForJavaScript>"/>
            <script>
                if ("<xss:encodeForJavaScript><%=isGoingToLoseAttributes%></xss:encodeForJavaScript>") {
                    if(confirm("<emxUtil:i18nScript localize="i18nId">emxLibraryCentral.Classification.Remove.ConfirmAttributesMessage</emxUtil:i18nScript>")) {
                        if(confirm("<emxUtil:i18nScript localize="i18nId">emxLibraryCentral.Classification.Remove.ConfirmMessage</emxUtil:i18nScript>")) {
                            <%-- document.location.href='<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>'; --%>
                            document.formForward.submit();
                        }
                    }
                }
            </script>
<%
        }
    }
    catch (Exception ex)
    {
        ex.printStackTrace();
    }

%>
