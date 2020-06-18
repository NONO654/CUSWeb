<%-- emxProgramCentralMemberTransferDialog.jsp

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  Custom Revision History
  =======================
  Date           Name            Description
  -----------------------------------------------------------------------------
  04-12-2004     DKort           Created
--%>
<%@include file = "emxProgramGlobals2.inc" %>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>


<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%

    com.matrixone.apps.program.ProjectSpace project = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);

    // Get required inputs from request
    String sLanguage = request.getHeader("Accept-Language");
    //changes by M1 India
	//String selectedPersonID = emxGetParameter( request, "selectedId" );
	String[] people = emxGetParameterValues(request, "emxTableRowId");
	String strTask = EnoviaResourceBundle.getProperty(context, "Framework",	"emxFramework.Type.Task", sLanguage);
	String strIssue = EnoviaResourceBundle.getProperty(context, "Framework",	"emxFramework.Type.Issue", sLanguage);
	String strRisk = EnoviaResourceBundle.getProperty(context, "Framework",	"emxFramework.Type.Risk", sLanguage);
	int cnt = 0;
	Map groupRoleMap = new HashMap();
   StringList pList = new StringList();
   if ( people != null ) {
    // get the number of people
    int numUsers = people.length;
    int numPersons = 0;

    for (int i=0; numUsers>i; i++) {
/*       //check if it is an id or a group/role name 
      if(people[i].indexOf("personid") == -1) {
        //is a group or role name pass access = "None" for removing
        //the access
        groupRoleMap.put(people[i], "None");
      }
      else { */
        //obtain the person id
        int pVal = people[i].indexOf("_") + 1;
        String personId = people[i].substring(pVal, people[i].length());
        pList.add(personId);
        numPersons++;
		cnt++;
     // }
    }
  }
String selectedPersonID = null;
  if(pList != null && !pList.isEmpty()) {
        StringItr pListItr = new StringItr(pList);
        while(pListItr.next()) {
			selectedPersonID = (String) pListItr.obj();
			
		}
	}
	//end of changes
    String objectId  = emxGetParameter( request, "objectId" );
	boolean flag = false;
if(selectedPersonID == null)
{
	
	String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.MemberTransfer.errMsg", sLanguage);
	throw new Exception(errMsg);
	//throw new Exception("Person not selected");
}
	
    com.matrixone.apps.common.Person pFromPerson = new com.matrixone.apps.common.Person( selectedPersonID );

    // Retrieve the information required for the person object
    StringList memberSelect = new StringList( 4 );
    memberSelect.add( pFromPerson.SELECT_ID );
    memberSelect.add( pFromPerson.SELECT_NAME );
    memberSelect.add( pFromPerson.SELECT_FIRST_NAME );
    memberSelect.add( pFromPerson.SELECT_LAST_NAME );

    Map mPersonInfo = pFromPerson.getInfo( context, memberSelect );

    // Retrieve the member list from the project
    project.setId( objectId );

    // Revised 04-01-2004 (dk): Added selectable to determine role of person
    StringList slMemberRelSelect = new StringList( 1 );
    slMemberRelSelect.add( "id[connection]" );

    MapList wbsMemberList = project.getMembers(context, memberSelect, slMemberRelSelect, null, null);
    if ( wbsMemberList != null ) wbsMemberList.sort( pFromPerson.SELECT_LAST_NAME, "ascending", "string" );


%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><script language="JavaScript">
    function moveNext() {
        if ((document.editForm.selTask.checked == false) &&
            (document.editForm.selIssue.checked == false) &&
            (document.editForm.selRisk.checked == false))
        {
			alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.TransferAssignment.NoCheckBoxesChecked</emxUtil:i18nScript>");
	        return;
		}
           // Below Helpmarker code modified for Bug 341592
        document.editForm.action = "../common/emxTable.jsp?HelpMarker=emxhelptransfertypes";
        document.editForm.target = "_parent";
        	
		if(document.editForm.txtPersonTo.length > 0){
			var toPersonID = document.editForm.txtPersonTo.options[document.editForm.txtPersonTo.selectedIndex].value;
			var fromPersonID = document.editForm.txtPersonFrom.value;
    		var subHeading = "<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.TransferAssignment.From</emxUtil:i18nScript> <%=mPersonInfo.get( pFromPerson.SELECT_LAST_NAME )%>,<%=mPersonInfo.get( pFromPerson.SELECT_FIRST_NAME )%>  <emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.TransferAssignment.To</emxUtil:i18nScript>  " + document.editForm.txtPersonTo.options[document.editForm.txtPersonTo.selectedIndex].text;
			document.editForm.subHeader.value = subHeading;
			document.editForm.SubmitURL.value = "../programcentral/emxProgramCentralMemberTransferProcess.jsp?txtPersonFrom=" + fromPersonID + "&txtPersonTo=" + toPersonID;
            //Added:4-Oct-2010:vf2:R2012
			//editForm.submit();
			document.editForm.submit();
            //End:4-Oct-2010:vf2:R2012
		}
		else{
			alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.TransferAssignment.NoToPerson</emxUtil:i18nScript>");
		}
        
    }

	function closeWindow() {
        parent.window.closeWindow();
    }
</script>


<body class="white" >

<form name="editForm" action="" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <input type="hidden" name="txtPersonFrom" value="<xss:encodeForHTMLAttribute><%=selectedPersonID%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="program" value="emxProjectSpace:getPersonAssignments" />
    <input type="hidden" name="table" value="PMCItemReassignment" />
    <input type="hidden" name="header" value="emxProgramCentral.Header.TransferAssignment2" />
    <input type="hidden" name="subHeader" value="" />
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=emxGetParameter( request, "suiteKey" )%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="SubmitURL" value="" />
    <input type="hidden" name="relId" value="" />
    <input type="hidden" name="sortColumnName" value="Name" />
    <input type="hidden" name="CancelButton" value="true" />
    <%-- This toolbar is used to set for the back button functionality
		Bug No. 357558  --%>
    <input type="hidden" name="toolbar" value="PMCTransferAssignmentToolbar" />

    <table border="0" width="100%">
    <tr>
        <td class="label">
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.From</emxUtil:i18n>
        </td>
        <td class="inputField">
            <%=mPersonInfo.get( pFromPerson.SELECT_LAST_NAME )%>,&nbsp;<%=mPersonInfo.get( pFromPerson.SELECT_FIRST_NAME )%>
        </td>
    </tr>
    <tr>
        <td class="labelRequired">
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ToPerson</emxUtil:i18n>
        </td>
        <td class="inputField">
            <select name="txtPersonTo">
            <%
            String personId;
            for ( int i=0; i<wbsMemberList.size(); i++ ) {

                // Remove the current user from the drop-down list
                Map mMember = (Map) wbsMemberList.get( i );
                personId    = (String) mMember.get( "id" );

                if ( personId != null && !personId.equals( selectedPersonID ) ) {
                    %>
                    <option value="<xss:encodeForHTMLAttribute><%=personId%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=mMember.get( pFromPerson.SELECT_LAST_NAME )%></xss:encodeForHTML>,<xss:encodeForHTML><%=mMember.get( pFromPerson.SELECT_FIRST_NAME )%></xss:encodeForHTML></option>
                    <%
                }

            }
            %>
            </select>
        </td>
    </tr>
    <tr>
        <td class="labelRequired">
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.TypesToTransfer</emxUtil:i18n>
        </td>
        <td class="inputField">
            <input type="checkbox" name="selTask" value="true"><%=strTask%><br>
            <input type="checkbox" name="selIssue" value="true"><%=strIssue%><br>
            <input type="checkbox" name="selRisk" value="true"><%=strRisk%>
        </td>
    </tr>
    </table>
</form>
