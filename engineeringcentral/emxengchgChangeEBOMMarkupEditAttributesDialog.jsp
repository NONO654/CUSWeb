<%--  emxengchgChangeEBOMMarkupEditAttributesDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgValidationUtil.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>


<%
  String languageStr      = request.getHeader("Accept-Language");
  String strObjectId      = emxGetParameter(request,"objectId");
  String removalFlag      = emxGetParameter(request,"removalFlag");
  String timeStamp        = emxGetParameter(request,"timeStamp");
  int totalSelParts       = 0;
  String SelEbomIds       = (String) session.getAttribute("SelEbomIds");
  Map finalRestoreMap     = (Map)session.getAttribute("finalRestoreMap");
  Map finalremovalMap     = (Map)session.getAttribute("finalremovalMap");
  String partType         = DomainObject.TYPE_PART;
  String ecrId            = emxGetParameter(request,"ecrId");
  String partToRemoveId   = emxGetParameter(request,"partToRemoveId");
  String partToReplaceId  = emxGetParameter(request,"partToReplaceId");
  String massUpdateAction = emxGetParameter(request,"massUpdateAction");
  String maintainSub      = emxGetParameter(request, "maintainSub");
  String attrNotes   = PropertyUtil.getSchemaProperty(context, "attribute_Notes");
  //Added for X3
  String attrHasManSub   = PropertyUtil.getSchemaProperty(context, "attribute_HasManufacturingSubstitute");
  StringList strlRestrictionList = new StringList(attrNotes); 
  strlRestrictionList.add(attrHasManSub);

%>

  <input type="hidden" name="partToRemoveId" value="<xss:encodeForHTMLAttribute><%=partToRemoveId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="partToReplaceId" value="<xss:encodeForHTMLAttribute><%=partToReplaceId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="massUpdateAction" value="<xss:encodeForHTMLAttribute><%=massUpdateAction%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="SelEbomIds" value="<xss:encodeForHTMLAttribute><%=SelEbomIds%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="maintainSub" value="<xss:encodeForHTMLAttribute><%=maintainSub%></xss:encodeForHTMLAttribute>" />

<%

  String partToRemove = emxGetParameter(request,"partToRemove");
  //Declare display variables
  String objectId                 = null;
  String objectType               = null;
  String objectName               = null;
  String objectRev                = null;
  String objectDesc               = null;
  String objectState              = null;
  String objectOwner              = null;
  String srelId                   = null;
  String srelFN                   = null;
  String txtName                  = null;
  String txtRev                   = null;
  String txtDisplay               = null;
  String txtValue                 = null;
  double tz                       = (new Double((String)session.getAttribute("timeZone"))).doubleValue();
  removalFlag                     = (removalFlag==null)?"":removalFlag;
  finalRestoreMap                 = (finalRestoreMap==null)?new HashMap():finalRestoreMap;
  finalremovalMap                 = (finalremovalMap==null)?new HashMap():finalremovalMap;

  StringTokenizer stringTokenizer = new StringTokenizer(SelEbomIds, ",");
  totalSelParts=stringTokenizer.countTokens();
  SelectList resultSelects = new SelectList(11);
  resultSelects.add("from."+DomainObject.SELECT_ID);
  resultSelects.add("from."+DomainObject.SELECT_TYPE);
  resultSelects.add("from."+DomainObject.SELECT_NAME);
  resultSelects.add("from."+DomainObject.SELECT_REVISION);
  resultSelects.add("from."+DomainObject.SELECT_DESCRIPTION);
  resultSelects.add("from."+DomainObject.SELECT_CURRENT);
  resultSelects.add("from."+DomainObject.SELECT_OWNER);
  resultSelects.add("from."+DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
  resultSelects.add("id");
  resultSelects.add(DomainObject.SELECT_FIND_NUMBER);
  resultSelects.addElement("from."+"policy");

  // storing the relationship id in an array
  String[] RelIdArray = new String[totalSelParts];
  int counter=0;
  while(stringTokenizer.hasMoreTokens())
  {
    RelIdArray[counter] = stringTokenizer.nextToken().trim();
    counter++;
  }
  // get the attribute details of the EBOM Relationship
  MapList resultList  = DomainRelationship.getInfo(context,
                                                   RelIdArray,
                                                   resultSelects);

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly))
  {
    isPrinterFriendly = "true".equals(printerFriendly);
  }

  String attrReferenceDesignator = PropertyUtil.getSchemaProperty(context, "attribute_ReferenceDesignator");
  String attrComponentLocation = PropertyUtil.getSchemaProperty(context, "attribute_ComponentLocation");
  String attrUsage = PropertyUtil.getSchemaProperty(context, "attribute_Usage");
  String attrFindNumber = PropertyUtil.getSchemaProperty(context, "attribute_FindNumber");
  String attrQuantity = PropertyUtil.getSchemaProperty(context, "attribute_Quantity");

%>

<script language="javascript">
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();

  //abstracts be selected
  var bAbstractSelect = false;
  // Allow multiselect
  var bMultiSelect = false;
  var bReload = false;
  //Types to be passed
  //XSSOK
  var arrTypes = new Array("<%=partType%>|<%=i18nNow.getTypeI18NString(partType,languageStr)%>");
  //specify the place to return the string AS A STRING...
  var strTxtType = "document.forms['editForm'].type";
  var txtType = null;
  var strTxtTypeDisp = "document.forms['editForm'].typeDisp";
  var txtTypeDisp = null;
  var btnName = null;
  var val     = null;

  function cancel()
  {
    getTopWindow().closeWindow();
  }

  // function to handle the change event for text box value change
  function textBoxChangeCheck(checkBoxNumber)
  {
    var checkElement = eval('document.editForm.checkBox['+ checkBoxNumber +']');
    if(!checkElement) {
      checkElement = eval('document.editForm.checkBox');
    }
    checkElement.checked=true;
  }

  // function to handle the change event for date text box value change
  function dateChangeCheck(checkBoxNumber,dateField)
  {
    if(oldDateValue!=document.forms['editForm'].elements[dateField].value)
    {
      var checkElement = eval('document.editForm.checkBox['+ checkBoxNumber +']');
      if(!checkElement) {
        checkElement = eval('document.editForm.checkBox');
      }

      checkElement.checked=true;
    }
  }

  // function to handle the change event for type chooser text box value change
  function typeChooserChangeCheck(checkBoxNumber)
  {
    txtTypeDisp = eval(strTxtTypeDisp+checkBoxNumber);
    if(val!=null && val!=txtTypeDisp.value)
    {
      var checkElement = eval('document.editForm.checkBox['+ checkBoxNumber +']');
      if(!checkElement) {
        checkElement = eval('document.editForm.checkBox');
      }

      checkElement.checked=true;
    }
    val=null;
  }


  function submit()
  {

    var totcount = document.editForm.myLength.value;
    //XSSOK
    var fnLength   = "<%=fnLength%>";
  	//XSSOK
    var rdLength   = "<%=rdLength%>";
 	 //XSSOK
    var fnUniqueness = "<%=fnUniqueness%>";
    var TNRDArray=new Array();
    var RdClientArray=new Array();
    var rdunique="false";
    var uniq ="true";
    var RefArray = new Array();
    RefArray=rdArray;
    var fnRequired ="";
    var rdRequired ="";
 	//XSSOK
    var rdUniqueness = "<%=rdUniqueness%>";
    //XSSOK
    var ebomUniquenessOperator="<%=ebomUniquenessOperator%>";

    for(var i = 0; i < totcount; i++)
    {
      var fnobj = eval('document.editForm.elements[\'Find Number'+ i + '\']');
    //XSSOK
      var rdobj = eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ i +'"]');
      fnRequired = fnPropertyArray[i];
      rdRequired = rdPropertyArray[i];

      if(fnobj != null|| rdobj != null) {
            fnobj.value = trim(fnobj.value);
            var fnvalue = fnobj.value;
            var rdvalue = rdobj.value;
            RdClientArray[i]=rdvalue;
            if(!validateFNRD(fnobj,rdobj,fnRequired,rdRequired,i,totcount))
            {
                return;
            }
    }

      var qtyobj = eval('document.editForm.Quantity' + i);

      if(qtyobj != null) {
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

        if(rdRequired=="true")
        {
            if(!isEmpty(rdvalue))
            {
                var qt = getRDQuantity(rdvalue)
                if (qtyvalue != parseInt(qt))
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
        }

      }
    }
	//XSSOK
    document.editForm.action = "emxengchgChangeMassEBOMMarkupCreateProcess.jsp?sflag=false&mode=Create&ecrId=<%=ecrId%>&partToRemoveId=<%=partToRemoveId%>&partToReplaceId=<%=partToReplaceId%>&massUpdateAction=<%=massUpdateAction%>&maintainSub=<%=maintainSub%>";
    startProgressBar(true);
    document.editForm.submit();
  }

  function selectAll(formName)
  {
       var operand = "";
       var bChecked = false;
       var count = eval("document." + formName + ".elements.length");
       var typeStr = "";
       //retrieve the checkAll's checkbox value
       var allChecked = "";
       for(var i = 1; i < count; i++)
       {
           var htmlElementName = eval("document." + formName + ".elements["+i+"].name");
           if(htmlElementName=="checkAll") {
               allChecked = eval("document." + formName + ".elements["+i+"].checked");
               break;
           }
       }


       for(var i = 1; i < count; i++)
       {
          operand = "document." + formName + ".elements[" + i + "].checked";
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox")
          {
             // Added the below line to check whether the check box is grayed or not.
             bChecked = eval("document." + formName + ".elements[" + i + "].disabled");
             // if the check box is grayed out, it cannot be selected.
             if(bChecked == false)
             {
                 operand += " = " + allChecked + ";";
                 eval (operand);
             }
          }
       }
       return;
  }

  function updateOnSelection(formName)
  {
     var operand = "";
     var bChecked = false, allSelected = true;
     var typeStr = "";
     var count = eval("document." + formName + ".elements.length");

     for(var i = 1; i < count; i++)  //exclude the checkAll checkbox
     {
        typeStr = eval("document." + formName + ".elements[" + i + "].type");
        if(typeStr == "checkbox")
        {
            bChecked = eval("document." + formName + ".elements[" + i + "].checked");
            if(bChecked == false)
            {
               allSelected = false;
               break;
            }
        }
     }

     //set check-all checkbox accordingly
     for(var i = 1; i < count; i++)
     {
          var htmlElementName = eval("document." + formName + ".elements["+i+"].name");
          if(htmlElementName=="checkAll") {
              operand = "document." + formName + ".elements["+i+"].checked = " + allSelected + ";";
              eval(operand);
              break;
          }
     }

     return;
  }

  function applyAll() {

       rowCount = -1;
       var fieldCount=0;
       var elmLength=document.editForm.elements.length;
       var fieldnames=new Array(elmLength);
       for (var i = 1; i<document.editForm.elements.length; i++) {
           var obj = document.editForm.elements[i];
           if(obj.type!="hidden" && obj.type!="checkbox" && obj.type!="button" && rowCount<0){
               fieldnames[fieldCount]=obj.name;
               fieldCount++;
           }
           if(obj.type == "checkbox" && obj.name == "selectedPart" ) {
               rowCount++;
           }
       }
       for(var j=0; j<fieldCount;j++){
           var fieldValue = eval("document.editForm.elements['"+fieldnames[j]+"'].value");
           for(var k=0;k<=rowCount;k++){
               if(fieldValue != "" ) {
                   eval("document.editForm.elements['"+fieldnames[j]+k+"'].value=fieldValue;");
               }
           }
       }
  }// function

function applySelected() {

       rowCount = -1;
       var fieldCount=0;
       var selectedCount=0;
       var elmLength=document.editForm.elements.length;
       var fieldnames=new Array(elmLength);
       var selectedRows=new Array(elmLength);
       rowSelection = false;
       for (var i = 1; i<document.editForm.elements.length; i++) {
           var obj = document.editForm.elements[i];
           if(obj.type!="hidden" && obj.type!="checkbox" && obj.type!="button" && rowCount<0){
               fieldnames[fieldCount]=obj.name;
               fieldCount++;
           }
           if(obj.type == "checkbox" && obj.name == "selectedPart" ) {
               rowCount++;
               if(obj.checked == true ) {
                    rowSelection = true;
                    selectedRows[selectedCount]=rowCount;
                    selectedCount++;
               }
           }
       }
       if(!rowSelection) {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseSelectAnItem</emxUtil:i18nScript>")
       }
       else{
        for(var j=0; j<fieldCount;j++){
           var fieldValue = eval("document.editForm.elements['"+fieldnames[j]+"'].value");
           for(var k=0;k<selectedCount;k++){
               if(fieldValue != "" ) {
                   eval("document.editForm.elements['"+fieldnames[j]+selectedRows[k]+"'].value=fieldValue;");
               }
           }
        }
       }
  }// function

  function InitialUpdate() {
        rowCount = -1;
        for (var i = 1; i<document.editForm.elements.length; i++) {
            var obj = document.editForm.elements[i];
            if(obj.type!="hidden" && obj.type!="checkbox" && obj.type!="button" && rowCount<0){
                if(obj.type=="text" || obj.type=="textarea"){
                    obj.value='';
                }
            }
            if(obj.type == "checkbox" && obj.name == "selectedPart" ) {
                rowCount++;
            }
        }
  }//function
//End
</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
<!-- <%@include file = "../emxUICommonHeaderEndInclude.inc" %> -->
</head>
<body onLoad="InitialUpdate()">


<%
  String txtType="document.forms['editForm'].type";
  // map to store the values of the attributes at the time when the Edit page is opened.
  Map storedMap           = new HashMap();

  // map to store the details of the relationship attributes.
  Map attDetailsMap       = new HashMap();
  Map finalattDetailsMap  = new HashMap();

  // iterate through each relationship id and store the relationship attribute details in the map
  for(int yy=0; yy<RelIdArray.length; yy++)
  {
    String relId = RelIdArray[yy];
    DomainRelationship relation = DomainRelationship.newInstance(context,relId);
    attDetailsMap = relation.getAttributeDetails(context,false);
    finalattDetailsMap.put(relId,attDetailsMap);
  }
  // if there is no EBOM in summary page then get the attribute names.
  if(RelIdArray.length==0)
  {
    attDetailsMap = DomainRelationship.getTypeAttributes(context,DomainConstants.RELATIONSHIP_EBOM);
  }
%>

<form name="editForm" method="post" action="" target="_parent">
<!-- /*ravi*/ -->
   <table width="100%" class="list">
      <tr>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
        <td >&nbsp;</td>
        
        <td >&nbsp;</td>
<%
         String applySelected = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.AVL.ApplySelected",languageStr);
         String applyAll = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.AVL.ApplyAll",languageStr);

%>
<!-- XSSOK -->
         <td colspan="2" align="right"><input type="button" name="ApplySelected" value="<%=applySelected%>" onClick="Javascript:applySelected()" />&nbsp;&nbsp;<input type="button" name="ApplyAll" value="<%=applyAll%>" onClick="Javascript:applyAll()" /></td>
     </tr>

      <tr>
<%
  String key;
  String attrName;
  Iterator iterator    = attDetailsMap.keySet().iterator();
  while(iterator.hasNext())
  {
    key = (String) iterator.next();
    Map mapinfo = (Map) attDetailsMap.get(key);
    attrName = (String)mapinfo.get("name");
	//Added for X3
	if(attrName == null || strlRestrictionList.contains(attrName)) continue;
%>
	<!-- XSSOK -->
    <th class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></th>
<%
  }
%>
     </tr>
      <tr>
<%
  iterator    = attDetailsMap.keySet().iterator();
  while(iterator.hasNext())
  {
    key = (String) iterator.next();
    Map mapinfo = (Map) attDetailsMap.get(key);
    attrName = (String)mapinfo.get("name");
	//Added for X3
	if(attrName == null || strlRestrictionList.contains(attrName)) continue;
%>
	<!-- XSSOK -->
    <td><%=EngineeringUtil.displayField(context,mapinfo,"edit",languageStr,session,key)%></td>
<%
  }
%>
     </tr>
   </table>
<br/>
  <table width="100%" class="list">
<%
        if (!isPrinterFriendly) {
%>
         <th><input type="checkbox" name="checkAll" onClick="selectAll('editForm')" /></th>
<%
        }
%>
    <th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.Assembly</emxUtil:i18n></th>
<%
  // get the attribute names and show as headings
  iterator    = attDetailsMap.keySet().iterator();
  while(iterator.hasNext())
  {
    key = (String) iterator.next();
    Map mapinfo = (Map) attDetailsMap.get(key);
    attrName = (String)mapinfo.get("name");
	//Added for X3
	if(attrName == null || strlRestrictionList.contains(attrName)) continue;
%>
	<!-- XSSOK -->
    <th class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></th>
<%
  }

  int i=0;
  int myLength = resultList.size();
%>
    <input type="hidden" name="myLength" value="<xss:encodeForHTMLAttribute><%=myLength%></xss:encodeForHTMLAttribute>" />
<%
  if(resultList.size()>0)
  {
%>
  <!-- XSSOK -->
  <fw:mapListItr mapList="<%=resultList%>" mapName="resultsMap">
<%
    objectId    = (String)resultsMap.get("from."+DomainObject.SELECT_ID);
    objectType  = (String)resultsMap.get("from."+DomainObject.SELECT_TYPE);
    objectName  = (String)resultsMap.get("from."+DomainObject.SELECT_NAME);
    objectRev   = (String)resultsMap.get("from."+DomainObject.SELECT_REVISION);
    objectState = (String)resultsMap.get("from."+DomainObject.SELECT_CURRENT);
    objectDesc  = (String)resultsMap.get("from."+DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
    objectOwner = (String)resultsMap.get("from."+DomainObject.SELECT_OWNER);
    srelId      = (String)resultsMap.get("id");
    srelFN      = (String)resultsMap.get(DomainObject.SELECT_FIND_NUMBER);

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
    String sPolicy  = (String)resultsMap.get("from."+"policy");
    DomainRelationship relation = DomainRelationship.newInstance(context,srelId);
    Map newMap = new HashMap();
    newMap.put("name",objectName);
    newMap.put("revision",objectRev);
    newMap.put("type",objectType);
    Map attrTypeMap1 = DomainRelationship.getAttributeMap(context, srelId);
    newMap.putAll(attrTypeMap1);
    storedMap.put(srelId,newMap);
%>
<!-- XSSOK -->
    <tr class='<fw:swap id="even"/>'>
<%
    txtName         = "txtName"+i;
    txtRev          = "txtRev"+i;
    txtDisplay      = "type"+i;
    txtValue        = "typeDisp"+i;
    if(finalRestoreMap.size()>0)
    {
      // restoring the values from the Map.
      Map tempMap=(Map)finalRestoreMap.get(srelId);
      tempMap=(tempMap==null)?new HashMap():tempMap;
      if(tempMap.size()>0)
      {
        objectName=(String)tempMap.get("name");
        objectRev=(String)tempMap.get("revision");
        objectType=(String)tempMap.get("type");
      }
    }
    // to restore the values entered by the user after the removal of EBOM.
    if(removalFlag.equals("true"))
    {
      if(finalremovalMap.size()>0)
      {
        Map tempMap=(Map)finalremovalMap.get(srelId);
        tempMap=(tempMap==null)?new HashMap():tempMap;
        if(tempMap.size()>0)
        {
          objectName=(String)tempMap.get("name");
          objectRev=(String)tempMap.get("revision");
          objectType=(String)tempMap.get("type");
        }
      }
    }
%>

      <input type="hidden" name="selId<%=i%>" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />

<%
    if (!isPrinterFriendly)
    {
       
        String alias = FrameworkUtil.getAliasForAdmin(context, "type", objectType, true);
        String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Part", "SmallIcon");
        String typeIcon = "";

        if ((alias == null) || (alias.equals("")) || (alias.equals("null")))
        {
            typeIcon = defaultTypeIcon;
        }
        else
        {
            typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
            if (typeIcon == null || "".equals(typeIcon) || "null".equals(typeIcon))
            {
                typeIcon = defaultTypeIcon;
            }
        }
%>
      <td width = "3%"><input type="checkbox" name="selectedPart" value="<%=objectId%>" onClick="updateOnSelection('editForm')" /></td>
      <!-- XSSOK -->
      <td class="label"><img border="0" src="../common/images/<%=typeIcon%>" />&nbsp;<%=objectName%></td>
<%
    }
    else
    {
%>
	  <!-- XSSOK -->
      <td width="70"><%=objectName%></td>
<%
    }

    Map attrTypeMap = (Map) finalattDetailsMap.get(srelId.trim());
    Iterator itr2 = attrTypeMap.keySet().iterator();
    String key1 = "";
    String attrValue = "";
    while(itr2.hasNext())
    {
      key1 = (String)itr2.next();
	  //Added for X3
	  if(key1 == null || strlRestrictionList.contains(key1)) continue;
      Map info = (Map) attrTypeMap.get(key1);
      String namesrelId="srelId"+i;
      String findNumber="findNo"+i;
      String displayName=key1+i;

      if(finalRestoreMap.size()>0)
      {
        Map tempMap=(Map)finalRestoreMap.get(srelId);
        tempMap=(tempMap==null)?new HashMap():tempMap;
        if(tempMap.size()>0)
        {
          attrValue = tempMap.get(key1).toString();
          // if the attribute is of timeStamp type then format it and put in the map
          if(info.get("type").equals("timestamp") && !attrValue.equals("") && !attrValue.equals(null))
          {
            attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(attrValue,tz,request.getLocale());
          }
          info.put("value",attrValue);
        }
      }
      if(removalFlag.equals("true"))
      {
        if(finalremovalMap.size()>0)
        {
          Map tempMap=(Map)finalremovalMap.get(srelId);
          tempMap=(tempMap==null)?new HashMap():tempMap;
          if(tempMap.size()>0)
          {
            attrValue = tempMap.get(key1).toString();
            // if the attribute is of timeStamp type then format it and put in the map
            if(info.get("type").equals("timestamp") && !attrValue.equals("") && !attrValue.equals(null))
            {
              attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(attrValue,tz);
            }
            info.put("value",attrValue);
          }

        }
      }
      String displayValue=(String)info.get("value");
%>
      <input type="hidden" name="<%=namesrelId%>" value="<xss:encodeForHTMLAttribute><%=srelId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="<%=findNumber%>" value="<xss:encodeForHTMLAttribute><%=srelFN%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
<%
      if (!isPrinterFriendly)
      {
%>
	  <!-- XSSOK -->
      <td width="70"><%=EngineeringUtil.displayField(context,info,"edit",languageStr,session,key1+i)%></td>
<%
      }
      else
      {
%>
	  <!-- XSSOK -->
      <td width="70"><%=(String)info.get("value")%>&nbsp;</td>
<%
      }
    }

    i++;
%>

    </tr>

  </fw:mapListItr>
<%
  }
  // show this row if there is no EBOM
  else
  {
%>
<!-- XSSOK -->
    <tr class='<fw:swap id="even"/>'>
      <td colspan="14" align="center" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.NoBOMFound</emxUtil:i18n></td>
    </tr>
<%
  }

  //removal of the session values.
  session.setAttribute("storedMap",storedMap);
  session.removeAttribute("finalRestoreMap");
  session.removeAttribute("finalremovalMap");
%>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "emxDesignBottomInclude.inc"%>


