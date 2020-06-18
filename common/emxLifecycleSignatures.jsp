<%--

  $Archive: emxLifecycleSignatures.jsp $
  $Revision: 1.15 $
  $Author: przemek $

  Name of the File : emxLifecycleSignatures.jsp

  Description : The frame where the signatures of the business obj are displayed
                for the given states.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%!
public boolean isRoleOrGroup(Context context,String roleOrGroupName, String sSignName) throws matrix.util.MatrixException {
    
  
    String sResult = MqlUtil.mqlCommand(context,"list $1 $2",roleOrGroupName,sSignName);
    if(sResult.equals("")){
        return false;
    }
    return true;
}
%>
<%
    // Get the Business Id and create a BusinessObject
    // Get the from and to States names.
    //
    String languageStr       = request.getHeader("Accept-Language");
    String sBusId            = emxGetParameter(request, "objectId");
    String sFromStateName    = emxGetParameter(request, "fromState");
    String sToStateName      = emxGetParameter(request, "toState");
    String sIsInCurrentState = emxGetParameter(request, "isInCurrentState");
    String sTargetPage        = "FSGenericDetails.jsp";
    Boolean BIsInCurrentState = Boolean.valueOf(sIsInCurrentState);
    boolean isInCurrentState  = BIsInCurrentState.booleanValue();
    String sErrorMessage      = (String)request.getAttribute("errMsg");
    String sStatePolicyName   = null;

    // Here, we figure out the "package" (i.e. engineering, sourcing, program etc),
    // to be used for DomainObject.newInstance().  This is done by checking for
    // the parameter "packageName".  Default to common if parameter is not passed.
    //
    String sPackage = (String)emxGetParameter(request, "packageName");
    if(sPackage == null || sPackage.trim().length()==0){
        sPackage = "common";
    }

	String strHelpMarker = "emxhelplifecycleapprovals";

    BusinessObject busObject = new BusinessObject(sBusId);
    boolean isObjectValid = true;
    try
    {
      busObject.open(context);
      sStatePolicyName = ((Policy)(busObject.getPolicy(context))).getName();
    }
    catch (Exception e)
    {
      isObjectValid = false;
    }
    String sDisplayState = " : "
        + i18nNow.getStateI18NString(sStatePolicyName,sFromStateName,languageStr);
%>
    <html>
    <head>
    <title><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Life_Cycle_Signatures</emxUtil:i18n></title>
    <%@include file = "emxUIConstantsInclude.inc"%>
  	<script language="JavaScript" type="text/javascript" src="scripts/emxUIToolbar.js"></script>
   
        <script type="text/javascript">
        	addStyleSheet("emxUIDefault");
			addStyleSheet("emxUIDialog");
    		addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIMenu");
            addStyleSheet("emxUIDOMLayout");
            addStyleSheet("emxUIList");            
        </script>
<script>
// Added for bug 368319
// To validate whether the approval page has opened from Lifecycle Signature link or not. If true then 
// refresh the lifecycle page.
function refreshSignatureTable()
{
    if (getTopWindow().getWindowOpener())
    {
    	var targetFrame = this.findFrame(getTopWindow().getWindowOpener().getTopWindow(),"portalDisplay");
    	if(targetFrame != null) {
    		targetFrame.location.href = targetFrame.location.href;
        }
    	else {
			getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        }
	}

    getTopWindow().closeWindow();
    return true; 
}
</script>

   <script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
   <script language="JavaScript" src="../emxUIPageUtility.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
  <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
    </head>

<body class='dialog no-footer'>
<div id="pageHeadDiv">
<form name="tableHeaderForm">
   <table>
     <tr>
    <td class="page-title">
      <h2><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Approvals</emxUtil:i18n><xss:encodeForHTML><%=sDisplayState%></xss:encodeForHTML></h2>
    </td>
        <td class="functions">
        </td>
        </tr>
        </table>

<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, sBusId)%>"/>
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="export" value="false"/> 
	<jsp:param name="HelpMarker" value="<%=strHelpMarker%>"/>   
</jsp:include>
</form>
</div><!-- /#pageHeadDiv -->

<div id="divPageBody">
<%
    try
    {
        //Starts Database transaction
        ContextUtil.startTransaction(context,false);

        if (isObjectValid)
        {
            StateList stateList = busObject.getStates(context);
            StateItr stateItr = new StateItr(stateList);

            State toState = null;
            State fromState = null;
            State state = null;

            while (stateItr.next())
            {
                state = stateItr.obj();
                String stateName = state.getName();
                if (stateName.equals(sFromStateName))
                {
                  fromState = state;
                  isInCurrentState = state.isCurrent();
                  sIsInCurrentState = Boolean.toString(isInCurrentState);
                }
                if (stateName.equals(sToStateName))
                {
                  toState = state;
                }
            }

            //Get signatures' details information for this object
          DomainObject dmObj = DomainObject.newInstance(context,sBusId,sPackage);

            MapList signatureList = dmObj.getSignaturesDetails(context,fromState,toState);
            
            if (signatureList != null && signatureList.size() > 0)
            {
                Iterator signatureItr = signatureList.iterator();
%>
        <table border="0" class='list'>
        <tr>
          <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Signature</emxUtil:i18n></th>
          <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Signer</emxUtil:i18n></th>
          <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Comments</emxUtil:i18n></th>
          <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Response</emxUtil:i18n></th>
        </tr>
<%
                // check if there was any error while processing the actions
                if((sErrorMessage != null)&&(!sErrorMessage.equalsIgnoreCase("null")))
                {
%>
          <tr>
            <td colspan="6">
              <font color=red><b><emxUtil:i18n localize="i18nId"><xss:encodeForHTML><%=sErrorMessage%></xss:encodeForHTML></emxUtil:i18n></b></font>
            </td>
          </tr>  
<%
                }

                String nextURL = null;
                int iOddEvenApproval = 1;
                String sRowClassApproval = "";
                String sHasApprove = "TRUE";
                String sHasReject = "TRUE";
                String sHasIgnore = "TRUE";

                while (signatureItr.hasNext())
                {                   
                    Map signatureMap = (Map) signatureItr.next();                    
                    String sSignStatus = "";

                    // check for the role or group in signature
                    boolean isRoleOrGroup = true;
                    String userObj = "";
                    String displayString = "";

                    if ("TRUE".equalsIgnoreCase((String)signatureMap.get("signed")))
                    {
                        if ("TRUE".equalsIgnoreCase((String)signatureMap.get("approved")))
                            sSignStatus = FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.Approved",
                                languageStr);
                        else if ("TRUE".equalsIgnoreCase((String)signatureMap.get("ignored")))
                            sSignStatus = FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.Ignored",
                                languageStr);
                        else if ("TRUE".equalsIgnoreCase((String)signatureMap.get("rejected")))
                            sSignStatus = FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.Rejected",
                                languageStr);
                        else
                          sSignStatus = FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.Signed",
                            languageStr);
                    }

                    //Define display variables
                    String sSignName = (String)signatureMap.get("name");
                    String sSigner = (String)signatureMap.get("signer");
                    String sSignDesc = (String)signatureMap.get("comment");
                    sHasApprove = (String)signatureMap.get("hasapprove");
                    sHasReject = (String)signatureMap.get("hasreject");
                    sHasIgnore = (String)signatureMap.get("hasignore");
                    String updatedStrName=sSignName.replace(' ', '_');
                    boolean showSigLink = false;

                    if("TRUE".equalsIgnoreCase(sHasApprove) ||
                       "TRUE".equalsIgnoreCase(sHasReject) ||
                       "TRUE".equalsIgnoreCase(sHasIgnore))
                    {
                        showSigLink = true;
                    }
                    // Checking whether the sSignName is a Role, if not, check whether it is a Group.
                    // If the signature name is a Role or a Group, form the key and get the corresponding value.
                    // If signature is not Role/Grouup, display as it is.
                    userObj = "Role";
                    if(!isRoleOrGroup(context,userObj,sSignName)){
                        userObj = "Group";
                        isRoleOrGroup = isRoleOrGroup(context,userObj,sSignName);
                    }
					if (isRoleOrGroup) {
                        String propertyName = "emxFramework."+userObj+"."+sSignName.replace(' ', '_');
                        displayString = FrameworkUtil.i18nStringNow(propertyName,languageStr);
                    }
					sRowClassApproval = (iOddEvenApproval%2 == 0) ? "even" : "odd";
                    iOddEvenApproval++;

                    StringBuffer nextURLBuffer = new StringBuffer(150);
                    nextURLBuffer.append("emxLifecycleApprovalDialogFS.jsp?objectId=");
                    nextURLBuffer.append(sBusId);
                    nextURLBuffer.append("&signatureName=");
                    String updatedString= "emxFramework.Lifecycle."+updatedStrName;
                    String returnString = UINavigatorUtil.getI18nString(updatedString,"emxFrameworkStringResource", languageStr);
                    nextURLBuffer.append(sSignName);  
                    nextURLBuffer.append("&toState=");
                    nextURLBuffer.append(sToStateName);
                    nextURLBuffer.append("&fromState=");
                    nextURLBuffer.append(sFromStateName);
                    nextURLBuffer.append("&isInCurrentState=");
                    nextURLBuffer.append(sIsInCurrentState);
                    nextURLBuffer.append("&sHasApprove=");
                    nextURLBuffer.append(sHasApprove);
                    nextURLBuffer.append("&sHasReject=");
                    nextURLBuffer.append(sHasReject);
                    nextURLBuffer.append("&sHasIgnore=");
                    nextURLBuffer.append(sHasIgnore);                   
                    nextURL = FrameworkUtil.encodeHref(request, nextURLBuffer.toString());
%>
      <!-- //XSSOK -->
      <tr class="<%=sRowClassApproval%>">
        <td>
<%
                if (isInCurrentState)
                {
                   if(showSigLink){
%>
                      <!-- //XSSOK -->
                      <a href="javascript:emxShowModalDialog('<%=nextURL%>',500,400,false)">
<%                 } 
%>
                        <img border="0" src="images/iconSmallSignature.gif" align="middle" />
                        
<%                 if(showSigLink){
%>                   
                      </a>&nbsp;
 
                      <!-- //XSSOK -->
                      <a href="javascript:emxShowModalDialog('<%=nextURL%>',500,400,false)">
<%                 }
                   
                   if (isRoleOrGroup) {
%>
                        <!-- //XSSOK -->
                        <%= displayString%>
<%                    } else  {                        
                        if((returnString.indexOf("emxFramework")!= -1) ||(returnString==null) ||("".equals(returnString)) ) {
%>                           
                            <%= XSSUtil.encodeForHTML(context, sSignName)%> 
 <%                       }
                        else{
%>                       
                            <!-- //XSSOK -->
                            <%= returnString%>
<%                          
                            }
%>
<%                    }                    
                    if(showSigLink){                    
%>
                      </a>
<%                  }                    
                }
                else
                {
%>
                    <img border="0" src="images/iconSmallSignature.gif" align="middle" /></a>&nbsp;
<%
                    if (isRoleOrGroup) {
%>
                       <!-- //XSSOK -->
                       <%= displayString%>
<%                    } else  {                        
                        if((returnString.indexOf("emxFramework")!= -1) ||(returnString==null) ||("".equals(returnString)) ) {
%>                           
                               <%= XSSUtil.encodeForHTML(context, sSignName)%> 
<%                       }
                        else{
%>                       
                             <!-- //XSSOK -->
                             <%= returnString%>
<%                          
                             }
%>
<%                    }
%>
                    </a>
<%
                 }
%>
        </td>
        <td><%=XSSUtil.encodeForHTML(context, sSigner)%>&nbsp;</td>
        <td><pre><%=XSSUtil.encodeForHTML(context, sSignDesc)%>&nbsp;</pre></td>
        <td><%=XSSUtil.encodeForHTML(context, sSignStatus)%>&nbsp;</td>
      </tr>
<%
                } //End of while (signatureItr.next())
%>
        </table>
<%
            } // end of if (signatureList != null && signatureList.size() > 0)
        } // end outer if (isObjectValid)

        ContextUtil.commitTransaction(context);
    }
    catch(Exception e)
    {
        ContextUtil.abortTransaction(context);
        String sErrorDetails = e.getMessage();
%>
<script language="JavaScript">
//XSSOK
    showError("<%=sErrorDetails%>");
</script>
<%
    }
    finally
  {
  }
%>
</div>
</body>
    </html>


