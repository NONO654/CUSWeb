<%--  emxVPMSRMPropCommentContent.jsp   -   Add Comment to the Proposal by taking new comment as input
                                       
   Copyright (c) 1992-2002 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   emxVPMSRMPropCommentFS.jsp
     - emxVPMSRMPropCommentContent.jspobject
       - emxVPMSRMPropCommentProcessing.jsp

    RCI - Wk37 2010 - Creation
	RCI - WK05 2011 - RI 75489 - Bloquer le submit tant que le champ n'est pas valué
--%>

<%@ page
	import="java.util.*,com.matrixone.vplmintegrationitf.util.*,com.matrixone.vplmintegration.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.framework.taglib.*,matrix.db.*"%>

<%@page  import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page  import="com.matrixone.apps.domain.util.MapList"%>
<%@page  import="matrix.util.StringList"%>


<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@include file="../emxStylePropertiesInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

 
<%
      String lang = (String)context.getSession().getLanguage();
      String objectId = emxGetParameter(request,"objectId");
      String rowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String user = (String) context.getUser();

      Map programMap = new HashMap();
      programMap.put("objectId", objectId);
%>

<HTML>
<HEAD>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
   function checkInput()
	{
	    var strValue = document.editForm.SRMComm.value;
        if ( "" == strValue ) {
            alert("<%=i18nNow.getI18nString("emxVPMSRMPropComment.Command.Comment.Warning","emxVPLMSRMServicesStringResource",context.getSession().getLanguage())%>");
        }
        else {
	  	 document.editForm.submit();
		 }
  	}
</SCRIPT>


<%@include file="../emxUICommonHeaderEndInclude.inc"%>
</head>

<BODY>
<p style="font-family:verdana;font-size:0.8em;">

<!--  History Comment Display -->
<FRAMESET rows="50%,*">
<TABLE BORDER="0" CELLPADING="5" CELLSPACING="2" WIDTH="100%">
	<TR><TD class="heading1" > History </td></tr>

<%
       String[] methodargs =JPO.packArgs(programMap);
      String  HistComm = "";
	  if (null!= rowIds)
      for (int i = 0; i < rowIds.length; i++)
	{	
        programMap.put("emxTableRowId", rowIds[i]);   // enlever les anciens comment ???
        String propComm= (String)JPO.invoke(context, "emxVPLMPropose", null,"getComments", methodargs, String.class);	

		String newLine = System.getProperty("line.separator");
		StringTokenizer myList = new StringTokenizer(propComm, newLine);
        while (myList.hasMoreTokens()){
		HistComm = newLine+myList.nextToken();
%>

	<TR><TD class="label" width="100%"><%=HistComm%></td></tr>

<% 
		}
    } 
%> 
</table>

<%
String hiddenParams="";

  // Specify URL to come in middle of frameset
  if (rowIds != null)
  {
	for (int k = 0; k < rowIds.length; k++){
		String itemId = rowIds[k];
                System.out.println("itemId = " +itemId);
		if(k==rowIds.length-1)
                hiddenParams += itemId;
		else
		hiddenParams += itemId + ",";
	}
  }

 String commValue="";
 %>

<FORM NAME="editForm" ID"SRMComm" METHOD="post" ACTION="emxVPMSRMPropCommentProcessing.jsp?action=comment&objectId=<%=objectId%>&emxTableRowId=<%=hiddenParams%>&user=<%=user%>" target=_parent>

<TABLE BORDER="0" CELLPADING="5" CELLSPACING="2" WIDTH="100%">
        <TR><TD class="heading1" > New Comment </td></tr>
	<TR>
		<TD class="inputField"><input type="text" size="80" name="SRMComm" value="<%=commValue%>" onFocus="" />
        </tr>
</td>
</table>
</form>
</body>
</HTML>


<%@include file="../emxUICommonEndOfPageInclude.inc"%>
