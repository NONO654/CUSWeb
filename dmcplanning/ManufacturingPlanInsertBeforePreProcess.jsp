<%--
  ManufacturingPlanInsertBeforePreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanUtil"%>


<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

                   
<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  {   
	 String strLanguage = context.getSession().getLanguage();      
     String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
     String arrObjIds[] = null;
     String strHelpMarker = emxGetParameter(request, "HelpMarker");
     String strObjectID = null;
	 strObjectID  = emxGetParameter(request, "objectId");
	 
	 DomainObject objContext=new DomainObject(strObjectID);
	 boolean isFromProductContext=false;
	 isFromProductContext=objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_PRODUCTS);
	 String parentId = null;
	 
	 String heading = "";
	 String formType = "";      
	 
	 String strMPBreakdownSelected = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.Error.MPBreakdownSelected",strLanguage);
	 String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.RowSelect.Single",strLanguage);
	 String strRootMP = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.InsertBefore.OnRoot",strLanguage);
	 String strFrozenMP = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.InsertBefore.FrozenState",strLanguage);
     String strBeforeDerivation = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.InsertBefore.Derivation", strLanguage);
	 heading = "DMCPlanning.Form.Heading.insertDerivation";
	 formType = "CFPInsertBeforeManufacturingPlanForm";

		 if(arrTableRowIds==null ||(arrTableRowIds.length ==0|| arrTableRowIds.length > 1)){
		     %>
		     <script language="javascript" type="text/javaScript">
		           alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectSingle)%>");
		     </script>
		    <%       
		 }else{
			   boolean isRootSelected=false;
		       StringList sl=FrameworkUtil.split(arrTableRowIds[0] , "|");
		       String strLevel=sl.get(sl.size()-1).toString();
		       StringList sl2=FrameworkUtil.split(strLevel , ",");
		    
		       if(sl2.size()==2)
		    	   isRootSelected=true;
		     
		       arrObjIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
			   StringTokenizer st = new StringTokenizer(arrObjIds[0],"|");
			   String strSelObjectID = st.nextToken();
			  
			    //boolean isRoot=new DomainObject(strSelObjectID).hasRelatedObjects(context, ManufacturingPlanConstants.RELATIONSHIP_MANAGED_ROOT, false);
			    boolean isRoot =DerivationUtil.isRootNode(context,strSelObjectID);
			    boolean isFrozenMP=ManufacturingPlan.isFrozenState(context,strSelObjectID);
		        String strDerivationType = DerivationUtil.getDerivationType(context, strSelObjectID);
		        boolean isDerivation = strDerivationType.equals(DerivationUtil.DERIVATION_TYPE_DERIVATION);

		        if(isFromProductContext && sl2.size()>2){
                %>
	 	 		     <script language="javascript" type="text/javaScript">
	 	 		           alert("<%=XSSUtil.encodeForJavaScript(context,strMPBreakdownSelected)%>");
	 	 		     </script>
	 	 		<%
	 	 		}else if(isFrozenMP){
 	     		%>
 	 		         <script language="javascript" type="text/javaScript">
 	 		               alert("<%=XSSUtil.encodeForJavaScript(context,strFrozenMP)%>");
 	 		         </script>
 	 		    <%
 	 		    }else if(isRoot){
 	      		%>
 	 		         <script language="javascript" type="text/javaScript">
 	 		             alert("<%=XSSUtil.encodeForJavaScript(context,strRootMP)%>");
 	 		         </script>
                <%
                }else if(!Product.isInsertBeforeDerivationEnabled(context) && isDerivation){
                %>
                     <script language="javascript" type="text/javaScript">
                        alert("<%=XSSUtil.encodeForJavaScript(context,strBeforeDerivation)%>");
                     </script>
 	 		    <%
 	 		    }else{
	 	 		  ManufacturingPlan mPlan = new ManufacturingPlan(strSelObjectID);
	              Map parentMPDetails=mPlan.getManufacturingPlanParent(context);
	              String parentMPID=(String)parentMPDetails.get(DomainObject.SELECT_ID);
	  			  String contextIDSelectable = "to["
					+ ManufacturingPlanConstants.RELATIONSHIP_ASSOCIATED_MANUFACTURING_PLAN
					+ "].from.id";
	  			  String parentMPContextID=(String)parentMPDetails.get(contextIDSelectable);
				  DomainObject domSelObj=new DomainObject(strSelObjectID);
				  String strSelType=domSelObj.getInfo(context,DomainObject.SELECT_TYPE);
				  String strSymbolicName = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strSelType, true);
	              %>
		          <body>   
		          <form name="MPDerivationInsert" method="post">
		          <script language="Javascript">
	              var isFromProductContext=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>;
	              var submitURL="";
	              if(isFromProductContext)
	          	    submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,parentMPID)%>&derivedFromID=<%=XSSUtil.encodeForURL(context,parentMPID)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&parentMPContextID=<%=XSSUtil.encodeForURL(context,parentMPContextID)%>&createJPO=ManufacturingPlan:insertManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=refreshCaller&preProcessJavaScript=populatefieldOnLoad&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&isFromProductContext=<%=XSSUtil.encodeForURL(context,String.valueOf(isFromProductContext))%>";
	          	  else
	          		submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,parentMPID)%>&derivedFromID=<%=XSSUtil.encodeForURL(context,parentMPID)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&parentMPContextID=<%=XSSUtil.encodeForURL(context,parentMPContextID)%>&createJPO=ManufacturingPlan:insertManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=XMLMessage&preProcessJavaScript=populatefieldOnLoad&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&isFromProductContext=<%=XSSUtil.encodeForURL(context,String.valueOf(isFromProductContext))%>&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../dmcplanning/ManufacturingPlanInsertBeforePostProcess.jsp";
	        	    getTopWindow().showSlideInDialog(submitURL, "true");
		          </script>
		          </form>
		          </body>
	              <%
	           }
       }
   }
  catch(Exception e)
     {
            bIsError=true;
            session.putValue("error.message", e.getMessage());
     }
     %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
