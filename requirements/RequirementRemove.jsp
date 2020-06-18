<%--
  RequirementRemove.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/RequirementRemove.jsp 1.4.2.2.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";
 --%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview LX6 JX5 10 Jan 2013  IR-208780V6R2014  STP: Removing of any object from Requirement structure is KO. 
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.*"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%-- Script Includes --%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>

<%
boolean bFlag    = false;
String action    = "";
String msg       = "";
//added below variables for Decision on Relationships feature.
String strUiType = "";
java.util.Map relIdMap = new HashMap();
java.util.Map objRelMap = new HashMap();
String sNoticeMessage1 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.RequirementsRemove1");
String sNoticeMessage2 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.RequirementsRemove2");
String sNoticeMessage3 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.RequirementsRemoveParen");


try
{
	action = "remove";
	ProductLineCommon ProductLineCommonBean = new ProductLineCommon();
	///extract Table Row ids of the checkboxes selected.
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String objectId = emxGetParameter(request, "objectId");
			   
    //------------------Code added for Decision on Relationships feature -start
		//get the value of uiType parameter
		strUiType =	emxGetParameter(request, "uiType");

		//If the value of uiType parameter is null, set it to default value "Structure Browser"
		if(("null").equals(strUiType) || strUiType == null){
			strUiType = "Structure Browser";
		}
		
		   //If the value of uiType parameter is 'Table',get the relId map which holds rel2rel ids.
		if("Table".equalsIgnoreCase(strUiType)){   
				  //extracts object and relationship ids of the Object/Relationships to be disconnected.   
				  relIdMap = RequirementsUtil.getObjectIdsRelIds(context,arrTableRowIds,objectId);
				
				  
		}
	//------------------Code added for Decision on Relationships feature -end
		 // when the value of uiType parameter is 'Structure Browser',get the relId map which holds rel ids by which two objects are connected.
		else { 	   
				  //extracts object and relationship ids of the Objects to be disconnected.   
				  relIdMap = ProductLineUtil.getObjectIdsRelIdsR213(arrTableRowIds);
		} 

	//Obtaining the relationship ids from the Map returned by the previous step
	String[] arrObjectIds = (String[]) relIdMap.get("ObjId");
	String[] arrRelIds    = (String[]) relIdMap.get("RelId");
	
	if(!"Table".equalsIgnoreCase(strUiType)){
       for(int i=0; i<arrRelIds.length; i++){
		  int iPosition = arrObjectIds[i].indexOf("|");
		  //START LX6 IR-208780V6R2014 STP: Removing of any object from Requirement structure is KO. 
		  if(iPosition == -1)
		  {
			  //this means that there is no | character
			  objRelMap.put(arrRelIds[i],arrObjectIds[i]);
		  }
		  else
		  {
			  //put in map rel as key and obj id as value
	      objRelMap.put(arrRelIds[i],arrObjectIds[i].substring(0, iPosition));
		  }
		//END LX6 IR-208780V6R2014 STP: Removing of any object from Requirement structure is KO.
		}
	}
    //returns true in case of successful disconnect.
	//Calling the removeObjects() method of ProductLineCommonBean.java
	if("Table".equalsIgnoreCase(strUiType)){   
	 bFlag = ProductLineCommonBean.removeObjects(context,arrRelIds);
	}
	else {
	 RequirementsCommon requirementcommonBean = new RequirementsCommon();
	 boolean parentDelete = false;

              for(int i=0; i< arrRelIds.length;i++){
                  
                    if(("").equals(arrRelIds[i])){
				          parentDelete =true;
						  break;
				}
			  }
            //if parent object is selected for delete, then show an alert
			if(parentDelete){
                msg = sNoticeMessage3;
			}
			else {

			//Starting the transaction to remove the selected Requirement Objects
	        ContextUtil.startTransaction(context, true);  
			Map resultMap = requirementcommonBean.relConnectedToRel(context,arrRelIds);
			//Commiting the transaction to delete the selected Requirement Objects
	        ContextUtil.commitTransaction(context); 

     StringList strAlertList = new StringList();
	 StringList strRemoveList = new StringList();

	 for(int i=0; i<arrRelIds.length; i++){
		
		    int iPosition = arrObjectIds[i].indexOf("|");
		    String relConnection = (String)resultMap.get(arrRelIds[i]);
			if(("true").equals(relConnection)){
                strAlertList.add(arrRelIds[i]);
			}
            else{
			strRemoveList.add(arrRelIds[i]);
			}
		}
	

	 String[] arrRelIdsConnected    = (String[])strAlertList.toArray(new String[]{});
	 String[] arrRelIdsNotConnected = (String[])strRemoveList.toArray(new String[]{});
	 String[] arrObjectIdsForAlert  = new String[arrRelIdsConnected.length];
	  //iterate thru connected rel ids to display the alert msg to user
		 for (int itrConn = 0; itrConn < arrRelIdsConnected.length; itrConn++)
		{
			 arrObjectIdsForAlert[itrConn] = (String)objRelMap.get(arrRelIdsConnected[itrConn]);
		}

		   if(arrRelIdsConnected.length >0){
					  StringList objectSelects = new StringList();
					  objectSelects.add(DomainConstants.SELECT_TYPE);
					  objectSelects.add(DomainConstants.SELECT_NAME);
					  objectSelects.add(DomainConstants.SELECT_REVISION);
					  //call getInfo to get the TYPE,NAME,REVISION of the bus object.
					  MapList removeAlert = DomainObject.getInfo(context,arrObjectIdsForAlert,objectSelects);
											 
					  StringBuffer alertMsg = new StringBuffer(100);
					  StringList strList = new StringList();
					  Iterator itr = removeAlert.iterator();
					  Map map      = new HashMap();

							   while (itr.hasNext()) {
									StringBuffer sbMsg    = new StringBuffer(50);
									map = (Map) itr.next();
									sbMsg.append((String) map.get(DomainConstants.SELECT_TYPE));
									sbMsg.append(" ");
									sbMsg.append((String) map.get(DomainConstants.SELECT_NAME));
									sbMsg.append(" ");
									sbMsg.append((String) map.get(DomainConstants.SELECT_REVISION));
									strList.add(sbMsg.toString());
								}
								//to display the alert msg to user
								alertMsg.append(sNoticeMessage1);
								alertMsg.append(" ");
								alertMsg.append(strList.toString());
								alertMsg.append(sNoticeMessage2);

								msg = alertMsg.toString();
								action = "error";
				 }
												
								bFlag = ProductLineCommonBean.removeObjects(context,arrRelIdsNotConnected);
		}
	  }
 	 
} //end of try block
catch(Exception e)
{
	action="error";
	msg=e.getMessage();
}

if("error".equals(action) && bFlag ==true)
{
	action="error";
} 

if(!bFlag)
{
	action="error";
} %>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
    //when uiType is table,refresh the table.
    if("<xss:encodeForJavaScript><%=strUiType%></xss:encodeForJavaScript>"=="Table")
    {  
        parent.location.href = parent.location.href;
    }
			   
</script> 
	  
<%
//refresh the structure browser
if("StructureBrowser".equalsIgnoreCase(strUiType) || "Structure Browser".equalsIgnoreCase(strUiType)){
	//clear the output buffer
	out.clear();
	//set the response object content type to xml.
    response.setContentType("text/xml");
%>

<mxRoot>

<action><![CDATA[<xss:encodeForHTML><%=action%></xss:encodeForHTML>]]></action>

<message><![CDATA[<xss:encodeForHTML><%=msg%></xss:encodeForHTML>]]></message>

<%
	if("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB")) && "remove".equalsIgnoreCase(action)){
		String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		for(int i = 0; i < arrTableRowIds.length; i++){
			String[] tokens = arrTableRowIds[i].split("[|]", -1);
			if(tokens.length == 4){
%>
<item r="<xss:encodeForHTMLAttribute><%=tokens[0]%></xss:encodeForHTMLAttribute>" o="<xss:encodeForHTMLAttribute><%=tokens[1]%></xss:encodeForHTMLAttribute>" p="<xss:encodeForHTMLAttribute><%=tokens[2]%></xss:encodeForHTMLAttribute>" id="<xss:encodeForHTMLAttribute><%=tokens[3]%></xss:encodeForHTMLAttribute>" />
<%				
			}
		}
	}
%>
</mxRoot>

<%
}
%>


