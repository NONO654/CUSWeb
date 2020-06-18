<%--  emxPartRaiseAnECOCheck.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%!    
    public String getObjectIds(String[] objectIds, String symbolToSplit, String symbolToConcat, int index) {
       String objectIdReturn = "";       
       
       int length = objectIds == null ? 0 : objectIds.length;
       
       for (int i = 0; i < length; i++) {
           
           if ("".equals(objectIdReturn)) {
               objectIdReturn = (String) FrameworkUtil.split(objectIds[i], symbolToSplit).get(index) + "|";
           } else {
               objectIdReturn += symbolToConcat + (String) FrameworkUtil.split(objectIds[i], symbolToSplit).get(index) + "|";
           }
       }
       
       return objectIdReturn;
    }

	public String[] getSelectedObjectId(String[] objectIds) {
	    int size = objectIds == null ? 0 : objectIds.length;
	    StringList sList;
	    String objectId;
	    String[] arrObjectIdReturn = new String[size];
	    
	    for (int i = 0; i < size; i++) {
	        sList = FrameworkUtil.split(objectIds[i], "|");    
	        
	        if (sList.size() == 3) {
	            objectId = (String) sList.get(0);
	        } else {
	            objectId = (String) sList.get(1);
	        }
	        
	        arrObjectIdReturn[i] = objectId;
	    }
	    
	    return arrObjectIdReturn;
	}
%>


<%
  String languageStr = request.getHeader("Accept-Language");
	Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String selectedParts = emxGetParameter(request, "selectedParts");
  String fromPartWhereUsed = emxGetParameter(request, "fromPartWhereUsed");
  String emxTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
  //String strDiffRDOMessage = i18nNow.getI18nString("emxEngineeringCentral.AffectedItem.AffectedItemHavingSameRDOs", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
  String strDiffRDOMessage = EnoviaResourceBundle.getProperty(context , "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.AffectedItem.AffectedItemHavingSameRDOs" );
  
  if ("true".equals(fromPartWhereUsed)) {               
        selectedParts = getObjectIds(emxTableRowIds, "|", ",", 1);        
  }
  
  String strMode = emxGetParameter(request, "Mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String objectId = emxGetParameter(request, "objectId");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String sContextMode = emxGetParameter(request, "sContextMode");
  session.setAttribute("selectedParts",selectedParts);
  //X3 Start - Added for EBOM Substitute Mass Change
  String sEBOMSubChange = emxGetParameter(request, "ebomSubstituteChange");
  if (sEBOMSubChange == null) sEBOMSubChange="false";
  session.setAttribute("ebomSubstituteChange",sEBOMSubChange);
  //X3 End - Added for EBOM Substitute Mass Change

  // clear the session for the user attribs
  session.removeAttribute("searchECRprop_KEY");
  session.removeAttribute("attributeMap");
  session.removeAttribute("selectedECRprop");
  session.removeAttribute("dispAttribs");

  StringTokenizer sObjectIdTok = new StringTokenizer(selectedParts, ",",false);
  boolean bObsoleteState = false;
  boolean bNotInPreliminaryOrRelease = false;
  boolean bConfig = false;
  boolean bUnConfig = false;
  boolean bConhigh = false;
  boolean isSpecification = false;//IR-084756V6R2012
  String  sTypeName = "";
  //String strMode = "AddToECOExisting";
  String modetype = "AddToECO";
  String strContentLabel = "";
  String strHeader = "Create ECO";
   String sRaiseECOURL = "";
  StringList strListObjectIds = new StringList();
  String strIds = "";
  //Added for IR-084750V6R2012 starts
  String sDevPart = PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart");
  String strContextPolicy=DomainConstants.EMPTY_STRING;
  //Added for IR-084750V6R2012 ends
  int l = 0;
  while (sObjectIdTok.hasMoreTokens()) {
    String passedId = sObjectIdTok.nextToken();
	String strObjectId = passedId.substring(0,passedId.indexOf("|")).trim();
	DomainObject domObj = new DomainObject(strObjectId);
	//Added for IR-084750V6R2012   starts 
    strContextPolicy   = domObj.getPolicy(context).getName();
	if(sDevPart.equals(strContextPolicy))
	{
	   %>
         <script language="javascript">
         alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOMPowerView.DevPartalertmessage</emxUtil:i18nScript>");
         </script>
       <% 
	return;
	}
    //Added for IR-084750V6R2012 ends
	String strCurrent = domObj.getInfo(context,DomainObject.SELECT_CURRENT);
    String strPolicy = domObj.getInfo(context,DomainObject.SELECT_POLICY);
    String strObsolete = PropertyUtil.getSchemaProperty(context, "policy", strPolicy, "state_Obsolete");
    String strPreliminary = PropertyUtil.getSchemaProperty(context, "policy", strPolicy, "state_Preliminary");
    String strReleased = PropertyUtil.getSchemaProperty(context, "policy", strPolicy, "state_Release");
	if(strCurrent.equals(strObsolete)){
		bObsoleteState = true;
		break;
	} else if(strPolicy.equals(DomainConstants.POLICY_EC_PART) && !(strCurrent.equals(strPreliminary) || strCurrent.equals(strReleased))){
		bNotInPreliminaryOrRelease = true;
		break;
	} else {		
		strListObjectIds.add(strObjectId);
		if (l==0)
		{
	strIds = passedId;
		}
		else
		{
	
	strIds = strIds + "~" + passedId;
		}
		l++;
	}
  }

	int strArrayObjectIdsSize = strListObjectIds.size();
	String[] strArrayObjectIds = new String[strArrayObjectIdsSize];
	for(int i=0;i<strArrayObjectIdsSize;i++){
	 strArrayObjectIds[i] = (String)strListObjectIds.get(i); 
	 
     String strPartMode = "";
     DomainObject domObj = new DomainObject(strArrayObjectIds[i]);
    // DomainObject doPart = new DomainObject(parentObjectId);
     String sRelPartRevision = PropertyUtil.getSchemaProperty(context,"relationship_PartRevision");
     String sAttributePartMode = PropertyUtil.getSchemaProperty(context,"attribute_PartMode");
     String objectSelects = "to["+sRelPartRevision+"].from.attribute["+sAttributePartMode+"].value";
     strPartMode = domObj.getInfo(context,objectSelects);
     if(strPartMode !=null && !"null".equalsIgnoreCase(strPartMode) && !"".equalsIgnoreCase(strPartMode)){
    /* strPartMode = i18nNow.getI18nString("emxFramework.Range.Part_Mode."+strPartMode,
                                      "emxFrameworkStringResource", "en"); //IR:068427*/
       strPartMode = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",new Locale("en"),"emxFramework.Range.Part_Mode."+strPartMode); //IR:068427
     if(strPartMode.equalsIgnoreCase("Configured")&& !bConfig){
         bConfig=true;
         //Selecting only highest rev of Configured part for PUE ECO
         String sLastid = domObj.getInfo(context, DomainObject.SELECT_LAST_ID);
         if(!sLastid.equalsIgnoreCase(strListObjectIds.get(i).toString())){
        	 bConhigh=true;
         }
     }else if(strPartMode.equalsIgnoreCase("Un-configured")&& !bUnConfig){
    	 bUnConfig=true;
     }else{
        strPartMode="";
       }
   	}//Starts: IR-084756V6R2012
     else if(!bConfig && !bUnConfig){
         
         String sBaseType = FrameworkUtil.getBaseType(context, domObj.getInfo(context, DomainConstants.SELECT_TYPE), context.getVault());
         isSpecification  = ((sBaseType != null) &&(PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS").equalsIgnoreCase(sBaseType)))?true:false;
     }
     
     //Ends: IR-084756V6R2012
	}
     
  if(bObsoleteState) {
%>
   <script language="javascript">
     alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSummary.ObsoletePartalertmessage</emxUtil:i18nScript>");
   </script>
<%
  } else if(bNotInPreliminaryOrRelease){
%>
	<script language="javascript">
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOMPowerView.ECOalertmessage</emxUtil:i18nScript>");
  	</script>
<%
} else {
	  
	// Added for IR-108282V6R2012x
	    String dynamicParamFS = "";
	    String dynamicParamCreate = "";
	    String rdoId = "";
	    String rdoName = "";
	    
	    //Modified for RDO Convergence start
	    //String rdoData = (String) JPO.invoke (context, "emxPart", null, "getRDOId", getSelectedObjectId(emxTableRowIds), String.class);
	    String rdoData = (String) JPO.invoke (context, "emxPart", null, "getPartorg", getSelectedObjectId(emxTableRowIds), String.class);
	    
	    if (rdoData != null && !"".equals(rdoData)) {
	        //rdoId   = (String) FrameworkUtil.split(rdoData, "|").get(0);
	       // rdoName = (String) FrameworkUtil.split(rdoData, "|").get(1);
	        String whrClause = "name == '"+rdoData +"'";
			String result = MqlUtil.mqlCommand(context, "temp query bus $1 $2 $3 where $4 select $5 dump $6",DomainConstants.TYPE_ORGANIZATION,"*","*",whrClause,"id","|"); 		
			rdoId = result.substring(result.lastIndexOf("|")+1);
		  	rdoName = rdoData;
	        
	        //dynamicParamFS = ":AFFECTEDITEMS_RDO=Unassigned|" + rdoId;
	        //dynamicParamFS = ":ALTOWNER1=Unassigned|" + rdoData; //Modified for IR-232344
	        dynamicParamFS = ":ORGANIZATION=" + rdoData;
	        //Modified for RDO Convergence End
	        
	        dynamicParamCreate = "&DesignRespOID=" + rdoId;
	        
	    }
	    // Added for IR-108282V6R2012x

	  if(strMode != null && !strMode.equals("") && strMode.equals("AddToECOExisting")){
		
          if ((!bConfig && bUnConfig) || (isSpecification)){ //IR-084756V6R2012
		String excludeOidProgramTxt = "";
		session.setAttribute("programMapforPart",strArrayObjectIds);	
		session.setAttribute("strMode",strMode);
		
		String smbPolicyFilterForECO = ":Policy!=policy_DECO,policy_TeamECO";
       //Modified the url for 375721
        sRaiseECOURL = "../common/emxFullSearch.jsp?field=TYPES=type_ECO" + smbPolicyFilterForECO + ":CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork"+ dynamicParamFS + "&HelpMarker=emxhelpfullsearch&objectId=" + objectId + "&programMap=" + strListObjectIds + "&strMode=" + strMode;
        sRaiseECOURL += "&hideHeader=true&submitURL=../engineeringcentral/emxEngrAssociateAffectedItemECOConnectECO.jsp&selection=single&txtType=type_ECO&table=ENCAddExistingGeneralSearchResults&submitAction=refreshCaller&fromPartWhereUsed=" + fromPartWhereUsed;   
        //375721 ends
           } 
	 }
	  if(strMode != null && !strMode.equals("") && strMode.equals("AddToECO")){
	        if ((!bConfig && bUnConfig) || (isSpecification)){//IR-084756V6R2012
	            sRaiseECOURL = "../common/emxCreate.jsp?form=type_CreateECO&type=type_ECO&policy=ECO&typeChooser=true&nameField=autoname&ExclusionList=type_DECO&header=" + strContentLabel + "&submitAction=insertContent&CreateMode=" + strMode + "&suiteKey="+suiteKey+ "&affectedItems="+ strIds + "&OBJId="+objectId+"&strMode=" + strMode + "&header="+strHeader+"&preProcessJavaScript=setRDOForCreateECO" + dynamicParamCreate;
	         }
	}
	
	   if ((bConfig && bUnConfig) || ((strMode.equals("AddToECOExisting") || strMode.equals("AddToECO")) && bConfig)) {   
%>
           <script language="javascript">
               alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSummary.ECOPartalertmessage</emxUtil:i18nScript>");
           </script>
<%
       } else if (!bConhigh) { 
%>    
	    <script language="javascript">
	    //XSSOK
	    var raiseECOURL = "<%=XSSUtil.encodeForJavaScript(context,sRaiseECOURL)%>";
	    //XSSOK
	    raiseECOURL += "&DesignRespName=" + encodeURIComponent(encodeURIComponent("<%= rdoName%>"));
	    
	    //alert(raiseECOURL);
	    //XSSOK
	     if ("<%= rdoData%>" == null || "<%= rdoData%>" == "null") {
	    	 //XSSOK
	    	 alert ("<%= strDiffRDOMessage%>");
	     } else {
		    if ("AddToECO" == "<xss:encodeForJavaScript><%= strMode%></xss:encodeForJavaScript>") {		    	
		        getTopWindow().showSlideInDialog(raiseECOURL, true);
		    } else {
		    //XSSOK
		        emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context,sRaiseECOURL)%>", 850, 630);
		    }
	     }
	    </script>
    
<%
      } 
  }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

