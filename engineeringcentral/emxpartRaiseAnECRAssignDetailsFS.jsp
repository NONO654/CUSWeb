<%--  emxpartRaiseAnECRAssignDetailsFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();


  // Get the attribute names
  String sReasonForChangeAttr           = PropertyUtil.getSchemaProperty(context, "attribute_ReasonforChange");
  String ECREvaluatorAttr               = PropertyUtil.getSchemaProperty(context, "attribute_ECREvaluator");
  String responsibleDesignEngineerAttr  = PropertyUtil.getSchemaProperty(context,"attribute_ResponsibleDesignEngineer");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String objectId     = emxGetParameter(request,"objectId");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String checkBoxValue=emxGetParameter(request,"checkboxValue");
  String defaultrdoId=emxGetParameter(request,"defaultrdoId");
  String rdoId=emxGetParameter(request,"RDOId");
  String mode=emxGetParameter(request,"mode");//    IR-068172V6R2012
  fs.setSuiteKey(suiteKey);

  if( rdoId== null || rdoId.equals("")|| rdoId.equals("null") ){
      rdoId = defaultrdoId;
   }
   session.setAttribute("rdoId",rdoId);
 
  String rdoName=emxGetParameter(request,"RDO");
if( rdoName== null || rdoName.equals("")|| rdoName.equals("null") ){
 rdoName = "";
}
session.setAttribute("rdoName",rdoName);

  String policy = emxGetParameter(request,"policy");

  String reasondForChange="";
  String Relationship="";

  String Create = emxGetParameter(request,"Create");
  if(Create==null || "null".equals(Create)) {
    Create="";
  }
  fs.setDirectory(appDirectory);
  String prevmode  = emxGetParameter(request,"prevmode");
  if(prevmode == null){
    prevmode="false";
  }

  if(prevmode.equalsIgnoreCase("true")){
    String strReasonForChange = emxGetParameter(request,"reasonForChange");
     if(null!=strReasonForChange)
      {
    session.setAttribute("ReasonForChange_KEY",strReasonForChange);
 }
    }
      Relationship=emxGetParameter(request,"Relationship");


  // Specify URL to come in middle of frameset
  String contentURL   = "emxpartRaiseAnECRAssignDetailsDialog.jsp";
  String selectedType = emxGetParameter(request,"selectedType");
  if(Create.equals("true")){
    if(!(prevmode.equals("true"))){
        Map attrMap = (Map) session.getAttribute("attributeMap");
        attrMap.remove("selProductLine");
        attrMap.remove("selVault");
        attrMap.remove("selPolicy");
        attrMap.remove("description");
        HashMap map = new HashMap();
        String attrValue ="";
        String attrName = "";
        java.util.Set keys = attrMap.keySet();
        Iterator itr = keys.iterator();
        HashMap allAttributesMap=new HashMap();
        while (itr.hasNext()){

             Map valueMap = (Map)attrMap.get((String)itr.next());
             attrName = (String)valueMap.get("name");
             if (ECREvaluatorAttr.equals(attrName)) {
                attrValue = emxGetParameter(request,"ECREvaluator");
                valueMap.put("value",attrValue);
                attrMap.put(attrName,valueMap);
             }
             else if (responsibleDesignEngineerAttr.equals(attrName)) {
                 attrValue = emxGetParameter(request,"ResponsibleDesignEngineer");
                 valueMap.put("value",attrValue);
                 attrMap.put(attrName,valueMap);
             }
             else if (sReasonForChangeAttr.equals(attrName)) {
                 attrValue = emxGetParameter(request,sReasonForChangeAttr);
                 valueMap.put("value",attrValue);
                 attrMap.put(attrName,valueMap);
                 reasondForChange=attrValue;
             }
             else {
                 attrValue = emxGetParameter(request,attrName);
                 valueMap.put("value",attrValue);
                 attrMap.put(attrName,valueMap);

             }

        }
              String sProductLineId         = emxGetParameter(request,"selProductLine");
                attrMap.put("selProductLine",sProductLineId);
                String selVault               = emxGetParameter(request,"selVault");
                attrMap.put("selVault",selVault);
                String selPolicy              = emxGetParameter(request,"selPolicy");
                attrMap.put("selPolicy",selPolicy);
                String description           = emxGetParameter(request,"description");
                attrMap.put("description",description);
                session.setAttribute("attributeMap",attrMap);
      }
  }
  else
       {

             Properties selectedECRprop  = new Properties();
             selectedECRprop.setProperty("selectedType_KEY",selectedType);
             session.setAttribute("selectedECRprop",selectedECRprop);
     }

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId+"&selectedType="+selectedType;
  contentURL += "&Create="+Create+"&checkedButtonValue="+checkedButtonValue+"&prevmode="+prevmode+"&Relationship="+Relationship;
  contentURL += "&rdoId="+rdoId+"&rdo="+rdoName;
  contentURL += "&policy="+policy+"&checkboxValue="+checkBoxValue;
  contentURL += "&mode="+mode;//    IR-068172V6R2012

  contentURL = Framework.encodeURL(response, contentURL);

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // Page Heading - Internationalized
  String PageHeading = "";
  String HelpMarker = "";

  if("true".equals(Create)) {
    PageHeading ="emxEngineeringCentral.RaiseECR.NewECRAssignDetails";
    HelpMarker = "emxhelpecrnewassigndetails";
   }
  else if("1".equals(checkedButtonValue)){
	    PageHeading ="emxEngineeringCentral.RaiseECR.ExistingECRAssignDetails";//IR:068172
	    HelpMarker = "emxhelpecrexistingassigndetails";
   }
  else{
    PageHeading ="emxEngineeringCentral.RaiseECR.NewECRAssignDetails";//IR:068172
    HelpMarker = "emxhelpecrexistingassigndetails";
  }

  /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer";*/
  String roleList ="role_GlobalUser";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  if (!"Create".equals(Create))
  {
  fs.createFooterLink("emxFramework.Command.Previous",
                      "goBack()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      0);
}
  fs.createFooterLink("emxFramework.Command.Next",
                      "submitForm()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      0);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "cleanUp()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  fs.writePage(out);
%>
