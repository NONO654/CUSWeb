<%--  emxQualificationDeleteExtensionFromObject.jsp  --  Delete extension from an object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxQualificationStartTransaction.inc"%>
<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
String selTypesId[] = emxGetParameterValues(request, "emxTableRowId");
String objectId = emxGetParameter(request, "objectId");
DomainObject BaseObject   = DomainObject.newInstance(context,objectId);
BaseObject.setId(objectId);
String strType = (String)BaseObject.getInfo(context,BaseObject.SELECT_TYPE);
String typeNls = strType;
String resNlsType = EnoviaResourceBundle.getTypeI18NString(context,strType,context.getLocale().getLanguage());
if(!resNlsType.isEmpty() && !resNlsType.contains("emxFramework")){
	typeNls = resNlsType;
}
int nbExt = (null != selTypesId) ? selTypesId.length : -1;
int k = 0;
System.out.println(nbExt + " Extension(s) to delete");
Map argsHash = new HashMap();
String retVal = null;
if ((null != selTypesId) )
{
    int nbDeletedExts = 0;
	try
	{
		for (k = 0; k<nbExt; k++)
		{				
			String extName = selTypesId[k];
			if (extName.startsWith("|") == true ) {
				extName = extName.substring(1);
			}
			int idxPipes = extName.indexOf("|");
			if (idxPipes > 0 ) {								
				extName = extName.substring(0,idxPipes);
			}
			//remove extension from the object
			argsHash.put("objectId", objectId);
			argsHash.put("extension", extName);
	
			// Pack arguments into string array.
			String[] args = JPO.packArgs(argsHash);
			retVal =(String) JPO.invoke(context, "emxQualificationProgram", null, "removeExtensionFromObject", args, String.class);

			//String mqlCmd = "mod bus "+objectId+" remove interface " + extName + ";";
			//String res = MqlUtil.mqlCommand(context,mqlCmd,true);	
			//System.out.println("YI3 - RemoveExtension - mql : " + mqlCmd + " ==> res = " + res);
			nbDeletedExts++;
		}
		System.out.println("Remove OK : " + nbDeletedExts + " removed on " + nbExt );
		//emxNavErrorObject.addMessage(nbDeletedExts + " Extension(s) on " + nbExt + "removed from Object,\n");			
		ArrayList<String> valMsg = new ArrayList<String>();
		valMsg.add(Integer.toString(nbDeletedExts));
		valMsg.add(Integer.toString(nbExt));
		valMsg.add(typeNls);
		String removeMsgNls = EnoviaResourceBundle.getProperty(context, "emxQualificationStringResource", context.getLocale(), "emxQualification.Message.ExtensionRemoved");
		if (removeMsgNls != null && !removeMsgNls.isEmpty()) {
			  for (String replacingVal : valMsg) {
				  removeMsgNls = removeMsgNls.replaceFirst("%val%",replacingVal);
			  }
			}
		emxNavErrorObject.addMessage(removeMsgNls);			
		%>
		<%@ include file = "emxQualificationCommitTransaction.inc" %>
		<%
		
	}
	catch (Exception e)
	{
		System.out.println("Remove KO" + e.getMessage());
		emxNavErrorObject.addMessage("Remove KO : " + e.getMessage());									
		%>
		<%@ include file = "emxQualificationAbortTransaction.inc" %>
		<%
	}		
		
	
}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%-- Reload the page --%>
<script language="Javascript" >
window.parent.location.href = window.parent.location.href ;	
</script>
