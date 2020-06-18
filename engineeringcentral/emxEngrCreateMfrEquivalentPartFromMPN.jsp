<%--  emxEngrCreateMfrEquivalentPartFromMPN   - Processing page to create a MEP part from MPN
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "emxDesignTopInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="JavaScript">
var exception=false;
</script>
<%
//    String type   = DomainConstants.TYPE_PART;
    String type   = emxGetParameter(request,"partType");
    String partNum   =     emxGetParameter(request,"partNum");
    String revision   =     emxGetParameter(request,"rev");
    String policy   =     emxGetParameter(request,"policy");
    String description   =     emxGetParameter(request,"description");

    String objectId   =     emxGetParameter(request,"objectId");

    // get the request attributes from previous screen
    String suiteKey       = emxGetParameter(request,"suiteKey");
    String jsTreeID       = emxGetParameter(request, "jsTreeID");

    boolean isContextPushed = false;
    try {

            ContextUtil.startTransaction(context, true);

            if ( policy == null || "".equals(policy))
            {
                policy = DomainConstants.POLICY_MANUFACTURER_EQUIVALENT;
            }

            if ( revision == null || revision.equals("") || revision.equals("None"))
            {
                Policy policyObj = new Policy (policy);
                policyObj.open(context);

                if (policyObj.hasSequence())
                {
                  revision = policyObj.getFirstInSequence();
                }
                else
                {
                  revision = "";
                }
            }

             BusinessObject tempObj = new BusinessObject(objectId);
             tempObj.open(context);
             ContextUtil.pushContext(context);
             isContextPushed = true;
             tempObj.change(context,type,partNum,revision,tempObj.getVault(),policy);
             tempObj.close(context);

            DomainObject dom = new DomainObject(objectId);
            if(description != null && !description.equals("")) {
                dom.setDescription(context, description);
            }

        ContextUtil.commitTransaction(context);
    }
    catch (Exception e)
    {
        ContextUtil.abortTransaction(context);
        //session.putValue("error.message",e.toString());
        if (e.toString() != null && (e.toString().trim()).length() > 0){
        	emxNavErrorObject.addMessage(e.toString().trim());
    	}
        
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="JavaScript">
            exception=true;
</script>
<%
    }
  finally{
     if (isContextPushed)
             ContextUtil.popContext(context);
     }

%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">

if(exception) {
	var objLocation = findFrame(getTopWindow(), "slideInFrame");
	if (objLocation) {
		//XSSOK
		objLocation.location.href = "emxEngrCreateMfrEquivalentPartFromMPNDialogFS.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>"
	} else {
		//XSSOK
    	getTopWindow().location.href="emxEngrCreateMfrEquivalentPartFromMPNDialogFS.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>"
	}
} else {
	var frameENCEquivalents = findFrame(getTopWindow(), "portalDisplay") == null ? findFrame(getTopWindow(), "content") : findFrame(getTopWindow(), "portalDisplay").frames[0];
	
	if (frameENCEquivalents != null) {	
		frameENCEquivalents.location.href = frameENCEquivalents.location.href; 
		getTopWindow().closeSlideInDialog();
	}
}

  </script>





