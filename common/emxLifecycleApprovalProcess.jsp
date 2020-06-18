<%--
  $Archive: emxLifecycleApprovalProcess.jsp $
  $Revision: 1.15.2.1 $
  $Author: ds-kvenkanna $

  Name of the File : emxLifecycleApprovalProcess.jsp

  Description : The processing page of the Approval dialog.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@ page import="com.matrixone.apps.domain.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
    // Get the required parameters from the request object.
    // These are busObjId, from and to states, the action which can be approve, reject, or ignore,
    // and Comment for signature.

    // Make sure that user has reentered the password and verify it against the database
    String loginPassword = emxGetParameter(request, "loginpassword");
    String sBusId = (String) emxGetParameter(request, "objectId");
    String sFromStateName = (String) emxGetParameter(request, "fromState");
    String sToStateName = (String) emxGetParameter(request, "toState");
    String sApprovalAction = (String) emxGetParameter(request, "approvalAction");
    String sSigner = (String) emxGetParameter(request, "signer");
    String sSignComment = (String) emxGetParameter(request, "txtareaCmtApp");
    String sIsInCurrentState = emxGetParameter(request, "isInCurrentState");
    String language = (String) request.getHeader("Accept-Language");
    //added for BUG 293393
	String sHasApprove   = emxGetParameter(request, "sHasApprove");
	String sHasReject    = emxGetParameter(request, "sHasReject");
	String sHasIgnore    = emxGetParameter(request, "sHasIgnore");
    String aradioChecked = "";
    String rradioChecked = "";
    String iradioChecked = "";
	if(sApprovalAction.equals("approve"))
	{
       aradioChecked="checked";
	}
	else if(sApprovalAction.equals("reject"))
	{
		rradioChecked="checked";
	}
	else if(sApprovalAction.equals("ignore"))
	{
		iradioChecked="checked";
	}


    String sApprovalPasswordConfirmation = EnoviaResourceBundle.getProperty(context, "emxFramework.LifeCycle.ApprovalPasswordConfirmation");
    String sExternalAuthentication = EnoviaResourceBundle.getProperty(context, "emxFramework.External.Authentication");
    boolean extAuth = false;

    if ((sExternalAuthentication != null) &&
        (!sExternalAuthentication.equalsIgnoreCase("null")) &&
        (sExternalAuthentication.equalsIgnoreCase("true")))
    {

        extAuth = true;
    }
    if (sApprovalPasswordConfirmation != null &&
        (!sApprovalPasswordConfirmation.equalsIgnoreCase("null")) &&
        sApprovalPasswordConfirmation.equalsIgnoreCase("true")) {
        if ((loginPassword != null) &&
            (!loginPassword.equalsIgnoreCase("null"))) {
			if (extAuth) {
                try {
                    HashMap creds = new HashMap();
                    creds.put("MX_PAM_USERNAME", context.getUser());
                    creds.put("MX_PAM_PASSWORD", loginPassword);
                    creds.put("MX_PAM_TENANT", context.getTenant());
                    Context ctx = new Context(":bos", "");
                    ctx.setCredentials(creds);
                    ctx.connect();
                    ctx.shutdown();
                } catch (Exception ex) {
                    StringBuffer url = new StringBuffer(80);
                    url.append("emxLifecycleApprovalDialog.jsp?signatureName=");
                    url.append(XSSUtil.encodeForURL(context, sSigner));
                    url.append("&fromState=");
                    url.append(XSSUtil.encodeForURL(context, sFromStateName));
                    url.append("&toState=");
                    url.append(XSSUtil.encodeForURL(context, sToStateName));
                    url.append("&isInCurrentState=");
                    url.append(XSSUtil.encodeForURL(context, sIsInCurrentState));
                    //added for BUG 293393
					url.append("&sHasApprove=");
                    url.append(XSSUtil.encodeForURL(context, sHasApprove));
                    url.append("&sHasReject=");
                    url.append(XSSUtil.encodeForURL(context, sHasReject));
                    url.append("&sHasIgnore=");
                    url.append(XSSUtil.encodeForURL(context, sHasIgnore));
					url.append("&sSignComment=");
                    url.append(XSSUtil.encodeForURL(context, sSignComment));
					url.append("&aradioChecked=");
                    url.append(aradioChecked);
					url.append("&rradioChecked=");
                    url.append(rradioChecked);
					url.append("&iradioChecked=");
                    url.append(iradioChecked);
                    emxNavErrorObject.addMessage(FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.InvalidPassword", language));
                    %><jsp:forward page="<%=url.toString()%>" /><%
                }
            } else {
                if (!loginPassword.equals(context.getPassword()))
                {
                    StringBuffer url = new StringBuffer(80);
                    url.append("emxLifecycleApprovalDialog.jsp?signatureName=");
                    url.append(XSSUtil.encodeForURL(context, sSigner));
                    url.append("&fromState=");
                    url.append(XSSUtil.encodeForURL(context, sFromStateName));
                    url.append("&toState=");
                    url.append(XSSUtil.encodeForURL(context, sToStateName));
                    url.append("&isInCurrentState=");
                    url.append(XSSUtil.encodeForURL(context, sIsInCurrentState));
                    //added for BUG 293393
					url.append("&sHasApprove=");
                    url.append(XSSUtil.encodeForURL(context, sHasApprove));
                    url.append("&sHasReject=");
                    url.append(XSSUtil.encodeForURL(context, sHasReject));
                    url.append("&sHasIgnore=");
                    url.append(XSSUtil.encodeForURL(context, sHasIgnore));
					url.append("&sSignComment=");
                    url.append(XSSUtil.encodeForURL(context, sSignComment));
					url.append("&aradioChecked=");
                    url.append(aradioChecked);
					url.append("&rradioChecked=");
                    url.append(rradioChecked);
					url.append("&iradioChecked=");
                    url.append(iradioChecked);
                    emxNavErrorObject.addMessage(FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.InvalidPassword", language));
                    %>
					<!-- //XSSOK -->
					<jsp:forward page="<%=url.toString()%>" />
					<%
	               }
            }
        }
    }
%>


<%
    DomainObject bo = DomainObject.newInstance(context,sBusId);
    String currentStateBefore = (String)bo.getInfo(context, DomainConstants.SELECT_CURRENT);

    try {
    	if(sSignComment != null && (sSignComment.indexOf("\"") >= 0)){
        	sSignComment = FrameworkUtil.findAndReplace(sSignComment, "\"", "\\\"");
        }
        String strQueryResult = MqlUtil.mqlCommand(context,"escape $1 bus $2 signature $3 comment $4",sApprovalAction,sBusId,sSigner,sSignComment);
       
    } catch (MatrixException me) {
        // ContextUtil.abortTransaction(context);
        if (me.toString() != null && (me.toString().trim()).length() > 0){
        	String strErrorMessage = me.toString().trim();
        	String strCustomMessage = "CustomMessage";
        	if(strErrorMessage.indexOf(strCustomMessage)>=0){
        		strErrorMessage = strErrorMessage.substring(strErrorMessage.lastIndexOf(strCustomMessage)+strCustomMessage.length());
        	}
            emxNavErrorObject.addMessage(strErrorMessage);
        }
        // Throw the exception again to stop any further processing
        // throw e;
    } catch (Exception ex) {
        // ContextUtil.abortTransaction(context);
        if (ex.toString() != null && (ex.toString().trim()).length() > 0){
        	String strErrorMessage = ex.toString().trim();
        	String strCustomMessage = "CustomMessage";
        	if(strErrorMessage.indexOf(strCustomMessage)>=0){
        		strErrorMessage = strErrorMessage.substring(strErrorMessage.lastIndexOf(strCustomMessage)+strCustomMessage.length());
        	}
            emxNavErrorObject.addMessage(ex.toString().trim());
        }
        // Throw the exception again to stop any further processing
        // throw e;
    } finally {// /ContextUtil.commitTransaction(context);
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


<script language="javascript">
//
// This dialog page to approve/reject/ignore lifecycle signature is being opened from 2 places.
// 1. From the Tasks/Signature table page's link in table cell
// 2. From the popped up lifeycle signature page
// The earlier functionality of refreshing the lifeycle page in case the state has changed due to auto-promote is
// no more supported, because of the different locations opening this page.
//

<%
	try{
		String initargs[] = {};
		HashMap paramsJPO = new HashMap();
		paramsJPO.put("objectId", sBusId);		
		paramsJPO.put("language", language);
		paramsJPO.put("content", "status");	
		String[] aResult = (String[])JPO.invoke(context, "emxExtendedHeader", initargs, "genHeaderFromJSP", JPO.packArgs (paramsJPO), String[].class);
		
%>
        var frameName;
	if(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener()){
			frameName = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow();
		}	
		else if(getTopWindow().getWindowOpener()) {
			frameName = getTopWindow().getWindowOpener().getTopWindow();			
		}
        getTopWindow().jQuery(frameName.document).find('#extendedHeaderStatus').html("<%= XSSUtil.encodeForJavaScript(context, aResult[0])%>");
		getTopWindow().jQuery(frameName.document).find('#headerDropZone').css('display',"<%= XSSUtil.encodeForHTML(context, aResult[1])%>");
	    if(frameName.deletePageCache){
		      frameName.deletePageCache();
	}
<%
	}catch (Exception e) {
			e.printStackTrace();
	}
%>

// Refresh the getWindowOpener()'s parent page is present, if no parent page then
// refresh the getWindowOpener() page itself and close this window
// Modified for Bug 368319
if (getTopWindow().getWindowOpener())
    {
		if(getTopWindow().getWindowOpener().getTopWindow().RefreshHeader) {
	          getTopWindow().getWindowOpener().getTopWindow().RefreshHeader();
       	 }
		else if(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().RefreshHeader){
			getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().RefreshHeader();
		}
        if (getTopWindow().getWindowOpener().refreshSignatureTable)
        {
            getTopWindow().getWindowOpener().refreshSignatureTable();
        }
	else if (getTopWindow().getWindowOpener().parent)
        {
		var parentFrame = getTopWindow().getWindowOpener().findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
		var targetFrame = parentFrame.findFrame(parentFrame,"portalDisplay");
    		if(targetFrame != null) {
    			targetFrame.location.href = targetFrame.location.href;
        	}
    		else {
				getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
        	}
			
			//
			// Actually, if the execution comes here then it should be the table page inside a portal tab.
			// For refreshing table page, the method parent.window.getWindowOpener().parent.refreshTableBody() can be called
			// but this does not refresh the contents of the table, so above way of refreshing is used.
			//
		}
		else
        {
			getTopWindow().getWindowOpener().location.reload();
		}
	}

	getTopWindow().closeWindow();
</script>

</html>

