<%-- C3DFooterPage.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
 --%>

<%@include file   ="../../common/emxLifecycleUtils.inc"%>  

<%-- file above provides i18nStringNowUtil--%>
<%@ page import = "com.matrixone.apps.framework.ui.*" %>

<html>
<head>
<link rel="stylesheet" href="../../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../../common/styles/emxUIDialog.css" type="text/css" >
<link rel="stylesheet" href="../../common/styles/emxUIList.css" type="text/css" >
<script language="JavaScript">
function turnOffProgress() {
    if(document.images['imgProgress']){
        document.images['imgProgress'].src = "../../common/images/utilSpacer.gif";
    }else if (parent.frames.length > 1) {
        if (parent.frames[1].document.images['imgProgress']) {
            parent.frames[1].document.images['imgProgress'].src = "../../common/images/utilSpacer.gif";
        } else if (parent.frames[0].document.images['imgProgress']) {
            parent.frames[0].document.images['imgProgress'].src = "../../common/images/utilSpacer.gif";
        }
    } else if (parent.frames.length > 0) {
        if (parent.frames[0].document.images['imgProgress']) {
                parent.frames[0].document.images['imgProgress'].src = "../../common/images/utilSpacer.gif";
        } 
    } else {
        setTimeout("turnOffProgress()", 500);
    }
}

</script>
</head>

<body>

<%
    boolean DEBUG             = false;
    String I18NResourceBundle = "c3dIntegrationStringResource";
    String acceptLanguage     = request.getHeader("Accept-Language");

    String footerDoneCaption  = request.getParameter("footerDoneCaption");
    boolean hasDoneBtn        = !((footerDoneCaption == null) || 
                                 footerDoneCaption.compareToIgnoreCase("null") == 0);

    String footerNextCaption  = request.getParameter("footerNextCaption");
    boolean hasNextBtn        = !((footerNextCaption == null) || 
                                 footerNextCaption.compareToIgnoreCase("null") == 0);

    String footerCancelCaption  = request.getParameter("footerCancelCaption");
    boolean hasCancelBtn        = !((footerCancelCaption == null) || 
                                 footerCancelCaption.compareToIgnoreCase("null") == 0);

%>

<script language="javascript">

	function doNext()
    {
        isValid = true;
        numForms = parent.window.frames[1].document.forms.length;
        //calls validateSubmit(form) for each form containing 'Validate' in its name
        for (i=0; i<numForms; i++) {
            curForm = parent.window.frames[1].document.forms[i];
            //also handle validation of more than one form!
            if ((curForm.name != null) & (curForm.name.lastIndexOf('Validate') != -1)) {
                //validate each element whose name contains "host" using validateHost
                numElements = curForm.elements.length;
                for (j=0; j<numElements; j++) {
                    if (curForm.elements[j].name.lastIndexOf('host') != -1) {
                        isValidHost = parent.window.frames[1].validateHost(curForm.elements[j], j);
                        if (!isValidHost) {
                            isValid = false;
                            break;
                        }
                    }
                    //validate each element whose name contains "port" using validatePort
                    if (curForm.elements[j].name.lastIndexOf('port') != -1) {
                        isValidPort = parent.window.frames[1].validatePort(curForm.elements[j], j);
                        if (!isValidPort) {
                            isValid = false;
                            break;
                        }
                    }
                }
            }
        }
        if (isValid) {
            //submit first form that contains the string 'doNext_' in its name
            for (i=0; i<numForms; i++) {
                curForm = parent.window.frames[1].document.forms[i];
                if ((curForm.name != null) & (curForm.name.lastIndexOf('doNext_') != -1)) {
                    //alert('Found it!');
                    curForm.submit();
                    this.window.location.href="C3DFooterPage.jsp?footerDoneCaption=c3dIntegration.Footer.Done";
                }
            }
        }
    }

	function doCancel()
	{
	   //alert('Cancel');
       parent.window.close();
	}

    window.onload=turnOffProgress;
</script>

<form name="bottomCommonForm"  onSubmit="return false">

<table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
<tr><td colspan=2><img src="spacer.gif" width="1" height="9"></td></tr>
<tr>
<td>
<table border="0">

<%
    String strQueryTo = ""; 
    String strResults = ""; 
    String sQueryLimit=request.getParameter("QueryLimit");
	if( ( sQueryLimit == null ) || ( sQueryLimit.equals("null") ) || ( sQueryLimit.equals("") ) ){
	 sQueryLimit=request.getParameter("qlim");
	}

    String strNext = null;
    if (hasNextBtn) {
        strNext = i18nStringNowUtil(footerNextCaption,I18NResourceBundle,acceptLanguage);
    }
    String strDone = null;
    if (hasDoneBtn) { 
        strDone = i18nStringNowUtil(footerDoneCaption,I18NResourceBundle,acceptLanguage);
    }
    String strCancel = null;
    if (hasCancelBtn) { 
        strCancel = i18nStringNowUtil(footerCancelCaption,I18NResourceBundle,acceptLanguage);
    }
    if( ( sQueryLimit == null ) || ( sQueryLimit.equals("null") ) || ( sQueryLimit.equals("") ) )
    {
%>
    <tr><td colspan="4">&nbsp;<input type="hidden" name="QueryLimit" value="">  </td></tr></table></td>
<%
    }
    else 
    {
        Integer integerLimit = new Integer(sQueryLimit);
        int intLimit = integerLimit.intValue();

        if( intLimit > 0 )
        {
%>
      <tr><td><%=strQueryTo%></td><td>&nbsp;<input type="text" size="5" name="QueryLimit" value="<%=sQueryLimit%>"></td>
      <td><%=strResults%></td><td>&nbsp;&nbsp;</td></tr></table></td>
 <%     }
        else
        {
%>
      <tr><td colspan="4">&nbsp;<input type="hidden" name="QueryLimit" value="">  </td></tr></table></td>
<%
        }
    }
%>

<td align="right">
<table border="0" cellspacing="0" cellpadding="0" align="right">
 <tr>
   <td align="right">&nbsp;&nbsp;</td>
     <% if (hasNextBtn) {%>
        <td align="right" ><a href="javascript:doNext()"  >
                           <img src="../../integrations/images/emxUIButtonNext.gif" border="0" >
                           </a></td>
        <td align="right" ><a href="javascript:doNext()"  >
                           <%=strNext%>
                           </a>&nbsp&nbsp;</td>
     
     <%} if (hasDoneBtn) {%>
        <td align="right" ><a href="javascript:doCancel()"  >
                           <img src="../../integrations/images/emxUIButtonDone.gif" border="0" >
                           </a></td>
        <td align="right" ><a href="javascript:doCancel()"  >
                           <%=strDone%>
                           </a>&nbsp&nbsp;</td>
    
    <%} if (hasCancelBtn ) {%>
        <td align="right" ><a href="javascript:doCancel()"  >
                           <img src="../../integrations/images/emxUIButtonCancel.gif" border="0" >
                           </a></td>
        <td align="right" ><a href="javascript:doCancel()"  >
                           <%=strCancel%>
                           </a>&nbsp&nbsp;</td>
    
    <% } %>
  </tr>
  <% if (DEBUG) { %>
    <tr>
        <td>footerDoneCaption = <%=footerDoneCaption%></td>
        <td>footerNextCaption = <%=footerNextCaption%></td>
        <td>footerCancelCaption = <%=footerCancelCaption%></td>        
    </tr>
  <% } %>
 </table>
 </td>
  </tr>
 </table>
</form>
</body>
</html>
