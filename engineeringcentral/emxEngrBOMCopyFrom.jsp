<%--  emxEngrBOMCopyFrom.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxengchgValidationUtil.js" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="Javascript">
var fnArray = new Array();
var TNRArray = new Array();
var rdArray = new Array();
</script>

<%
  Part selPartObj = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String initSource  = emxGetParameter(request,"initSource");
  String suiteKey    = emxGetParameter(request,"suiteKey");

  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteEngineeringCentral";
  }

  String strObjectId  = emxGetParameter(request,"objectId");
  String strSelPartId = emxGetParameter(request,"checkBox");

  String showAppendReplaceOption = emxGetParameter(request,"showAppendReplaceOption");
  String AppendReplaceOption     = emxGetParameter(request,"AppendReplaceOption");

  String isAVLReport = emxGetParameter(request,"AVLReport");
  String frameName = emxGetParameter(request, "frameName");
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  if (!selPartObjectId.equals("") || selPartObjectId!=null || !selPartObjectId.equals("null")) {
  strObjectId = selPartObjectId;
  }

  //Declare display variables
  String objectId = "";
  String objectType = "";
  String objectName = "";
  String objectRev = "";
  String objectDesc = "";
  String objectState = "";
  String objectOwner = "";
  String strRd="";

  selPartObj.setId(strObjectId);

%>
     <script language="Javascript">

<%
        StringList selectStmts = new StringList(3);
        selectStmts.addElement(DomainConstants.SELECT_ID);
        StringList selectRelStmts = new StringList(2);
        selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
         //selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
        // get Relationship Data like Find Number and use in checking for uniqueness
        MapList ebomList = selPartObj.getRelatedObjects(context,
                                             DomainConstants.RELATIONSHIP_EBOM,           // relationship pattern
                                             DomainConstants.TYPE_PART,                   // object pattern
                                             selectStmts,                 // object selects
                                             selectRelStmts,              // relationship selects
                                             false,                        // to direction
                                             true,                       // from direction
                                             (short)1,                    // recursion level
                                             null,                        // object where clause
                                             null);

        int k = 0;
        int i=0;
        String fnValue = "";
        String rdValue="";

        Iterator bomItr = ebomList.iterator();
        while(bomItr.hasNext())
        {
            Map bomMap = (Map)bomItr.next();
            fnValue = (String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
            rdValue= (String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);

            if(k ==1)
            {
              strRd=rdValue;
            }
            else
            {
               strRd=strRd + "," + rdValue;
            }
%>			//XSSOK
            fnArray["<%=i%>"]="<%=fnValue%>";
            //XSSOK
            rdArray["<%=k%>"]="<%=rdValue%>";
<%
            i++;
            k++;
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
  resultSelects.addElement(DomainConstants.SELECT_POLICY);


  String key="";
  String attrName="";
  Map attrMap = DomainRelationship.getTypeAttributes(context,DomainConstants.RELATIONSHIP_EBOM);

  Iterator itr = null;

    // Included this condition to avoid Null Pointer exception
  if(attrMap != null) {
    selectRelStmts = new StringList(attrMap.size()+1);
    itr = attrMap.keySet().iterator();
    while(itr.hasNext())
    {
      key = (String) itr.next();
      Map mapinfo = (Map) attrMap.get(key);
      attrName = (String)mapinfo.get(DomainConstants.SELECT_NAME);
      selectRelStmts.addElement("attribute["+attrName+"]");
    }
  }
  else {
    selectRelStmts = new StringList(1);
  }
  selectRelStmts.addElement(Part.SELECT_RELATIONSHIP_ID);


%>

<script language="Javascript">

var fnPropertyArray = new Array();
var rdPropertyArray = new Array();

function selectAll()
  {
       var operand = "";
       var bChecked = false;
       var count = eval("document.editForm.elements.length");
       var typeStr = "";
       //retrieve the checkAll's checkbox value
       var allChecked = eval("document.editForm.checkAll.checked");
       for(var i = 0; i < count; i++)
       {
          operand = "document.editForm.elements[" + i + "].checked";
          typeStr = eval("document.editForm.elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
             operand += " = " + allChecked + ";";
             eval (operand);
          }
       }
       return;
}

  function updateCheckboxHeader()
  {
     var operand = "";
     var bChecked = false, allSelected = true;
     var typeStr = "";
     var strName = "";
     var count = eval("document.editForm.elements.length");

     for(var i = 0; i < count; i++)  //exclude the checkAll checkbox
     {
        typeStr = eval("document.editForm.elements[" + i + "].type");
        strName = eval("document.editForm.elements[" + i + "].name");
        if(typeStr == "checkbox" && strName != "checkAll")
        {
            bChecked = eval("document.editForm.elements[" + i + "].checked");
            if(bChecked == false)
            {
               allSelected = false;
               break;
            }
        }
     }

     //set check-all checkbox accordingly
     operand = "document.editForm.checkAll.checked = " + allSelected + ";";
     eval (operand);

     return;
  }


function submit(){
    var totCountObj = document.editForm.selCount;
    //XSSOK
    var fnLength   = "<%=fnLength%>";
  	//XSSOK
    var rdLength ="<%=rdLength%>";
    var RefArray = new Array()
    RefArray=rdArray;
  //XSSOK
    var fnUniqueness = "<%=fnUniqueness%>";
    var fnRequired ="";
    var rdRequired ="";
  //XSSOK
    var rdUniqueness = "<%=rdUniqueness%>";
  //XSSOK
    var ebomUniquenessOperator="<%=ebomUniquenessOperator%>";
    var TNRDArray=new Array();
    var RdClientArray=new Array();
    var rdunique="false";
    var k=0;

    if(totCountObj != null && totCountObj != '' && totCountObj != 'undefined')
    {
      var totcount = totCountObj.value;
      var selList= "";
      var isChecked = false;
      for(var i = 0; i < totcount; i++)
      {
        var checkObj = eval("document.editForm.selId" + i);
        var chkStatus = eval("document.editForm.selId" + i +".checked");

        if(chkStatus)
        {
            isChecked = true;

            //FieldNames for dynamically displayed attributes (except attribute usage),
            //Findnumber and Qty will contain "|"---refer bug fix:275466
           /*  var fnobj = eval("document.editForm.elements[\"FindNumber"+i+"\"]");
            var rdobj = eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ i +'"]');
            fnobj.value = trim(fnobj.value)
            var findnumvalue = fnobj.value;
            var rdvalue=rdobj.value;
            RdClientArray[i]=rdvalue;

            fnRequired = fnPropertyArray[i];
            rdRequired = rdPropertyArray[i];
            if(!validateFNRD(fnobj,rdobj,fnRequired,rdRequired,i,totcount))
            {
                return;
            }
            var nonUniqueFNs = getNonUniqueFNFromSelected(totcount);
            var focus = nonUniqueFNs.charAt(nonUniqueFNs.length-1);
            nonUniqueFNs = nonUniqueFNs.substring(0,nonUniqueFNs.indexOf("~"));
            var nonUniqueFNObj = eval("document.editForm.elements[\"FindNumber"+focus+"\"]");

            if(fnUniqueness=="true" && !isFNUnique(findnumvalue,i))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
                fnobj.focus();
                return;
            }
            if(fnUniqueness=="true" && nonUniqueFNs.length>0)
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNNotUniqueForTNR</emxUtil:i18nScript>"+" "+nonUniqueFNs);
                nonUniqueFNObj.focus();
                return;
            }
             if(fnUniqueness!="true" && rdUniqueness!="true")
             {
                if(!isFNUnique(findnumvalue,i))
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
                    fnobj.focus();
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
                var refstr=RefArray.join();
                unique = isRDUnique(refstr,rdvalue);
                if(!unique)
                {
                    TNRDArray[i]=TNRArray[i];
                }
                rdunique="true";
            }


            var qtyobj = eval("document.editForm.elements[\"Qty"+i+"\"]");
            qtyobj.value = trim(qtyobj.value)
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

            if(!isEmpty(rdobj.value))
            {
                var qt = getRDQuantity(rdobj.value)
                if (qtyvalue != qt)
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
            }*/


            selList += i + ",";

            /*if (rdunique=="true")
            {
                uniq = checkUnique(RdClientArray);
                var k=0;
                if(uniq==false)
                    {
                        rdobj.focus();
                        return;
                    }
                else
                {
                    if(TNRDArray.length > 0)
                    {
                        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDNotUniqueForTNR</emxUtil:i18nScript>"+" "+TNRDArray);
                        rdobj.focus();
                        return;
                    }
                }
            }*/
         }
      }
      if(!isChecked) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.YouMustSelectAtLeastOneOfTheCheckBoxes</emxUtil:i18nScript>");
        return;
      }

      document.editForm.selList.value = selList;
        if (jsDblClick())
        {

               document.editForm.submit();
      }


   }
  }

  function Append()
  {
    if (jsDblClick())
    {
      document.editForm.action = "emxEngrBOMCopyFromFS.jsp";
      document.editForm.AppendReplaceOption.value = "Append";
      document.editForm.submit();
    }
  }

  function Replace()
  {
    if (jsDblClick())
    {
	 if (confirm("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.ReplaceAlert1</emxUtil:i18nScript>"))
	 {
      document.editForm.action = "emxEngrBOMCopyFromFS.jsp";
      document.editForm.AppendReplaceOption.value = "Replace";
      document.editForm.submit();
    }
  	else
  	{
		document.location.href=document.location.href;
	}
    }
  }

  // Added by Garima for Copy Actions start
  function Merge()
  {
    if (jsDblClick())
    {
      document.editForm.action = "emxEngrBOMCopyFromFS.jsp";
      document.editForm.AppendReplaceOption.value = "Merge";
      document.editForm.submit();
    }
  }
  // Added by Garima for Copy Actions end

</script>
<%@include file ="../emxUICommonHeaderEndInclude.inc" %>
<%
  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;

  String printerFriendly = emxGetParameter(request, "PrinterFriendly");
  if (printerFriendly != null && "true".equals(printerFriendly)) {
    isPrinterFriendly = true;
  }

  String showPrinterFriendly = emxGetParameter(request,"showPrinterFriendly");
  String queryString = emxGetQueryString(request);
  boolean tempBool = false;
  String displayAttr = "";
  String sortKey = "";
  Map info = null;
  // Get default icon for type
  String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
  MapList selBOMsList = null;

  StringList relAttributeList = new StringList();
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_FIND_NUMBER);
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR);
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_COMPONENT_LOCATION);
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_QUANTITY);
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_USAGE);
  relAttributeList.addElement(DomainConstants.ATTRIBUTE_UNIT_OF_MEASURE);
  
 // if(EngineeringUtil.isENGSMBInstalled(context)) { //Commented for IR-213006
	 if(FrameworkUtil.isSuiteRegistered(context, "appVersionENOVIA VPM Team Multi-discipline Collaboration Platform", false, null, null)) {
	  relAttributeList.addElement(EngineeringConstants.ATTRIBUTE_VPM_VISIBLE);
  }
  
  Iterator relAttributeListItr = relAttributeList.iterator();
  
  
  if(strSelPartId != null && strObjectId.equals(strSelPartId)) {
%>
    <table width="100%">
      <tr><td>&nbsp;</td></tr>
      <tr><td class="errorMessage"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOM.CannotCopySamePart</emxUtil:i18n></td></tr>
      <tr><td>&nbsp;</td></tr>
    </table>
<%
  } else if(showAppendReplaceOption != null && "true".equals(showAppendReplaceOption)) {
    selPartObj.setId(strObjectId);
%>


    <form name="editForm" method="post" action="emxEngrBOMCopyFromProcess.jsp" target="_parent">
      <input type="hidden" name="AppendReplaceOption" />
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="checkBox" value="<xss:encodeForHTMLAttribute><%=strSelPartId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="showPrinterFriendly" value="<xss:encodeForHTMLAttribute><%=showPrinterFriendly%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="AVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selPartRelId" value="<xss:encodeForHTMLAttribute><%=selPartRelId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selPartObjectId" value="<xss:encodeForHTMLAttribute><%=selPartObjectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selPartParentOId" value="<xss:encodeForHTMLAttribute><%=selPartParentOId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="frameName" value="<xss:encodeForHTMLAttribute><%=frameName%></xss:encodeForHTMLAttribute>" />

      <table width="100%">
        <tr><td>&nbsp;</td></tr>
        <tr><td class="errorMessage">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOM.BOMExists</emxUtil:i18n>
        <!-- XSSOK -->
         &nbsp;<%=i18nNow.getTypeI18NString(selPartObj.getInfo(context,DomainObject.SELECT_TYPE),languageStr)%>&nbsp;<%=selPartObj.getInfo(context,DomainObject.SELECT_NAME)%>&nbsp;<%=selPartObj.getInfo(context,DomainObject.SELECT_REVISION)%>
        </td></tr>
        <tr><td>&nbsp;</td></tr>
      </table>
    </form>
<%
  } else {
    try {

      selPartObj.setId(strSelPartId);
      selBOMsList = selPartObj.getEBOMs(context, resultSelects, selectRelStmts, false);

      tempBool = selBOMsList.isEmpty();
%>

      <form name="editForm" method="post" action="emxEngrBOMCopyFromProcess.jsp" target="_parent">

    <input type="hidden" name="AVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="checkBox" value="<xss:encodeForHTMLAttribute><%=strSelPartId%></xss:encodeForHTMLAttribute>" />    
      <input type="hidden" name="selPartRelId" value="<xss:encodeForHTMLAttribute><%=selPartRelId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selPartObjectId" value="<xss:encodeForHTMLAttribute><%=selPartObjectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selPartParentOId" value="<xss:encodeForHTMLAttribute><%=selPartParentOId%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="frameName" value="<xss:encodeForHTMLAttribute><%=frameName%></xss:encodeForHTMLAttribute>" />
      <table class="list" id="UITable" >
		<!-- XSSOK -->
      <fw:sortInit defaultSortKey="<%= Part.SELECT_NAME %>" defaultSortType="string" resourceBundle="emxEngineeringCentralStringResource" mapList="<%= selBOMsList %>" params="<%= queryString %>" ascendText="emxEngineeringCentral.Common.SortAscending" descendText="emxEngineeringCentral.Common.SortDescending" />
        <tr>

<%
        if (!isPrinterFriendly) {
%>
          <th><input type="checkbox" name="checkAll" onClick="javascript:selectAll();" /></th>
<%
        }
%>

          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.Name"
              sortKey="<%= Part.SELECT_NAME %>"
              sortType="string"  />

          </th>

          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.Rev"
              sortKey="<%= Part.SELECT_REVISION %>"
              sortType="string" />

          </th>

          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.Type"
              sortKey="<%= Part.SELECT_TYPE %>"
             sortType="string" />
          </th>
<%
		
		while(relAttributeListItr.hasNext()) {
			attrName = (String) relAttributeListItr.next();
         	displayAttr = i18nNow.getAttributeI18NString(attrName,languageStr);
          	sortKey = "attribute["+attrName+"]";
%>
          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader title="<%=displayAttr%>" sortKey="<%=sortKey%>" sortType="string" />
          </th>
<%
		}
            
           

%>

           <th nowrap="nowrap">
           <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.Description"
              sortKey="<%= Part.SELECT_DESCRIPTION %>"
              sortType="string"
               />
          </th>

          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.State"
              sortKey="<%= Part.SELECT_CURRENT %>"
              sortType="string"
               />
          </th>

          <th nowrap="nowrap">
          <!-- XSSOK -->
            <fw:sortColumnHeader
              title="emxEngineeringCentral.Common.Owner"
              sortKey="<%= Part.SELECT_OWNER %>"
              sortType="string"
               />
          </th>

          <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selCount" value="<xss:encodeForHTMLAttribute><%=selBOMsList.size()%></xss:encodeForHTMLAttribute>" />
          <!-- XSSOK -->
          <input type="hidden" name="AppendReplaceOption" value="<%=AppendReplaceOption%>" />
          <input type="hidden" name="selList" />
        </tr>

<%
    i = 0;
%><!-- XSSOK -->
    <fw:mapListItr mapList="<%= selBOMsList %>" mapName="resultsMap">
<%
     objectId    = (String)resultsMap.get(DomainObject.SELECT_ID);
     objectType  = (String)resultsMap.get(DomainObject.SELECT_TYPE);
     objectName  = (String)resultsMap.get(DomainObject.SELECT_NAME);
     objectRev   = (String)resultsMap.get(DomainObject.SELECT_REVISION);
     objectState = (String)resultsMap.get(DomainObject.SELECT_CURRENT);
     objectDesc  = (String)resultsMap.get(DomainObject.SELECT_DESCRIPTION);
     objectOwner = (String)resultsMap.get(DomainObject.SELECT_OWNER);
     String ATTRIBUTE_NOTE = PropertyUtil.getSchemaProperty(context, "attribute_Notes");
     String SELECT_ATTRIBUTE_NOTE = "attribute["+ ATTRIBUTE_NOTE+ "]";
     String ATTRIBUTE_SOURCE = PropertyUtil.getSchemaProperty(context, "attribute_Source");
     String SELECT_ATTRIBUTE_SOURCE = "attribute["+ ATTRIBUTE_SOURCE+ "]";
     
     // 365752
     String FN = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);	 
     String QTY = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);	 
     String USG = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_USAGE);	 
     String RD = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);	 
     String CMPLOC = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
	 String NOTE = (String)resultsMap.get(SELECT_ATTRIBUTE_NOTE);
	 String SOURCE = (String)resultsMap.get(SELECT_ATTRIBUTE_SOURCE);
	 String UOM = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
	 
     String parentAlias  = FrameworkUtil.getAliasForAdmin(context, "type", objectType, true);
     String fnRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"FindNumberRequired");
     if(fnRequired==null || "null".equals(fnRequired) || "".equals(fnRequired))
     {
       fnRequired= EngineeringUtil.getParentTypeProperty(context,objectType,"FindNumberRequired");
     }
     String rdRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"ReferenceDesignatorRequired");
     if(rdRequired==null || "null".equals(rdRequired) || "".equals(rdRequired))
     {
       rdRequired= EngineeringUtil.getParentTypeProperty(context,objectType,"ReferenceDesignatorRequired");
     }
     StringBuffer partTNR = new StringBuffer();
     partTNR.append(objectType);
     partTNR.append(" ");
     partTNR.append(objectName);
     partTNR.append(" ");
     partTNR.append(objectRev);
%>
<script language ="Javascript">
//XSSOK
   fnPropertyArray["<%=i%>"]="<%=fnRequired%>";
//XSSOK
   rdPropertyArray["<%=i%>"]="<%=rdRequired%>";
//XSSOK   
   TNRArray["<%=i%>"]="<%=partTNR.toString()%>";
</script>
<%
     String sRelId    = (String)resultsMap.get(Part.SELECT_RELATIONSHIP_ID);
     String policy = (String)resultsMap.get(DomainConstants.SELECT_POLICY);
 %>
     <tr class='<fw:swap id="1"/>'>
<%

        //
        String alias = FrameworkUtil.getAliasForAdmin(context, "type", (String)resultsMap.get(DomainObject.SELECT_TYPE), true);
        String typeIcon = "";
        if ((alias == null) || (alias.equals("")) || (alias.equals("null"))){
          typeIcon = defaultTypeIcon;
        }else{
            String type = (String)resultsMap.get(DomainObject.SELECT_TYPE);
            if ( alias != null && !alias.equals(""))
			{
  			 	typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
 			}

 			if (typeIcon == null || "".equals(typeIcon))
 			{
			     //modified to display the type icon
			     String sSmallIcon=UINavigatorUtil.getTypeIconFromCache(type);
			
			     if(sSmallIcon != null && !sSmallIcon.equals("")) 
			     {
			       	typeIcon = sSmallIcon;
			     }
			     else
			     { 
			      	typeIcon = defaultTypeIcon;
			     }
 			}       
                    
        }

        if (!isPrinterFriendly) {
%>		  <!-- XSSOK -->
          <td><input type="checkbox" name="selId<%=i%>" value="<%= objectId %>" onClick="javascript:updateCheckboxHeader();" /></td>
          <input type="hidden" name="selRelId<%=i%>" value="<xss:encodeForHTMLAttribute><%= sRelId %></xss:encodeForHTMLAttribute>" />
          <!--365752-->
          <input type="hidden" name="selFN<%=i%>" value="<xss:encodeForHTMLAttribute><%= FN %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selQTY<%=i%>" value="<xss:encodeForHTMLAttribute><%= QTY %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selUSG<%=i%>" value="<xss:encodeForHTMLAttribute><%= USG %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selRD<%=i%>" value="<xss:encodeForHTMLAttribute><%= RD %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selCMPLOC<%=i%>" value="<xss:encodeForHTMLAttribute><%= CMPLOC %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selNOTE<%=i%>" value="<xss:encodeForHTMLAttribute><%= NOTE %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selSOURCE<%=i%>" value="<xss:encodeForHTMLAttribute><%= SOURCE %></xss:encodeForHTMLAttribute>" />
           <input type="hidden" name="selUOM<%=i%>" value="<xss:encodeForHTMLAttribute><%= UOM %></xss:encodeForHTMLAttribute>" />
           
<%
        }
%>
        <td wrap="hard">
          <table>
            <tr>
<%
        if (!isPrinterFriendly) {
%>			<!-- XSSOK -->
            <td><img src="../common/images/<%=typeIcon%>" border="0" /></td>
<%
        }
        else
        {
%>
            <td>&nbsp;</td>
<%
        }
%>
            <td><xss:encodeForHTML><%=objectName%></xss:encodeForHTML></td>
            </tr>
          </table>
        </td>
        <td wrap="hard"><xss:encodeForHTML><%=objectRev%></xss:encodeForHTML></td>
        <!-- XSSOK -->
        <td wrap="hard"><%=i18nNow.getTypeI18NString(objectType,languageStr)%></td>

<%
			relAttributeListItr = relAttributeList.iterator();
            while(relAttributeListItr.hasNext()) {
            	attrName = (String) relAttributeListItr.next();

            	info = new HashMap();
            	info.put(DomainConstants.SELECT_NAME, attrName);
                info.put("value", (String)resultsMap.get("attribute["+attrName+"]"));

            	if(attrName.equals(DomainConstants.ATTRIBUTE_FIND_NUMBER)){attrName="FindNumber";}
            	if(attrName.equals(DomainConstants.ATTRIBUTE_QUANTITY)){attrName="Qty";}
            	if(attrName.equals(DomainConstants.ATTRIBUTE_UNIT_OF_MEASURE)){attrName="UOM";}
%>					<!-- XSSOK -->
                	<td wrap="hard" value=""><%= EngineeringUtil.displayField(context,info,"view", languageStr, session,attrName+"|"+i) %></td>
<%
           }


%>		
        <td wrap="hard"><xss:encodeForHTML><%=objectDesc%></xss:encodeForHTML></td>
        <!-- XSSOK -->
        <td wrap="hard"><%=i18nNow.getStateI18NString(policy,objectState,languageStr)%></td>
        <!-- XSSOK -->
        <td wrap="hard"><%=PersonUtil.getFullName(context,objectOwner)%></td>
      </tr>
<%
      i++;
%>
      </fw:mapListItr>
<%      
      if (tempBool)
      {        
%>      
        <tr><td colspan="13" class="error"> <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.NoBOMFound</emxUtil:i18n> </td></tr>
<%        
      }
%>
      </table>
      </form>
<%
      } catch(Exception e) {
    }
  }

%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
