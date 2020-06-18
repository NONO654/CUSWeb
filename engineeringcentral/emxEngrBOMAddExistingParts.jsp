<%--  emxEngrBOMAddExistingParts.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil" %>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants" %>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<%@include file = "emxengchgValidationUtil.js" %>
<script language="Javascript">
var fnArray = new Array();
var rdArr = new Array();
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();
var TNRArray = new Array();
</script>

<%
  String strRd="";
  String ROLE_SENIOR_DESIGN_ENGINEER=PropertyUtil.getSchemaProperty(context,"role_SeniorDesignEngineer");
  String ROLE_DESIGN_ENGINEER=PropertyUtil.getSchemaProperty(context,"role_DesignEngineer");
  boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
  Part domObj = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

  String languageStr              = request.getHeader("Accept-Language");
  String jsTreeID                 = emxGetParameter(request,"jsTreeID");

  String isAVLReport = emxGetParameter(request,"AVLReport");

  String strObjectId = emxGetParameter(request,"objectId");

  domObj.setId(strObjectId);

  String uiType = emxGetParameter(request, "uiType");
  boolean bIsToManuPol = false;
  boolean bIsFromManuPol = false;
      //EngineeringUtil.isManuPartPolicy(context,domObj.getInfo(context,EngineeringConstants.SELECT_POLICY));
  


MapList tempListNew = new MapList();

  //Declare display variables
  String objectType  = "";

  int totalSelParts = 0;
  String[] selPartIds = (String[]) session.getAttribute("checkBox");
  if(selPartIds != null){
    totalSelParts = selPartIds.length;
  }
  //domObj.setId(strObjectId);

  String attrRef                 = PropertyUtil.getSchemaProperty(context,"attribute_ReferenceDesignator");
  boolean hasDsgEngSrDsgEng = false;
  String attrHasManufacturingSubstitute = "";
  if(isMBOMInstalled) {
      bIsFromManuPol =   EngineeringUtil.isManuPartPolicy(context,domObj.getInfo(context,EngineeringConstants.SELECT_POLICY));
  	hasDsgEngSrDsgEng = (PersonUtil.hasAssignment(context,ROLE_DESIGN_ENGINEER) || 
          PersonUtil.hasAssignment(context,ROLE_SENIOR_DESIGN_ENGINEER))?true:false;
  	attrHasManufacturingSubstitute= PropertyUtil.getSchemaProperty(context, "attribute_HasManufacturingSubstitute");
  }

%>
     <script language="Javascript">

<%
        StringList selectStmts = new StringList(3);
        selectStmts.addElement(DomainConstants.SELECT_ID);
        StringList selectRelStmts = new StringList(1);
        selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
        selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
        // get Relationship Data like Find Number and use in checking for uniqueness
        MapList ebomList = domObj.getRelatedObjects(context,
                                             DomainConstants.RELATIONSHIP_EBOM,    // relationship pattern
                                             DomainConstants.TYPE_PART,            // object pattern
                                             selectStmts,                 // object selects
                                             selectRelStmts,              // relationship selects
                                             false,                       // to direction
                                             true,                        // from direction
                                             (short)1,                    // recursion level
                                             null,                        // object where clause
                                             null);
        int j = 0;
        String fnValue = "";
        String rdValue="";
        Iterator bomItr = ebomList.iterator();
        while(bomItr.hasNext())
        {
            Map bomMap = (Map)bomItr.next();
            fnValue = (String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
            rdValue=(String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);

            if(j ==1)
            {
              strRd=rdValue;
            }
            else
            {
               strRd=strRd + "," + rdValue;
            }
%>			//XSSOK
            rdArr["<%=j%>"]="<%=rdValue%>";
            //XSSOK
            fnArray["<%=j%>"]="<%=fnValue%>";

<%
            j++;
        }
%>
   </script>
<%

  SelectList resultSelects = new SelectList(8);
  resultSelects.add(DomainObject.SELECT_ID);
  resultSelects.add(DomainObject.SELECT_TYPE);
  resultSelects.add(DomainObject.SELECT_NAME);
  resultSelects.add(DomainObject.SELECT_REVISION);
  resultSelects.add(DomainObject.SELECT_DESCRIPTION);
  resultSelects.add(DomainObject.SELECT_CURRENT);
  resultSelects.add(DomainObject.SELECT_OWNER);
  resultSelects.addElement("policy");

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
    isPrinterFriendly = "true".equals(printerFriendly);
  }

%>


<script language="javascript">
function previous() {
    <%
      String part1 = emxGetParameter(request,"part1");
      String part2 = emxGetParameter(request,"part2");
      String part3 = emxGetParameter(request,"part3");
      String part4 = emxGetParameter(request,"part4");
      String part5 = emxGetParameter(request,"part5");
      String part1Revision = emxGetParameter(request, "part1Revision");
      String part2Revision = emxGetParameter(request, "part2Revision");
      String part3Revision = emxGetParameter(request, "part3Revision");
      String part4Revision = emxGetParameter(request, "part4Revision");
      String part5Revision = emxGetParameter(request, "part5Revision");
      String specificTxt1 = emxGetParameter(request,"specificTxt1");
      String specificTxt2 = emxGetParameter(request,"specificTxt2");
      String specificTxt3 = emxGetParameter(request,"specificTxt3");
      String specificTxt4 = emxGetParameter(request,"specificTxt4");
      String specificTxt5 = emxGetParameter(request,"specificTxt5");
      String vault = emxGetParameter(request,"vault");
 StringBuffer url = new StringBuffer("emxEngrBOMManualAddExistingpartFS.jsp?");
      url.append("part1="+part1);
      url.append("&part2="+part2);
      url.append("&part3="+part3);
      url.append("&part4="+part4);
      url.append("&part5="+part5);
      url.append("&part1Revision="+part1Revision);
      url.append("&part2Revision="+part2Revision);
      url.append("&part3Revision="+part3Revision);
      url.append("&part4Revision="+part4Revision);
      url.append("&part5Revision="+part5Revision);
      url.append("&specificTxt1="+specificTxt1);
      url.append("&specificTxt2="+specificTxt2);
      url.append("&specificTxt3="+specificTxt3);
      url.append("&specificTxt4="+specificTxt4);
      url.append("&specificTxt5="+specificTxt5);
      url.append("&vault="+vault);

     %>
     //XSSOK
      document.editForm.action="<%=XSSUtil.encodeForJavaScript(context,url.toString())%>";
      document.editForm.submit();
}



  function submit() {

if(jsIsClicked())
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Process.MultiSubmit</emxUtil:i18nScript>");
       return;
    }

    var totcount = document.editForm.selCount.value;
    var fnRequired ="";
    var rdRequired ="";
    //XSSOK
    var fnLength     = "<%=fnLength%>";
    //XSSOK
    var rdLength      = "<%=rdLength%>";
    //XSSOK
    var ParentStr      = "<%=strRd%>";
  //XSSOK
    var fnUniqueness = "<%=fnUniqueness%>";
  //XSSOK
    var rdUniqueness = "<%=rdUniqueness%>";
  //XSSOK
    var ebomUniquenessOperator="<%=ebomUniquenessOperator%>";
    var RefArray = new Array()
    var TNRDArray=new Array();
    var RdClientArray=new Array();
    RefArray=rdArr;
    var rdunique="false";
    var uniq ="true";

    for(var i = 0; i < totcount; i++)
    {
      var fnObj = eval('document.editForm.FindNumber' + i);
	//XSSOK
      var rdObj = eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ i +'"]');
       if(rdObj==null)
       {
           rdObj="";
       }
       fnRequired = fnPropertyArray[i];
       rdRequired = rdPropertyArray[i];

        if(fnObj != null || rdObj != null)
        {
          fnObj.value = trim(fnObj.value);
          var fnvalue = fnObj.value;
          var rdvalue = rdObj.value;
          RdClientArray[i]=rdvalue;

          if(!validateFNRD(fnObj,rdObj,fnRequired,rdRequired,i,totcount))
          {
                return;
          }
          if(fnUniqueness=="true" && !isFNUnique(fnvalue,i))
          {
              alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
              fnObj.focus();
              return;
          }
          var nonUniqueFNs = getNonUniqueFN(totcount);
          var focus = nonUniqueFNs.charAt(nonUniqueFNs.length-1);
          nonUniqueFNs = nonUniqueFNs.substring(0,nonUniqueFNs.indexOf("~"));
          var nonUniqueFNObj = eval("document.editForm.FindNumber"+focus);

          if(fnUniqueness=="true" && nonUniqueFNs.length>0)
          {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNNotUniqueForTNR</emxUtil:i18nScript>"+" "+nonUniqueFNs);
                nonUniqueFNObj.focus();
                return;
          }
          else if(fnUniqueness!="true" && rdUniqueness!="true")
          {
              if(!isFNUnique(fnvalue,i))
              {
                  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
                  fnObj.focus();
                  return;
              }
              if(nonUniqueFNs.length>0)
              {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNNotUniqueForTNR</emxUtil:i18nScript>"+" "+nonUniqueFNs);
                nonUniqueFNObj.focus();
                return;
              }
          }
        if(rdUniqueness=="true" && !isEmpty(rdvalue))
        {
           var refstr=RefArray.join()
            unique = isRDUnique(refstr,rdvalue)
            if(!unique)
            {
              TNRDArray[i]=TNRArray[i];
            }
            rdunique="true";
           }

        var qtyobj = eval('document.editForm.Qty' + i);

      if(qtyobj != null)
      {
        qtyobj.value = trim(qtyobj.value);
        var qtyvalue = qtyobj.value;

        if(isEmpty(qtyvalue))
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
          qtyobj.focus();
          return;

        }

        if(!isNumeric(qtyvalue))
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
          qtyobj.focus();
          return;
        }

        if((qtyvalue).substr(0,1) == '-')
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
          qtyobj.focus();
          return;
        }
        
        if(!isEmpty(rdvalue))
        {
            var qt = getRDQuantity(rdvalue)
           
            if (qtyvalue!= qt)
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
                qtyobj.focus();
                return;
            }

            if(qt==0)
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
                qtyobj.focus();
                return;
            }

               

        }
         /*commented for the bug no 332272
         // added for the bug 305791
          if(qtyvalue.indexOf(".") != -1){
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeNumber</emxUtil:i18nScript>");
                qtyobj.focus();
                return;
              }
          //end the bug 305791
           */
      }
    }

  } // end of For
 if (rdunique=="true")
 {
   uniq = checkUnique(RdClientArray);
   var k=0;
   if(uniq==false)
   {
	   //XSSOK
       var rdobj=eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ k +'"]');
       rdObj.focus();
       return;
   }
   else
   {
    if(TNRDArray.length > 0)
    {
         alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDNotUniqueForTNR</emxUtil:i18nScript>"+" "+TNRDArray);
         //XSSOK
         var rdobj=eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ k +'"]');
         rdObj.focus();
         return;

    }
 }
} // if

if (jsDblClick())
     {
        startProgressBar(true);
       document.editForm.submit();
       return;
     }

}
</script>

<script language="Javascript">
<%
  String queryString = emxGetQueryString(request);
  StringList slDispUsageVals  = null;

  MapList tempList = new MapList();
  String typeIcon = null;
  for(int i = 0; i < totalSelParts; i++)
  {
    String partId = selPartIds[i];
    if(partId == null){
      continue;
    }
    domObj.setId(partId);
	if(isMBOMInstalled) {
	    //get policy type manufacturing or not 
	    bIsToManuPol = EngineeringUtil.isManuPartPolicy(context,domObj.getInfo(context,EngineeringConstants.SELECT_POLICY));
	    /*
	    retusn  list of items to be shown in the Usage combo box depending on the 
	    policy type of from and to side objects of ebom rel
	    */
	    slDispUsageVals  = EngineeringUtil.getUsageDispVals(context,bIsFromManuPol,bIsToManuPol);
	}
    Map resultsMap1 = domObj.getInfo(context, resultSelects);
    String partType = (String)resultsMap1.get(DomainObject.SELECT_TYPE);
    String partName = (String)resultsMap1.get(DomainObject.SELECT_NAME);
    String partRev  = (String)resultsMap1.get(DomainObject.SELECT_REVISION);

    StringBuffer partTNR = new StringBuffer();
    partTNR.append(partType);
    partTNR.append(" ");
    partTNR.append(partName);
    partTNR.append(" ");
    partTNR.append(partRev);
    String parentAlias  = FrameworkUtil.getAliasForAdmin(context, "type", partType, true);
    String fnRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"FindNumberRequired");

    String rdRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"ReferenceDesignatorRequired");
    if(fnRequired==null || "null".equals(fnRequired) || "".equals(fnRequired))
    {
      fnRequired= EngineeringUtil.getParentTypeProperty(context,partType,"FindNumberRequired");
    }
    if(rdRequired==null || "null".equals(rdRequired) || "".equals(rdRequired))
    {
      rdRequired= EngineeringUtil.getParentTypeProperty(context,partType,"ReferenceDesignatorRequired");
    }
%>
	//XSSOK
    fnPropertyArray["<%=i%>"]="<%=fnRequired%>";
    //XSSOK
    rdPropertyArray["<%=i%>"]="<%=rdRequired%>";
    //XSSOK
    TNRArray["<%=i%>"]="<%=partTNR.toString()%>";

<%
	if(isMBOMInstalled) {
		resultsMap1.put("UsageDispVals",slDispUsageVals);
	}
    tempList.add(resultsMap1);
tempListNew.add(resultsMap1);
	
  }

%>
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

  <form name="editForm" method="post" action="emxEngrBOMAddExistingPartsProcess.jsp" target="_parent">
  <input type="hidden" name="selCount" value="<xss:encodeForHTMLAttribute><%=totalSelParts%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
 <input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=uiType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="tempListNew" value="<xss:encodeForHTMLAttribute><%=tempListNew%></xss:encodeForHTMLAttribute>" />

<input type="hidden" name="AVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
	<!-- XSSOK-->
    <fw:sortInit
        defaultSortKey="<%= DomainObject.SELECT_NAME %>"
        defaultSortType="string"
        resourceBundle="emxEngineeringCentralStringResource"
        mapList="<%= tempList %>"
        params="<%= queryString %>"
        ascendText="emxEngineeringCentral.Common.SortAscending"
        descendText="emxEngineeringCentral.Common.SortDescending" />

  <table class="list" id="UITable" width="700" border="0" cellpadding="3" cellspacing="2">
    <tr>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.Name"
            sortKey="<%= DomainObject.SELECT_NAME %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.Rev"
            sortKey="<%=DomainObject.SELECT_REVISION %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.Type"
            sortKey="<%=DomainObject.SELECT_TYPE %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
<%
      

	  session.setAttribute("tempListNew", tempListNew);

      String strNotes =DomainConstants.ATTRIBUTE_NOTES;
      String strGlobalNotesName =null;
      Map mGlobalNotesMap = null;
      String key;
      String attrName;

      TreeMap attrMap = new TreeMap(DomainRelationship.getTypeAttributes(context,DomainConstants.RELATIONSHIP_EBOM));

      HashMap UOMTypeMap = EngineeringUtil.getMappingUOMValues(context,selPartIds);
      
      // Add to session for Process page
      session.setAttribute("attrMap", attrMap);

      matrix.db.MQLCommand mqlCmd = new MQLCommand();

      Iterator itr    = attrMap.keySet().iterator();
      while(itr.hasNext())
      {
        key = (String) itr.next();
        Map mapinfo = (Map) attrMap.get(key);
        attrName = (String)mapinfo.get("name");

        //Performance Improvement:
        //get the multiline flag once for each attribute - not filled in by getAttributeTypeMapFromRelType

        String sResult ="";
        try
        {
           mqlCmd.open(context);
           mqlCmd.executeCommand(context, "print attribute $1 select $2 dump $3",attrName,"multiline","|");
           sResult = mqlCmd.getResult();
           mqlCmd.close(context);
        }
        catch(Exception me)
        {
           throw me;
        }
        if(sResult.trim().equalsIgnoreCase("TRUE"))
        {
           mapinfo.put(DomainObject.ATTRIBUTE_DETAILS_MULTILINE,"true");
        }
        else
        {
           mapinfo.put(DomainObject.ATTRIBUTE_DETAILS_MULTILINE,"false");
        }
        attrMap.put(attrName, mapinfo);
        if(isMBOMInstalled) {
            if( (!attrName.equals(strNotes)) && (!attrName.equals(attrHasManufacturingSubstitute)) )
            {
    %>      <!-- XSSOK -->
    		<th class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></th>
    <%      }
        }else {
        if(!attrName.equals(strNotes))
        {
%>      <!-- XSSOK -->
		<th class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></th>
<%   }
        }
     }
%>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.Description"
            sortKey="<%=DomainObject.SELECT_DESCRIPTION %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.State"
            sortKey="<%=DomainObject.SELECT_CURRENT %>"
            sortType="string"
            anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
            title="emxEngineeringCentral.Common.Owner"
            sortKey="<%=DomainObject.SELECT_OWNER %>"
            sortType="string"
            anchorClass="sortMenuItem" />
       </th>
       <!-- XSSOK -->
       <th class="label"><%=i18nNow.getAttributeI18NString(strNotes,languageStr)%></th>
    </tr>
<%
        int i=0;
        String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default","SmallIcon");
%>
<!-- XSSOK -->
<fw:mapListItr mapList="<%= tempList %>" mapName="resultsMap">
<%

      objectType  = (String)resultsMap.get(DomainObject.SELECT_TYPE);
      String strNewObjectId  = (String)resultsMap.get(DomainObject.SELECT_ID);

      String sPolicy  = (String)resultsMap.get("policy");
%>
     <!-- XSSOK -->
      <tr class='<fw:swap id="even"/>'>
<%

      typeIcon = null;
      String alias = FrameworkUtil.getAliasForAdmin(context, "type", objectType, true);

      //modified to display the type icon
      if ( alias != null && !alias.equals(""))
      {
        typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
      }

      if (typeIcon == null || "".equals(typeIcon))
      {
          //modified to display the type icon
          String sSmallIcon=UINavigatorUtil.getTypeIconFromCache(objectType);

          if(sSmallIcon != null && !sSmallIcon.equals("")) 
          {
            typeIcon = sSmallIcon;
          }
          else
          { 
            typeIcon = defaultTypeIcon;
          }
      }

      String nodeType = alias.substring(alias.indexOf("_")+1, alias.length());
%>
      <td>
        <input type="hidden" name="selId<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID)%></xss:encodeForHTMLAttribute>" />
        <table>
          <tr>
<%
      if (!isPrinterFriendly) {
%>		  <!-- XSSOK -->
          <td><img src="../common/images/<%=typeIcon%>" border="0" /></td>
<%
        }
%>
		  <!-- XSSOK -->
          <td><%=(String)resultsMap.get(DomainObject.SELECT_NAME)%></td>
          </tr>
        </table>
      </td>
      <!-- XSSOK -->
      <td><%=(String)resultsMap.get(DomainObject.SELECT_REVISION)%></td>
      <!-- XSSOK -->
      <td><%=i18nNow.getTypeI18NString(objectType,languageStr)%></td>
<%
      String attribute = "";
      itr    = attrMap.keySet().iterator();
      String usageval="";
      String selected="";
      while(itr.hasNext())
      {
         attribute = (String) itr.next();
         if(isMBOMInstalled) {
             if(!attribute.equals(attrHasManufacturingSubstitute))
             {
               Map mapinfo = (Map) attrMap.get(attribute);
                if (attribute.equals(DomainConstants.ATTRIBUTE_FIND_NUMBER)){
                    attribute="FindNumber";
                }
                if (attribute.equals(DomainConstants.ATTRIBUTE_QUANTITY)){
                    attribute="Qty";
                }
                if (attribute.equals(DomainConstants.ATTRIBUTE_UNIT_OF_MEASURE)) {
               	 mapinfo.put("choices", UOMTypeMap.get(strNewObjectId));
                }
                if (attribute.equals(strNotes)) {
                     mGlobalNotesMap = mapinfo;
                }
                else
                {
                   if (!isPrinterFriendly)
                    {
                        if (attribute.equals(DomainConstants.ATTRIBUTE_USAGE))
                        {
                           slDispUsageVals = (StringList)resultsMap.get("UsageDispVals");
   %>
                           <!-- XSSOK -->
                           <td width="70"><select name="<%=attribute+""+i%>">
   <%
                           for(int ks=0;ks<slDispUsageVals.size();ks++)
                           {
                               usageval=(String)slDispUsageVals.get(ks);
                               selected="";
                               if( (hasDsgEngSrDsgEng)&&(usageval.equals("Reference-Eng")) ||(usageval.equals("Reference-Mfg")))
                                   selected="selected";
   %>						   <!-- XSSOK -->
                               <option value="<%=usageval%>" <%=selected%>><%=usageval%></option>
   <%
                           }
   %>
                           </select>&nbsp;</td>
   <%
                        }else
                        {
   %>                   <!-- XSSOK -->        
   						<td width="70"><%=EngineeringUtil.displayField(context,mapinfo,"edit",languageStr,session,attribute+"|"+i)%>&nbsp;</td>
   <%                  }//end of else for usage attribute check
                    }else
                    {
   %>               <!-- XSSOK --> 
   					<td width="70"><%=(String)mapinfo.get("value")%>&nbsp;</td>
   <%               }
               }
           }
         }else {
         Map mapinfo = (Map) attrMap.get(attribute);

         if (attribute.equals(DomainConstants.ATTRIBUTE_FIND_NUMBER)){
             attribute="FindNumber";
         }
         if (attribute.equals(DomainConstants.ATTRIBUTE_QUANTITY)){
             attribute="Qty";
         }

         if (attribute.equals(strNotes)) {
              mGlobalNotesMap = mapinfo;
         }
         else
         {
             if (!isPrinterFriendly)
             {
%>            <!-- XSSOK -->
			  <td width="70"><%=EngineeringUtil.displayField(context,mapinfo,"edit",languageStr,session,attribute+"|"+i)%>&nbsp;</td>
<%        }
             else
             {
            	 
%>            <!-- XSSOK -->
				<td width="70"><%=(String)mapinfo.get("value")%>&nbsp;</td>
<%        }
         }
      }
      }//end of while

%>	  <!-- XSSOK -->
      <td><%=(String)resultsMap.get(DomainObject.SELECT_DESCRIPTION)%>&nbsp;</td>
      <!-- XSSOK -->
      <td><%=i18nNow.getStateI18NString(sPolicy,(String)resultsMap.get(DomainObject.SELECT_CURRENT),languageStr)%></td>
      <!-- XSSOK -->
      <td><%=PersonUtil.getFullName(context,(String)resultsMap.get(DomainObject.SELECT_OWNER))%></td>
<%
       if (!isPrinterFriendly)
       {
       	String fieldString= EngineeringUtil.displayField(context,mGlobalNotesMap,"edit",languageStr,session,strNotes+"|"+i);
    	fieldString =fieldString.replaceAll("textarea", "textarea style=\"width:210px;\"");

%>      <!-- XSSOK -->  
		<td width="70"><%=fieldString%>&nbsp;</td>
<%     }
       else
       {
%>        <!-- XSSOK -->
	      <td width="70"><%=(String)mGlobalNotesMap.get("value")%>&nbsp;</td>
<%     }

      i++;
 %>
    </tr>
  </fw:mapListItr>
  </table>
  </form>
  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
