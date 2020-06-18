<%-- EnterpriseChangeMgtCandidateItemIntermediate.jsp 
  
  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
  
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
  
  static const char RCSID[] = $Id: ImpactAnalysisUtil.jsp.rca 1.6 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $  
 --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
    String strMode = null;
	StringBuffer sbObjectTemp = new StringBuffer(10);
    StringBuffer sbRelTemp = new StringBuffer(10);
	String strParentId = emxGetParameter(request, "objectId");
	//getting table row ids from the list page
	String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	Map map = changeUXUtil.getObjectIdsRelIdsMapFromTableRowID(strTableRowIds);
	StringList slRelIds = (StringList)map.get("RelId");
	StringList slObjectIds = (StringList)map.get("ObjId");
	String type = ChangeConstants.TYPE_CHANGE_ORDER;
	String Current = "policy_FormalChange.state_Propose,policy_FormalChange.state_Prepare";
	
	if(DomainObject.newInstance(context, strParentId).isKindOf(context, ChangeConstants.TYPE_CHANGE_REQUEST)){
		type = ChangeConstants.TYPE_CHANGE_REQUEST;
		Current = "policy_ChangeRequest.state_Create,policy_ChangeRequest.state_Evaluate";		
	}
	
    try 
    {
        //Getting the mode from the Command
        strMode = emxGetParameter(request,"mode");
        
        if("CopyToChange".equalsIgnoreCase(strMode)) 
        {
           for(Object e : slObjectIds)
           {
        	   if(sbObjectTemp.length() != 0)
        	   {
        		   sbObjectTemp.append("|");
        		   sbObjectTemp.append(e);
          	   }
        	   else
        		   sbObjectTemp.append(e);
           }
      
            %>
            <script>
            var contentURL = "../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context, type)%>:CURRENT=<%=XSSUtil.encodeForURL(context, Current)%>&table=AEFGeneralSearchResults&selection=single&excludeOID=<%=XSSUtil.encodeForURL(context, strParentId)%>&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=CopyToChange&ObjectIDs=<%=XSSUtil.encodeForURL(context, sbObjectTemp.toString())%>&contextCOId=<%=XSSUtil.encodeForURL(context, strParentId)%>";
            //window.location.href = contentURL;
			showModalDialog(contentURL, "600", "500", true);
            </script>
            <%
        }
        
        if("MoveToChange".equalsIgnoreCase(strMode)) 
        {
            for(Object e : slObjectIds)
            {
         	   if(sbObjectTemp.length() != 0)
         	   {
         		  sbObjectTemp.append("|");
         		  sbObjectTemp.append(e);
         	   }
         	   else
         		  sbObjectTemp.append(e);      	   
            }
            for(Object e : slRelIds)
            {
         	   if(sbRelTemp.length() != 0)
         	   {
         		  sbRelTemp.append("|");
         		  sbRelTemp.append(e);
         	   }
         	   else
         		  sbRelTemp.append(e);      	   
            }
            
            %>
            <script>
            var contentURL = "../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context, type)%>:CURRENT=<%=XSSUtil.encodeForURL(context, Current)%>&table=AEFGeneralSearchResults&selection=single&excludeOID=<%=XSSUtil.encodeForURL(context, strParentId)%>&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=MoveToChange&ObjectIDs=<%=XSSUtil.encodeForURL(context, sbObjectTemp.toString())%>&RelIDs=<%=XSSUtil.encodeForURL(context, sbRelTemp.toString())%>&contextCOId=<%=XSSUtil.encodeForURL(context, strParentId)%>";
            //window.location.href = contentURL;
			showModalDialog(contentURL, "600", "500", true);
            </script>
            <%
        } 
    }
    catch(Exception ex)
    {
    	ex.printStackTrace();
        throw ex;
    }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

