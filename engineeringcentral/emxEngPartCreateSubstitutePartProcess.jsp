<%--  emxEngPartCreateSubstitutePartProcess.jsp  - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.Part,com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "com.matrixone.apps.engineering.EngineeringConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject" %>

<%

	Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
	String jsTreeID = emxGetParameter(request,"jsTreeID");
	String suiteKey = emxGetParameter(request,"suiteKey");
	String strLanguage = context.getSession().getLanguage();
	String I18NResourceBundle = "emxFrameworkStringResource";
	String objectId = emxGetParameter(request,"objectId");
	String bomId = emxGetParameter(request,"bomId");
	String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
	String sEBOMPartId = emxGetParameter(request,"sEBOMPartId");
	String alertMsg = com.matrixone.apps.engineering.EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Substitute.AlreadyExists",strLanguage);
	//String alertMsg1 = com.matrixone.apps.engineering.EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.RecursionError.Message",strLanguage) + " : ";
	com.matrixone.apps.domain.DomainObject doObj = new com.matrixone.apps.domain.DomainObject();
	doObj.setId(sEBOMPartId);
	alertMsg+= " " + doObj.getInfo(context, "name")+ " : ";
	String selectedId = "";
	
	boolean processFailed = false;
	boolean recursion = false;
	String url = "";
	
	StringList sLListOfNotAddedItems = new StringList(); // UOM Management
	String sRootObjUOMType = doObj.getInfo(context,EngineeringConstants.SELECT_UOM_TYPE );

	try {
		String sDuplicateMessage ="";
		String sMessage = "Create Successful";
		String sRelId = emxGetParameter(request,"sRelId");
		part.setId(objectId);

		if(checkBoxId != null)
		{
		
		try{
		      ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"), DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING); //372340
	  
			for (int i=0; i < checkBoxId.length ;i++) {
				StringTokenizer strTokens = new StringTokenizer(checkBoxId[i],"|");
				if (strTokens.hasMoreTokens()) {
				    try{
						selectedId = strTokens.nextToken();
						/* //UOM Management- start
						DomainObject dmSelObj = DomainObject.newInstance(context,selectedId );
						String sSelObjUomType = dmSelObj.getInfo(context,EngineeringConstants.SELECT_UOM_TYPE );
						System.out.println(sSelObjUomType);
						if(sSelObjUomType.equals(sRootObjUOMType)) */
						part.createSubstitutePart(context, bomId, sRelId, selectedId);
						/* else
							sLListOfNotAddedItems.addElement(sSelObjUomType); */
						//UOM Management- end
				    } catch (Exception exp){
                        String msg = exp.getMessage();
                        /*if (msg.indexOf("trigger") != -1)
                        {
                            recursion = true;
                            doObj.setId(selectedId);
                            alertMsg1 = alertMsg1 + doObj.getInfo(context, "name") + ",";
                        } else*/
						if (msg.indexOf("trigger") == -1)
                        {
                            doObj.setId(selectedId);
                            alertMsg +=  doObj.getInfo(context, "name") + ",";
                            processFailed = true;                        	
                        }
				    }
				}//End of if loop
			}//End of for loop
			
			}
			  finally{
			          ContextUtil.popContext(context); //372340
                }
         
		        //UOM Management- start
				if(sLListOfNotAddedItems.size()>0)
				{
					%>
					<script language="Javascript">
					alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.UOMTypeMismatch</emxUtil:i18n>");
					</Script>
					<%
				}
				 //UOM Management- end
		
		}//End of if loop
		else{
		processFailed = true;
%>
<script language="Javascript">
alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18n>");
</Script>
<%
		}//End of else loop
	}//End of try Block
	catch(Exception ex) {
	    alertMsg = ex.getMessage()+ ",";
		processFailed = true;
	}//End of Catch Block
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
	//XSSOK
	var processFailed = <%=processFailed%>;
	//XSSOK
	var recursion = <%=recursion%>;
	if(processFailed){
		//XSSOK
		alert("<%=alertMsg.trim().substring(0, alertMsg.length()-1)%>");
	}
	/*if (recursion){
		//XSSOK
		<%--alert("<%=alertMsg1.trim().substring(0, alertMsg1.length()-1)%>");--%>
	}*/
	getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().location.href;
	getTopWindow().getWindowOpener().closeWindow();
	//getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	getTopWindow().closeWindow();
	//top.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	//End of if loop
</script>
