<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@page import="java.util.List"%>

<%@page import="com.dassault_systemes.enovia.changeaction.factory.ChangeActionFactory"%>
<%@page import="com.dassault_systemes.enovia.changeaction.interfaces.IChangeAction"%>
<%@page import="com.dassault_systemes.enovia.changeaction.interfaces.IChangeActionServices"%>

<html>
<head>
<title></title>
</head>

<body>

	<%
	String strLanguage     = request.getHeader("Accept-Language");
	String suiteKey = emxGetParameter(request, "suiteKey");
	String msgString       = null;
	String targetLocation = emxGetParameter(request, "targetLocation");
	String strObjectId    = emxGetParameter(request, "objectId");
	List<String> caList    = new ArrayList<String>();
	String objectProcessed = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Notify.Success.ObjProcessed", strLanguage);
	String objectCreated   = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Notify.Success.ObjCreated", strLanguage);
	String objectUpdated   = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Notify.Success.ObjUpdated", strLanguage);
	String objectDeleted   = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Notify.Success.ObjDeleted", strLanguage);
	String syncSuccess     = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Message.Success", strLanguage);
	String syncFail        = EnoviaResourceBundle.getProperty(context, suiteKey,"EnterpriseChangeMgt.Message.Fail", strLanguage);
		
		try {

	
	
	Hashtable syncResultHashTable = new Hashtable();
	caList.add(strObjectId);
			String strStatusReport = "";
			String strErrorMessage = "";
			String strOperationStatus = "";

			try {

				IChangeActionServices iCaServices = ChangeActionFactory.CreateChangeActionFactory();
				IChangeAction iChangeAction = iCaServices.retrieveChangeActionFromDatabase(context, strObjectId);
				syncResultHashTable = iChangeAction.synchronize(context);
				if (!syncResultHashTable.isEmpty()) {
					if(syncResultHashTable.containsKey("ERROR_MESSAGE") && !(syncResultHashTable.get("ERROR_MESSAGE") == null || "null".equals(syncResultHashTable.get("ERROR_MESSAGE"))))
					strErrorMessage = syncResultHashTable.get("ERROR_MESSAGE").toString();
					strOperationStatus = syncResultHashTable.get("OPERATION_STATUS").toString();
				}else{
					strStatusReport = syncFail;
				}
				if (strErrorMessage.isEmpty()) {
					if (!strOperationStatus.isEmpty() && strOperationStatus.equalsIgnoreCase("true")) {
						strStatusReport = syncSuccess;
					} else {
						strStatusReport = syncFail;
		}		
				} else {
					strStatusReport = strErrorMessage;
		}
			} catch (Exception ex) {
				strStatusReport = ex.getMessage();
	}
	%>
	<p><%=strStatusReport%></p>
	
	<%	
		} catch (Exception exception) {
			 exception.printStackTrace();
	%>
	<p>
		<%=syncFail%></p>
	<%
}
%>
</body>
</html>

