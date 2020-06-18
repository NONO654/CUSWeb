<%--  emxSynchronizationEnvCheckerFS.jsp   -   Page to execute Data Checker and display results
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
    @quickreview E25 19:06:03 [Modifications for Change Object Checker].
    @quickreview E25 17:03:22 [Modifications for New UI ].
    @quickreview KRT3 17:05:25 [IR-523580-3DEXPERIENCER2018x - Proper error handling and Message reporting from StringResource]
    @quickreview E25 17:06:01 [Modifications to modify colors of mandetory fiels and change fornt of non mandetory fields ].
--%>
<html>
<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMxIntegrationUtilities"%>
<%@ page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationEnvVariable"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil"%>
<%@ page import="java.util.Set" %>
<%@ page import="matrix.db.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker"%>
<%@ page import="com.dassault_systemes.collaborationmodelerchecker.util.VPLMJCollaborationModelerCheckerConstants"%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
    String languageStr           = request.getHeader("Accept-Language");
    String strBundle             = "emxVPLMSynchroStringResource";
    String strSelectObject       = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMJCollab.Selection.Object");
    String strSelectChecker               = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMJCollab.Selection.Checker");
    String strExpandStruct              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMSynchro.Synchronization.ExpandStructure");
    String strNoObjectSelected   =EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMSynchro.Error.SelectObject");
    String strNoCheckerSelected   =EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxVPLMSynchro.Error.SelectChecker");
String objectId="";	
String objectName="";
objectId= emxGetParameter(request, "objectId");
		String selPartIds[] 		= emxGetParameterValues(request,"emxTableRowId");

		if(null != selPartIds)
		{
		for (int i=0; i < selPartIds.length ;i++){
			StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
			if (strTokens.hasMoreTokens()){
			        objectId= strTokens.nextToken();
				}
		}
		}
Map<String,String> selectcheckerInfo=new HashMap<String,String>();
Map<String,String> allcheckerInfo=new HashMap<String,String>();
Set<String> selectedCheckerset=new HashSet<String>();
System.out.println("*** Selected object is "+objectId);
if(objectId == null)
{
objectName="";
}
else
{
VPLMBusObject boToSync  = new VPLMBusObject(context,objectId);
objectName=boToSync.getSelectableValue("name");
selectcheckerInfo=VPLMJCollaborationModelerChecker.getCheckerList(context,boToSync);
selectedCheckerset=selectcheckerInfo.keySet();
}
 StringBuffer contentURL=new StringBuffer("emxSynchronizeVPLMDataCheckerReportFS.jsp");
%>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">

     function isEmpty(str) {
       return (!str || 0 === str.length || str == "null" || str == "" || str == null);
    }
	function checkInput()
	{
	var selectedCheckers= "";
 	var checkerName =document.getElementsByName("checkerName");
	var objectID =document.getElementById("objectID").value.trim();
	    if(isEmpty(objectID))
	{
		alert("<%=strNoObjectSelected%>");

	}
    	for(var i = 0; i < checkerName.length; i++)
   	{
    	 if(checkerName[i].checked)
      	{
        
		selectedCheckers=selectedCheckers+checkerName[i].value.trim()+",";
	
      	}
   	}
	selectedCheckers= selectedCheckers.substring(0, selectedCheckers.length - 1);
	
  	if(!isEmpty(objectID) && isEmpty(selectedCheckers))
	{
  	    alert("<%=strNoCheckerSelected%>");
	}
	if(!isEmpty(objectID) && !isEmpty(selectedCheckers))
	{  
	 var jscontentURL="<%=contentURL.toString()%>?objectID="+objectID+"&expandStructure="+document.getElementById("expandStruct").checked+"&ichecker="+selectedCheckers;
	 window.parent.location=jscontentURL;
	}
	}
	function reset()
	{
		 window.parent.location= "../common/emxSynchronizeVPLMDataCheckerDialogFS.jsp?titleKey=emxVPLMSynchro.Synchronization.Command.SyncDataChecker.Title";
	}
</SCRIPT>
<emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%=request.getHeader("Accept-Language")%>' />
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="javaScript" src="../common/scripts/emxUITableUtil.js"></script>

<script language="javascript">
		    addStyleSheet("emxUIDefault","../common/styles/");
		    addStyleSheet("emxUIToolbar","../common/styles/");
		    addStyleSheet("emxUIList","../common/styles/");
		    addStyleSheet("emxUIProperties","../common/styles/");
    		addStyleSheet("emxUITemp","../");
		    addStyleSheet("emxUIForm","../common/styles/");
    </script>


<body>
<form name="checkerForm" action="" method="post" >
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" >
		<TR WIDTH="60%">
		<TD CLASS="createLabelRequired" width="150"><%=strSelectObject%>
		</TD>
		<TD CLASS="inputField" width="150">

						<input type="text" name= "objectName" id="objectName" value="<%=objectName%>" size="20" readonly="readonly" />
						<input type="text" name= "objectID" id="objectID" value="<%=objectId%>" style="display:none" size="20" readonly="readonly" />
<%if(VPLMIntegrationEnvVariable.isChangeObjectCheckerActive(context)){ %>
						<input name="button" type="button" value="..." onclick="javascript:getTopWindow().showChooser('../common/emxFullSearch.jsp?field=TYPES=type_Part,type_VPMReference,type_ENOCLG_LibraryReference,type_GeneralLibrary,type_LOGICALSTRUCTURES,type_HardwareProduct,type_HardwareProduct,type_Change&showInitialResults=false&table=AEFGeneralSearchResults&selection=single&submitURL=../common/emxVPMDataCheckerSearchUtil.jsp')" />
						<%}else{ %>
						<input name="button" type="button" value="..." onclick="javascript:getTopWindow().showChooser('../common/emxFullSearch.jsp?field=TYPES=type_Part,type_VPMReference,type_ENOCLG_LibraryReference,type_GeneralLibrary,type_LOGICALSTRUCTURES,type_HardwareProduct,type_HardwareProduct&showInitialResults=false&table=AEFGeneralSearchResults&selection=single&submitURL=../common/emxVPMDataCheckerSearchUtil.jsp')" />
						<%} %>

		</TD>
		</TR>
<TR>
  		 <td width="150" class="createLabelRequired"><%=strSelectChecker%></td>
                <td class="inputField">
                    <div id="dlabelDirVal">
                        <table>
	<%	
allcheckerInfo=VPLMJCollaborationModelerChecker.getCheckerList(context,null);
Set<String> checkerset = allcheckerInfo.keySet();
for (String s : checkerset) {
	if(s.equals(VPLMJCollaborationModelerCheckerConstants.FactoryConstants.ChangeObjectChecker) && !VPLMIntegrationEnvVariable.isChangeObjectCheckerActive(context))
		continue;
%>
<tr>
<% if(selectedCheckerset.contains(s))
{
%>
                                <td><input type="checkbox" name="checkerName" id= "checkerName" value="<%out.println(s.toString());%>"/><%out.println(selectcheckerInfo.get(s).toString());%></p></td>
<%
}
else
{
%>
				<td><input type="checkbox" name="checkerName" id= "checkerName" value="<%out.println(s.toString());%>" disabled/><%out.println(allcheckerInfo.get(s).toString());%></p></td>

<%
}
%>

                            </tr>

   
<%}%>
                            <tr>
                        </table>
                    </div> 
                </td>
</TR>
<TR>
	<td width="150" class="createLabel"><%=strExpandStruct%>
 </td>
	<%
	if(null != selectedCheckerset && !selectedCheckerset.isEmpty() && !selectedCheckerset.contains(VPLMJCollaborationModelerCheckerConstants.FactoryConstants.ChangeObjectChecker))
	{%>
	<td width="150" class="inputField"><input type="checkbox" name="expandStruct" id="expandStruct" false />
	<%}
	else
	  {
	%>
	<td width="150" class="inputField"><input type="checkbox" name="expandStruct" id="expandStruct" false disabled/>
	<%}
	%>
</td>
</TR>

	</table>
</form>
</body></html>


