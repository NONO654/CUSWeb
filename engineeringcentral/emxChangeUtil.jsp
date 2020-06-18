<%--emxChangeUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
  --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.engineering.ECR"%>
<%@page import="com.matrixone.apps.engineering.ECO"%>
<%@page import="com.matrixone.apps.engineering.Change"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>

<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>


<%
	String TYPE_PART_MARKUP = PropertyUtil.getSchemaProperty(context,"type_PARTMARKUP");
	String TYPE_EBOM_MARKUP = PropertyUtil.getSchemaProperty(context,"type_EBOMMarkup");
	String TYPE_MECO = PropertyUtil.getSchemaProperty(context,"type_MECO");

	String RELATIONSHIP_APPLIED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
	String RELATIONSHIP_PROPOSED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_ProposedMarkup");
	String RELATIONSHIP_AFFECTED_ITEM = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");

	boolean blnInvalidTypeError = false;
	boolean blnApprovedMarkupError = false;

	String strMode   = emxGetParameter(request, "mode");
	String strFunctionality   = emxGetParameter(request, "functionality");    
	String strTreeId = emxGetParameter(request,"jsTreeID");
	String objectId  = emxGetParameter(request, "objectId"); 
	String strLanguage = context.getSession().getLanguage();    
	boolean bIsError = false; 
	boolean bIsRemoved= false; 

	try
	{
		//EngineeringChange ECBean = (EngineeringChange)DomainObject.newInstance(context,DomainConstants.TYPE_ENGINEERING_CHANGE);
		DomainObject dObject = new DomainObject();
		String strTypeName = dObject.getTypeName();

		if (strMode!=null && strMode.equalsIgnoreCase("disconnectAssignee")) 
		{
			//get the table row ids of the objects selected
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //get the relationship ids of the table row ids passed from the EC Bean 
            Map relIdMap=Change.getObjectIdsRelIds(arrTableRowIds);

			String[] arrRelIds = (String[]) relIdMap.get("RelId");
			String[] strObjectIds = (String[]) relIdMap.get("ObjId");

			//Map for passing to the bean
			  HashMap programMap = new HashMap();
              programMap.put("arrRelIds[]",arrRelIds);
              programMap.put("strObjectIds[]",strObjectIds);
              programMap.put("objectId",objectId);
              String jpoName = "enoEngChange";
              String[] intArgs = new String[]{};
              String methodName = "removeAssignee";

			  StringList strRelIdsRetainPersonName = new StringList(arrRelIds.length); 

			Change changeObject = new Change();
			// Removing Person Objects and returning those objects which cannot be removed
			strRelIdsRetainPersonName = (StringList)changeObject.removeAssignee(context, programMap);
		 
			String language  = request.getHeader("Accept-Language");
			//Multitenant
			//String strWarning = i18nNow.getI18nString("emxEngineeringCentral.Assignee.RemoveAssigneeError","emxEngineeringCentralStringResource", language);
			String strWarning = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Assignee.RemoveAssigneeError");

			 String strPersonName = strRelIdsRetainPersonName.toString();
			 strWarning= strWarning.concat(strPersonName);
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
	if((strRelIdsRetainPersonName.size())!=0)
		  {
	// Putting an Alert anf Refreshing the List Page subsequently.
%>

<Script language="JavaScript">
//XSSOK
alert("<%=strWarning%>");

</Script>

<%
		}
%>

<Script language="JavaScript">
getTopWindow().refreshTablePage();
</Script>
<%
		}


 else if (strMode!=null && strMode.equalsIgnoreCase("disconnectAffectedItem")) 
        {
     
			//get the table row ids of the test case objects selected
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
             int sRowIdsCount = arrTableRowIds.length;
			//get the object ids of the tablerow ids passed
            //get the relationship ids of the table row ids passed
            Map relIdMap=Change.getObjectIdsRelIds(arrTableRowIds);
            String[] arrRelIds = (String[]) relIdMap.get("RelId");
            String[] strObjectIds = (String[]) relIdMap.get("ObjId");

            int intNumSelectedIds = strObjectIds.length;

            String strMarkupRelName = RELATIONSHIP_PROPOSED_MARKUP;

			DomainObject doChange = new DomainObject(objectId);
			if (doChange.isKindOf(context, DomainConstants.TYPE_ECO)|| doChange.isKindOf(context, TYPE_MECO))
			{
				strMarkupRelName = RELATIONSHIP_APPLIED_MARKUP;
			}

			String objectWhere = "(to[" + strMarkupRelName + "].from.id == " + objectId + ") && (current == \"" + DomainConstants.STATE_EBOM_MARKUP_APPROVED + "\")";

            DomainObject doAffectedItem = null;
            MapList mapListMarkups = new MapList();

            Map mapPartDetails = null;

          	//Multitenant
            //String strInvalidItems = i18nNow.getI18nString("emxEngineeringCentral.AffectedItems.InvalidTypeError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
            String strInvalidItems = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.AffectedItems.InvalidTypeError"); 
	        //Multitenant
            //String strApprovedMarkupItems = i18nNow.getI18nString("emxEngineeringCentral.AffectedItems.HasApprovedMarkups", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
          	String strApprovedMarkupItems = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.AffectedItems.HasApprovedMarkups");

			String strAIName = null;
			String strAIType = null;
			String strAIRev = null;

			StringList strlPartSelects = new StringList(3);
			strlPartSelects.add(DomainConstants.SELECT_TYPE);
			strlPartSelects.add(DomainConstants.SELECT_NAME);
			strlPartSelects.add(DomainConstants.SELECT_REVISION);
			
			StringList relIds = new StringList();
			StringTokenizer tokens = null;
			String partId = "";

            for (int k = 0; k < intNumSelectedIds; k++) {
				doAffectedItem = new DomainObject(strObjectIds[k]);

				mapPartDetails = doAffectedItem.getInfo(context, strlPartSelects);

				strAIName = (String) mapPartDetails.get(DomainConstants.SELECT_NAME);
				strAIType = (String) mapPartDetails.get(DomainConstants.SELECT_TYPE);
				strAIRev = (String) mapPartDetails.get(DomainConstants.SELECT_REVISION);

				if (doAffectedItem.isKindOf(context, TYPE_PART_MARKUP) || doAffectedItem.isKindOf(context, TYPE_EBOM_MARKUP))
				{
					blnInvalidTypeError = true;
					strInvalidItems = strInvalidItems + " " + strAIType + " " + strAIName + " " + strAIRev;
					break;
				}

				if (doAffectedItem.isKindOf(context, DomainConstants.TYPE_PART))
				{
					// retrieve the markups that are unique to Part and ECR/ECO.
					mapListMarkups =	doAffectedItem.getRelatedObjects(context,
																	 DomainConstants.RELATIONSHIP_EBOM_MARKUP,
																	 "*",
																	 new StringList(DomainConstants.SELECT_ID),
																	 null,
																	 false,
																	 true,
																	 (short)1,
																	 objectWhere,
																	 null);

					if (mapListMarkups.size() > 0)
					{
						blnApprovedMarkupError = true;
						strApprovedMarkupItems = strApprovedMarkupItems + " " + strAIType + " " + strAIName + " " + strAIRev;
						break;
					}
				}

            }
            
            if (blnInvalidTypeError)
			{
%>
			<script language="javascript" type="text/javaScript">
			//XSSOK
			alert("<%=strInvalidItems%>");
			</script>
<%
			}
			else if (blnApprovedMarkupError)
			{
%>
			<script language="javascript" type="text/javaScript">
			//XSSOK
			alert("<%=strApprovedMarkupItems%>");
			</script>
<%			}
			else
			{
			String jpoName = "enoEngChange";
			HashMap programMap = new HashMap();
			 programMap.put("arrTableRowIds", arrTableRowIds);
			 programMap.put("arrRelIds", arrRelIds);
			 programMap.put("changeId",objectId); //370192
			String methodName = "removeAffectedItems";
			 // JPO.invoke(context,jpoName,intArgs, methodName,methodargs1,String.class); 
           Change changeObject=new Change();
          changeObject.removeAffectedItems(context,jpoName,methodName,programMap);

            
			
            //refresh the tree after disconnect
%>
            <script language="javascript" type="text/javaScript">
<%
            for(int i=0;i<strObjectIds.length;i++){
				java.util.StringTokenizer strTokens = new java.util.StringTokenizer(strObjectIds[i],"|");
		    	String strObjs = strTokens.nextToken();
%>              
				var tree = getTopWindow().trees['emxUIDetailsTree'];
				if(tree){
				if (tree.root != null)
                {
					//XSSOK
                tree.getSelectedNode().removeChild("<xss:encodeForJavaScript><%=strObjs.trim()%></xss:encodeForJavaScript>");
                }
                }
                 //]]>
<%
            }
%>
            refreshTreeDetailsPage();
            //]]>
           </script>
<%
    }
    }
        
   else if (strMode!=null && strMode.equals("createnewrevision"))
   {
    
       //this if code is for creating new revision for afftected items based on the
       //value of Requested Change attribute
       String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
       Map relIdMap=Change.getObjectIdsRelIds(arrTableRowIds);
       String[] strObjectIds = (String[]) relIdMap.get("ObjId");
       HashMap programMap = new HashMap();
       programMap.put("arrTableRowIds",arrTableRowIds);
       programMap.put("strObjectIds",strObjectIds);
       programMap.put("objectId",objectId);
       String jpoName = "enoEngChange";
       String[] intArgs = new String[]{};
       String methodName = "createNewRevisionForAffectedItem";
       Change changeObject=new Change();
       changeObject.createNewRevisionForAffectedItem(context,jpoName,methodName,programMap);
                            
	 }     
		
    
	} catch (Exception e)
	{
	    e.printStackTrace();
	}
  %>          
  
  <%@include file = "emxEngrVisiblePageInclude.inc"%>
  <Script language="JavaScript">
	getTopWindow().refreshTablePage();
</Script>
