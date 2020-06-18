<%--  DisconnectUEBOM.jsp  - To disconnect bom for a part.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="com.matrixone.apps.engineering.Part" %>
<%@ page import="com.matrixone.apps.unresolvedebom.*" %>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil" %>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
    //2012
    String parentState     = emxGetParameter(request,"parentState");
    String objState        = emxGetParameter(request,"objState");
    //String isWipBomAllowed = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
    //String isWipBomAllowed = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
   
    //2012
	String timeStamp          = emxGetParameter(request,"timeStamp");
	String userConfirmation   = emxGetParameter(request,"userConfirmation");
	String removeRowSelection = "false";
	String sTableMode = emxGetParameter(request,"tablemode");
	String selectedRow = emxGetParameter(request,"selectedRow");

	String objectId    = emxGetParameter(request,"objectId");
	String uiType      = emxGetParameter(request,"uiType");
	String action      = "remove";
	String msg         = "";
	String strInput    = "<mxRoot>";
	String alrtMsg     ="";
	String alrtMsg1    ="";
	String delId       ="";
	Locale Local = context.getLocale();
	
	//String isWipBomAllowed = UnresolvedEBOM.isWipBomAllowedForParts(context,objectId);
	String isWipBomAllowed ="false";
	java.util.HashMap toolbarMap = new java.util.HashMap();
	com.matrixone.apps.domain.util.MapList objectList = indentedTableBean.getObjectList(timeStamp);
	String sToolbarData = (String)request.getParameter("toolbarData");
	
	if (sToolbarData != null) {
	    matrix.util.StringList toolbarList = com.matrixone.apps.domain.util.FrameworkUtil.split(sToolbarData, "|");
	    for (int itr = 0; itr < toolbarList.size(); itr++) {
	        String urlParameter = (String)toolbarList.get(itr);
	        if (urlParameter != null && !"".equals(urlParameter)) {
	            matrix.util.StringList urlParameterList = com.matrixone.apps.domain.util.FrameworkUtil.split(urlParameter, "=");
	            toolbarMap.put(urlParameterList.get(0), urlParameterList.get(1));
	        }
	    }
	}
	String language                = request.getHeader("Accept-Language");
	String calledMethod            = emxGetParameter(request, "calledMethod");
	String strRemoverowSelected    = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.RemoverowSelection","emxUnresolvedEBOMStringResource", language);
	String strInvalidApplicability = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Invalidapplicability","emxUnresolvedEBOMStringResource", language);
	String strCyclicDependency     = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency","emxUnresolvedEBOMStringResource", language);
	String strMoreThanOneParent    = i18nStringNowUtil("emxUnresolvedEBOM.Common.CannotRemoveConnectedParts","emxUnresolvedEBOMStringResource", language);
	
	
	String contextECO     = emxGetParameter(request,"PUEUEBOMContextChangeFilter_actualValue");
	//String propAllowLevel = (String)com.matrixone.apps.domain.util.FrameworkProperties.getProperty("emxEngineeringCentral.Part.RestrictPartModification");
	String propAllowLevel = (String)com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.Part.RestrictPartModification");
	StringBuffer restrictedParts     = new StringBuffer();
	String strMoreThanOneParentError = "false";
	//String strMoreThanOneParentErrorMessage = com.matrixone.apps.domain.util.i18nNow.getI18nString("emxEngineeringCentral.Common.CannotRemoveConnectedParts5", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
	String strMoreThanOneParentErrorMessage = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", Local,"emxEngineeringCentral.Common.CannotRemoveConnectedParts5");
	String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
	boolean isRemoveAllowedInViewMode = true;
	String sRowIdsCanNotRemoved = "";
	//2012--Starts invoking bean with stringlist of affected items
     if ("true".equalsIgnoreCase(isWipBomAllowed) && ("unAssignPUEECO".equalsIgnoreCase(calledMethod))) {
	    
	    String     selectedParts      = emxGetParameter(request, "selectedPartsList");
	    StringList slPartObjectList   = new StringList();
	    StringTokenizer selectedIdTok = new StringTokenizer(selectedParts, "~");
	    
	    while (selectedIdTok.hasMoreTokens()){
	            String selectedInfo           = selectedIdTok.nextToken();
	            StringList selectedInfoList   = FrameworkUtil.split(selectedInfo, "|");
	            String strObjectId            = (String)selectedInfoList.get(0);
	            slPartObjectList.addElement(strObjectId);
	           }
	    
	     //PUEECO.connectOrDisconnectAffectedItemsToPUEECO(context,slPartObjectList,null,false,"");

	 }

	   if(!"unAssignPUEECO".equalsIgnoreCase(calledMethod) && sCheckBoxArray != null) 
      {
         try
         {
			 String strParentId = null;
			 if(!"edit".equals(sTableMode)){
				 StringList slSelectedObjectList = FrameworkUtil.split(
							selectedRow, "~");
				 StringList relToDisconnect = new StringList();
					for (int i = 0; i < slSelectedObjectList.size(); i++) {
						StringList tempList = FrameworkUtil.split(
								(String) slSelectedObjectList.get(i), "|");
						String ebomRel = ((String) tempList.get(0)).trim();
						String sParentObjId = ((String)tempList.get(2)).trim();
						String sChildObjId = ((String)tempList.get(1)).trim();
						String sRowId = ((String)tempList.get(3)).trim();
						if("0".equals(sRowId)){
							break;
						}
						//if(UIUtil.isNotNullAndNotEmpty(sParentObjId))
						 DomainObject parentObject = new DomainObject(sParentObjId);
						 String childName = new DomainObject(sChildObjId).getInfo(context, DomainConstants.SELECT_NAME);
						 
					     String sChangeControlled = parentObject.getInfo(context, EngineeringConstants.SELECT_ATTRIBUTE_CHANGE_CONTROLLED);
					     if("False".equals(sChangeControlled) && UIUtil.isNotNullAndNotEmpty(ebomRel)){
							//DomainRelationship.disconnect(context, ebomRel);
					    	 relToDisconnect.add(ebomRel);
					     }
					     else {
					    	 isRemoveAllowedInViewMode = false;
					    	 if("".equals(sRowIdsCanNotRemoved)){
					    		 sRowIdsCanNotRemoved = childName;
					    	 }
					    	 else {
					    		 sRowIdsCanNotRemoved = sRowIdsCanNotRemoved +"," +childName;
					    	 }
					     }
					}
					if(isRemoveAllowedInViewMode ) {
						for(int j=0;j<relToDisconnect.size();j++)
							DomainRelationship.disconnect(context, (String)relToDisconnect.get(j));
					}
						
			 }else {
		            for(int i=0; i < sCheckBoxArray.length; i++)
		            {
					   boolean allowDelete = true;
		               java.util.StringTokenizer st = new java.util.StringTokenizer(sCheckBoxArray[i], "|");
		               String sRelId  = st.nextToken();
					   String sObjId  = st.nextToken();
					   String sParentObjId = st.nextToken();
					   if (sParentObjId!=null &&!sParentObjId.equals("")) 
					   {
					       objectId = sParentObjId;
					   }
					   
					   String strNewParentId      = objectId;
					   boolean dependencyCheck    = false;
					   boolean applicabilityCheck = false;
					   strParentId = strNewParentId;
					   strInput    = strInput+ "<object objectId=\"" + objectId + "\">";
					   applicabilityCheck = true;
		
					
					if (applicabilityCheck) 
					{
		                strInput = strInput + "<object objectId=\"" + sObjId + "\" relId=\"" + sRelId + "\" relType=\"relationship_UEBOM\" markup=\"cut\"/>";
		            }
					else {
						action = "alert";
						if(applicabilityCheck == false)
							alrtMsg = strInvalidApplicability;
						else if (dependencyCheck == false)
						    alrtMsg = strCyclicDependency ;
		
		                 }
					    strInput = strInput + "</object>";
		
		            }
            }

         }

         catch(Exception Ex)
         {
                session.putValue("error.message",Ex.getMessage());
                action = "error";
                msg = Ex.getMessage();
         }
    }
//clear the output buffer
strInput = strInput + "</mxRoot>";
out.clear();
if("structureBrowser".equalsIgnoreCase(uiType))
{
 if(action.equals("alert"))
 {
%>
     <script language="javascript">
     //XSSOK
	     alert("<%=alrtMsg%>");
    </script>
     <%
   }
else
	{
    %>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
	<script language="javascript">
    var contentFrame = findFrame(parent,"listHidden");
    //XSSOK
	if('<%=removeRowSelection%>' == "true")
	{
		//XSSOK
		alert("<%=strRemoverowSelected%>");
	}
    //XSSOK
	else if('<%=strMoreThanOneParentError%>' == "true")
	{
		//XSSOK
		alert("<%=strMoreThanOneParent%>");
	}
	//XSSOK
	else if ('<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>' == "unAssignPUEECO")
	{
		contentFrame.parent.emxEditableTable.refreshStructureWithOutSort();
	}
	else
	{
		var tabMode = "<xss:encodeForJavaScript><%=sTableMode%></xss:encodeForJavaScript>";
		if(tabMode != "edit"){
			var isRemoveAllowed = <%=isRemoveAllowedInViewMode%>;
			if(!isRemoveAllowed){
				//XSSOK
				alert("<%=EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Command.RemovePartsInViewMode")%>"+"\n"+"<%=sRowIdsCanNotRemoved%>");
				
			}
			else{
        	if(contentFrame.parent.displayView && contentFrame.parent.displayView != null && contentFrame.parent.displayView != undefined){
    			if(contentFrame.parent.displayView == "tree"){
    				contentFrame.parent.location.href=contentFrame.parent.location.href;
    			}
    			else {
					var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(sCheckBoxArray, "~"))%>";
	            	parent.emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
    			}
        	}}
		}
		else{
			var callback = eval(contentFrame.parent.emxEditableTable.prototype.loadMarkUpXML);
			callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>', "true");
		}
	}
	</script>
<%
	}
   }
%>

