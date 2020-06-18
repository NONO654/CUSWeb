<%--  emxLifecycleProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycleProcess.jsp.rca 1.20 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.framework.lifecycle.LifeCycleUtil"%>
<html>
<%@include file="emxNavigatorTopErrorInclude.inc"%>

<%
    String sCommand = (String) emxGetParameter(request, "cmd");
    String header       = (String) emxGetParameter(request, "header");
    String helpMarker   = (String) emxGetParameter(request, "HelpMarker");
    String sErrorMsg = "";
    String toolbar = (String) emxGetParameter(request, "toolbar");
    String export = (String) emxGetParameter(request, "export");
    String portalMode = (String) emxGetParameter(request, "portalMode");
    String postProcessPage = (String) emxGetParameter(request, "postProcessPage");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String categoryTreeName = emxGetParameter(request, "categoryTreeName");

    boolean treeRefresh = false;

    // Here, we figure out the "package" (i.e. engineering, sourcing, program etc),
    // to be used for DomainObject.newInstance().  This is done by checking for
    // the parameter "packageName".  Default to common if parameter is not passed.
    //
    String sPackage = (String)emxGetParameter(request, "packageName");

    if(sPackage == null || sPackage.trim().length()==0){
        sPackage = "common";
    }

    String objectId = emxGetParameter(request, "objectId");
    boolean statusFlag = true;

    try
    {
        DomainObject bo = DomainObject.newInstance(context,objectId,sPackage);
        String strKindOfPLMEntity = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_PLMEntity") +"]";
        StringList selectList = new StringList();
        selectList.addElement(DomainConstants.SELECT_CURRENT);
        selectList.addElement(strKindOfPLMEntity);
        String symbolictype = FrameworkUtil.getAliasForAdmin(context, "type", bo.getInfo(context, bo.SELECT_TYPE), true);

        Map objectDetails = bo.getInfo(context, selectList);
        String sIsVPLMEntity  = (String)objectDetails.get(strKindOfPLMEntity); 
        // This is for validation only. Check if the current state the user is viewing is actually the same as in database.
        String sActualCurrentStateName = (String)objectDetails.get(DomainConstants.SELECT_CURRENT);
        if("TRUE".equalsIgnoreCase(sIsVPLMEntity)){
        	String strCantPromoteType  = UINavigatorUtil.getI18nString("emxFramework.Type.PLMEntity.Engineering","emxFrameworkStringResource",request.getHeader("Accept-Language"));
        	throw new MatrixException(strCantPromoteType);
        }
        //if command is promote
        if (sCommand.equals("promote"))
        {
            try
            {
                com.matrixone.apps.framework.lifecycle.LifeCycleUtil.checksToPromoteObject(context, bo);
                bo.promote(context);

                // This condition is added specially for PMC
                if("type_ProjectConcept".equals(symbolictype) && "Review".equalsIgnoreCase(sActualCurrentStateName)) {
                    treeRefresh = true;
                }
            }
            catch (MatrixException me)
            {
            	String stringPromotionErrorMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed.ErrorMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
                String stringPromotionMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed","emxFrameworkStringResource",request.getHeader("Accept-Language"));
                boolean clientTaskMessagesExists = false;

                clientTaskMessagesExists = MqlNoticeUtil.checkIfClientTaskMessageExists(context);
                if (!clientTaskMessagesExists) {
                int errCode = 0;
                ErrorMessage mxErrMsg = null;
                Vector meMessages = me.getMessages();
                if (meMessages != null) {
                    mxErrMsg = (ErrorMessage) meMessages.get(0);
                    if (mxErrMsg != null)
                        errCode = mxErrMsg.getErrorCode();
                }

                if (errCode == 5000001) {
                    sErrorMsg = mxErrMsg.getMessage();
                    int pos = sErrorMsg.indexOf("#5000001:");
                    if (pos > -1) {
                        sErrorMsg = sErrorMsg.substring(pos + 9).trim();
                    }
                }
                if (sErrorMsg == null || sErrorMsg.length() == 0) {
                    sErrorMsg = stringPromotionErrorMsg;
                } else {
                    sErrorMsg = stringPromotionMsg + sErrorMsg;
                }

                statusFlag = false;

                if ((sErrorMsg.toString() != null)
                        && (sErrorMsg.toString().trim()).length() > 0) {
                    emxNavErrorObject.addMessage(sErrorMsg.toString()
                            .trim());
                }
            
            } else {
					LifeCycleUtil.reorganizeClientTaskMessages(context, stringPromotionMsg);
            }
				
            }
        }

        if (sCommand.equals("demote"))
        {
            try
            {
                bo.demote(context);
            }
            catch (MatrixException me)
            {
                // SLM incident 360126
                // Check if this is System Error: #5000001.
                // In an attempt to send back a specific error message,
                // the application may have thown an exception
                // from a check trigger. This exception gets reported
                // from the kernel as System Error: #5000001.
                // In this case, use the message of the exception.
                String stringDemotionErrorMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.DemotionFailed.ErrorMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
                String stringDemotionMsg = UINavigatorUtil.getI18nString("emxFramework.LifeCycle.DemotionFailed","emxFrameworkStringResource",request.getHeader("Accept-Language"));
                int errCode = 0;
                ErrorMessage mxErrMsg = null;
                Vector meMessages = me.getMessages();
				boolean clientTaskMessagesExists = false;
				clientTaskMessagesExists = MqlNoticeUtil.checkIfClientTaskMessageExists(context);
				if (!clientTaskMessagesExists) {
                if (meMessages != null){
                    mxErrMsg = (ErrorMessage)meMessages.get(0);
                    if (mxErrMsg != null)
                        errCode = mxErrMsg.getErrorCode();
                }

                if (errCode == 5000001)
                {
                    sErrorMsg = mxErrMsg.getMessage();
                    int pos = sErrorMsg.indexOf("#5000001:");
                    if (pos > -1)
                    {
                        sErrorMsg = sErrorMsg.substring(pos+9).trim();
                    }
                }
                if (sErrorMsg == null || sErrorMsg.length() == 0)
                {
                  sErrorMsg = stringDemotionErrorMsg;
                }
                else
                {
                    sErrorMsg = stringDemotionMsg + sErrorMsg;
                }

                 statusFlag = false;
                 if( ( sErrorMsg.toString()!=null )
                    && (sErrorMsg.toString().trim()).length()>0)
                 {
                    emxNavErrorObject.addMessage(sErrorMsg.toString().trim());
                 }
            } else {
					LifeCycleUtil.reorganizeClientTaskMessages(context, stringDemotionMsg);
            }
            }
        }
    }
    catch(Exception ex)
    {
        statusFlag = false;
        if( ( ex.toString()!=null )
            && (ex.toString().trim()).length()>0 )
            emxNavErrorObject.addMessage(ex.toString().trim());
    }

    StringBuffer url = new StringBuffer(100);
    url.append("emxLifecycle.jsp?objectId=");
    url.append(XSSUtil.encodeForURL(context, objectId));
    url.append("&cmd=none");
    url.append("&toolbar=");
    url.append(XSSUtil.encodeForURL(context, toolbar));
    url.append("&header=");
    url.append(XSSUtil.encodeForURL(context, header));
    url.append("&HelpMarker=");
    url.append(XSSUtil.encodeForURL(context, helpMarker));
    url.append("&export=");
    url.append(XSSUtil.encodeForURL(context, export));
    url.append("&packageName=");
    url.append(XSSUtil.encodeForURL(context, sPackage));
    url.append("&suiteKey=").append(XSSUtil.encodeForURL(context, suiteKey));
    if(categoryTreeName != null && !"null".equalsIgnoreCase(categoryTreeName.trim()) && categoryTreeName.trim().length() > 0) {
        url.append("&categoryTreeName=");
        url.append(XSSUtil.encodeForURL(context, categoryTreeName));
    }
    
    if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
      url.append("&portalMode=");
      url.append(XSSUtil.encodeForURL(context, portalMode));
    }
%>
<head>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</head>

<body class="content" onload="turnOffProgress();">
<form name="lifecycleProcess" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
<%
    //take all params passed in and draw hidden fields
    Enumeration eNumParameters = emxGetParameterNames(request);
    while( eNumParameters.hasMoreElements() )
    {
        String strParamName = (String)eNumParameters.nextElement();

        // If the parameter contains multiple values, create multiple hidden
        // fields so that all the values are retained
        String strParamValues[] = emxGetParameterValues(request, strParamName);

        if (strParamValues != null)
        {
            for (int iCount=0; iCount<strParamValues.length; iCount++)
            {
%>
<input type="hidden" name="<xss:encodeForHTMLAttribute><%=strParamName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=strParamValues[iCount]%></xss:encodeForHTMLAttribute>"/>
<%
            }
        }
    }
%>
</form>

<script language="JavaScript">
<%
if (statusFlag)
{
	try{
		String initargs[] = {};
		HashMap paramsJPO = new HashMap();
		paramsJPO.put("objectId",objectId);		
		paramsJPO.put("language",(String)request.getHeader("Accept-Language"));
		paramsJPO.put("content", "status");	
		paramsJPO.put("timezone",(String)session.getAttribute("timeZone"));
		String[] aResult = (String[])JPO.invoke(context, "emxExtendedHeader", initargs, "genHeaderFromJSP", JPO.packArgs (paramsJPO), String[].class);
		
		%>		
		jQuery(getTopWindow().document).find('#extendedHeaderStatus').html("<%= XSSUtil.encodeForJavaScript(context, aResult[0])%>");
		jQuery(getTopWindow().document).find('#extendedHeaderModified').html("<%= XSSUtil.encodeForJavaScript(context, aResult[4])%>");
		
		jQuery(getTopWindow().document).find('#headerDropZone').css('display',"<%= XSSUtil.encodeForHTML(context, aResult[1])%>");
	    if(getTopWindow().deletePageCache){
			getTopWindow().deletePageCache();
		}	
		<%
	}catch (Exception e) {
			e.printStackTrace();
	}
    //post processing
    if(postProcessPage != null && !"".equals(postProcessPage) && !"null".equals(postProcessPage))
    {
%>
        var hidLifecycleFrm = getTopWindow().findFrame(getTopWindow(), "hiddenLifecycle");
        if(hidLifecycleFrm)
        {
            hidLifecycleFrm.document.lifecycleProcess.action= "<xss:encodeForJavaScript><%=postProcessPage%></xss:encodeForJavaScript>";
            hidLifecycleFrm.document.lifecycleProcess.submit();
        }
<%
    }
    // This Condition is specially added for PMC to refresh the tree.
    else if(treeRefresh) {
        String appDirectory = EnoviaResourceBundle.getProperty(context, "eServiceSuiteProgramCentral.Directory");
%>

        var treeDisplayFrame = findFrame(getTopWindow(), "content");
        if(treeDisplayFrame == null)
        {
      		getTopWindow().getWindowOpener().document.location.href = "emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&DefaultCategory=PMCLifecycle&emxSuiteDirectory=<%=appDirectory%>";
        	getTopWindow().closeWindow();
        }
        else {
        treeDisplayFrame.document.location.href = "emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&DefaultCategory=PMCLifecycle&emxSuiteDirectory=<%=appDirectory%>";
        }
<%
    } else {
%>
        //XSSOK
        parent.location = "<%=url.toString()%>";
<%
        //Below is the fix for IR-115668V6R2012x, Refresh the Tasks/Signatures and Approvals channels if there is a promotion / demotion
        if("true".equalsIgnoreCase(portalMode)){
%>
            var taskSignatureTableFrame = findFrame(getTopWindow(),"AEFLifecycleTaskSignatures");
            if(taskSignatureTableFrame){
            	taskSignatureTableFrame.document.location.href = taskSignatureTableFrame.document.location.href;
            }
            var approvalsTableFrame = findFrame(getTopWindow(),"AEFLifecycleApprovals");
            if(approvalsTableFrame){
            	approvalsTableFrame.document.location.href = approvalsTableFrame.document.location.href;
            }
<%
        }// end of fix for 115668V6R2012x
    }
} else {
%>
    // enable the link
    parent.clicked = false;
<%
}
%>
</script>

</body>

</html>

