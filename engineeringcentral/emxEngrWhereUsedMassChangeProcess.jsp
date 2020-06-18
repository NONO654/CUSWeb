<%--  emxEngrWhereUsedMassChangeProcess.jsp   - The Processing page for Mass Change in Where used
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringUtil"%>


<%!

	//Method to return object list only from table row id
	public StringList getObjectIdsFromTableRowID(String[] strRowId) {
		int size = strRowId == null ? 0 : strRowId.length;
		StringList sList;
		StringList objListReturn = new StringList();
		
		for (int i = 0; i < size; i++) {
			sList = FrameworkUtil.split(strRowId[i], "|");    		    
		    if (sList.size() == 3) 
		    	objListReturn.addElement((String) sList.get(0));
		    else  
		    	objListReturn.addElement((String) sList.get(1));
		    }		
		return objListReturn;
	}
	
	//Method to return map contains obj/rel/row id stringlist of values from table row id
	public static Map getObjectIdsRelIdsMapFromTableRowID(String[] strRowId) 
	{        	    
		Map returnMap = new HashMap();
	    int iRowSize  = 0;
	    
	    StringList arrBusIdList = new StringList();
	    StringList arrRelIdList = new StringList();
	    StringList tempList 	= new StringList();
	    if (strRowId != null) {
	   	 iRowSize  = strRowId.length;
		     for (int i = 0; i < iRowSize; i++) {
		     	tempList = FrameworkUtil.split(strRowId[i], "|");		     	
		     	if (tempList.size() == 3) {
		     		arrBusIdList.addElement((String) tempList.get(0));
		     	} 
		     	else{
		     		arrRelIdList.addElement((String) tempList.get(0));
		            arrBusIdList.addElement((String) tempList.get(1));
		     	}
		     }
	    }    
	    returnMap.put("ObjId", arrBusIdList);
	    returnMap.put("RelId", arrRelIdList);
	    return  returnMap;      	    
	}
	
	//method to return xml string for add to selected api
	public String getAddToSelectedXML(Context context,StringList parentIdList,StringList relIDList,String addOrReplacePartId,String contextObjectId,String functionality) throws Exception{
    	StringBuffer returnBuffer = new StringBuffer(100);
    	String parentId,relId;
    	String FN,RD,Qty;
    	Map<String,String> attrMap;
    	//status would be pending in case of add other cases status would be committed
    	String status = ("MassChangeAdd".equalsIgnoreCase(functionality)) ? "pending" : "commited";    	
    	String oid    = ("MassChangeAdd".equalsIgnoreCase(functionality)) ? addOrReplacePartId : contextObjectId;
    		for(int i=0;i<parentIdList.size();i++) {
    			parentId = (String)parentIdList.get(i);
    			relId	 = (String)relIDList.get(i);	
    			attrMap  = (HashMap<String,String>)DomainRelationship.newInstance(context,relId).getAttributeMap(context);
       			FN		 = 	getAttrVal(attrMap,"Find Number");
       			RD		 = 	getAttrVal(attrMap,"Reference Designator");
       			Qty		 = 	getAttrVal(attrMap,"Quantity");
       			//kp end
    			if(returnBuffer.length() < 1)returnBuffer.append("<mxRoot><action>add</action><data status=\"" + status +"\">");  	
    			returnBuffer.append("<item oid=\"" + oid + "\" relId=\"" + relId + "\" pid=\"" + parentId + "\" relType=\"relationship_EBOM\">")
    			.append("<column name=\"Find Number\" edited=\"true\" a=\""+ FN +"\">"+FN+"</column>")
				.append("<column name=\"Reference Designator\" edited=\"true\" a=\""+ RD +"\">"+RD+"</column>")
				.append("<column name=\"Quantity\" edited=\"true\" a=\""+ Qty +"\">"+Qty+"</column>")
    			.append("</item>");
       			
    		}
    		returnBuffer.append("</data></mxRoot>");
	    	return returnBuffer.toString();
    }

	//Method to return load markup xml for replace and remove cases
    public String getLoadMarkUpXML(Context context,StringList parentIdList,StringList relIDList,String addOrReplacePartId,String contextObjectId,String functionality) throws Exception{
    	StringBuffer returnBuffer = new StringBuffer(100);
    	String parentId,relId;
   		for(int i=0;i<parentIdList.size();i++) {
   			parentId = (String)parentIdList.get(i);
   			relId	 = (String)relIDList.get(i);
   			if(returnBuffer.length() < 1)returnBuffer.append("<mxRoot>");
			returnBuffer.append("<object objectId=\"" + parentId + "\">")
						.append("<object objectId=\"" + contextObjectId + "\" relId=\"" + relId + "\" parentId=\"" + parentId + "\" relType=\"relationship_EBOM\" markup=\"cut\" param1=\"\" param2=\""+addOrReplacePartId+"\" param3=\"replace\">")
						.append("</object></object>");
   		}	
		returnBuffer = returnBuffer.length() > 0 ? returnBuffer.append("</mxRoot>") : returnBuffer;
		return returnBuffer.toString();
    }
	//Method to return load mark up xml for edit cases
    public String getLoadMarkUpXMLForEdit(Context context,StringList parentIdList,StringList relIDList,String addOrReplacePartId,String contextObjectId,String functionality) throws Exception{
    	StringBuffer returnBuffer = new StringBuffer(100);
    	String parentId,FN,RD,Qty,relId;
    	Map<String,String> attrMap;

   		for(int i=0;i<parentIdList.size();i++) {
   			parentId = (String)parentIdList.get(i);
   			relId	 = (String)relIDList.get(i);
   			attrMap  = (HashMap<String,String>)DomainRelationship.newInstance(context,relId).getAttributeMap(context);
   			FN		 = 	getAttrVal(attrMap,"Find Number");
   			RD		 = 	getAttrVal(attrMap,"Reference Designator");
   			Qty		 = 	getAttrVal(attrMap,"Quantity");
   			
   			if(returnBuffer.length() < 1)returnBuffer.append("<mxRoot>");
			returnBuffer.append("<object objectId=\"" + contextObjectId + "\" relId=\"" + relId + "\" parentId=\"" + parentId + "\" relType=\"relationship_EBOM\" markup=\"changed\" param1=\"\" param2=\""+addOrReplacePartId+"\" param3=\"replace\">")
						.append("<column name=\"Find Number\" edited=\"true\" a=\""+ FN +"\">"+FN+"</column>")
						.append("<column name=\"Reference Designator\" edited=\"true\" a=\""+ RD +"\">"+RD+"</column>")
						.append("<column name=\"Quantity\" edited=\"true\" a=\""+ Qty +"\">"+Qty+"</column>")					
						.append("</object>");            
   		}	
		returnBuffer = returnBuffer.length() > 0 ? returnBuffer.append("</mxRoot>") : returnBuffer;
		return returnBuffer.toString();
    }
    private String getAttrVal(Map<String,String> m,String key) {
    	return (m != null) ? m.get(key) : "";	
    }
    
%>

<%
	  long timeinMilli = System.currentTimeMillis();	
      String contextObjectId = emxGetParameter(request, "objectId");
      String functionality   = emxGetParameter(request, "Functionality");      
      String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
      String strLanguage     = request.getHeader("Accept-Language");
      
      Map  tableRowIdMap 	  = getObjectIdsRelIdsMapFromTableRowID(selectedItems);
      StringList relIDList 	  = (StringList)tableRowIdMap.get("RelId");
      StringList parentIdList = (StringList)tableRowIdMap.get("ObjId");      
      String selPartObjectId  = "";
      String fullSearchURL    = "";
      String parentId 		  = "";
      String errorMsg 		  = "";
      String addToSelectedXML = "";
      String loadMarkUpXML    = "";
      String addToSelectedReplaceXML = "";
      boolean addReplaceCheck = true;
      String msgAlertDev = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.BOMPowerView.DevPartalertmessageForAction", context.getSession().getLanguage());
  	String error = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.CommonAlert.ERROR", context.getSession().getLanguage());
  	String stateLevelCheck1 = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.WhereUsedSumary.StateLevelCheckAlert", context.getSession().getLanguage());
  	String stateLevelCheck2 = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.WhereUsedSumary.StateCheckAlert1", context.getSession().getLanguage());
  	String invalidLevelCheck = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.RaiseECR.InvalidLevelPropertyAlertCR", context.getSession().getLanguage());
  	String levelCheck = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.WhereUsedSumary.LevelCheckAlert", context.getSession().getLanguage());
  	String sameRelCheck = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.WhereUsedSumary.SubsituteMassChangeAlert", context.getSession().getLanguage());
  	String propAllowLevel = JSPUtil.getCentralProperty(application, session, "emxEngineeringCentral" ,"AllowMassEBOMChangeUptoLevel");

	  if(("MassChangeAdd".equals(functionality))|| ("MassChangeReplace".equals(functionality))){
		  
		  addReplaceCheck = false;
	  }
	  
	  if(addReplaceCheck){
      //kp
    Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
	String objectId = emxGetParameter(request, "objectId");	
	String mode = emxGetParameter(request, "mode");
		boolean bFailed = false;
	  String  sTypeName = "";
	
	  String sDevPart = PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart");
	  String strContextPolicy=DomainConstants.EMPTY_STRING;
	  String stateRelease = com.matrixone.apps.engineering.EngineeringUtil.getReleaseState(context,DomainObject.POLICY_EC_PART);
	  
	 
	  for(int i=0;i<parentIdList.size();i++){
	    String passedId =(String) parentIdList.get(i);

	
		
		part.setId(passedId);
	  
	    strContextPolicy   = part.getPolicy(context).getName();
	    if(sDevPart.equals(strContextPolicy))
	    {
	       %>
	         <script language="javascript">
	         //XSSOK
	         alert("<%=msgAlertDev%>");
	         closeWindow();
	         </script>
	       <% 
	    return;
	    }
	    StringList strSelects = new StringList(3);
	    strSelects.add(DomainConstants.SELECT_NAME);
	    strSelects.add(DomainConstants.SELECT_TYPE);
	    strSelects.add(DomainConstants.SELECT_VAULT);

	    StringList strPartSelects = new StringList(DomainConstants.SELECT_ID);

	    Map mapInfo = (Map) part.getInfo(context, strSelects);
	String strWhereClause = "(current =="+DomainConstants.STATE_PART_RELEASE+") && (!((next.current == "+DomainConstants.STATE_PART_RELEASE+") || (next.current == "+DomainConstants.STATE_PART_OBSOLETE+")))";

	 MapList mapListParts = DomainObject.findObjects(context,
	                  (String) mapInfo.get(DomainConstants.SELECT_TYPE),
	                  (String) mapInfo.get(DomainConstants.SELECT_NAME),
	                  "*",
	                  null,
	                  "*",
	                  strWhereClause,
	                  false,
	                  strPartSelects);

	 boolean bReturn = false;

	if (mapListParts.size() > 0)
	{
		Map mapPart = (Map) mapListParts.get(0);
		String strId = (String) mapPart.get(DomainConstants.SELECT_ID);

		if (strId.equals(passedId))
		{
			bReturn = true;
		}
	}

	    if(!bReturn) {
	      sTypeName = " " + part.getInfo(context,DomainConstants.SELECT_NAME) + " ";
	      bFailed = true;
	      break;
	    }    
	    
	  }
	
	  if(bFailed) {

		  %>
		     <script language="javascript">
		       //XSSOK
		       alert("<%=error%>"+"<%=stateLevelCheck1%>"+"<%=sTypeName%>"+"<%=stateLevelCheck2%>");
		       closeWindow();
		     </script>
		  <%
		  return;
		    } 
	
	  }
	  %>
	 
		  
		  <%
      try {
    	  String stateNames = EngineeringUtil.getProductAndDevelopmentPolicyList(context);
    	  selPartObjectId  = (String)((StringList)getObjectIdsFromTableRowID(selectedItems)).get(0);
    		//In replace case, call add to selected twice for pending once and for committed once
    		if("MassChangeReplace".equalsIgnoreCase(functionality) || "MassChangeAdd".equalsIgnoreCase(functionality)) {    			
    			tableRowIdMap    = getObjectIdsRelIdsMapFromTableRowID((String[])session.getAttribute("WhereUsedTableRowIds"));
   		      	relIDList 		 = (StringList)tableRowIdMap.get("RelId");
   		      	parentIdList 	 = (StringList)tableRowIdMap.get("ObjId");
   		     	selPartObjectId  = (String)((StringList)getObjectIdsFromTableRowID(selectedItems)).get(0);
   		     	contextObjectId  = (String)session.getAttribute("contextObjectId");
   		     	//for replace case/add case, for pending add (green mark up row)  
   		     	addToSelectedXML = getAddToSelectedXML(context,parentIdList,relIDList,selPartObjectId,contextObjectId,"MassChangeAdd");
   		   		//for replace case, for committed add (later will be cutting this row)
   		   		if("MassChangeReplace".equalsIgnoreCase(functionality)) {
	   		     	addToSelectedReplaceXML = getAddToSelectedXML(context,parentIdList,relIDList,selPartObjectId,contextObjectId,functionality);
	   		     	loadMarkUpXML    = getLoadMarkUpXML(context,parentIdList,relIDList,selPartObjectId,contextObjectId,functionality);
   		   		}	
    		} //This else loop for framing full search url for add/replace
    		else if ("MassChangeFullSearchAdd".equals(functionality) || "MassChangeFullSearchReplace".equalsIgnoreCase(functionality)) {
    			String postProcessfunctionality = "MassChangeFullSearchAdd".equalsIgnoreCase(functionality) ? "MassChangeAdd" : "MassChangeReplace";
    			fullSearchURL ="../common/emxFullSearch.jsp?field=TYPES=type_Part:" +stateNames+ "&table=ENCAffectedItemSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrWhereUsedMassChangeProcess.jsp&Functionality="+postProcessfunctionality+"&HelpMarker=emxhelpfullsearch&suiteKey=EngineeringCentral&excludeOIDprogram=emxENCFullSearch:excludeObjectForMassChange&selPartObjectId="+selPartObjectId+"&contextObjectId="+contextObjectId;
    			session.setAttribute("WhereUsedTableRowIds",selectedItems);
    			session.setAttribute("contextObjectId",contextObjectId);
    		}
    		//else block would be invoked in case of mass update(edit) and mass remove
    		else {
	       		addToSelectedXML = getAddToSelectedXML(context,parentIdList,relIDList,selPartObjectId,contextObjectId,functionality);
	       		if("MassChangeUpdate".equalsIgnoreCase(functionality))
	       			loadMarkUpXML  = getLoadMarkUpXMLForEdit(context,parentIdList,relIDList,selPartObjectId,contextObjectId,functionality);
	       		else
	       			loadMarkUpXML  = getLoadMarkUpXML(context,parentIdList,relIDList,selPartObjectId,contextObjectId,functionality);
        	}
      } 
      	catch (Exception ex) 
      	{
          if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
        	  errorMsg =  ex.toString().trim();
        	  emxNavErrorObject.addMessage(ex.toString().trim());              
            }
        }   
	  //System.out.println("addToSelectedXML"+addToSelectedXML);
	  //System.out.println("addToSelectedReplaceXML"+addToSelectedReplaceXML);
	  //System.out.println("loadMarkUpXML"+loadMarkUpXML);
  
%>

<html>
<head>
</head>
<body>
<form name="whereUsedFullSearch" method="post">
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>  
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>

<script language="Javascript">
if(levelCheck()){
//XSSOK
var functionality = "<%=functionality%>";
//XSSOK
var errorMessage  = "<%=errorMsg%>";
if (errorMessage != null && errorMessage != "" && errorMessage != "null" && errorMessage != "undefined"){
	alert(errorMessage);	
}
//Opens full search window
else if("MassChangeFullSearchAdd" == functionality || "MassChangeFullSearchReplace" == functionality) {	   
	 
	
 	 /*showModalDialog("../common/emxBlank.jsp","570","570","true"); 
 	 var objWindow =  getTopWindow().modalDialog.contentWindow;
	 document.whereUsedFullSearch.target=objWindow.name;	
	 document.whereUsedFullSearch.action="<%=fullSearchURL%>";
	 document.whereUsedFullSearch.submit();*/
	 //XSSOK
	 showModalDialog("<%=fullSearchURL%>"); 
}
else 
{	
	
	var whereUsedFrame    = getWhereUsedFrame();
	var callAddToSelected = whereUsedFrame.getTopWindow().sb.emxEditableTable.addToSelected;
	callAddToSelected('<xss:encodeForJavaScript><%=addToSelectedXML%></xss:encodeForJavaScript>');

	if("MassChangeAdd" != functionality) {
		//In replace case, call add to selected twice for pending once and for committed once
		if("MassChangeReplace" == functionality){
			callAddToSelected('<xss:encodeForJavaScript><%=addToSelectedReplaceXML%></xss:encodeForJavaScript>');
		}
		//this load markup for cut/changed case which operates on committed rows of add to selected data
		var callLoadMarkup = whereUsedFrame.getTopWindow().sb.emxEditableTable.prototype.loadMarkUpXML;  
		callLoadMarkup('<xss:encodeForJavaScript><%=loadMarkUpXML%></xss:encodeForJavaScript>',"true");
	}	
	if("MassChangeReplace" == functionality || "MassChangeAdd" == functionality) {
		getTopWindow().closeWindow();
	}	
}	  
}
function levelCheck(){
	//XSSOK
	 var propLevelVal = "<%=propAllowLevel%>";

     try {
         propVal = parseInt(propLevelVal, 10).toString();
         if (propVal != propLevelVal) {
             propLevelVal = "1";
         }
     } catch (e) {
       propLevelVal = "1";
     }

     if ((isNaN(propLevelVal) == true) || propLevelVal < 0) {
    	//XSSOK
     alert("<%=error%>"+"<%=invalidLevelCheck%>");			         			         
         self.closeWindow();			         
     } else {
         var parseIntVal = parseInt(propLevelVal, 10).toString();
         if (parseIntVal.length != propLevelVal.length) {
        	//XSSOK
         alert("<%=error%>"+"<%=invalidLevelCheck%>");			         
             self.closeWindow();			             
        }
     }

     
     var sbReference  = getWhereUsedFrame();
     var dupemxUICore = sbReference.emxUICore;    
     var oXML         = sbReference.oXML;
     var isIncrement  = false;
     try {
         var checkedRows = dupemxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
        
         var breakLoop = false;
         var temp = false;         		   
         var samRelType = true;
         var temRelType = "";		        

         for (var i = 0; i < checkedRows.length; i++) {
              temp = true;         
	          var objectId = checkedRows[i].getAttribute("o");
	          var rowId    = checkedRows[i].getAttribute("id");				          
	          var level = sbReference.emxEditableTable.getCellValueByRowId(rowId, "Levels").value.current.actual;				          
	       
	          var reltype = checkedRows[i].getAttribute("rel");				          		             
              if (temRelType == "") {
                  temRelType = reltype;
              }
	          if (temRelType != reltype) {
	              samRelType = false;
	              break;
	          }				       
	          if(propLevelVal != 0) {             
	            if(level != "#") {              
	              if(level.length > 0  && level.charAt(0) == '-') {
	                level = level.substring(1, level.length);
	              }
					try{
					level = parseInt(level, 10);
					}
					catch(e){
						level ="1";
					}
	              if(level > propLevelVal) {  
	            	//XSSOK      
	               alert("<%=error%>"+"<%=levelCheck%>"+propLevelVal);                    
	               return false;
	                breakLoop = true;
	                break;
	              }
	            }
	          }
	          
	          
         }
         
           
         if (!samRelType) {
        	//XSSOK
        	 alert("<%=sameRelCheck%>");
        	 return false;
        	 self.closeWindow();
             //return;
         }
		
		return true;
		
   		     
     } catch (e) {
         alert("Exception Occurred:"  +e.message);
         self.closeWindow();       
     }
	

}

function getWhereUsedFrame() {

	return (parent && parent.frameElement && (parent.frameElement.name == "ENCWhereUsed" || parent.location.href.indexOf("partWhereUsed=true") > -1)) ? parent : getTopWindow().getWindowOpener().parent;	
}
</script>
</form>
</body>
</html>
