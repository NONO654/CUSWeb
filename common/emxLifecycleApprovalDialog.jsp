<%--

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxLifecycleApprovalDialog.jsp.rca 1.12 Wed Oct 22 15:48:21 2008 przemek Experimental przemek $

--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxJSValidation.inc" %>

<%
  String languageStr       = request.getHeader("Accept-Language");
  String jsTreeID          = emxGetParameter(request,"jsTreeID");
  String objectId          = emxGetParameter(request,"objectId");
  String initSource        = emxGetParameter(request,"initSource");
  String suiteKey          = emxGetParameter(request,"suiteKey");
  String sSigner           = emxGetParameter(request, "signatureName");
  String toState           = emxGetParameter(request, "toState");
  String fromState         = emxGetParameter(request, "fromState");
  String isInCurrentState  = emxGetParameter(request, "isInCurrentState");
  String sHasApprove       = emxGetParameter(request, "sHasApprove");
  String sHasReject        = emxGetParameter(request, "sHasReject");
  String sHasIgnore        = emxGetParameter(request, "sHasIgnore");
  String sApprovalPasswordConfirmation = EnoviaResourceBundle.getProperty(context, "emxFramework.LifeCycle.ApprovalPasswordConfirmation");
  //added for BUG 293393
  String aradioChecked     = emxGetParameter(request, "aradioChecked");
  String rradioChecked     = emxGetParameter(request, "rradioChecked");
  String iradioChecked     = emxGetParameter(request, "iradioChecked");
  String sSignComment      = emxGetParameter(request, "sSignComment");
  if(sSignComment == null || "null".equals(sSignComment) || !(sSignComment.length() > 0))
  {
	  sSignComment="";
  }
  /*if(aradioChecked == null || "null".equals(aradioChecked) || !(aradioChecked.length() > 0))
  {
	  aradioChecked="";
  }
  if(rradioChecked == null || "null".equals(rradioChecked) || !(rradioChecked.length() > 0))
  {
	  aradioChecked="";
  }
  if(iradioChecked == null || "null".equals(iradioChecked) || !(iradioChecked.length() > 0))
  {
	  iradioChecked="";
  }*/
  boolean isRoleOrGroup = true;
  String userObj = "";
  String displayString = "";
  try {
	Role roleObj = new Role(sSigner);
	roleObj.open(context);
	userObj = "Role";
	roleObj.close(context);
  } catch (MatrixException me){
	isRoleOrGroup = false;
  }
  if (!isRoleOrGroup){
	try {
		Group groupObj = new Group(sSigner);
		groupObj.open(context);
		userObj = "Group";
		groupObj.close(context);
		isRoleOrGroup = true;
	}
	catch (MatrixException me){
		isRoleOrGroup = false;
	}
  }
  if (isRoleOrGroup) {
	String propertyName = "emxFramework."+userObj+"."+sSigner.replace(' ', '_');
	displayString = FrameworkUtil.i18nStringNow(propertyName,languageStr);
  }

  %>


<script language="JavaScript">
  var loginpassword = '';
  function checkInput() {
    var bSelected = false;

    for(var i=0 ; i < document.approvalForm.elements.length; i++)
    {
       var obj = document.approvalForm.elements[i];
       if(obj.type == "radio" && obj.checked == true)
       {
           bSelected = true;
           break;
       }
    }

    if(!bSelected)
    {
       var msg = "<%=FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.PleaseMakeASelection",
                                   request.getHeader("Accept-Language"))%>";
       alert(msg);
    }
    else 
    {
	
<%
        if(sApprovalPasswordConfirmation.equalsIgnoreCase("TRUE"))
        {
%>
            var url = "emxPasswordPopupFS.jsp?callbackFunctionName=passwordCallback()";
            //Modified for IR-154822V6R2013x
			showModalDialog(url, 300, 350, false, "Small");
<%
        }
        else
        {
%>
   if (jsDblClick()){
    document.approvalForm.submit();
    }
<%
        }
%>
    }
  }

  function passwordCallback() {
    document.approvalForm.loginpassword.value=loginpassword;
    document.approvalForm.submit();

  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="approvalForm" method="post" onsubmit="checkInput(); return false" action="emxLifecycleApprovalProcess.jsp">
<script language="JavaScript">
	document.body.style.overflow = 'hidden'; //Hide the Vertical Scrollbar
</script>
<table border="0" cellpadding="3" cellspacing="2" width="100%">
  <tr>
    <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Approval</emxUtil:i18n></td>
    <td class="inputField">
      <table border="0">
        <tr>
          <td><img alt="*" src="images/iconSmallSignature.gif" /></td>
          <td><span class="object"><xss:encodeForHTML><%=displayString%></xss:encodeForHTML></span></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Comments</emxUtil:i18n></td>
    <td class="inputField"><textarea cols="25" rows="5" name="txtareaCmtApp" id=""><xss:encodeForHTML><%=sSignComment%></xss:encodeForHTML></textarea></td>
  </tr>
  <tr>
    <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Action</emxUtil:i18n></td>
    <td class="inputField">
      <table border="0">
        <tr>
          <td><input type="radio" name="approvalAction" id="" value="approve"  <%=XSSUtil.encodeForHTMLAttribute(context, aradioChecked)%> <%= "TRUE".equals(sHasApprove) ? "": "disabled"%> />&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Approve</emxUtil:i18n></td>
          </tr>
        <tr>
          <td><input type="radio" name="approvalAction" id="" value="reject" <%=XSSUtil.encodeForHTMLAttribute(context, rradioChecked)%> <%= "TRUE".equals(sHasReject) ? "": "disabled"%> />&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Reject</emxUtil:i18n></td>
          </tr>
        <tr>
          <td><input type="radio" name="approvalAction" id="" value="ignore" <%=XSSUtil.encodeForHTMLAttribute(context, iradioChecked)%> <%= "TRUE".equals(sHasIgnore) ? "": "disabled"%> />&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Ignore</emxUtil:i18n></td>
         </tr>
      </table>
    </td>
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="signer" value="<xss:encodeForHTMLAttribute><%=sSigner%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="loginpassword" value="" />
    <input type="hidden" name="fromState" value="<xss:encodeForHTMLAttribute><%=fromState%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="toState" value="<xss:encodeForHTMLAttribute><%=toState%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="isInCurrentState" value="<xss:encodeForHTMLAttribute><%=isInCurrentState%></xss:encodeForHTMLAttribute>" />
    <!--added for BUG 293393-->
    <input type="hidden" name="sHasApprove" value="<xss:encodeForHTMLAttribute><%=sHasApprove%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sHasReject" value="<xss:encodeForHTMLAttribute><%=sHasReject%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sHasIgnore" value="<xss:encodeForHTMLAttribute><%=sHasIgnore%></xss:encodeForHTMLAttribute>" />

  </tr>
</table>
</form>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
