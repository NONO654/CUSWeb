<%--  emxpartCreatePartRevisionProcess.jsp   - Processing page to revise a part.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "emxDesignTopInclude.inc" %>
<%@page import = "com.matrixone.apps.engineering.EngineeringConstants" %>
<%--@page errorPage = "emxengchgErrorHandler.jsp"--%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../common/emxTreeUtilInclude.inc"%>



<%

  PartFamily partFamily = (PartFamily)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART_FAMILY,DomainConstants.ENGINEERING);

  Part part = (Part)DomainObject.newInstance(context,
                  DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String sErrMsgCode    = "";

  String objectId       = emxGetParameter(request,"objectId");
  String sRevision      = emxGetParameter(request,"revLevel");
  String sVaultName     = emxGetParameter(request,"Vault");
  String sDesc          =  emxGetParameter(request,"description").trim();
  String sOwner         = emxGetParameter(request,"Owner").trim();
  String sRDOId         = emxGetParameter(request,"RDOId");
  String sManufacturerId = emxGetParameter(request,"manufacturerId");
  String sPartNum       = emxGetParameter(request,"partNum");
  String sTypePart      = emxGetParameter(request,"type");
  String suiteKey       = emxGetParameter(request, "suiteKey");
  String jsTreeID       = emxGetParameter(request, "jsTreeID");
  String strSelectedPolicy = emxGetParameter(request, "selectedPolicy");
  String oldRDOIds = emxGetParameter(request,"oldRDOIds");
  boolean isMFGInstalled = EngineeringUtil.isMBOMInstalled(context);

  if(sRDOId == null || "null".equals(sRDOId))
      {
          sRDOId = "";
      }
          sRDOId = sRDOId.trim();

  double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();

  Map attrMap           = (Map) session.getAttribute("attributeMap");
  HashMap attributesMap = new HashMap();

  java.util.Set keys = attrMap.keySet();
  Iterator itr = keys.iterator();
  while (itr.hasNext()){
    Map valueMap = (Map)attrMap.get((String)itr.next());
    //don't display this attribute because it's already displayed
    String attrName = (String)valueMap.get("name");
    String attrValue = emxGetParameter(request,attrName);
  
    if ((attrValue!= null) && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals(""))){
      String sDataType = "";
      try {
        AttributeType attrTypeGeneric = new AttributeType(attrName);
        attrTypeGeneric.open(context);
        sDataType = attrTypeGeneric.getDataType();
        attrTypeGeneric.close(context);
      } catch (Exception ex ) {
        // Ignore the exception
        sDataType = "";
      }
      if (sDataType.equals("timestamp"))
      {
        attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrValue,tz,request.getLocale());
      }
      //IR-040596 - Starts
      else if((sDataType.equals("real") || sDataType.equals("integer")))
      {
            String strUOMAttribute  = emxGetParameter(request, attrName);
            String strUOMAttributeUnit  = emxGetParameter(request, "units_"+attrName);

            if(strUOMAttribute==null || "null".equalsIgnoreCase(strUOMAttribute) || "".equals(strUOMAttribute))
            {
                strUOMAttribute = "0";
            }

            if(strUOMAttributeUnit!=null && !"null".equalsIgnoreCase(strUOMAttributeUnit) && !"".equals(strUOMAttributeUnit))
            {
                attrValue = strUOMAttribute + " " + strUOMAttributeUnit;
            }
            else{
                attrValue = strUOMAttribute;
            }
      }
      //IR-040596 - Ends
     boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
     if(isMBOMInstalled){
          if(attrName.equals(EngineeringConstants.ATTRIBUTE_ALL_LEVEL_MBOM_GENERATED))
            {
              attrValue = "false";
            }
     }
     attributesMap.put(attrName, attrValue);
    }
  }
%>

<%@include file = "emxEngrStartUpdateTransaction.inc"%>

<%
try
{
   part.setId(objectId);
   BusinessObject revBO = part.revise(context, sRevision, sVaultName);
   Part revPart = new Part(revBO);

   revPart.getBasics(context);  // 250564 - setOwner will crash (null ptr in BusinessObject.getBasics)
                                //          if you change RDO.  This call populates _basics and prevents crash.
   String revPartId = revPart.getObjectId(context);
   revPart.setDescription(context, sDesc);

    HashMap requestMap = new HashMap();
    requestMap.put("objectId",revPartId);
    requestMap.put("New OID",sRDOId);
    requestMap.put("OLDRDOID",new String [] {oldRDOIds});
    String initargs[] = {};

    JPO.invoke(context, "emxPart", initargs, "connectRDOsForRevise", JPO.packArgs (requestMap));

   revPart.setAttributeValues(context,attributesMap);
   revPart.setOwner(context, sOwner);

   if(strSelectedPolicy != null && !strSelectedPolicy.trim().equals(""))
   {
       revPart.setPolicy(context, strSelectedPolicy);
   }

   if ((sManufacturerId != null) && (!sManufacturerId.equals(""))){
      revPart.connectManufacturerResponsibility(context, sManufacturerId);
    }
   
   SelectList select = new SelectList(2);
   String selectStr = "relationship[" + revPart.RELATIONSHIP_PART_FAMILY_MEMBER + "].from.id";
   select.addElement(selectStr);

   BusinessObjectWithSelect partSelect = part.select(context, select);
   String partFamilyId = partSelect.getSelectData(selectStr);

   if ((partFamilyId != null) && (!partFamilyId.equals("")))
   {
     partFamily.setId(partFamilyId);
     partFamily.addPart(context, revPartId);
   }

   //Added for MCC EC Interoperability Feature
   //Below code will  be used to automatically enable revised EC parts when the Parent part's MCC Update setting is Unset i.e. interface is not associated
   boolean mccInstall = FrameworkUtil.isSuiteRegistered(context,"appVersionMaterialsComplianceCentral",false,null,null);
   if(mccInstall)
   {
         String attrEnableCompliance =PropertyUtil.getSchemaProperty(context,"attribute_EnableCompliance");
         String sEnableCompliance = part.getInfo (context, "attribute["+attrEnableCompliance+"]");

         //check if  "Enable Compliance" attribute present on the part. if it does not contain the attribute i.e. interface is not associated then the value for attribute to be return as blank ""
         if("".equals(sEnableCompliance))
         {   //check that values for this property will be "Yes"
             String strEnableForMCC = FrameworkProperties.getProperty(context, "emxMaterialsCompliance.EnableMCCForNewECParts");

             if(strEnableForMCC !=null && strEnableForMCC.equalsIgnoreCase("Yes"))
             {
                  //associate the Compliance interface to a new revise part
                  MqlUtil.mqlCommand(context,"modify bus $1 add interface $2",revPartId,"Material Compliance");
                  //getting default value for "Enable Compliance" attribute & set it
                  AttributeType attrEnableComplianceType = new AttributeType(attrEnableCompliance);
                  revPart.setAttributeValue(context,attrEnableCompliance,attrEnableComplianceType.getDefaultValue(context));
             }
         }
   }
   //end
%>

   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript">
   //XSSOK
       updateCountAndRefreshTree("<%=appDirectory%>", getTopWindow().getWindowOpener().getTopWindow());
       getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
       getTopWindow().closeWindow();
   </script>
<% 
   //082358V6R2012 start
    if (isMFGInstalled) {
    	revPart.setEndItem(context);
    }
    //082358V6R2012 end
}

catch(Exception e)
{
%>
  <%@include file = "emxEngrAbortTransaction.inc"%>
<%
  session.putValue("error.message",e.toString());
%>
    <script language="javascript">
    getTopWindow().location.href = getTopWindow().location.href;
    </script>
<%

}

%>
   <%@include file = "emxEngrCommitTransaction.inc"%>
<%
  session.setAttribute("emxEngErrorMessage", sErrMsgCode);
  %>
  <%@include file = "emxDesignBottomInclude.inc"%>
