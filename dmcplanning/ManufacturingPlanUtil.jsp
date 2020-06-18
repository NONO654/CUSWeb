<%--
ManufacturingPlanUtil.jsp
Copyright (c) 1993-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of 
Dassault Systemes.
Copyright notice is precautionary only and does not evidence any actual
or intended publication of such program

static const char RCSID[] = "$Id: /web/configuration/ManufacturingPlanUtil.jsp 1.86.2.5.1.1.1.5.1.8 Fri Jan 16 14:21:52 2009 GMT ds-shbehera Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../components/emxComponentsCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>

<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.dmcplanning.Model"%>
<html>
<head>
<script language="javascript">
<%
String language  = request.getHeader("Accept-Language");
String validateMsg = i18nStringNowUtil("DMCPlanning.Error.NoManufacturingPlans","dmcplanningStringResource", language);
String subMPMsg = i18nStringNowUtil("DMCPlanning.Error.NoSubManPlanSelect","dmcplanningStringResource", language);
String strObjId = emxGetParameter(request, "objectId");
boolean isFromProductContext=false;
DomainObject objContext=null;
if(strObjId!=null){
	objContext=new DomainObject(strObjId);
	isFromProductContext=objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_PRODUCTS);
}
%>
function processOperation(objId,selectId)
{
    var dupemxUICore = undefined;
    var mxRoot = undefined;
    var contentFrame   = findFrame(getTopWindow(),"listHidden");
    var xmlRef = contentFrame.parent.oXML;
    var validateMsg = "<%=XSSUtil.encodeForJavaScript(context,validateMsg)%>";
    var subMPMsg = "<%=XSSUtil.encodeForJavaScript(context,subMPMsg)%>";
    var isFromProductContext="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>";
    if(xmlRef!=undefined)
    {
        dupemxUICore   = contentFrame.parent.emxUICore;
        mxRoot         = contentFrame.parent.oXML.documentElement;
    }
    //If the Manufacturing Plans exist for the Product then levelOne will not be null,else throw an alert
    var levelOne    = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@level=1]");
    var checkedRows = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@checked='checked']");
    var flagSubMP = false;
    for(var i=0; i<checkedRows.length;i++){ 
        var chkLev = checkedRows[i].getAttribute("level");
        //If a root node is selected then show all context Manufacturing Plans
        if(chkLev==0 && !isFromProductContext){
            selectId ="";
        }
        if(chkLev==1){
            flagSubMP = true;
            break;
        }       
    }
    /*if(levelOne==null){
        alert(validateMsg);
    }
    else*/ if(flagSubMP && isFromProductContext=="true"){
        alert(subMPMsg);
    }else{
        //IR-031364V6R2011
        //getTopWindow().window.showNonModalDialog("../common/emxIndentedTable.jsp?expandProgram=ManufacturingPlan:expandManufacturingPlanMatrix&table=CFPViewManufacturingPlanMatrixTable&freezePane=Name&header=DMCPlanning.Heading.ViewManufacturingPlanMatrix&objectId="+objId+"&selectId="+selectId+"&expandLevelFilterMenu=&suiteKey=DMCPlanning&toolbar=&HelpMarker=emxhelpmanufacturingplanmatrixview",1200,650);
        getTopWindow().window.showModalDialog("../common/emxIndentedTable.jsp?expandProgram=ManufacturingPlan:expandManufacturingPlanMatrix&table=CFPViewManufacturingPlanMatrixTable&freezePane=Name&header=DMCPlanning.Heading.ViewManufacturingPlanMatrix&objectId="+objId+"&selectId="+selectId+"&expandLevelFilterMenu=&suiteKey=DMCPlanning&toolbar=&HelpMarker=emxhelpmanufacturingplanmatrixview",1200,650);    

    }
}
</script>

<body>
<form name="ManufacturingPlanForm" target="listHidden" method="post">

<%

String strMode = emxGetParameter(request,"mode");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String objectId = emxGetParameter(request, "objectId");
String[] emxTableRowId = emxGetParameterValues(request,"emxTableRowId");
String strContext = emxGetParameter(request, "context");
String uiType = emxGetParameter(request,"uiType");
String suiteKey = emxGetParameter(request, "suiteKey");
String registeredSuite = emxGetParameter(request,"SuiteDirectory");
String strLanguage = context.getSession().getLanguage();
String strObjectName = "";
String strRevision = "";
boolean bIsError = false;
boolean isMpInRelease = false;
boolean isStateConflict = false;
try{
    String strContextObjectId = "";
    String strSelectedObjectId[] = emxGetParameterValues(request,"selObjId");
    
    if(strSelectedObjectId!= null){
        strContextObjectId = strSelectedObjectId[0];  
    }
    StringBuffer bn = new StringBuffer();
    if(emxTableRowId != null){
        String[] arrBusIdList = new String[emxTableRowId.length];
        StringBuffer sbObjectid = null;
        for (int i = 0; i < emxTableRowId.length; i++)
        {
            sbObjectid = new StringBuffer(emxTableRowId[i]);
            int iCount = sbObjectid.length();
            int iPosition = emxTableRowId[i].indexOf("|");
            if (iPosition == -1) {
                arrBusIdList[i] = emxTableRowId[i];
            }
            else {
                arrBusIdList[i] = emxTableRowId[i].substring(iPosition + 1, iCount);
            }
        }   
        for(int i=0;i<arrBusIdList.length;i++)
        {   
            String strObjectId=arrBusIdList[i].substring(0,arrBusIdList[i].indexOf("|"));
            bn.append(strObjectId+",");
        }
        if(objContext.isKindOf(context, ManufacturingPlanConstants.TYPE_MODEL)){
        	 DomainObject strSelectDOM= new DomainObject(bn.toString());
        	 String strPlannedForSelectedMP=strSelectDOM.getInfo(context, "to["+ManufacturingPlanConstants.RELATIONSHIP_ASSOCIATED_MANUFACTURING_PLAN+"].from.id");
        	 strObjId=strPlannedForSelectedMP;
         }
    }
    if(strMode.equalsIgnoreCase("")){
        try{
            %>
            <script language="javascript">
            window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
            window.getTopWindow().closeWindow();
            </script>
            <%
        }catch(Exception e){
            bIsError=true;
            session.putValue("error.message", e.toString());
        }
    }
    
    else if(strMode.equalsIgnoreCase("ViewManufacturingPlan"))   
    {
        %>
        <script language="javascript" type="text/javaScript">
        var objId = '<%=XSSUtil.encodeForJavaScript(context,strObjId)%>'; 
        var selectId = '<%=XSSUtil.encodeForJavaScript(context,bn.toString())%>'; 
        processOperation(objId,selectId);      
         </script>
        <%  
    }

    else if(strMode.equalsIgnoreCase("editManufacturingPlanBreakdown"))
    {
            String strObjectId = emxGetParameter(request,"objectId");
            String strParentId = emxGetParameter(request,"parentOID");
            String selObjId = emxGetParameter(request,"selObjId");
            String strRemMPRelIds = emxGetParameter(request,"strRemMPRelIds");
            
            ManufacturingPlan manuPlan=null;
            String strRelId = "";
            
            if(emxTableRowId!=null && emxTableRowId.length>0){
                StringTokenizer strRowIdTZ = new StringTokenizer(emxTableRowId[0],"|");

                if(strContext.equalsIgnoreCase("Products")){
                    if(strRowIdTZ.hasMoreElements()){
                        strRelId = strRowIdTZ.nextToken();
                    }
                    if(strRowIdTZ.hasMoreElements()){
                        strObjectId = strRowIdTZ.nextToken();
                    }
                    if(strRowIdTZ.hasMoreElements()){
                        strParentId = strRowIdTZ.nextToken();
                    }
                }else{
                    if(strRowIdTZ.hasMoreElements()){
                        strRelId = strRowIdTZ.nextToken();
                    }
                    strObjectId = objectId;
                    strParentId = new DomainObject(objectId).getInfo(context, "to["+ManufacturingPlanConstants.RELATIONSHIP_ASSOCIATED_MANUFACTURING_PLAN+"].from.id");
                }
            }
             if(strObjectId.equalsIgnoreCase("0")&& strContext.equalsIgnoreCase("Products"))
              {
                      %>
                          <script language="javascript" type="text/javaScript">
                          var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.RootNode","dmcplanningStringResource",language)%> ";
                          alert(msg);
                          </script>  
                      <% 
               }else if((strObjectId!=null && !strObjectId.equalsIgnoreCase("")) && (strParentId!=null && !strParentId.equalsIgnoreCase("")))
               {
            	   
            	   if(null == selObjId || "".equals(selObjId) || "null".equals(selObjId)){
            		   selObjId = strObjectId; 
            	   }
                //Define target URL
                String strURL = "";
                if(selObjId!=null && !selObjId.equalsIgnoreCase("")){
                	 DomainObject domMP = new DomainObject(selObjId);
                     //String strState = (String)domMP.getInfo(context,DomainConstants.SELECT_CURRENT);
                     if(ManufacturingPlan.isFrozenState(context,selObjId))
                     {
                         isMpInRelease = true;
                     }
                     else{                    
                    	    strURL = "../common/emxIndentedTable.jsp?objectId="+strParentId+"&parentOID="+strParentId+"&selObjId="+selObjId+"&expandProgram=ManufacturingPlan:getManufacturingPlanEditBreakdown&selection=multiple&mode=edit&table=CFPEditManufacturingPlanBreakdownTable&header=DMCPlanning.Heading.ManufacturingPlanBreakDown&subHeader="+strObjectName+" "+strRevision+"&toolbar=CFPEditManufacturingPlanBreakdownToolbar&connectionProgram=ManufacturingPlan:connectManufacturingPlan&SuiteDirectory=DMCPlanning&suiteKey=DMCPlanning&expandLevelFilterMenu=FTRExpandAllLevelFilter&triggerValidation=false&multiColumnSort=false&massUpdate=false&objectCompare=false&massPromoteDemote=false&HelpMarker=emxhelpmanufacturingplanbreakdownedit&postProcessJPO=ManufacturingPlan:refreshManufacturingPlanEditBreakdown";
                    	    manuPlan=new ManufacturingPlan(selObjId);
                    	  //Added for IR-078267V6R2012 
                            session.setAttribute("ctxMPPlan",selObjId);
                            //End of IR-078267V6R2012 
                     }
                }else if (strContext.equalsIgnoreCase("Products")){
                     DomainObject domMP = new DomainObject(strObjectId);
                        String strState = (String)domMP.getInfo(context,DomainConstants.SELECT_CURRENT);
                        if(strState.equalsIgnoreCase(ManufacturingPlanConstants.STATE_RELEASE))
                        {
                            isMpInRelease = true;
                        }
                        else{
                        strURL = "../common/emxIndentedTable.jsp?objectId="+strParentId+"&parentOID="+strParentId+"&selObjId="+strObjectId+"&expandProgram=ManufacturingPlan:getManufacturingPlanEditBreakdown&selection=multiple&mode=edit&table=CFPEditManufacturingPlanBreakdownTable&header=DMCPlanning.Heading.ManufacturingPlanBreakDown&subHeader="+strObjectName+" "+strRevision+"&toolbar=CFPEditManufacturingPlanBreakdownToolbar&connectionProgram=ManufacturingPlan:connectManufacturingPlan&SuiteDirectory=DMCPlanning&suiteKey=DMCPlanning&expandLevelFilterMenu=FTRExpandAllLevelFilter&triggerValidation=false&multiColumnSort=false&massUpdate=false&objectCompare=false&massPromoteDemote=false&HelpMarker=emxhelpmanufacturingplanbreakdownedit&postProcessJPO=ManufacturingPlan:refreshManufacturingPlanEditBreakdown";
                        manuPlan=new ManufacturingPlan(strObjectId);
                        //Added for IR-078267V6R2012 
                        session.setAttribute("ctxMPPlan",strObjectId);
                        //End of IR-078267V6R2012 
                        }
                }else if(strContext.equalsIgnoreCase("ManufacturingPlan"))
                {
                	DomainObject domSelectedObject = new DomainObject(strObjectId);
                    String strState = (String)domSelectedObject.getInfo(context,DomainConstants.SELECT_CURRENT);
                    if(strState.equalsIgnoreCase(ManufacturingPlanConstants.STATE_RELEASE))
                    {
                        isMpInRelease = true;
                    }
                    else{                    
                    strParentId = domSelectedObject.getInfo(context, "to["+ManufacturingPlanConstants.RELATIONSHIP_ASSOCIATED_MANUFACTURING_PLAN+"].from.id");
                    strURL = "../common/emxIndentedTable.jsp?objectId="+strParentId+"&parentOID="+strParentId+"&selObjId="+strObjectId+"&expandProgram=ManufacturingPlan:getManufacturingPlanEditBreakdown&selection=multiple&mode=edit&table=CFPEditManufacturingPlanBreakdownTable&header=DMCPlanning.Heading.ManufacturingPlanBreakDown&subHeader="+strObjectName+" "+strRevision+"&toolbar=CFPEditManufacturingPlanBreakdownToolbar&connectionProgram=ManufacturingPlan:connectManufacturingPlan&SuiteDirectory=DMCPlanning&suiteKey=DMCPlanning&expandLevelFilterMenu=FTRExpandAllLevelFilter&triggerValidation=false&multiColumnSort=false&massUpdate=false&objectCompare=false&massPromoteDemote=false&HelpMarker=emxhelpmanufacturingplanbreakdownedit&postProcessJPO=ManufacturingPlan:refreshManufacturingPlanEditBreakdown";
                    manuPlan=new ManufacturingPlan(strObjectId);
                    }
                }
                
                //Check Manufacturing Plan Implements and updade if needed
              if(manuPlan!=null){
            	     //Modified for IR-077763V6R2012
                     MapList unresolvedDesignToImplementObjects=null;
                     com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(strParentId);
                     unresolvedDesignToImplementObjects = product.editManufacturingPlanImplements(context,manuPlan);
                     //End of IR-077763V6R2012
                       if(unresolvedDesignToImplementObjects!=null && !unresolvedDesignToImplementObjects.isEmpty()){
                    	   session.setAttribute("RemMPRelIDs",strRemMPRelIds);
                        //Get OR Design list
                            //diplay OR resolution window
                            %>
                            <script language="javascript" type="text/javaScript">
                           // var vURL="../dmcplanning/ManufacturingPlanResolutionFS.jsp?mode=edit&objectId=<%=strParentId%>&parentOID=<%=strParentId%>&selObjId=<%=strObjectId%>";
                           var vURL="../components/emxCommonFS.jsp?functionality=ManufacturingPlanResolution&suiteKey=DMCPlanning&mode=edit&objectId=<%=XSSUtil.encodeForURL(context,strParentId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&selObjId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";

                           //Modified for IR-202514V6R2014
                           
                           //showModalDialog(vURL,600,600);
                            getTopWindow().location.href =vURL; 

                            //End of IR-202514V6R2014 
                           
                            </script>
                            <%
                            //perform disconnect and connect in the other jsp
                            //recall jsp
                        }   
               }
                //Display Manufacturing Plan Breakdown window
                %>
                <script language="javascript" type="text/javaScript">
                     var url = '<%=XSSUtil.encodeForJavaScript(context,strURL)%>';
                     var contextMP = '<%=XSSUtil.encodeForJavaScript(context,selObjId)%>';
                     var RemMPRelIDs = '<%=XSSUtil.encodeForJavaScript(context,strRemMPRelIds)%>';
                     var urlParams = "mode=disconnectMPForSync&RemMPRelIDs="+RemMPRelIDs+"&contextMPID="+contextMP;
                     emxUICore.getDataPost("../dmcplanning/ManufacturingPlanUtil.jsp", urlParams);
                     //showModalDialog(url,1400,900);
                     var listFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'CFPProductManufacturingPlanComposition');
                     if(listFrame==null)
                     listFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'detailsDisplay');
        			 if(listFrame!=null){
        				 listFrame.editableTable.loadData();
        				 listFrame.rebuildView();          				        
            	     }
                     getTopWindow().location.href =url;            
                </script>
                <%
            }
    }
    else if(strMode.equalsIgnoreCase("getFormDerivationLevelField")){
	    String objectID = emxGetParameter(request,"objectID");
	    String strType = emxGetParameter(request,"strType");
        String strDerivationType = emxGetParameter(request,"derivationType");
        String fieldName = "DerivationLevel";
        String htmlString = DerivationUtil.getDerivationLevelFormField 
                (context, objectID, strType, fieldName, "DMCPlanning", strDerivationType);
        out.println("htmlString=");
	    out.println(htmlString);
	    out.println("#");
    }
    else if(strMode.equalsIgnoreCase("updateUnresolvedDesignObjects")){
        String objectTempId = emxGetParameter(request,"objectId");
        String parentTempOID = emxGetParameter(request,"parentOID");
        String selObjTempId = emxGetParameter(request,"selObjId");
        String masterList = emxGetParameter(request,"masterList");
        String refreshMode = emxGetParameter(request,"refreshMode");
        if(masterList!=null && !masterList.equalsIgnoreCase("")){
            java.util.StringTokenizer stTk = new java.util.StringTokenizer(masterList,"[,],,",false);
            while(stTk.hasMoreTokens()){
                String masterId = stTk.nextToken().replaceAll(" ","");
                if(masterId!=null && !masterId.equalsIgnoreCase("")){
                    String selectedId = emxGetParameter(request,masterId);
                    if(selectedId!=null && !selectedId.equalsIgnoreCase("")){
                        if(selObjTempId!=null && !selObjTempId.equalsIgnoreCase("")){
                            DomainObject selObjTempDom = new DomainObject(selObjTempId);
                            //Get objects all revisions
                            //java.util.List listRevisions = new com.matrixone.apps.configuration.BooleanOptionCompatibility().getAllRevisions(context,selectedId);
                            java.util.List listRevisions=new Model(masterId).getManagedRevisions(context);
                            MapList relatedImplementedObjects = selObjTempDom.getRelatedObjects(context,
                                    ManufacturingPlanConstants.RELATIONSHIP_MANUFACTURING_PLAN_IMPLEMENTS,
                                    ManufacturingPlanConstants.TYPE_LOGICAL_FEATURE + "," + ManufacturingPlanConstants.TYPE_PRODUCTS,
                                    new StringList(DomainConstants.SELECT_ID),
                                    new StringList(DomainConstants.SELECT_RELATIONSHIP_ID),
                                    false,  //to relationship
                                    true,   //from relationship
                                    (short)1,
                                    DomainConstants.EMPTY_STRING, //objectWhereClause
                                    DomainConstants.EMPTY_STRING, //relationshipWhereClause
                                    0);
                            
                            //Check that relationship doesn't already exist
                            Boolean isAlreadyConnected = false;
                            if(relatedImplementedObjects!=null && !relatedImplementedObjects.isEmpty()){
                                Iterator relatedImplementedObjectsItr = relatedImplementedObjects.iterator();
                                while(relatedImplementedObjectsItr.hasNext()){
                                    Map relatedImplementedObject = (Map)relatedImplementedObjectsItr.next();
                                    if(relatedImplementedObject!=null && !relatedImplementedObject.isEmpty()){
                                        String relatedImplementedObjectId = (String)relatedImplementedObject.get(DomainConstants.SELECT_ID);
                                        if(relatedImplementedObjectId!=null && !relatedImplementedObjectId.equalsIgnoreCase("")){
                                            if(relatedImplementedObjectId.equalsIgnoreCase(selectedId)){
                                                isAlreadyConnected = true;
                                            }else{
                                                //Check that other revisions is not connected to to MP
                                                for(int i=0;i<listRevisions.size();i++){
                                                    String listRevisionId = (String)listRevisions.get(i);
                                                    if(listRevisionId!=null && !listRevisionId.equalsIgnoreCase("")){
                                                        if(listRevisionId.equalsIgnoreCase(relatedImplementedObjectId)){
                                                            String relatedImplementedObjectRelId = (String)relatedImplementedObject.get(DomainConstants.SELECT_RELATIONSHIP_ID);
                                                            if(relatedImplementedObjectRelId!=null && !relatedImplementedObjectRelId.equalsIgnoreCase("")){
                                                                DomainRelationship domRel = new DomainRelationship(relatedImplementedObjectRelId);
                                                                domRel.open(context);
                                                                domRel.remove(context);
                                                                domRel.close(context);
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            //if not already connected
                            if(!isAlreadyConnected){
                                DomainRelationship domRel = com.matrixone.apps.domain.DomainRelationship.connect(context,
                                        selObjTempDom,
                                        ManufacturingPlanConstants.RELATIONSHIP_MANUFACTURING_PLAN_IMPLEMENTS,
                                        new DomainObject(selectedId));
                            }
                        }
                    }
                }   
            }
        }
        String strURL = "../dmcplanning/ManufacturingPlanUtil.jsp?mode=editManufacturingPlanBreakdown&context=Products&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&objectId="+objectTempId+"&parentOID="+parentTempOID+"&selObjId="+selObjTempId+"&emxExpandFilter=1";

        if(refreshMode.equalsIgnoreCase("refresh")){
            %>
            <script language="javascript">
                getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
                getTopWindow().closeWindow();
            </script>
            <%  
        }else{
            %>
            <script language="javascript">
                //top.close();
        var frameProductContext= findFrame(getTopWindow().getWindowOpener().getTopWindow(),'CFPProductManufacturingPlanComposition');
        if(frameProductContext!=null)
        {
            frameProductContext.emxEditableTable.refreshStructureWithOutSort();
        }
        
        if(frameProductContext==null)
        {
        	var frameMPContext = findFrame(getTopWindow().getWindowOpener().getTopWindow(),'detailsDisplay');
        		if(frameMPContext!=null)
        			{
        				frameMPContext.emxEditableTable.refreshStructureWithOutSort();
        			}
        }
                var url = '<%=XSSUtil.encodeForJavaScript(context,strURL)%>';
                getTopWindow().location.href =url;
                //window.open(url, "listHidden");         
            </script>
            <%  
        }
    }
    
    else if (strMode.equalsIgnoreCase("InsertManufacturingPlan")) {
        String strObjIdContext = emxGetParameter(request,"objectId");
        String strSearchHeader = EnoviaResourceBundle.getProperty(context,"DMCPlanning","DMCPlanning.Heading.Search.ManufacturingPlan", strLanguage);
        String strContextParentOID = "";
        //Added for IR-046355V6R2011
        if(strContextObjectId==null ||strContextObjectId.equalsIgnoreCase("")){
            strContextObjectId=(String)session.getAttribute("strContextObjectId");
        }
        //End of IR-046355V6R2011
        String strFeatureType = emxGetParameter(request,"featureType");
        String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
        String strObjectID = null;
        String strParentID = null;
        String selObjTempId = emxGetParameter(request,"selObjId");
        String strRelID = null;
        String txtType = null;

        
        StringBuffer strBuffer = new StringBuffer(400);
        Enumeration enumParamNames = emxGetParameterNames(request);
        while(enumParamNames.hasMoreElements()){
            String paramName = (String) enumParamNames.nextElement();
            if(paramName.equalsIgnoreCase("parentOID")){
                strContextParentOID  = emxGetParameter(request,paramName);
            }

            String paramValue = emxGetParameter(request,paramName);
            strBuffer.append("&");
            strBuffer.append(paramName);
            strBuffer.append("=");
            strBuffer.append(paramValue);
        }

        session.setAttribute("params",strBuffer.toString());
        StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0], "|");

        if(strTokenizer.hasMoreElements()){
            strRelID = strTokenizer.nextToken(); 
        }
        if(strTokenizer.hasMoreElements()){
            strObjectID = strTokenizer.nextToken(); 
        }
        if(strTokenizer.hasMoreElements()){
            strParentID = strTokenizer.nextToken(); 
        }
          if(strObjectID.equalsIgnoreCase("0")){
        	  strObjectID=strRelID;
             }
        DomainObject domSelectedObject = new DomainObject(strObjectID);
        
        String strManufacturingIntent = "";
        if(selObjTempId==null ||selObjTempId.equalsIgnoreCase("")){
            selObjTempId=(String)session.getAttribute("selObjId");
        }
        if(selObjTempId!=null && !selObjTempId.equalsIgnoreCase("")){
            DomainObject selObjTempDom = new DomainObject(selObjTempId);
            strManufacturingIntent = selObjTempDom.getAttributeValue(context,ManufacturingPlanConstants.ATTRIBUTE_MANUFACTURING_INTENT);
        }
        
        txtType = domSelectedObject.getInfo(context,DomainConstants.SELECT_TYPE);
        // Modified for Bug No. IR-042997V6R2011
        if(mxType.isOfParentType(context, txtType,ManufacturingPlanConstants.TYPE_MANUFACTURING_PLAN)){
            %>
            <script language="javascript" type="text/javaScript">
            var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.InsertOperationNotAllowedForMP","dmcplanningStringResource",language)%> ";
            alert(msg);
            </script>
            <%
        }else{
            String includeOIDMethod = "";
            if(strManufacturingIntent!=null && !strManufacturingIntent.equalsIgnoreCase("")){
                if(strManufacturingIntent.equalsIgnoreCase("Regular")){
                    includeOIDMethod = "getMPofCurrentRevision";
                }else if(strManufacturingIntent.equalsIgnoreCase("Retrofit")){
                    includeOIDMethod = "getMPofCurrentAndAllPreviousRevisions";
                }
            }
            
            if(mxType.isOfParentType(context,txtType,ManufacturingPlanConstants.TYPE_PRODUCTS)){  
                //Check if Selected object is root node
                if(strObjectID.equalsIgnoreCase(strContextParentOID)){
                    %>
                    <script language="javascript" type="text/javaScript">
                    var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.RootNode","dmcplanningStringResource",language)%> ";
                    alert(msg);
                    </script>
                    <%
                }else{
                    %>
                    <script language="javascript" type="text/javaScript">
                    showModalDialog("../common/emxFullSearch.jsp?includeOIDprogram=ManufacturingPlanSearch:<%=XSSUtil.encodeForJavaScript(context,includeOIDMethod)%>&excludeOIDprogram=ManufacturingPlanSearch:getMPBreakdown&parentID=<%=XSSUtil.encodeForJavaScript(context,strParentID)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectID)%>&field=TYPES=type_ManufacturingPlan&table=CFPManufacturingPlanSearchResultsTable&showInitialResults=false&Registered Suite=DMCPlanning&HelpMarker=emxhelpfullsearch&selection=multiple&showSavedQuery=true&header=<%=XSSUtil.encodeForURL(context,strSearchHeader)%>&hideHeader=true&SelId=<%=XSSUtil.encodeForJavaScript(context,strContextObjectId)%>&submitURL=../dmcplanning/ManufacturingPlanSearchUtil.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectID)%>&parentID=<%=XSSUtil.encodeForJavaScript(context,strParentID)%>&mode=insertManufacturingPlan&relName=relationship_ManufacturingPlanBreakdown&relnID=<%=XSSUtil.encodeForJavaScript(context,strRelID)%>&featureType=<%=XSSUtil.encodeForJavaScript(context,strFeatureType)%>&suiteKey=DMCPlanning",850,630);
                    </script>
                    <%
                }
            }else{
                %>
                <script language="javascript" type="text/javaScript">
                showModalDialog("../common/emxFullSearch.jsp?includeOIDprogram=ManufacturingPlanSearch:<%=XSSUtil.encodeForJavaScript(context,includeOIDMethod)%>&excludeOIDprogram=ManufacturingPlanSearch:getMPBreakdown&parentID=<%=XSSUtil.encodeForJavaScript(context,strParentID)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectID)%>&field=TYPES=type_ManufacturingPlan&table=CFPManufacturingPlanSearchResultsTable&showInitialResults=false&Registered Suite=DMCPlanning&HelpMarker=emxhelpfullsearch&selection=multiple&showSavedQuery=true&header=<%=XSSUtil.encodeForURL(context,strSearchHeader)%>&hideHeader=true&SelId=<%=XSSUtil.encodeForJavaScript(context,strContextObjectId)%>&submitURL=../dmcplanning/ManufacturingPlanSearchUtil.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,strObjectID)%>&parentID=<%=XSSUtil.encodeForJavaScript(context,strParentID)%>&mode=insertManufacturingPlan&relName=relationship_ManufacturingPlanBreakdown&relnID=<%=XSSUtil.encodeForJavaScript(context,strRelID)%>&featureType=<%=XSSUtil.encodeForJavaScript(context,strFeatureType)%>&suiteKey=DMCPlanning",850,630);
                </script>
                <%
            }
        }
    }
    
    else if (strMode.equalsIgnoreCase("RemoveManufacturingPlan")) {
        //check if any of selected nodes is not saved
    	boolean isMarkup = false;
    	if(emxTableRowId != null){
    		for (int i = 0; i < emxTableRowId.length; i++)
            {
    			StringList splitIdsList = FrameworkUtil.split(emxTableRowId[i], "|");
                if(splitIdsList.size() == 3 && !"".equals(splitIdsList.get(1)))
                {
                	isMarkup = true;
                	break;
                }
            }
        }
    	if(isMarkup)
    	{
			%>
            <script language="javascript" type="text/javaScript">
            var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.Remove.OnUnsaved", "dmcplanningStringResource",language)%> ";
            alert(msg);
            </script>  
            <%
		}
    	else
    	{
	    //
        // added by IVU to fix IR-044229 Start
        // Get the selected rows and check if the second level objects are selected
        boolean isMP = true;

        if(emxTableRowId != null){
            String[] arrList = new String[emxTableRowId.length];
            StringBuffer sbObjectid = null;
            String strSelectedObjectID = "";
            String strSelectedRelID = "";
            String strLevelID = "";
            for (int i = 0; i < emxTableRowId.length; i++)
            {
                StringList slList = FrameworkUtil.split(emxTableRowId[i], "|");
                String levelId = ((String)slList.get(slList.size()-1)).trim();
                StringList levelSplit = FrameworkUtil.split(levelId, ",");
                if(levelSplit.size()==2)
                {
                    isMP = false;
                    break;
                }
            }   
        }
        // added by IVU to fix IR-044229 Ends
        
        String strObjIdContext = emxGetParameter(request,"objectId");
        String strFeatureType = emxGetParameter(request,"featureType");
        String strTableRowId = emxGetParameter(request,"emxTableRowId");
        String selObjId = emxGetParameter(request,"selObjId");
        String strObjectID = "";
        String strParentID = "";
        String strRelID = "";
        String txtType = "";
        String strCntxtOfSelMP = "";
        
        

        StringBuffer strBuffer = new StringBuffer(400);
        Enumeration enumParamNames = emxGetParameterNames(request);

        while(enumParamNames.hasMoreElements())
        {
            String paramName = (String) enumParamNames.nextElement();
            String paramValue = emxGetParameter(request,paramName);
            strBuffer.append("&");
            strBuffer.append(paramName);
            strBuffer.append("=");
            strBuffer.append(paramValue);
        }
        session.setAttribute("params",strBuffer.toString());
        session.setAttribute("selObjId",selObjId);
        //Added for IR-046355V6R2011
        if(strContextObjectId.equals("") || strContextObjectId==null){
            session.getAttribute(strContextObjectId) ;
        }
        else{
            session.setAttribute("strContextObjectId",strContextObjectId);
        }
        java.util.StringTokenizer stTk = new java.util.StringTokenizer(strTableRowId,"|");
          if(stTk.countTokens()>3){
        strRelID=(String)stTk.nextToken();
          }
        strObjectID=(String)stTk.nextToken();
        strParentID=(String)stTk.nextToken();

        DomainObject domSelectedObject = new DomainObject(strObjectID);
        txtType = domSelectedObject.getInfo(context,"type");
        
        // added by IVU to fix IR-044229 Start
        if(!isMP){
            %>
            <script language="javascript" type="text/javaScript">
            var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.SelectedIsNotMP", "dmcplanningStringResource",language)%> ";
            alert(msg);
            </script>  
            <%

        }// added by IVU to fix IR-044229 ends
        //Modified for IR-080188V6R2012
        // else if(txtType.equalsIgnoreCase(ManufacturingPlanConstants.TYPE_MANUFACTURING_PLAN))
        	 else if(mxType.isOfParentType(context,txtType,ManufacturingPlanConstants.TYPE_MANUFACTURING_PLAN))
        //End of IR-080188V6R2012
        {
        
        //Get the selected MP ids to remove
        String sArrayMPIdsToRem[] = new String[emxTableRowId.length];
        String sArrayCntxtPrdIdOfMPIdsToRem[] = new String[emxTableRowId.length];
        String strSelId="";
        for (int i=0;i<emxTableRowId.length;i++){   
            StringTokenizer strToken = new StringTokenizer(emxTableRowId[i]);
            String strRelId= strToken.nextToken("|");
            strSelId= strToken.nextToken("|");
            sArrayMPIdsToRem[i]=strSelId;
            String strCntxtProdId= strToken.nextToken("|");
            sArrayCntxtPrdIdOfMPIdsToRem[i]=strCntxtProdId;
        }
        
        StringList sLMPIdsToRem = new StringList();
        StringList sLCntxtPrdIdOfMPIdsToRem = new StringList();
        
        for(int i=0;i<sArrayMPIdsToRem.length;i++){
        	String strMPIdToRem = sArrayMPIdsToRem[i];
        	sLMPIdsToRem.add(strMPIdToRem);
        }
        
        for(int j=0;j<sArrayCntxtPrdIdOfMPIdsToRem.length;j++){
        	
        	String strCntxtPrdIdOfMPIdToRem = sArrayCntxtPrdIdOfMPIdsToRem[j];
        	sLCntxtPrdIdOfMPIdsToRem.add(strCntxtPrdIdOfMPIdToRem);
        	
        }

            %>
            <script language="javascript" type="text/javaScript">
            parent.editableTable.cut();
            </script>
            <%
            //To check  atleast one MP has Preferred value =Yes
            ManufacturingPlan MP = new ManufacturingPlan();
            MP.checkForMPPreferredAttrVal(context,selObjId,sLCntxtPrdIdOfMPIdsToRem,sLMPIdsToRem);
            
        }
        else
        {
            %>
            <script language="javascript" type="text/javaScript">
            var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.SelectedIsNotMP", "dmcplanningStringResource",language)%> ";
            alert(msg);
            </script>  
            <%
        }
    }
    }
    else if (strMode.equalsIgnoreCase("disconnectMPForSync"))
    {
        String strRemMPRelIDs = emxGetParameter(request,"RemMPRelIDs");
        String strContextMPID = emxGetParameter(request,"contextMPID");
        if(strRemMPRelIDs==null ||strRemMPRelIDs.equalsIgnoreCase("")){
        	strRemMPRelIDs=(String)session.getAttribute("RemMPRelIDs");
        	session.removeAttribute("RemMPRelIDs");
        }
        if(strRemMPRelIDs!=null){
	        java.util.StringTokenizer stTk = new java.util.StringTokenizer(strRemMPRelIDs,"[,],,");
	        StringList sLRemMPRelIDs = new StringList();
	        while(stTk.hasMoreElements())
	        {
	            sLRemMPRelIDs.addElement(stTk.nextToken().toString());
	        }
	        ManufacturingPlan manufacturingPlan = new ManufacturingPlan(strContextMPID);  
	        manufacturingPlan.disconnectManufacturingPlan(context, sLRemMPRelIDs);
	        manufacturingPlan.updateMPPrefferedValue(context);
        }
    }   
    else if (strMode.equalsIgnoreCase("checkConflictingMPB"))
    {
	     String strObjectId = emxGetParameter(request,"objectId");
	     String strParentId = emxGetParameter(request,"parentOID");
	     String selObjId = emxGetParameter(request,"selObjId");
	     ManufacturingPlan manuPlan=null;
	     String strRelId = "";
	     if(emxTableRowId!=null && emxTableRowId.length>0){
	         StringTokenizer strRowIdTZ = new StringTokenizer(emxTableRowId[0],"|");
	         if(strContext.equalsIgnoreCase("Products")){
	             if(strRowIdTZ.hasMoreElements()){
	                 strRelId = strRowIdTZ.nextToken();
	             }
	             if(strRowIdTZ.hasMoreElements()){
	                 strObjectId = strRowIdTZ.nextToken();
	             }
	             if(strRowIdTZ.hasMoreElements()){
	                 strParentId = strRowIdTZ.nextToken();
	             }
	         }else{
	             if(strRowIdTZ.hasMoreElements()){
	                 strRelId = strRowIdTZ.nextToken();
	             }
	             strObjectId = objectId;
	             strParentId = new DomainObject(objectId).getInfo(context, "to["+ManufacturingPlanConstants.RELATIONSHIP_ASSOCIATED_MANUFACTURING_PLAN+"].from.id");
	         }
	     }
         if(strObjectId.equalsIgnoreCase("0")&& strContext.equalsIgnoreCase("Products")){
          %>
                      <script language="javascript" type="text/javaScript">
                      var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.RootNode","dmcplanningStringResource",language)%> ";
                      alert(msg);
                      </script>  
         <% 
         }else if((strObjectId!=null && !strObjectId.equalsIgnoreCase("")) && (strParentId!=null && !strParentId.equalsIgnoreCase(""))){
        	if(null == selObjId || "".equals(selObjId) || "null".equals(selObjId)){
      		   selObjId = strObjectId; 
    	}
           if(ManufacturingPlan.isFrozenState(context,selObjId))
                isMpInRelease = true;
    	   boolean bFlag  = false;
    	   String strRemMPRelIds = "";
    	   Map mapReturn = new HashMap();
    	   mapReturn =  manuPlan.getMPsConnectedManufacturingPlans(context,strParentId,selObjId);
    	   bFlag = (Boolean)mapReturn.get("bFlag");
    	   strRemMPRelIds = (String)mapReturn.get("strRemMPRelIds");%>
    	   
        <script language="javascript" type="text/javaScript">
           var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
           var strRemMPRelIds = '<%=XSSUtil.encodeForURL(context,strRemMPRelIds)%>';
           var objectId = '<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>';
           var parentOID = '<%=XSSUtil.encodeForJavaScript(context,strParentId)%>';
           var selObjId = '<%=XSSUtil.encodeForJavaScript(context,selObjId)%>';
           var vURL;
           var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
            
           var dupemxUICore = undefined;
           var mxRoot = undefined;
           var contentFrame   = findFrame(getTopWindow(),"listHidden");
           var xmlRef = contentFrame.parent.oXML;
           if(xmlRef!=undefined){
               dupemxUICore   = contentFrame.parent.emxUICore;
               mxRoot         = contentFrame.parent.oXML.documentElement;
           }
           
           var checkedRows = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@checked='checked']");
           var flagSubMP = false;
           for(var i=0; i<checkedRows.length;i++){ 
             var chkLev = checkedRows[i].getAttribute("level");
             if(chkLev==1){
               flagSubMP = true;
               break;
             }
             else if(chkLev>=1 && strContext=="ManufacturingPlan"){
                 flagSubMP = true;
                 break;
             }
          }
          if(flagSubMP){
              var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.NoSubManPlanSelect","dmcplanningStringResource",language)%> ";
              alert(msg);
          }
          else if(<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isMpInRelease))%>){
              var msg = "<%=i18nStringNowUtil("DMCPlanning.Error.EditMPNotAllowedinRelease","dmcplanningStringResource",language)%> ";
              alert(msg);
          }else{
              
           var url = "../dmcplanning/ManufacturingPlanUtil.jsp?mode=editManufacturingPlanBreakdown&context="+strContext+"&objectId="+objectId+"&parentOID="+parentOID+"&selObjId="+selObjId+"&strRemMPRelIds="+strRemMPRelIds+"";
           var bFlag = '<%=XSSUtil.encodeForJavaScript(context,Boolean.toString(bFlag))%>';
           if(bFlag == "true"){
	           var RemMPRelIDs = '<%=XSSUtil.encodeForJavaScript(context,strRemMPRelIds)%>';
	           var confirmmsg = "<%=i18nStringNowUtil("DMCPlanning.Alert.EditManufacturingPlanBreakdownConflict","dmcplanningStringResource",language)%> ";
	           if(confirm(confirmmsg)){                           
	                   showModalDialog(url,860,600,true,'MediumTall'); 
	           }else{
	                   //return;
	                   //do nothing 
	           }
          }else {
                     showModalDialog(url,860,600,true,'MediumTall');
          }
         }
    	</script>	 
        <%
         }
    }
}catch(Exception e){
    bIsError=true;
    session.putValue("error.message", e.toString());
}



%>
</form>
</body>
</head>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
