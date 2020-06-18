<%-- emxEngrBOMAddExistingPartsProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<jsp:useBean id="connectPart" class="com.matrixone.apps.engineering.Part" scope="session" />
<%@ page import="com.matrixone.apps.domain.util.ContextUtil" %>
<%@ page import="com.matrixone.apps.domain.*"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%

  DomainObject partObj = DomainObject.newInstance(context);
  DomainObject selObj = DomainObject.newInstance(context);
  boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
  String objectId = emxGetParameter(request, "objectId");
  
  String uiType = emxGetParameter(request, "uiType");

  String strRefresh = "false";

 /* DomainObject partObj = DomainObject.newInstance(context);
  DomainObject selObj = DomainObject.newInstance(context);*/

  
  //System.out.println("uiType------->"+uiType);


  String replace = emxGetParameter(request, "replace");
  String addNext = emxGetParameter(request, "addNext");
  //String bomObjectId = (String)session.getAttribute("selPartObjectId");
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  if(selPartRelId==null) {
  selPartRelId="";
  }
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  if(selPartObjectId==null) {
  selPartObjectId="";
  }
  String selPartParentOId = emxGetParameter(request,"selPartParentOId"); 
  if(selPartParentOId==null) {
  selPartParentOId="";
  }
  
  String isApplyTrue = emxGetParameter(request, "isApplyTrue");
  
  String strInput = "<mxRoot>";//<action><![CDATA[add]]></action><message><![CDATA[]]></message><data status=\"pending\">";
  String callbackFunctionName = "loadMarkUpXML";
  
  String partFamilyId = objectId;
  
  if(!"".equals(selPartObjectId)) {
    objectId = selPartObjectId;
  }

// Added If loop

if(!"AVLReportAddmanualPart".equalsIgnoreCase(uiType))
{
	
  if (!replace.equals("true") && !addNext.equals("true")) {
  strInput = strInput + "<object objectId=\"" + objectId + "\">";
  }
}


  partObj.setId(objectId);

  String isAVLReport = emxGetParameter(request,"AVLReport");
  BusinessObjectWithSelect busWithSelect = null;
  StringList mepSelectStmts = new StringList(2);
  mepSelectStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_MANUFACTURER_EQUIVALENT_TO_ID);
  mepSelectStmts.addElement(DomainConstants.SELECT_LOCATION_EQUIVALENT_TO_ID);
  StringList tempList = new StringList();
  String failedToConnect = "";
  String ebomPartName = "";
  String policy = "";
  String mePartList = "";
  String relType = DomainConstants.RELATIONSHIP_EBOM;
  Vector vSelIds = new Vector();


  int totalCount = 0;

     String[] selPartIds = null;
    // Loop through parameters
    StringBuffer param = new StringBuffer("");
    for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
    {
        String name = (String) names.nextElement();
  
        if(name.equals("checkBox"))
        {
          selPartIds = emxGetParameterValues(request, name);

        } 
  }
    if(selPartIds != null){
        totalCount = selPartIds.length;
  }

  MQLCommand mqlCommand = new MQLCommand();
  mqlCommand.open(context);


%>
  <%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%

if("AVLReportAddmanualPart".equalsIgnoreCase(uiType)){
	strRefresh = "true";
	
	MapList tempListNewget=(MapList)session.getAttribute("tempListNew");
	Iterator ItrSelIdMEPartCheck=tempListNewget.iterator();
	DomainObject selObjAVL;
	
	while(ItrSelIdMEPartCheck.hasNext()){
		Map selObjInfo =  (Map)ItrSelIdMEPartCheck.next();
		try{	        
			selObjAVL = DomainObject.newInstance(context, (String)selObjInfo.get(DomainConstants.SELECT_ID)); 
	        ebomPartName = (String)selObjInfo.get(DomainConstants.SELECT_NAME);
            busWithSelect = selObjAVL.select(context,mepSelectStmts);
            tempList = busWithSelect.getSelectDataList(DomainConstants.SELECT_RELATIONSHIP_MANUFACTURER_EQUIVALENT_TO_ID);
            if (tempList==null || tempList.size()<=0) {
            	failedToConnect= failedToConnect.length()== 0 ? ebomPartName : failedToConnect + "," +ebomPartName;
            }
		 }catch(Exception ex){
	           session.putValue("error.message",ex.getMessage());
		 }
	}
	
	
	if ("".equals(failedToConnect)) {
	    
	    Iterator ItrFortempListNewget=tempListNewget.iterator();
	    
	    DomainObject doobjectId=new DomainObject();
	    doobjectId.setId(objectId);

	    int i=0;

	    while(ItrFortempListNewget.hasNext())
	    {
	    String strFN = emxGetParameter(request, "FindNumber"+i);
	    String strRD=  emxGetParameter(request, "Reference Designator"+i);
	    String strCL=emxGetParameter(request, "Component Location"+i);
	    String strHMS=emxGetParameter(request, "Has Manufacturing Substitute"+i);
	    String strQty=emxGetParameter(request, "Qty"+i);
	    String strUsage=emxGetParameter(request, "Usage"+i);
	    String strNotes=emxGetParameter(request, "Notes"+i);  
	    String strUOM=emxGetParameter(request, "Unit of Measure"+i); 
	    


	    Map nMap=(Map)ItrFortempListNewget.next();
	    String sOid=(String)nMap.get("id");
	    
	    
	    DomainObject dosOid=new DomainObject();
	    dosOid.setId(sOid);

	      DomainRelationship doRelNew = DomainRelationship.connect(context, doobjectId, DomainConstants.RELATIONSHIP_EBOM, dosOid);
	      doRelNew.setAttributeValue(context,DomainConstants.ATTRIBUTE_FIND_NUMBER,strFN);
	      doRelNew.setAttributeValue(context,DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR,strRD);
	      doRelNew.setAttributeValue(context,DomainConstants.ATTRIBUTE_COMPONENT_LOCATION,strCL);
	      doRelNew.setAttributeValue(context, DomainConstants.ATTRIBUTE_QUANTITY,strQty);
	      doRelNew.setAttributeValue(context,DomainConstants.ATTRIBUTE_USAGE,strUsage);
	      doRelNew.setAttributeValue(context, DomainConstants.ATTRIBUTE_NOTES,strNotes);
	      doRelNew.setAttributeValue(context, DomainConstants.ATTRIBUTE_UNIT_OF_MEASURE,strUOM);



	        i++;
	    }
	}
}

boolean flag=true;
  for(int i =0; i < totalCount; i++)
  {
    flag=true;
    try
    {
      String selOid = selPartIds[i];
      if(selOid == null){
      continue;
      }
  
      try
      {
        mqlCommand.executeCommand(context, "set transaction savepoint $1","EBOM");
        selObj.setId(selOid);
        ebomPartName = selObj.getName(context);
        policy = selObj.getInfo(context, DomainConstants.SELECT_POLICY);
        //if (!policy.equalsIgnoreCase(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT)) {
        if (isAVLReport != null && !isAVLReport.equalsIgnoreCase("null") && isAVLReport.equalsIgnoreCase("TRUE")) {
            busWithSelect = selObj.select(context,mepSelectStmts);
            tempList = busWithSelect.getSelectDataList(DomainConstants.SELECT_RELATIONSHIP_MANUFACTURER_EQUIVALENT_TO_ID);
            if (tempList!=null) {
                if (tempList.size()<=0) {
                    flag = false;
                } else {
                    flag = true;
                }
            } else  {
                flag = false;
            }
            if (!flag) {
                tempList = busWithSelect.getSelectDataList(DomainConstants.SELECT_LOCATION_EQUIVALENT_TO_ID);
                if (tempList!=null) {
                    if (tempList.size()<=0) {
                        flag = false;
                    } else {
                        flag = true;
                    }
                } 
                else {
                    flag = false;
                }
            }
        }
        if (flag) {
                vSelIds.add(selPartIds[i]);
                if (!replace.equals("true") && !addNext.equals("true")) {

                //connectPart.connectPartToBOMBean(context, objectId, selPartIds[i], relType);
                //strInput = strInput + "<item pid=\"" + objectId + "\" oid=\"" + selPartIds[i] + "\" relId=\"\" relType=\"EBOM\" direction=\"from\"><column name=\"Find Number\">23</column></item>";
                if(isMBOMInstalled){
                    //Modified for Additing parts from Common View : Start
                    strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">";
    				strInput+= "<column name=\"Find Number\" edited=\"true\"></column><column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\">Standard</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    				strInput+="</object>";
                    //Modified for Additing parts from Common View : End
                }else {
                strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"></object>";
                }
                //DomainRelationship dr = partObj.connect(context,relType, selObj, false);
                }

        }
        else {
            if (failedToConnect.length()== 0) {
                failedToConnect = ebomPartName;
            } else {
                failedToConnect = failedToConnect + ", " +ebomPartName;
            }
        }
       /*}
       else {
            if (mePartList.length() == 0){
               mePartList = ebomPartName;
            } else {
                mePartList = mePartList + ", " +ebomPartName;
            }
       }*/
      }
      catch(Exception ex)
      {
         mqlCommand.executeCommand(context, "abort transaction $1","EBOM");

         session.putValue("error.message",ex.getMessage());
      }
    }
    catch(Exception Ex)
    {
      session.putValue("error.message",Ex.getMessage());
    }
  }  // ends for selected objects

                if ("true".equals(replace)) {
                session.putValue("selPartIds",selPartIds);
		String newUrl = "emxEngrBOMReplaceDailogFS.jsp?partFamilyContextId="+partFamilyId+"&selPartObjectId="+objectId+"&selPartParentOId="+selPartParentOId+"&selPartRelId="+selPartRelId+"&createdPartObjId="+"&isApplyTrue="+isApplyTrue+"&totalCount="+totalCount+"&replaceWithExisting=true";
                %>
                  <script language="Javascript">
                  //XSSOK
                      document.location.href = "<%=XSSUtil.encodeForJavaScript(context,newUrl)%>";
                  </script>
                <%
                }

                if("true".equals(addNext)) {
      //connectPart.addNextPartinBOM(context, vSelIds, objectId, selPartRelId, selPartObjectId, selPartParentOId, partFamilyId);

      DomainObject ctxObj = DomainObject.newInstance(context);
      ctxObj.setId(partFamilyId);
      String ctxPolicy = ctxObj.getInfo(context, DomainConstants.SELECT_POLICY);
      String state = ctxObj.getInfo(context, DomainObject.SELECT_CURRENT);
      String newFindNumberIncr = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.IncrementValue");

      MapList ebomList= new MapList();
      Integer newFNValue = new Integer(0);
      int incrFNValue = 0;

	Part selPartObj = new Part(selPartParentOId);
	StringList selectStmts = new StringList(7);
	selectStmts.addElement(selPartObj.SELECT_ID);
	selectStmts.addElement(selPartObj.SELECT_NAME);
	selectStmts.addElement(selPartObj.SELECT_REVISION);
	selectStmts.addElement(selPartObj.SELECT_TYPE);
	selectStmts.addElement(selPartObj.SELECT_DESCRIPTION);
	selectStmts.addElement(selPartObj.SELECT_CURRENT);
	selectStmts.addElement(selPartObj.SELECT_ATTRIBUTE_UNITOFMEASURE);

	StringList selectRelStmts = new StringList(2);
	selectRelStmts.addElement(selPartObj.SELECT_RELATIONSHIP_ID);
        selectRelStmts.addElement(selPartObj.SELECT_FIND_NUMBER);
        
        ebomList = selPartObj.getEBOMs(context, selectStmts, selectRelStmts, false);
        ebomList.addSortKey("attribute[" + DomainConstants.ATTRIBUTE_FIND_NUMBER + "]", "ascending", "String");
        ebomList.sort();             

        int size = vSelIds.size();
        int div = size + 1;

        String sFNvalue = "";
        String oldFNvalue = "";
        strInput = strInput + "<object objectId=\"" + selPartParentOId + "\">";
          // Add EBOM to the newly created part
          if(ebomList!=null || !ebomList.equals("null")) {

            Iterator itr = ebomList.iterator();

            while(itr.hasNext()) {
              Map newMap = (Map)itr.next();
              String sEBOMId = (String)newMap.get("id");
              String relId = (String)newMap.get("id[connection]");
              
              newFNValue = newFNValue + new Integer(10);  
      if ((ctxPolicy.equals(DomainConstants.POLICY_DEVELOPMENT_PART) && !state.equals(DomainConstants.STATE_DEVELOPMENT_PART_COMPLETE)) || (ctxPolicy.equals(DomainConstants.POLICY_EC_PART) && state.equals(DomainConstants.STATE_PART_PRELIMINARY)) ) {
      
              if (sEBOMId.equals(selPartObjectId)) {

              for(int i=0;i<vSelIds.size();i++) {
              String selId = (String) vSelIds.get(i);
              newFNValue = newFNValue + new Integer(10);
              if(isMBOMInstalled) {
                  //Modified for Additing parts from Common View : Start
                  strInput = strInput + "<object objectId=\"" + selId + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+newFNValue.toString()+"</column>";
    			  strInput+="<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\">Standard</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    			  strInput+="</object>";
    			  //Modified for Additing parts from Common View : End
   
              }else {
                strInput = strInput + "<object objectId=\"" + selId + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+newFNValue+"</column></object>";
              }

              }
         break;
              } 
          } else {
                if (sEBOMId.equals(selPartObjectId)) {
                oldFNvalue = (String)newMap.get("attribute["+DomainConstants.ATTRIBUTE_FIND_NUMBER+"]");
                newFNValue = Integer.parseInt(oldFNvalue);

                if(itr.hasNext()) {
                newMap = (Map)itr.next();
                sFNvalue = (String)newMap.get("attribute["+DomainConstants.ATTRIBUTE_FIND_NUMBER+"]");
                }

                if(!sFNvalue.equals("")) {
                incrFNValue = (Integer.parseInt(sFNvalue) - Integer.parseInt(oldFNvalue))/div;
                } else {
                incrFNValue = Integer.parseInt(newFindNumberIncr);
                }

                if (incrFNValue>0) {
                for(int i=0;i<vSelIds.size();i++) {
                String selId = (String) vSelIds.get(i);

                newFNValue = newFNValue + new Integer(incrFNValue);
                if(isMBOMInstalled){
                    //Modified for Additing parts from Common View : Start
                    strInput = strInput + "<object objectId=\"" + selId + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\"  edited=\"true\">"+newFNValue.toString()+"</column>";
    				strInput+= "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\">Standard</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    				strInput+="</object>";
    				//Modified for Additing parts from Common View : End
                }else {
                strInput = strInput + "<object objectId=\"" + selId + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\"  edited=\"true\">"+newFNValue+"</column></object>";
                }
                }
                break;
                }
                else {
                %>
                <script language="Javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.BOM.NumberOfPartsExceed</emxUtil:i18nScript>");
                </script>
                <%
                break;
                }
                }
                }
                }
      strInput = strInput + "</object>"; 
      if ((ctxPolicy.equals(DomainConstants.POLICY_DEVELOPMENT_PART) && !state.equals(DomainConstants.STATE_DEVELOPMENT_PART_COMPLETE)) || (ctxPolicy.equals(DomainConstants.POLICY_EC_PART) && state.equals(DomainConstants.STATE_PART_PRELIMINARY)) ) {
        Iterator iter = ebomList.iterator();
        newFNValue = 0;
        while(iter.hasNext()) {
        Map newMap = (Map) iter.next();
        String sEBOMId = (String) newMap.get("id");
        String relId = (String) newMap.get("id[connection]");
        newFNValue = newFNValue + 10;
      
        strInput = strInput + "<object objectId=\"" + sEBOMId + "\" relId=\"" + relId + "\" parentId=\"" + selPartParentOId + "\" relType=\"relationship_EBOM\" markup=\"changed\"><column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+newFNValue+"</column></object>";
        if(sEBOMId.equals(selPartObjectId)) {
          for(int i=0;i<vSelIds.size();i++) {
            newFNValue = newFNValue + 10;
          }
        }
     }
     }
     } 
     strInput = strInput + "</mxRoot>";              
     }
                
  mqlCommand.close(context);
if (!"true".equals(replace) && !"true".equals(addNext)) {
  //strInput = strInput + "</data></mxRoot>";
  strInput = strInput + "</object></mxRoot>";
}
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
  var isApplyTrue = "<%=XSSUtil.encodeForJavaScript(context,isApplyTrue)%>";
  
<%
    if (failedToConnect.length()!=0) {
%>
		//XSSOK
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.AVL.NoManufacturingData</emxUtil:i18nScript>"+ " " + "<%=failedToConnect%>");
<%
    }
%>
<%
//XSSOK
    if (mePartList.length()!=0) {
%>
//XSSOK
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.EBOM.NotConnectMEParts</emxUtil:i18nScript>"+ " - " + "<%=mePartList%>");
<%
    }
%>
    
 <%
   //String url = "emxEngrCommonPartSearchDialogFS.jsp?targetSearchPage=emxEngrBOMAddExistingPartsProcess.jsp&page1Heading=emxEngineeringCentral.EBOM.FindParts&page2Heading=emxEngineeringCentral.EBOM.SelectParts&omitSpareParts=TRUE&showCollections=true&readOmitAllRevisions=TRUE&objectId="+partFamilyId+"&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&uiType="+uiType;
   String url = "emxEngrCommonPartSearchDialogFS.jsp?targetSearchPage=emxEngrBOMAddExistingPartsProcess.jsp&pageHeading=Search&formName=ECEnhancedPartSearchForm&toolbar=ENCEnhancedPartSearchToolbar&omitSpareParts=TRUE&uiType=structureBrowser&objectId="+partFamilyId+"&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&uiType="+uiType+"&replace="+replace+"&addNext="+addNext;
 %>
//XSSOK
if('<%=strRefresh%>' == "true") {
	var parentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "listDisplay");
   	if(parentDetailsFrame==null)
   	{
   		this.getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().location.href = this.getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().location.href;
   		this.getWindowOpener().getTopWindow().closeWindow();
   		this.closeWindow();
   		
   	}
   	else
   	{
    	parentDetailsFrame.parent.document.location.href=parentDetailsFrame.parent.document.location.href;
		parent.closeWindow();
	}
} else 
{
  var objWin = getTopWindow().getWindowOpener().parent;
  if(getTopWindow().getWindowOpener().parent.name == "treeContent")
  {
     objWin=getTopWindow().getWindowOpener();
  }
//XSSOK
  var callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);
  var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>', "true");
  //objWin.document.location.href = objWin.document.location.href;
   if (isApplyTrue != "true") {
 
   parent.closeWindow();
}
    else {
    	//XSSOk
   parent.document.location.href = "<%=XSSUtil.encodeForJavaScript(context,url)%>";
   }
}
</script>
