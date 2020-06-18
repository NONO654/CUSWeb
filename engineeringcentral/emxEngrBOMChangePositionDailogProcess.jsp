<%--  emxEngrBOMChangePositionDailogProcess.jsp -  This page disconnects the selected objects.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.interfaces.input.IBOMFilterIngress"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.engineering.*"%>
<%@page import="com.matrixone.apps.engineering.Part"%>
<%@page import="com.matrixone.apps.common.util.*"%>
<%@page import="com.matrixone.apps.domain.*"%>

<jsp:useBean id="changePositionBean" class="com.matrixone.apps.engineering.Part" scope="session" />
<%
String action = "refresh";
String msg = "";
//read the necessary parameters from the posted data

String tableRowId   = emxGetParameter(request, "tableRowId");
String selectedtableRowId   = emxGetParameter(request, "emxTableRowId");
StringList tableRowInfoList = FrameworkUtil.split(tableRowId, "|");
StringList selectedTableRowInfoList = FrameworkUtil.split(selectedtableRowId, "|");

String radioPartObjectId = (String) selectedTableRowInfoList.get(1);
String bomObjectId   = (String) tableRowInfoList.get(1);
String bomParentOID  = emxGetParameter(request, "objectId");

String selPartParentRowId = ((String) tableRowInfoList.get(3)).replaceAll(",*[0-9]*$", "").trim();
String selBOMRelId =  (String) tableRowInfoList.get(0);
  
  String newFindNumberValue   = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.InitialValue");
  String newFindNumberIncr = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.IncrementValue");

  int newValue = 10;
  try
  {
  	newValue = Integer.parseInt(newFindNumberValue);
  }
  catch (Exception ex)
  {
	  newValue = 10;
  }

  int incrValue = 10;
  try
  {
  	incrValue = Integer.parseInt(newFindNumberIncr);
  }
  catch (Exception ex)
  {
	  incrValue = 10;
  }

  HashMap paramMap = new HashMap();

try {
     ContextUtil.startTransaction(context, true);
            {
                 Part part = (Part)DomainObject.newInstance(context,
                 DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
                 //set id of part
                 part.setId(bomParentOID);
                 
                 StringList selectStmts = new StringList(9);
                 selectStmts.addElement(part.SELECT_ID);
                 selectStmts.addElement(part.SELECT_NAME);
                 selectStmts.addElement(part.SELECT_REVISION);
                 selectStmts.addElement(part.SELECT_TYPE);
                 selectStmts.addElement(part.SELECT_DESCRIPTION);
                 selectStmts.addElement(part.SELECT_CURRENT);
                 selectStmts.addElement(part.SELECT_ATTRIBUTE_UNITOFMEASURE);

                 StringList selectRelStmts = new StringList(5);
                 selectRelStmts.addElement(part.SELECT_RELATIONSHIP_ID);
                 selectRelStmts.addElement(part.SELECT_FIND_NUMBER);
                 selectRelStmts.addElement(part.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
                 selectRelStmts.addElement(part.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
                 selectRelStmts.addElement(part.SELECT_ATTRIBUTE_QUANTITY);
                 selectRelStmts.addElement(part.SELECT_ATTRIBUTE_USAGE);
				 
                 MapList ebomList = BOMMgtUtil.getEBOM(context, bomParentOID, selectRelStmts, selectStmts);

                 // Change Position of parts in BOM
                 if(ebomList!=null)
                {
                    Iterator itr = ebomList.iterator();  
                    //Added for TreeOrder Sorting
                    String sPrevRelId = "";
                    LinkedList slOrderedList = new LinkedList();
                    LinkedList slModifiedList = new LinkedList();
                    while(itr.hasNext())
                    {
                        Map newMap = (Map)itr.next();
                        String sObjId = (String)newMap.get("id");
                        String relId = (String)newMap.get("id[connection]");
                        // Check if the selected radio part id is same as sObjId then add the part selected in BOM
                        if(sObjId.equals(radioPartObjectId))
                        {
                           Iterator iter = ebomList.iterator();
                           if(!"".equals(sPrevRelId)){
                     		  slOrderedList.add(sPrevRelId);
                     	  }
                     	  slOrderedList.add(relId);
                           break;
                        } 
                        // Check if the selected part in BOM is same as sObjId then no action
                        else if(sObjId.equals(bomObjectId)) {
                           continue;
                        }

                        newValue = newValue + incrValue;
                        sPrevRelId = relId;
                    }  
                    
            		
                    slModifiedList.add(selBOMRelId);
                    if(slOrderedList.size()>1){
                    	slOrderedList.add(1, selBOMRelId);
                    }
                    else {
                    	slOrderedList.add(0, selBOMRelId);
                    }
                    BOMMgtUtil.persistBOMOrderFromJSP(context, slOrderedList, slModifiedList);
                }
            }
            
      // Call the Bean to invoke JPO
     //changePositionBean.changePositionBeanMethod(context, bomRelId, bomObjectId, bomParentOID, radioPartObjectId);

} catch (Exception ex) {
     ContextUtil.abortTransaction(context);
     action = "error";
     if (ex.toString() != null && (ex.toString().trim()).length()> 0){
     msg = ex.toString().trim();
}
} finally {
  ContextUtil.commitTransaction(context);
}

//clear the output buffer
out.clear();

%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
	getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	closeWindow();
</script>

<mxRoot>
<!-- XSSOK -->
<action><![CDATA[<%= action %>]]></action>
<!-- XSSOK -->
<message><![CDATA[ <%= msg %>]]></message>
</mxRoot>
