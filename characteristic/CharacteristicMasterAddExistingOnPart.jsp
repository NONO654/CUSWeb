<%-- CharacteristicMasterAddExistingOnPart.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: ENOCriteriaUtil.jsp.rca 1.60 Wed Apr  2 16:23:14 2008 przemek Experimental przemek $";
Reviewer : G1G Developer: J2J fix : IR-437201-3DEXPERIENCER2016x
--%>

<%@page import="javax.json.JsonArrayBuilder"%>
<%@page import="com.dassault_systemes.enovia.characteristic.impl.CharacteristicServices"%>
<%@page import="com.dassault_systemes.enovia.characteristic.util.CharacteristicMasterUtil"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOICriteria"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOCriteriaFactory"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOICriteriaUtil"%>
<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaConstants"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.util.CharacteristicMasterConstants"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOICharacteristicMaster"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOCharacteristicFactory"%>
 <%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaUtil"%>
<%@page	import="com.dassault_systemes.enovia.characteristic.interfaces.ENOCharacteristicServices"%>
<%@page import="com.matrixone.apps.common.util.ComponentsUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%
	
	String mode=(String)emxGetParameter(request, "mode");
	String[] strEmxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String objectId  	= emxGetParameter(request, "objectId");
	String rowIds[] = CriteriaUtil.parseTableRowId(strEmxTableRowIds, CriteriaConstants.OBJECT_ID);
	//String strSelectedObjId;
	String jsonString = null;
	boolean exceptionThrown = false;
	JsonObjectBuilder jsonObject= Json.createObjectBuilder();
	JsonArrayBuilder jsonArray= Json.createArrayBuilder();
	try {
		if ("AddExistingCMonPart".equalsIgnoreCase(mode)) {
			List<String> newCharsCreatedList = new ArrayList<String>();
			/*Commenting the below as the row ids are passed to the function at once instead of sequential: For performance improvement*/
			/*for(int i = 0; i < rowIds.length; i++){
				strSelectedObjId = rowIds[i];
				newCharsCreatedList.add(ENOCharacteristicServices.createCharacteristicOnItemBasedOnMaster(context, objectId, strSelectedObjId, false, true));
			}*/
			/*To create all the characteristics with one DB hit*/
			 newCharsCreatedList= CharacteristicServices.createCharacteristicsFromMasters(context, objectId, rowIds, false, true); 
			MapList mlReturnCharDetails = ENOCharacteristicServices.getCharacteristicDetailsForUI(context, objectId, newCharsCreatedList);
			jsonString = CharacteristicMasterUtil.transformToJSON(mlReturnCharDetails);
		}
		else if("AddTestMethodToChar".equalsIgnoreCase(mode))
		{
			
			StringBuilder sbData = new StringBuilder();
			for(int i=0; i< rowIds.length; i++)
			{
				DomainObject dObj = new DomainObject(rowIds[i]);
				JsonObjectBuilder detailsMap = Json.createObjectBuilder();
				
				String key1 = "id";
				String key2 = "name";
				String key3 = "attribute[Title]";
				
				Map<String, String> tmDetails= dObj.getInfo(context, StringList.create(DomainObject.SELECT_NAME, "attribute[Title]"));
				String value1= CriteriaUtil.stringConcat(rowIds[i]);	
				String value2= tmDetails.get(DomainObject.SELECT_NAME);
				String value3= tmDetails.get("attribute[Title]");
				detailsMap.add(key1, value1);
				detailsMap.add(key2, value2);
				detailsMap.add(key3, value3);
				jsonArray.add(detailsMap); 
				//jsonObject.put("name", (Object)dObj.getInfo(context,DomainObject.SELECT_NAME));
			}
			jsonObject.add("details", jsonArray);	
		}
		
	} catch (Exception ex) {
		ex.printStackTrace();
		exceptionThrown = true;
		emxNavErrorObject.addMessage(ex.getLocalizedMessage());
	} 
%>

<script type="text/javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<script type="text/javaScript">

	//XSSOK
	var action = "<%=XSSUtil.encodeForJavaScript(context, mode)%>";
	//XSSOK
	var errorMsg = "<%=exceptionThrown%>";
	
	
	var listHiddenTabFrame  = getTopWindow().getWindowOpener();
	var detailsFrame= findFrame(getTopWindow(),'detailsDisplay');
	if(errorMsg == 'false') {
		if ("AddExistingCMonPart" == action) {
			//XSSOK
		//IR-503940-3DEXPERIENCER2017x-To refresh the Characteristic page on add from CM.
			var jsonString = "<%=XSSUtil.encodeForJavaScript(context, jsonString)%>";	
			//This block is required when 3dsearch not enabled
			if(listHiddenTabFrame.parent.addFromSelectedObjects)
				listHiddenTabFrame.parent.addFromSelectedObjects(action, jsonString);
			//This block is required when 3dsearch is enabled
			else
				detailsFrame.addFromSelectedObjects(action, jsonString);
		}else if("AddTestMethodToChar" == action){
			//XSSOK
			//SRR7: Required to build the JSON before sending it to the javascript API(Fix for IR-584503-3DEXPERIENCER2019x and IR-595051-3DEXPERIENCER2019x)
			var testMethodDetails = <%=jsonObject.build()%>;
			if(listHiddenTabFrame.parent.addFromSelectedObjects) {
				listHiddenTabFrame.parent.addFromSelectedObjects(action, testMethodDetails);
			} else {
				detailsFrame.addFromSelectedObjects(action, testMethodDetails);
			}
		}
		getTopWindow().closeWindow();
	}
</script>

