<%-- C3DRegisterFormats.jsp

   Copyright Dassault Systemes, 1992-2011. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program      
--%>

<script language="Javascript">
function checkAll(curForm) {
  if (curForm.chkList.checked == true) {
    for (i = 1; i < curForm.elements.length; i++)
      curForm.elements[i].checked = true ;
  } else {
    for (i = 1; i < curForm.elements.length; i++)
      curForm.elements[i].checked = false ;
  }
  return;
}

function disableCheckbox(curForm, disable) 
{
  if (disable == false)
  {
    for (i = 0; i < curForm.elements.length; i++)
      curForm.elements[i].disabled = true ;
  } 
  else 
  {
    for (i = 0; i < curForm.elements.length; i++)
      curForm.elements[i].disabled = false ;
  }
  return;
}

function uncheckSelectAll(curForm, isRegistered)
{
   if (isRegistered.checked == false)
    {
      curForm.chkList.checked =false;
    }
     return;
}

//  End
</script>
<script language="JavaScript" src="../../common/scripts/emxUIConstants.js"></script> <%--Required by emxUIActionbar.js below--%>
<%@include file = "../../emxUICommonAppInclude.inc"%>
<%@include file = "../../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.ds.enovia.cif.intrf.ENOCIFUtil"%>

<script language="JavaScript" src="../../common/scripts/emxUIActionbar.js" type="text/javascript"></script> <%--To show javascript error messages--%>
<script language="JavaScript" src="../../common/scripts/emxJSValidationUtil.js" type="text/javascript"></script> <%--To show javascript error messages--%>
<script language="JavaScript" src="../../common/scripts/emxUISearch.js" type="text/javascript"></script> <%--To show javascript error messages--%>


<script language="javascript">
  function doSearch1() {
    // File Name can not have special characters
    var apostrophePosition  = document.ContentFindFile.name.value.indexOf("'");
    var DoublecodesPosition = document.ContentFindFile.name.value.indexOf("\"");
    var hashPosition        = document.ContentFindFile.name.value.indexOf("#");
    var dollarPosition      = document.ContentFindFile.name.value.indexOf("$");
    var atPosition          = document.ContentFindFile.name.value.indexOf("@");
    var andPosition         = document.ContentFindFile.name.value.indexOf("&");
    var percentPosition     = document.ContentFindFile.name.value.indexOf("%");

    var x = new Date();
    currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
    document.ContentFindFile.timeZone.value = currentTimeZoneOffsetInHours;

    if( DoublecodesPosition != -1 || apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1) {
      alert ("<emxUtil:i18nScript localize=" + i18nId + ">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.ContentFindFile.name.focus();
    } else {
      startSearchProgressBar();  //kf
      document.ContentFindFile.submit();
    }
        return;
    }

  function closeWindow() {
    parent.window.close();
    return;
  }
  function selectVal(val) {

    if(val == "owner") {
      showModalDialog('../../teamcentral/emxTeamRouteWizardSelectPeopleDialogFS.jsp?callPage=Search',775,475);
      return;
    } else {
      //emxShowModalDialog('emxTeamGenericSelectFolderDialogFS.jsp?formName=ContentFindFile&callPage=Search',575,575);
      showTreeDialog('DSCFolderSearchDialogFS.jsp?formName=ContentFindFile&callPage=Search&showWorkspace=true&tnr=&showApplyToChildren=false');
      return;
    }
  }
  function advancedSearch()
  {
    alert('DSCSearchContentDialog.jsp:advance search');
  }
window.onload=turnOffProgress;
</script>

 <% //i18n section
  
  String m_Lang = request.getHeader("Accept-Language");
  String I18NResourceBundle = "c3dIntegrationStringResource";

  //internationalize page contents
  //i18nStringNow is in file emxDesignTopInclude.inc

  String pageTitle         = i18nStringNowUtil("c3dIntegration.ViewerReg.PageTitle", 
                                               I18NResourceBundle, m_Lang);
  String pageHeader        = i18nStringNowUtil("c3dIntegration.ViewerReg.PageHeader",  
                                               I18NResourceBundle, m_Lang);
  String tickTableHeader   = i18nStringNowUtil("c3dIntegration.ViewerReg.TickTableHeader",  
                                               I18NResourceBundle, m_Lang);
  String selectAllButton   = i18nStringNowUtil("c3dIntegration.ViewerReg.SelectAllButton",  
                                               I18NResourceBundle, m_Lang);
  String regTableHeader    = i18nStringNowUtil("c3dIntegration.ViewerReg.RegTableHeader", 
                                               I18NResourceBundle, m_Lang);
  String NoRegTodo         = i18nStringNowUtil("c3dIntegration.ViewerReg.NoRegTodo", 
                                               I18NResourceBundle, m_Lang);
  String unregTableHeader  = i18nStringNowUtil("c3dIntegration.ViewerReg.UnregTableHeader", 
                                               I18NResourceBundle, m_Lang);
  String NoUnregTodo       = i18nStringNowUtil("c3dIntegration.ViewerReg.NoUnregTodo", 
                                               I18NResourceBundle, m_Lang);
  String errCtx            = i18nStringNowUtil("c3dIntegration.ViewerReg.errMsgContext", 
                                               I18NResourceBundle, m_Lang);
 



    String actionStr  = request.getParameter("action");
    String doneStr    = request.getParameter("done_button");

	StringBuffer msg		= new StringBuffer();
    Map curSystemRegFormats = null;
	String isAdmin			= null;
	String makeReadOnly		= "true"; 
	String messageTodisplay = "";

    java.util.SortedSet tickedFormats		= null;
    java.util.SortedSet untickedFormats		= null;
    java.util.SortedSet registeredFormats	= null;
    java.util.SortedSet unregisteredFormats = null;

    try {
        curSystemRegFormats = ENOCIFUtil.getSystemFormatRegistrations(context);
		  isAdmin = emxGetParameter(request, "isAdmin");
        if ((actionStr != null) && (actionStr.equals("doRegistration"))) {
            //Compile list of ticked and unticked formats.
            tickedFormats = ENOCIFUtil.getTickedFormats(request);
            untickedFormats = ENOCIFUtil.getUntickedFormats(curSystemRegFormats, tickedFormats);

            //modify registration for both sets
            registeredFormats = ENOCIFUtil.registerTickedFormats(context, tickedFormats, curSystemRegFormats);
            unregisteredFormats = ENOCIFUtil.unregisterUntickedFormats(context, untickedFormats, curSystemRegFormats);

            //Refresh the current registered formats in the system
            curSystemRegFormats = ENOCIFUtil.getModifiedFormats(context,registeredFormats,unregisteredFormats);
			if((registeredFormats != null && registeredFormats.size() > 0) || (unregisteredFormats != null && unregisteredFormats.size() > 0 ))
			{
			//messageTodisplay = "R: Registered Formats <BR> U: Unregistered Formats";
				messageTodisplay  = i18nStringNowUtil("c3dIntegration.ViewerReg.FormatReg","c3dIntegrationStringResource", m_Lang);

			}else
			{
			//	messageTodisplay = "Nothing to register/unregister ";
				messageTodisplay  = i18nStringNowUtil("c3dIntegration.ViewerReg.NoFormatReg","c3dIntegrationStringResource", m_Lang);
			}

        } //if action = "doRegistration"
		boolean containsFalse = true;
		if(curSystemRegFormats != null && curSystemRegFormats.size() > 0)
		{
			containsFalse = curSystemRegFormats.values().contains("false");
		}
		if(messageTodisplay != null && messageTodisplay.length() > 0)
		{
			makeReadOnly = "false";
		}
		if(isAdmin != null && isAdmin.length() > 0 && isAdmin.equalsIgnoreCase("false"))
		{
			makeReadOnly = "false";
		}

%>
    <TITLE><%=pageTitle%></TITLE>
    <META http-equiv="imagetoolbar" content="no">
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <LINK rel="stylesheet" href="../../common/styles/emxUIDefault.css"
          type="text/css">
    <LINK rel="stylesheet" href="../../common/styles/emxUIForm.css" type=
    "text/css">
    <LINK rel="stylesheet" href="../../common/styles/emxUIList.css" type=
    "text/css">
<%@include file = "../../emxUICommonHeaderEndInclude.inc" %>

    <FORM method="POST"
	  name="doNext_formatsForm"
          action="C3DRegisterFormats.jsp">

 	 <body onload ="disableCheckbox(document.doNext_formatsForm,<%=makeReadOnly%>)">

     <TABLE width=550 border="0" cellpadding="3" cellspacing="2">
      <tr>
      <th><LABEL>
	<%
	  String selectAllChecked = "";
	  if(!containsFalse)
	  {
		selectAllChecked = "CHECKED";
	  } 
	  %>
	<td align="right">
	  <input type="checkbox" name="chkList" onclick="checkAll(document.doNext_formatsForm)" <%=selectAllChecked%>><B> 
	  <%=selectAllButton%></B></td></LABEL>
	  </th>
      </tr>
      </TABLE>
     <TABLE width=550 border="0" cellpadding="3" cellspacing="2"></TABLE>
	 <TABLE width=550 height = 30>
	 <TR>
	 </TR>	 
	 </TABLE>
      <TABLE width=550 border="0" cellpadding="3" cellspacing="2">
      <% //display all non-IEF formats with a check box
            //get all system formats
            java.util.SortedSet keySet = new TreeSet(curSystemRegFormats.keySet());
            //minus the IEF formats
					
            if (null != keySet)
			{
                Iterator keyItr = keySet.iterator();
                while (keyItr.hasNext()) 
				{ 
                    //Construct the table on two columns.
                    //Left cell
                    String formatNameStr = (String) keyItr.next();
		
                    String isRegistered  = (String) curSystemRegFormats.get(formatNameStr); 
					%>
                    <tr><td class="inputField"><INPUT TYPE="checkbox" 
                                     NAME="<%=formatNameStr%>"
                                     VALUE="<%=isRegistered%>" onclick = "uncheckSelectAll(document.doNext_formatsForm, this)"
                                     <% if (isRegistered.equals("true")) {
                                         %>CHECKED>
                                         <%} else {%>><%}%>
                       <%=formatNameStr%></td>
                    
                <%
                    //Middle cell has content only if one more item is available.
                    if (keyItr.hasNext()) {
                        //put item and close row
                        formatNameStr = (String) keyItr.next();
                        isRegistered  = (String) curSystemRegFormats.get(formatNameStr); 
                        %>
                        <td class="inputField"><INPUT TYPE="checkbox" 
                                     NAME="<%=formatNameStr%>"
                                     VALUE="<%=isRegistered%>" onclick = "uncheckSelectAll(document.doNext_formatsForm, this)"
                                     <% if (isRegistered.equals("true")) {
                                         %>CHECKED>
                                         <%} else {%>><%}%>
                       <%=formatNameStr%></td>

						 <%
                    //Right cell has content only if one more item is available.
                    }if (keyItr.hasNext()) {
                        //put item and close row
                        formatNameStr = (String) keyItr.next();
                        isRegistered  = (String) curSystemRegFormats.get(formatNameStr); 
                        %>
                        <td class="inputField"><INPUT TYPE="checkbox" 
                                     NAME="<%=formatNameStr%>"
                                     VALUE="<%=isRegistered%>" onclick = "uncheckSelectAll(document.doNext_formatsForm, this)"
                                     <% if (isRegistered.equals("true")) {
                                         %>CHECKED>
                                         <%} else {%>><%}%>
                       <%=formatNameStr%></td>
					    <%
                    //Right cell has content only if one more item is available.
					 }if (keyItr.hasNext()) {
                        //put item and close row
                        formatNameStr = (String) keyItr.next();
                        isRegistered  = (String) curSystemRegFormats.get(formatNameStr); 
                        %>
                        <td class="inputField"><INPUT TYPE="checkbox" 
                                     NAME="<%=formatNameStr%>"
                                     VALUE="<%=isRegistered%>" onclick = "uncheckSelectAll(document.doNext_formatsForm, this)"
                                     <% if (isRegistered.equals("true")) {
                                         %>CHECKED>
                                         <%} else {%>><%}%>
                       <%=formatNameStr%></td>


                    </tr>
                        <%
                    } else {
                        //put empty item to complete row
                        %>
                        <td class="inputField"> &nbsp; </td>
                        </tr>
                        <% 
                    }   
                } //end while
            }
	    //IEF standard formats are hidden and always ticked
       } catch (Exception e) 
	{  
        msg.append("<font size=\"4\" color=red>");
		msg.append(errCtx);
		msg.append("</BR>");
		msg.append(e.getMessage());
		msg.append("</BR>");
        msg.append("</font>");		
    }   
    %>
	<%=msg.toString()%>
   </TABLE>
   	  <%if(isAdmin != null && isAdmin.equalsIgnoreCase("false")){
		 String  userError  = i18nStringNowUtil("c3dIntegration.ViewerReg.UserAuthError","c3dIntegrationStringResource", m_Lang);
		  %>
	  <BR>
	  <font size = "2" color='red'>
		<%=userError%>
	</font>
	<%}%>
	<BR>
		<%=messageTodisplay%>
      <input type="hidden" name="action" value="doRegistration">
    </FORM>
</body>
<%@include file = "../../emxUICommonEndOfPageInclude.inc" %>


