<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../emxContentTypeInclude.inc" %>

<%
	String selectedRow = emxGetParameter(request, "selectedRow");
	String BOMViewMode = emxGetParameter(request, "BOMViewMode");
	String WorkUnderOID = emxGetParameter(request, "WorkUnderOID");
	String selPartRowId = "";
	String sFailedMessage = "";
	out.clear();
	response.setContentType("text/plain");
	
    try{
		StringList slSelectedObjectList = FrameworkUtil.split(
				selectedRow, "~");
		StringList relToDisconnect = new StringList();
		boolean isRemoveAllowedInViewMode = true;
		String sRowIdsCanNotRemoved = "";
		for (int i = 0; i < slSelectedObjectList.size(); i++) {
			StringList tempList = FrameworkUtil.split(
					(String) slSelectedObjectList.get(i), "|");
			String ebomRel = ((String) tempList.get(0)).trim();
			String sParentObjId = ((String)tempList.get(2)).trim();
			String sChildObjId = ((String)tempList.get(1)).trim();
			String sRowId = ((String)tempList.get(3)).trim();
			if("0".equals(sRowId)){
				out.clear();
				//XSSOK
		    	out.write(EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
		        		   context.getLocale(),"emxEngineeringCentral.Part.BOM.RemoveRootNodeError"));
		    	break;
			}
			 DomainObject parentObject = new DomainObject(sParentObjId);
		     String curstate = parentObject.getInfo(context, DomainObject.SELECT_CURRENT);
		     String childName = new DomainObject(sChildObjId).getInfo(context, DomainConstants.SELECT_NAME);
		     relToDisconnect.add(ebomRel);
		}
		if(isRemoveAllowedInViewMode ) {			
			try {
				if(relToDisconnect.size() > 0){ 
					Map programMap = new HashMap();
			    	programMap.put("bomOperation","cut");
			    	programMap.put("relIds",relToDisconnect);
			    	programMap.put("BOMViewMode",BOMViewMode);
			    	programMap.put("WorkUnderOID",WorkUnderOID);
			    	StringBuffer sbf1= (StringBuffer)JPO.invoke(context, "enoUnifiedBOM", null, "updateBOMInView", JPO.packArgs(programMap),StringBuffer.class);
			    	if(UIUtil.isNotNullAndNotEmpty(sbf1.toString())){
			    		out.write(sbf1.toString());
			    	}
				}
			}		
			catch (Exception e) { throw new Exception (e.getMessage()); }
		}
		else {
			String[] messageValues = new String[1];
	         messageValues[0] = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(),"emxFramework.State.EC_Part.Preliminary");
			 String sRemoveNotAllowed = MessageUtil.getMessage(context,null,
                 "emxEngineeringCentral.Command.RemovePartsInViewMode",
                 messageValues,null,
                 context.getLocale(),"emxEngineeringCentralStringResource");
			 out.clear();
			 //XSSOK
	    	 out.write(sRemoveNotAllowed+"\n"+sRowIdsCanNotRemoved);
		}
	} catch (Exception e) {
		out.clear();
		out.write(e.getMessage());
	}
%>
 
