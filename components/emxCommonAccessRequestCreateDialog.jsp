<%--  emxCommonAccessRequestCreateDialog.jsp.	 -  The dialog page for creating a new  Access Request.
	 
	 Copyright (c) 1992-2018  Dassault Systemes.
	 All Rights Reserved.
	 This program contains proprietary and trade secret information of MatrixOne, Inc.
	 Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
	 
	 static const char RCSID[] = $Id: emxCommonAccessRequestCreateDialog.jsp.rca 1.3.6.5 Tue Oct 28 19:01:08 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<!-- content begins here -->
<script language="javascript">

  function trim (textBox) 
  {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }
  
  function enableAutoName()
  {
	if ( document.CreateAccessRequestForm.autoRequestName.checked == true )
	{
		 document.CreateAccessRequestForm.strRequestName.disabled = true;
		 document.CreateAccessRequestForm.strRequestName.value = "<emxUtil:i18n localize = "i18nId">emxComponents.Common.Autoname</emxUtil:i18n>";
	 }
	 else
	 {
		 document.CreateAccessRequestForm.strRequestName.disabled = false;
		 document.CreateAccessRequestForm.strRequestName.value = "";
	 }
  }

  function cancel()
  {
      getTopWindow().closeWindow();
  }

  function submitform() 
  {
	var strReasonforRequest =  trim( document.CreateAccessRequestForm.strReasonforRequest.value );
	var hiddenAssignees =  trim( document.CreateAccessRequestForm.hiddenAssignees.value );
	var strRequestName =  trim( document.CreateAccessRequestForm.strRequestName.value );
    
	if ( strRequestName == "" ) 
	{
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.NameAlert</emxUtil:i18nScript>");
      document.CreateAccessRequestForm.strRequestName.value = "";
      document.CreateAccessRequestForm.strRequestName.focus();
      return;
    }    

	if ( strReasonforRequest == "" )
	{
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.AccessRequest.ResasonforRequestAlertMsg</emxUtil:i18nScript>");
      document.CreateAccessRequestForm.strReasonforRequest.value = "";
      document.CreateAccessRequestForm.strReasonforRequest.focus();
      return;
    } 

    if ( hiddenAssignees == "" && document.CreateAccessRequestForm.strIncludeSelf[1].checked == true ) 
	{
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.AccessRequest.AssigneeChooserAlertMsg</emxUtil:i18nScript>");
      document.CreateAccessRequestForm.hiddenAssignees.value = "";
      document.CreateAccessRequestForm.strAssignees.value = "";
      document.CreateAccessRequestForm.btnAssignees.focus();
      return;
    } 
	document.CreateAccessRequestForm.submit();
  }

  function checkForBadChars()
  {
     if ( ! checkForNameBadChars( event.srcElement.value, false ) )
	  {
		alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.NotValidEntry</emxUtil:i18nScript>");
		event.srcElement.value = "";
        event.srcElement.focus();
	  }
  }
</script>

<%
	String jsTreeID = emxGetParameter( request,"jsTreeID" );
	String initSource = emxGetParameter( request,"initSource" );
	String suiteKey = emxGetParameter( request,"suiteKey" );

	// Url for owner Person Chooser
	String ownerUrl = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&form=IssueSearchPersonsForm&table=IssueSearchPersonsTable&selection=multiple&&suiteKey=Components&submitURL=../common/AEFSearchUtil.jsp&showInitialResults=true&fieldNameActual=hiddenAssignees&fieldNameDisplay=strAssignees";
%>

  <%@include file="../emxUICommonHeaderEndInclude.inc" %>  
  <form name="CreateAccessRequestForm" method="post" action="emxCommonAccessRequestCreateProcess.jsp" onSubmit="submitform(); return false" >
  <input type=hidden name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />

    <table border="0" width="100%" cellpadding="5" cellspacing="2">
        <tr>
          <td  width="200" class="labelRequired">
			<emxUtil:i18n localize = "i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;&nbsp;
		  </td>
          <td  class="inputField"  colspan="2">
			 <input type="text" name="strRequestName" value='<emxUtil:i18n localize = "i18nId">emxComponents.Common.Autoname</emxUtil:i18n>' disabled onchange="checkForBadChars()" />
			 <input type="checkbox" name="autoRequestName" checked onClick="enableAutoName()" />
			 <emxUtil:i18n localize = "i18nId">emxComponents.Common.Autoname</emxUtil:i18n>&nbsp;&nbsp;
          </td>
        </tr>
		<tr>
          <td  width="200" class="label">
			<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.RequestedDocuments</emxUtil:i18n>&nbsp;&nbsp;
		</td>
		  <td  class="inputField"  colspan="2">
			<% 
			  /**
			  * Requested Doucment Ids for Access.
			  **/
				String []documentIds = ( String [] )session.getAttribute( "documentIds" );
				DomainObject documentObj = new DomainObject(); // Document Object
				StringBuffer sbDocName = new StringBuffer(); // Document Name
				StringBuffer sbDocId = new StringBuffer(); // Documnet Id
				StringList objectSelects = new StringList( 2 );
				objectSelects.add( DomainConstants.SELECT_NAME );
				objectSelects.add( DomainConstants.SELECT_TYPE );
				
				 // DOCUMENTS Type 	
				 String strParentType = PropertyUtil.getSchemaProperty(context,"type_DOCUMENTS"); 
				 // eService Production Vault 	
				 String strVault = PropertyUtil.getSchemaProperty(context,"vault_eServiceProduction"); 

				for ( int docCount = 0; docCount< documentIds.length; docCount++ )
				{
					String strDocId = "";
					if ( documentIds[ docCount ].indexOf( "|" ) > 0 )
					{
						StringList slDocId = FrameworkUtil.split( ( String )documentIds[ docCount ] , "|" );
						strDocId = ( String ) slDocId.get( 1 );
					}
					else
					{
						strDocId = documentIds[ docCount ];
					}
					documentObj.setId(strDocId);
					Map docInfo = documentObj.getInfo( context, objectSelects );
					String strIsKind = MqlUtil.mqlCommand( context, "print type $1 select $2 dump", ( String )docInfo.get( DomainConstants.SELECT_TYPE ), "kindof" );
					if ( strIsKind.equals( strParentType ) )
					{
						sbDocId.append( strDocId );
						sbDocId.append( "|" );
						documentObj.setId( strDocId );
						sbDocName.append( ( String )docInfo.get( DomainConstants.SELECT_NAME ) );
						sbDocName.append( ";" );
					}
					else
					{
					%>
					<script>
						alert("<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.PartSelectAlertMsg</emxUtil:i18n>");
						getTopWindow().closeWindow();
					</script>
					<%
					}
                }				
                //Added for bug 352414
				if(sbDocName.length()>0)
				{
				%>
            <!-- Encoding changed from encodeForJavascript to encodeForHTML by PSA11 start(IR-438954-3DEXPERIENCER2018x)--> 
            <%=XSSUtil.encodeForHTML(context, sbDocName.substring( 0, sbDocName.length() - 1 )) %>
            <!-- Change added by PSA11 end.-->
			<%
				}//Added for bug 352414
		    %>
			<input type="hidden" name="strRequestedDocuments" value="<xss:encodeForHTMLAttribute><%=sbDocId.toString()%></xss:encodeForHTMLAttribute>"/>
          </td>
        </tr>
       <tr>
			<td width="200" class="labelRequired">
				<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.ReasonforRequest</emxUtil:i18n>&nbsp;&nbsp;
			</td>
			<td colspan="1" class="inputField">
				<textarea name="strReasonforRequest" cols=20 rows=5 onchange="checkForBadChars()"></textarea>
			</td>
		</tr>
       <tr>
		<td width="200" class="label">
			<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.IncludeSelf</emxUtil:i18n>&nbsp;&nbsp;
		</td>
        <td colspan="1" class="inputField">
			<input type="radio" name="strIncludeSelf" value="Yes" Checked />
				<emxUtil:i18n localize = "i18nId">emxComponents.Common.Yes</emxUtil:i18n>&nbsp;&nbsp;
			<input type="radio" name="strIncludeSelf" Value="No" />
				<emxUtil:i18n localize = "i18nId">emxComponents.Common.No</emxUtil:i18n>&nbsp;&nbsp;
				<!--<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.IncludeSelf</emxUtil:i18n>-->
       </td>
	   </tr>
	   	<tr>
          <td  width="200" class="label">
			<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.RequestedAssignees</emxUtil:i18n>&nbsp;&nbsp;
		  </td>
		<td class = "inputField">
			<input type="text" name = "strAssignees" id = "strAssignees" value = "" size ="20" readonly="readonly" />
                         <!--//XSSOK-->
			<input type="button" value = "..." name = "btnAssignees" id = "btnAssignees" onclick = "showChooser('<%=ownerUrl%>',700,500)" />
			<a class = "dialogClear" href = "javascript:;" onclick = "document.forms[0].strAssignees.value = '', document.forms[0].hiddenAssignees.value = ''">
				<emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n>
			</a>
		  </td>
			<input type="hidden" name = "hiddenAssignees" id = "hiddenAssignees" value = "" />
        </tr>
    </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
