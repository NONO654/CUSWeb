<%--  FeatureOptionValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /web/configuration/FeatureOptionValidation.jsp 1.30.2.2.2.2.1.1 Wed Jan 14 16:01:56 2009   GMT ds-shbehera Experimental$

 --%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
var SeqOrdPropertyArray = new Array();
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
String accLanguage  = request.getHeader("Accept-Language");
String maxQueryLimit = EnoviaResourceBundle.getProperty(context,"emxConfiguration.MaxQueryLimit");

//R208-Added for 377890
String attSeqNumber = "SequenceNumber";//com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_SequenceOrder");
String seqNoUniqueness = JSPUtil.getCentralProperty(application, session,"emxConfiguration","SeqNumberUnique");
%>
//Added for bug 377756
var maxLimit = "<%=XSSUtil.encodeForJavaScript(context,maxQueryLimit)%>";
var maxLimitValidation = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MaxQueryLimit</emxUtil:i18nScript>";
var positiveNumberValidation = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.PositiveNumericNumber</emxUtil:i18nScript>";
//End 377756

//R208-Added for 377890
var attSeqNumber = "<%=XSSUtil.encodeForJavaScript(context,attSeqNumber)%>";
var seqNoUniqueness = "<%=XSSUtil.encodeForJavaScript(context,seqNoUniqueness)%>";
var SEQNO_VALIDATION = "<emxUtil:i18nScript localize="i18nId">emxConfigurationCentral.SeqNumber.ValidationFailed</emxUtil:i18nScript>";
var SEQNO_UNIQUE_MSG = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceNumberNotUnique</emxUtil:i18nScript>";
var BOM_PROCESS_ALERT="<emxUtil:i18nScript localize="i18nId">emxConfiguration.BOMGeneration.process</emxUtil:i18nScript>";
var varSingleSelect ="<%=EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.SelectionType.Single",context.getSession().getLanguage())%>";
var varYesDefaultSelection="<%=EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Range.Dafault_Selection.Yes",context.getSession().getLanguage())%>";

/*******************************************************************************/
/* function validateSelectionType()                                                 */
/* Validates the Selection Type values from indented table edit                     */
/* Added in R211
/*******************************************************************************/
function validateSelectionType()
{ 
    //var objColumnKeyin = colMap.getColumnByName("Key-In Type"); 
    var objColumnKeyinValue = getValueForColumn("Key-In Type");
    var objColumnTypeValue = getValueForColumn("Type");
    var FeatSelectionTypevalue = trim(arguments[0]);
    var arr = new Array();
    arr = FeatSelectionTypevalue.split(" ");
    FeatSelectionTypevalue = arr.join("");
    
    <%
     String strSelectMore = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.AllowedSelections.More",context.getSession().getLanguage());
     String strBlank1 = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Range.KeyIn_Type.Blank", context.getSession().getLanguage());  
     String strAlert = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.SelectionTypeNotCorrect", context.getSession().getLanguage());
     String strAlert1 = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.SelectTypeNotCorrectForKeyInType", context.getSession().getLanguage());
     String strAlert2 = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.SelectTypeNotCorrectForKeyInType1", context.getSession().getLanguage());
    %>
     if(FeatSelectionTypevalue != null)
     {
        //XSSOK
        if(FeatSelectionTypevalue == "<%=strSelectMore%>")
        {   
             /*var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=strBlank1%></a></c>";
             updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank");*/
             
             if(objColumnTypeValue.length == 21 && objColumnKeyinValue == "Blank")
             {
                alert("<%=XSSUtil.encodeForJavaScript(context,strAlert1)%>");
                return false;
             }
             
             if(objColumnTypeValue.length == 21 && objColumnKeyinValue != "Blank")
             {
                alert("<%=XSSUtil.encodeForJavaScript(context,strAlert2)%>");
                return false;
             }
             
             if(objColumnTypeValue.length == 20)
             {
                alert("<%=XSSUtil.encodeForJavaScript(context,strAlert)%>");
                return false;
             }    
        } 
     }
    return true;
}

/*******************************************************************************/
/* function validateKeyInTypeValues()                                                 */
/* Validates the Key-In Type values from indented table edit                     */
/* Added in R211
/*******************************************************************************/
function validateKeyInTypeValues()
{
    var objColumnTypeValue = getValueForColumn("Type");
    var objColumnSelTypeValue = getValueForColumn("Selection Type");

    var KeyInTypevalue = trim(arguments[0]);
    var arr = new Array();
    arr = KeyInTypevalue.split(" ");
    KeyInTypevalue = arr.join("");

    <%
     String strAlrt = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.KeyInTypeNotCorrect", context.getSession().getLanguage());
    %>

    if(KeyInTypevalue != null && objColumnTypeValue != "Configuration Option")
    {
        //XSSOK
        if(KeyInTypevalue != "<%=strBlank1%>")
        {            
            //XSSOK
            if(objColumnSelTypeValue == "<%=strSelectMore%>")
            {
                alert("<%=XSSUtil.encodeForJavaScript(context,strAlrt)%>");
                return false;
            }
        }
    }    
    return true;
}


/*******************************************************************************/
/* function validateQuantity()                                                 */
/* Validates the Quantity entered from indented table edit                     */
/*******************************************************************************/


function validateQuantity()
{
    var qtyvalue = arguments[0];

       if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(qtyvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkNumericQuantity</emxUtil:i18nScript>");
        return false;
      }
      if(qtyvalue <= 0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumericQuantity</emxUtil:i18nScript>");
        return false;
      }

     }
    return true;
}

/*******************************************************************************/
/* function validateMaxQuantity()                                              */
/* Validates the Max Quantity entered from indented table edit                 */
/*******************************************************************************/

function validateMaxQuantity()
{
    var qtyvalue = arguments[0];
    var minqtyvalue = getValueForColumn("MinQty");
    var numqtyvalue = new String();
    var numminqtyvalue = new String();
    numqtyvalue = Number(qtyvalue);
    numminqtyvalue = Number(minqtyvalue);
     if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(qtyvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MaxNumeric</emxUtil:i18nScript>");
        return false;
      }
      if(qtyvalue<=0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumericQuantity</emxUtil:i18nScript>");
        return false;
      }
        if(numqtyvalue<numminqtyvalue)
        {
			alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.FeatureValidateQuantityFailed</emxUtil:i18nScript>");
        return false;
        }
     }
    return true;
}

/*******************************************************************************/
/* function validateMinQuantity()                                              */
/* Validates the Min Quantity entered from indented table edit                 */
/*******************************************************************************/

function validateMinQuantity()
{
    var qtyvalue = arguments[0];
    var maxqtyvalue = getValueForColumn("MaxQty");
    var numqtyvalue = new String();
    var nummaxqtyvalue = new String();
    numqtyvalue = Number(qtyvalue);
    nummaxqtyvalue = Number(maxqtyvalue);
     if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(qtyvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MinNumeric</emxUtil:i18nScript>");
        return false;
      }
      if(qtyvalue<=0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumericQuantity</emxUtil:i18nScript>");
        return false;
      }
        if(nummaxqtyvalue<numqtyvalue)
            {
				alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.FeatureValidateQuantityFailed</emxUtil:i18nScript>");
            return false;
            }
     }
    return true;
}

/*******************************************************************************/
/* function validateMaxResource()                                              */
/* Validates the Max Resource entered from indented table edit                 */
/*******************************************************************************/


function validateMaxResource()
{
    var resvalue = arguments[0];
    var minresvalue = getValueForColumn("Minimum");
    var initresvalue = getValueForColumn("Initial");
    var numresvalue = new String();
    var numminresvalue = new String();
    var numinitresvalue = new String();
    numresvalue = Number(resvalue);
    numminresvalue = Number(minresvalue);
     numinitresvalue = Number(initresvalue);
     if(resvalue != null)
    {
      if( isEmpty(resvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(resvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MaxNumeric</emxUtil:i18nScript>");
        return false;
      }
      if(resvalue<=0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        return false;
      }
        if(numresvalue<numminresvalue)
        {
			alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MinMaxConstraint</emxUtil:i18nScript>");
        return false;
        }
       if(numresvalue<numinitresvalue)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MinMaxConstraint</emxUtil:i18nScript>");
        return false;
        }
       
     }
    return true;
}

/*******************************************************************************/
/* function validateMinResource()                                              */
/* Validates the Min Resource entered from indented table edit                 */
/*******************************************************************************/

function validateMinResource()
{
    var resvalue = arguments[0];
    var maxresvalue = getValueForColumn("Maximum");
    var initresvalue = getValueForColumn("Initial");
    var numresvalue = new String();
    var nummaxresvalue = new String();
    var numinitresvalue = new String();
    numresvalue = Number(resvalue);
    nummaxresvalue = Number(maxresvalue);
    numinitresvalue = Number(initresvalue);
     if(resvalue != null)
    {
      if( isEmpty(resvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(resvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MinNumeric</emxUtil:i18nScript>");
        return false;
      }
      if(resvalue<=0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        return false;
      }
        if(nummaxresvalue<numresvalue)
            {
				alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MaxMinConstraint</emxUtil:i18nScript>");
            return false;
            }
        if(numresvalue > numinitresvalue)
        {
               alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.InitialMaxMinConstraint</emxUtil:i18nScript>");
            return false;
        }   
     }
    return true;
}


/*******************************************************************************/
/* function validateInitialResource()                                              */
/* Validates the Min Resource entered from indented table edit                 */
/*******************************************************************************/

function validateInitialResource()
{
    var resvalue = arguments[0];
    var maxresvalue = getValueForColumn("Maximum");
    var minresvalue = getValueForColumn("Minimum");
    var numresvalue = new String();
    var numminresvalue = new String();
    var nummaxresvalue = new String();
    numresvalue = Number(resvalue);
    numminresvalue = Number(minresvalue);
    nummaxresvalue = Number(maxresvalue);
         if(resvalue != null)
    {
      if( isEmpty(resvalue)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
      }
      if(!isNumeric(resvalue))
      {
              alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.InitialNumeric</emxUtil:i18nScript>");
        return false;
      }
      if(resvalue<=0)
      {
 	 		 alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        return false;
      }
        if((nummaxresvalue<numresvalue)||(numresvalue<numminresvalue))
            {
				alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.InitialMaxMinConstraint</emxUtil:i18nScript>");
            return false;
            }
     }
    return true;
}

/******************************************************************************/
/* function checkBlank() - checks whether the value is blank or not              */
/*                                                                            */
/******************************************************************************/
function checkBlank()
{
    var blankvalue = arguments[0];
        if(isEmpty(blankvalue)){
	  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlank</emxUtil:i18nScript>");
        return false;
    }
        return true;
}
/******************************************************************************/
/* function isEmpty() - checks whether the value is blank or not              */
/*                                                                            */
/******************************************************************************/

function isEmpty(s)
{
  return ((s == null)||(s.length == 0));
}

/******************************************************************************/
/* function isNumeric() - checks whether the value is numeric or not          */
/*                                                                            */
/******************************************************************************/

function isNumeric(varValue)
{
    if (isNaN(varValue))
    {
        return false;
    } else {
        return true;
    }
}


/*******************************************************************************/
/* function validateSequenceOrder()                                            */
/* Validates the Sequence Order entered from indented table edit  .            */
/*******************************************************************************/
function validateSequenceOrder()
{

    //var cellData   = getColumnDataAtLevel();
    var inputSeqOrder    = trim(arguments[0]);
    var intseqOrder =  Math.floor (inputSeqOrder);
    if(!isNumeric(inputSeqOrder)){
	alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        return false;
    }
    if(inputSeqOrder!=intseqOrder)
    {
		alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceInteger</emxUtil:i18nScript>");
        return false;
    }
    if(isEmpty(inputSeqOrder)){
		  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForSequenceNumber</emxUtil:i18nScript>");
            return false;
    }
    if(inputSeqOrder<=0){
	 	 	alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceNumericPositive</emxUtil:i18nScript>");
            return false;
    }
    if(inputSeqOrder>=100)
    {
	   alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.LengthExceeded</emxUtil:i18nScript>");
       return false;
    }
    if(!(isSequenceOrderUnique(cellData,inputSeqOrder)))
    {
  	    alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceNumberNotUnique</emxUtil:i18nScript>");
        return false;
    }

    return true;
}


/******************************************************************************/
/* function isSequenceOrderUnique() - returns true if the supplied value      */
/* is unique with respect to the other values on the form.                    */
/* takes column values and new value as arguments                             */
/******************************************************************************/

function isSequenceOrderUnique(cellData, inputSeqOrder)
{
    var arrayValue= new String();
    for(var i=0;i < cellData.length-1;i++ )
    {
       arrayValue = cellData[i];

       if(arrayValue!="" && (arrayValue==inputSeqOrder))
       {
           return false;
       }
    }
    return true;
}

/******************************************************************************/
/* function chkLength() - returns true if length of the text field             */
/* is below the valid length.                                              */
/******************************************************************************/

function chkLength(validLength,txtLength)
{

     return((validLength!=0 && txtLength.length<=validLength));

}

//Related to Product Variant
function selectedFeature(objId)
{

   var objId = objId;
   var current ;
   var parentArr;
   var childArr;
   current = document.getElementById(objId);
   var childArr1 = current.getAttribute("childobjid");
   var varRowID = current.getAttribute("rowid");
   var parentArr1 = current.getAttribute("parentobjid");
   parentArr = document.getElementById(parentArr1);

   var isSelected = false;
   if(current.checked==true){
	   isSelected = true;
   }
   else if(current.checked==false){
	   isSelected = false;
   }
   current.setAttribute("isSelected",isSelected);

   if (childArr1 != "")
   {
      var currentTagTokens = childArr1.split("," );
      for ( var i = 0; i < currentTagTokens.length; i++ )
      {
        childArr = document.getElementById(currentTagTokens[i]);
        if(current.checked==false)
        {
          if (childArr!=null && childArr.checked==true)
          {
               childArr.click();
               childArr.focus();
		   }		
          }
        }
      }

   if(current.checked==true)
   {
      var tagCheckbox="<c><div align=\"center\"><input checked=\"checked\" type=\"checkbox\"  onclick=\"selectedFeature('"+objId+"')\" childobjid=\""+childArr1+"\" rowid=\""+varRowID+"\" parentobjid=\""+parentArr1+"\" id=\""+objId+"\" name=\""+objId+"\" /></div></c>";           
      updateXMLByRowId(varRowID,tagCheckbox,2); 
      if (parentArr!=null && parentArr.checked==false){
           parentArr.click();
           parentArr.focus();
       }
    }
    else if(current.checked==false)
    {
      var tagCheckbox="<c><div align=\"center\"><input type=\"checkbox\"  onclick=\"selectedFeature('"+objId+"')\" childobjid=\""+childArr1+"\" rowid=\""+varRowID+"\" parentobjid=\""+parentArr1+"\" id=\""+objId+"\" name=\""+objId+"\" /></div></c>";
      updateXMLByRowId(varRowID,tagCheckbox,2); 
      if (childArr!=null && childArr.checked==true)
      {
           childArr.click();
           childArr.focus();
      }
    }
}

function selectedFeatureLevel(objId)
{

   var objId = objId;
   var current ;
   var parentArr;
   var childArr;
   current = document.getElementById(objId);
   var childArr1 = current.getAttribute("childobjid");
   var varRowID = current.getAttribute("rowid");
   var parentArr1 = current.getAttribute("parentobjid");
   var strRelId  = current.getAttribute("relid");
   var strActualObjId  = current.getAttribute("oidlevel");   

   var varParentRowId = varRowID.slice(0,varRowID.length-2);
   
   var actualParentOId = current.getAttribute("parentobjid");
   
   

   parentArr1 = parentArr1+":"+ varParentRowId;
   parentArr = document.getElementById(parentArr1);
   
   var childActualID;
   var isSelected = false;
   if(current.checked==true){
	   isSelected = true;
   }
   else if(current.checked==false){
	   isSelected = false;
   }
   current.setAttribute("isSelected",isSelected);
   current.setAttribute("checked",isSelected);   
   
   if (childArr1 != "")
   {
      var currentTagTokens = childArr1.split("," );
      var tempLength = currentTagTokens.length;

      for ( var i = 0; i < currentTagTokens.length; i++ )
      {
		for(var j = 0; j < tempLength; j++)
		{
			childActualID = currentTagTokens[j]+":"+varRowID+","+i;
			childArr = document.getElementById(childActualID);
			
			if(current.checked==false)
			{
			  if (childArr!=null && childArr.checked==true)
			  {
				   childArr.click();
				   childArr.focus();
			   }		
			  }
		}
        }
      }

   if(current.checked==true)
   {
      var tagCheckbox="<c><div align=\"center\"><input checked=\"true\" type=\"checkbox\"  onclick=\"selectedFeatureLevel('"+objId+"')\" childobjid=\""+childArr1+"\" rowid=\""+varRowID+"\" isselected=\""+isSelected+"\" relid=\""+strRelId+"\" parentobjid=\""+actualParentOId+"\" id=\""+objId+"\" name=\""+objId+"\" /><input type=\"hidden\" id=\""+strActualObjId+"\" name=\"hiddenObjectId\"/></div></c>";	  
      updateXMLByRowId(varRowID,tagCheckbox,2); 
      if (parentArr!=null && parentArr.checked==false){
           parentArr.click();
           parentArr.focus();
       }
    }
    else if(current.checked==false)
    {
      var tagCheckbox="<c><div align=\"center\"><input checked=\"false\" type=\"checkbox\"  onclick=\"selectedFeatureLevel('"+objId+"')\" childobjid=\""+childArr1+"\" rowid=\""+varRowID+"\" relid=\""+strRelId+"\" isselected=\""+isSelected+"\" parentobjid=\""+actualParentOId+"\" id=\""+objId+"\" name=\""+objId+"\" /><input type=\"hidden\" id=\""+strActualObjId+"\" name=\"hiddenObjectId\"/></div></c>";
      updateXMLByRowId(varRowID,tagCheckbox,2); 
      if (childArr!=null && childArr.checked==true)
      {
           childArr.click();
           childArr.focus();
      }
    }
}



//Related to Product Variant
function selectedFeatureForEditAll(objId)
{
   var objId = objId;
   var current ;
   current = document.getElementById(objId);
   var strRelId  = current.getAttribute("relid");
   var strCheckboxType  = current.getAttribute("checkboxtype");   
         
   var temp = current.getAttribute("src");
   var varRowID = current.getAttribute("rowid");
   var checkOn = "../common/images/utilTreeCheckOn.gif";
   var checkOff = "../common/images/utilTreeCheckOff.gif";
   
   var checkOnTemp = "utilTreeCheckOn.gif";
   var checkOffTemp = "utilTreeCheckOff.gif";
   
 
   if(temp.match(checkOnTemp)){
        current.setAttribute("src",checkOff); 
		var tagCheckbox="<c><div align=\"center\" onclick=\"selectedFeatureForEditAll('"+objId+"')\" ><img border=\"0\" id=\""+objId+"\" relid=\""+strRelId+"\" checkboxtype=\"checkOff\"  rowID=\""+varRowID+"\" src=\""+checkOff+"\" name=\"EditAll\" /></div></c>";
		updateXMLByRowId(varRowID,tagCheckbox,2);         
        
   }
   else if(temp.match(checkOffTemp)){
        current.setAttribute("src",checkOn);
		var tagCheckbox="<c><div align=\"center\" onclick=\"selectedFeatureForEditAll('"+objId+"')\" ><img border=\"0\" id=\""+objId+"\" relid=\""+strRelId+"\" checkboxtype=\"checkOn\" rowID=\""+varRowID+"\" src=\""+checkOn+"\" name=\"EditAll\" /></div></c>";
		updateXMLByRowId(varRowID,tagCheckbox,2);         
   }
}
function selectedFeatureForEditAllDisabled(objId)
{
   var objId = objId;
   var current ;
   
   current = document.getElementById(objId);
   var strRelId  = current.getAttribute("relid");
   var strCheckboxType  = current.getAttribute("checkboxtype");         
         
   var temp = current.getAttribute("src");
   var varRowID = current.getAttribute("rowid");
   var checkOn = "../common/images/utilTreeCheckOn.gif";
   var checkOff = "../common/images/utilTreeCheckOff.gif";   
   var checkOnDisabled = "../common/images/utilCheckOffDisabled.gif";
   
   var checkOnTemp = "utilTreeCheckOn.gif";
   var checkOffTemp = "utilTreeCheckOff.gif";
   var checkOnDisabledTemp = "utilCheckOffDisabled.gif";
 
   if(temp.match(checkOnTemp)){
        current.setAttribute("src",checkOff); 
		var tagCheckbox="<c><div align=\"center\" onclick=\"selectedFeatureForEditAllDisabled('"+objId+"')\" ><img border=\"0\" id=\""+objId+"\" checkboxtype=\"checkOff\" relid=\""+strRelId+"\" rowID=\""+varRowID+"\" src=\""+checkOff+"\" name=\"EditAll\" /></div></c>";
		updateXMLByRowId(varRowID,tagCheckbox,2);         
   }
   else if(temp.match(checkOffTemp)){
        current.setAttribute("src",checkOnDisabled);
		var tagCheckbox="<c><div align=\"center\" onclick=\"selectedFeatureForEditAllDisabled('"+objId+"')\" ><img border=\"0\" id=\""+objId+"\" checkboxtype=\"checkDisabled\" relid=\""+strRelId+"\" rowID=\""+varRowID+"\" src=\""+checkOnDisabled+"\" name=\"EditAll\" /></div></c>";
		updateXMLByRowId(varRowID,tagCheckbox,2);         
   }
   else if(temp.match(checkOnDisabledTemp)){
        current.setAttribute("src",checkOn);
		var tagCheckbox="<c><div align=\"center\" onclick=\"selectedFeatureForEditAllDisabled('"+objId+"')\" ><img border=\"0\" id=\""+objId+"\" checkboxtype=\"checkOn\" relid=\""+strRelId+"\" rowID=\""+varRowID+"\" src=\""+checkOn+"\" name=\"EditAll\" /></div></c>";
		updateXMLByRowId(varRowID,tagCheckbox,2);         
   }      
}

/*******************************************************************************/
/* function validateFeatSelectionType()                                              */
/* Validates the Key In Type value entered from indented table edit                 */
/*******************************************************************************/

function validateFeatureSelectionType()
{  // Added for IR-025975V6R2011 
    //var uid = currentCell.target.parentNode.getAttribute("id"); //modified for IR-054297V6R2011x as uid is used nowhere in the function
    var objColumnKeyin = colMap.getColumnByName("Key-In Type");
    var objColumnFeatureSel = colMap.getColumnByName("SelectionOption");
    
    var FeatSelectionTypevalue = trim(arguments[0]);
    var arr = new Array();
    arr = FeatSelectionTypevalue.split(" ");
    FeatSelectionTypevalue = arr.join("");
<%
 String strMustSelectOnlyOne = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.Must_Select_Only_One", context.getSession().getLanguage());
 String strMaySelectOnlyOne = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.May_Select_Only_One", context.getSession().getLanguage());
 String strMustSelectAtLeastOne = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.Must_Select_At_Least_One", context.getSession().getLanguage());
 String strMaySelectOneOrMore = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.May_Select_One_Or_More", context.getSession().getLanguage());
 String strKeyIn = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.Key-In", context.getSession().getLanguage());
 String strInput = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Input", context.getSession().getLanguage());
 String strDate = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Date",context.getSession().getLanguage());
 String strInteger = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Integer", context.getSession().getLanguage());
 String strReal = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Real",context.getSession().getLanguage());
 String strTextArea = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Text_Area", context.getSession().getLanguage());
 String strBlank = com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Key-In_Type.Blank",context.getSession().getLanguage());
   
 %>
     if(FeatSelectionTypevalue != null)
     {
      
       if( FeatSelectionTypevalue == "MustSelectOnlyOne")
       {  
          //set value for strKeyInTypeValue to BLANK and return true         
          var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=XSSUtil.encodeForHTML(context,strBlank)%></a></c>";
          updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank"); 
          
          return true;
       }
      if( FeatSelectionTypevalue == "MustSelectAtLeastOne")
       {
          //set value for strKeyInTypeValue to BLANK and return true
          var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=XSSUtil.encodeForHTML(context,strBlank)%></a></c>";
          updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank");
          
          return true;
       }
      if( FeatSelectionTypevalue == "MaySelectOnlyOne")
       {
          //set value for strKeyInTypeValue to BLANK and return true  
          var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=XSSUtil.encodeForHTML(context,strBlank)%></a></c>";
          updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank");  
           
          return true;
       }
        if( FeatSelectionTypevalue== "MaySelectOneOrMore")
       {
         //set value for strKeyInTypeValue to BLANK and return true 
         var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=XSSUtil.encodeForHTML(context,strBlank)%></a></c>";
         updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank");
          
         return true;
       } 
       if( FeatSelectionTypevalue == "Key-In")
       {
         //set value for strKeyInTypeValue to Input and return true  
         var newXML = "<c a=\"&lt;a TITLE=&quot;Input&quot;&gt;Input&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Input\"><%=XSSUtil.encodeForHTML(context,strInput)%></a></c>"; 
         updatePostXMLByRowId(newXML,objColumnKeyin.index,"Input");
              
         return true;
       }
     }
    return false;
}





/*******************************************************************************/
/* function validateKeyInType()                                              */
/* Validates the Key In Type value entered from indented table edit                 */
/*******************************************************************************/

function validateKeyInType()
{ // Added for IR-025975V6R2011 
       //modified for IR-054297V6R2011x as currentCell is null for "Mass Update"
    //var uid = currentCell.target.parentNode.getAttribute("id");
    var uid = currentRow.getAttribute("id");
    //modified for IR-054297V6R2011x -- end
    var objColumnKeyin = colMap.getColumnByName("Key-In Type");
    var objColumnFeatureSel = colMap.getColumnByName("SelectionOption");
   var val;
   
   var KeyInTypevalue =trim(arguments[0]);
 
   if(KeyInTypevalue == "")
   KeyInTypevalue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + uid + "']/c["+objColumnKeyin.index+"]/a/text()");
 
   if(KeyInTypevalue==null)
   KeyInTypevalue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + uid + "']/c["+objColumnKeyin.index+"][@a]/text()");
   var featSeletionTypevalue =null;
	if(featSeletionTypevalue==null)
	featSeletionTypevalue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + uid + "']/c["+objColumnFeatureSel.index+"][@a]/text()");
      
	if(featSeletionTypevalue==null)
	featSeletionTypevalue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + uid + "']/c["+objColumnFeatureSel.index+"]/a/text()");
	 
	if(typeof featSeletionTypevalue == 'object')
	{
	    featSeletionTypevalue = featSeletionTypevalue.xml;
	}
	
	if(typeof KeyInTypevalue ==  'object')
	{
	  KeyInTypevalue = KeyInTypevalue.xml
	}
	
   if(KeyInTypevalue != null)
    {
	        if(featSeletionTypevalue!=null)
               {
            	          //XSSOK
					      if(featSeletionTypevalue == "<%=strKeyIn%>" )
					        {
							        if(  KeyInTypevalue =="Blank" )
									{
									   //Ask user to change first featSeletionTypevalue to other than Key In and then select value for KeyInTypevalue as Blank
									   alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkstrKeyInSelectionTypevalue</emxUtil:i18nScript>");    				 
									   return false; 							
									}
									else
									{
									    //XSSOK
									  	if( KeyInTypevalue =="<%=strTextArea%>" || KeyInTypevalue =="TextArea" )
									    {
										     val="Text Area";	           
										}
										//XSSOK
										else if( KeyInTypevalue =="<%=strDate%>"|| KeyInTypevalue =="Date" )
										{
										    val="Date";	           
										 }
										 //XSSOK
										 else if( KeyInTypevalue =="<%=strInput%>"|| KeyInTypevalue =="Input" )
										 {
										    //alert("aaaaa...");
											val="Input";	           
										 }
										 //XSSOK
										 else if( KeyInTypevalue =="<%=strInteger%>"|| KeyInTypevalue =="Integer"  )
										 {
										    val="Integer";	           
										 }
										 //XSSOK
										 else if( KeyInTypevalue =="<%=strReal%>"|| KeyInTypevalue =="Real" )
										 {
										    val="Real";	           
									     }
									//set the value for KeyInTypevalue=val
					                var newXML = '<c a=\"&lt;a TITLE=&quot;'+KeyInTypevalue+'&quot;&gt;'+KeyInTypevalue+'&lt;/a&gt;\" edited=\"true\">'+KeyInTypevalue+'</c>';		                
		                            updatePostXMLByRowId(newXML,objColumnKeyin.index,val); 
		                            return true; 
				                   }
                            }
                            //XSSOK
						   if(featSeletionTypevalue != "<%=strKeyIn%>" && KeyInTypevalue !="Blank")
							{
							  //Ask user to change first featSeletionTypevalue to other than Key In and then select value for KeyInTypevalue as Blank
    						  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkstrFeatSelectionTypevalue</emxUtil:i18nScript>");    				 
        			          return false;      	        
							}
							//XSSOK
							else if ( KeyInTypevalue =="<%=strBlank%>" ||  KeyInTypevalue =="Blank")
							{
									 //set value for strKeyInTypeValue to BLANK and return true 
									 var newXML = "<c a=\"&lt;a TITLE=&quot;Blank&quot;&gt;Blank&lt;/a&gt;\" edited=\"true\"><a TITLE=\"Blank\"><%=XSSUtil.encodeForHTML(context,strBlank)%></a></c>";
									 updatePostXMLByRowId(newXML,objColumnKeyin.index,"Blank");
									 return true;
							}
							
					}
          }
       
}




function validateFNByLevel()
{
   
	var cellData   = getColumnDataAtLevel();
    var inputFN    = trim(arguments[0]);
    var intFNNumber =  Math.floor (inputFN);

    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var objColumnFN = colMap.getColumnByName("FindNumber");
    if(objColumnFN == undefined || objColumnFN == null){
    var objColumnFN = colMap.getColumnByName("Find Number");
    }
    var columnName = objColumnFN.name;
    var cellActualValue = getValueForColumn(columnName);
    var findNumberCellData = new Array();
    var fnIndex=0;
    
 //    if(inputFN ==null || isEmpty(inputFN)){
 //   if(validation  == "false")
 //   {
 //   
 //   return true;
 //   }
 //   }
 //   if(inputFN!=null){
    if(isEmpty(inputFN)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForFindNumber</emxUtil:i18nScript>");
        return false;
      }
 //   }
    for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			findNumberCellData[fnIndex]=cellData[i];
			fnIndex++;
		}
	}
	
	if(!IsNumeric(inputFN))
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveInteger</emxUtil:i18nScript>");
		return false;
	}
// if(validation  == "true")
//   {
//    
//	if(!isFNUnique(findNumberCellData,inputFN))
//	{
//		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
//		return false;
//	}
//	
//}
  if(inputFN!=intFNNumber)
    {
		alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveInteger</emxUtil:i18nScript>");
        return false;
    }	
    return true;
}

function IsNumeric(sText)
{
   var validChars = "0123456789.";
   var isNumber=true;
   var Char;

 
   for (i = 0; i < sText.length && isNumber == true; i++) 
      { 
      Char = sText.charAt(i); 
      if (validChars.indexOf(Char) == -1) 
         {
         isNumber = false;
         }
      }
   return isNumber;
   
   }

/*******************************************************************************/
/* function validateRDByLevel()                                                */
/* Validates the Reference Designator entered from indented table edit         */
/*******************************************************************************/
function validateRDByLevel()
{

    var cellData   = getColumnDataAtLevel();
    var inputRD    = arguments[0];
    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var cellActualValue = getValueForColumn("ReferenceDesignator");
    var refDesignatorCellData = new Array();
    var refIndex=0;
    
    
//    if(inputRD == null || isEmpty(inputRD))
//    {
//    
//    if(validation  == "false")
//   {
//    return true;
//   }
//    
//    }
    
    
    
    
    
//    if(inputRD!=null){
//    if(isEmpty(inputRD)) {
//          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForRefDesignator</emxUtil:i18nScript>");
//        return false;
//      }
//    }
    
    for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			refDesignatorCellData[refIndex]=cellData[i];
			refIndex++;
		}
	}
    //Above code is to bypass the currentcell from array
    //to avoid checking of value against itself
     if(inputRD!="")
     {
         if(!isRDAlphaNumeric(inputRD))
         {
			  alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.FNFieldNotAnAlphaNumericPleaseReEnter</emxUtil:i18nScript>");
              return false;
         }


//           if(validation  == "true")
//           {
//            if(!isFNUnique(refDesignatorCellData,inputRD))
//            {
//                alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.RDNotUniqueForTNR</emxUtil:i18nScript>");
//                return false;
//            }
//          }
     }
  return true;
}

function isFNUnique(cellData, inputFN)
{
    var arrayValue="";
    for(var i=0;i < cellData.length; i++)
    {
       arrayValue = cellData[i];
       if(arrayValue!="" && arrayValue==inputFN)
       {
           return false;
       }

    }
    return true;
}

function isRDAlphaNumeric(string)
{
    var format=string.match(/([a-zA-Z]+[0-9])/);
    if(format)
    {
      return true;
    }
    else
    {
      return false;
    }
    return true;
}

function isEmpty(s)
{
  return ((s == null)||(s.length == 0));
}

/*******************************************************************************/
/* function validateSequenceNumberByLevel()                                    */
/* Validates the Sequence Number entered from indented table edit              */
/*******************************************************************************/

function validateSequenceNumberByLevel()
{
	var cellData   = getColumnDataAtLevel();
    var inputFN    = trim(arguments[0]);

    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var cellActualValue = getValueForColumn("SequenceNumber");
    var findNumberCellData = new Array();
    var fnIndex=0;
    
    if(inputFN!=null){
    if(isEmpty(inputFN)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForSequenceNumber</emxUtil:i18nScript>");
        return false;
      }
    }
    

    
    for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			findNumberCellData[fnIndex]=cellData[i];
			fnIndex++;
		}
	}
	
	if(!IsNumeric(inputFN))
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.SeqNoFieldNotNumericPleaseReEnter</emxUtil:i18nScript>");
		return false;
	}

	if(!isFNUnique(findNumberCellData,inputFN))
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.SeqNoFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
		return false;
	}
	
    return true;
}


function updateXMLByRowId(rowId,xmlCellData,columnId){
	var oldColumn = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']/c["+columnId+"]");
	var row = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id = '" + rowId + "']");
	var objDOM = emxUICore.createXMLDOM();
    objDOM.loadXML(xmlCellData);
	row.replaceChild(objDOM.documentElement,oldColumn);
}


function updatePostXMLByRowId (newColumn,columnNo,colVal)
{  
  var uid = currentRow.getAttribute("id");  
  var row = emxUICore.selectSingleNode (oXML.documentElement, "/mxRoot/rows//r[@id = '" + uid + "']");  
  updateXMLByRowId(uid,newColumn,columnNo);
  updatePostXML (row,colVal,columnNo);
}

function submitUpdatedData(levelIds,grpNos)
{
for(var i =0; i<grpNos.length;i++){
   var aRows = emxUICore.selectSingleNode(oXML.documentElement,"/mxRoot/rows/r[@id='"+levelIds[i]+"']");  
   var colCount = 0;  
   aRows.removeAttribute("status");   
   for(var j=0;j<aRows.childNodes.length;j++)
   {							
					var value = emxUICore.getText(aRows.childNodes[j]);
					if(aRows.childNodes[j].tagName =="c")
					{					
						if(colCount == 1){
					   var objDOM = emxUICore.createXMLDOM();
					   objDOM.loadXML("<c a='"+grpNos[i]+"'>"+grpNos[i]+"</c>");					   
					   aRows.replaceChild(objDOM.documentElement,aRows.childNodes[j]);
					   }
					else{
					   aRows.childNodes[j].setAttribute("a",value);				   
					   }
					
					colCount++;
					}		
			aRows.childNodes[j].setAttribute("edited","false");			
      }     
   }
   //emxUICore.oXML.loadXML ("'"+aRows.xml+"'");
   arrUndoRows = new Object();
   postDataXML.loadXML("<mxRoot/>");
  rebuildView();
}
function validateDesignVariantValue()
{
    
    var uid = currentRow.getAttribute("id");
    var row = emxUICore.selectSingleNode (oXML.documentElement, "/mxRoot/rows//r[@id = '" + uid + "']"); 
    var ruletype = row.childNodes[5].getAttribute("a");
    var complexRuleType = "<emxUtil:i18nScript localize="i18nId">emxProduct.Rule_Type.ComplexInclusionRule</emxUtil:i18nScript>";
    var alertMssg = "<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.DVEditNotAllowed</emxUtil:i18nScript>";
//CODE CHANGE FOR BUG 361709 START
	//if(complexRuleType == ruletype || ruletype.indexOf("iconStatusMulti.gif") > -1)
//	{
//	 alert(alertMssg);
//	 return false;
//	}
//	else
//	{
//	 return true;
//	}
//CODE CHANGE FOR BUG 361709 END
return true;
	
}

function validateListPrice(){
    //var cellData   = getColumnDataAtLevel();
    var inputFN    = trim(arguments[0]);
    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var cellActualValue = getValueForColumn("ListPrice");
    var findNumberCellData = new Array();
    var fnIndex=0;

    if(inputFN!=null){
		if(isEmpty(inputFN)) {
			  alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForListPrice</emxUtil:i18nScript>");
			return false;
		  }
		if(!IsNumeric(inputFN))
		{
			alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.FNFieldNotNumericPleaseReEnter</emxUtil:i18nScript>");
			return false;
		}
    }


      var DecimalFound = false
      for (var i = 0; i < inputFN.length; i++) {
            var ch = inputFN.charAt(i)
            if (i == 0 && ch == "-") {
                  continue
            }
            if (ch == "." && !DecimalFound) {
                  DecimalFound = true
                  continue
            }
            if (ch < "0" || ch > "9") {
			alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Real</emxUtil:i18nScript>");
                  return false
            }
      }
      return true
}

function ClearDesignResponsibility(fieldName) {

	var formElement= eval ("document.forms[0]['"+ fieldName + "']");

	if (formElement){


	if(formElement.length>1){
		
		if (formElement[i].value != ""){
			
			var response = window.confirm("<emxUtil:i18nScript localize="i18nId">emxProduct.Confirm.DesignResponsibility.Clear</emxUtil:i18nScript>");
			if(!response){
				return ;
			}
		}
		for(var i=0; i < formElement.length-1; i++)
		{
				 formElement[i].value="";
		}
	}else{
			if (formElement.value != ""){
			var response = window.confirm("<emxUtil:i18nScript localize="i18nId">emxProduct.Confirm.DesignResponsibility.Clear</emxUtil:i18nScript>");
				if(!response){
					return ;
				}
			}
		   formElement.value="";
	    }
	 }

	formElement=eval ("document.forms[0]['"+ fieldName + "Display']");

	if (formElement){
	  if(formElement.length>1){
		for(var i=0; i < formElement.length-1; i++)
		  {
			 formElement[i].value="";
		  }
		}else{
		   formElement.value="";
	   }
	 }

	formElement=eval ("document.forms[0]['"+ fieldName + "OID']");

	if (formElement){
	  if(formElement.length>1){
		for(var i=0; i < formElement.length-1; i++)
		  {
			 formElement[i].value="";
		  }
		}else{
		   formElement.value="";
	   }
	 }
}
function validateFeatureSelType(){
	    var FeatSelectionType = arguments[0];
    var arr = new Array();
    var val;
    arr = FeatSelectionType.split(" ");
    var FeatSelectionTypevalue = arr.join("");
    var featureUsageValue = getValueForColumn("FeatureUsage");
    // Added for IR-025975V6R2011 
    //var uid = currentCell.target.parentNode.getAttribute("id"); //modified for IR-054297V6R2011x as uid is used nowhere in the function
    var objColumnFeatureSel = colMap.getColumnByName("SelectionOption");
<%
 String strMaySelectOnlyOneValue = EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Range.Feature_Selection_Type.May_Select_Only_One",context.getSession().getLanguage());
 %>    
if(featureUsageValue == "Mandatory"){
if (FeatSelectionTypevalue == "MaySelectOnlyOne" || FeatSelectionTypevalue == "MaySelectOneOrMore"){
	alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Error.InvalidFeatureSelectionType</emxUtil:i18nScript>");    				 
	return false; 
}else {
	if(FeatSelectionTypevalue == "MustSelectOnlyOne"){
	
		val="Must Select Only One";
        var newXML = '<c a=\"&lt;a TITLE=&quot;'+FeatSelectionType+'&quot;&gt;'+FeatSelectionType+'&lt;/a&gt;\" edited=\"true\">'+FeatSelectionType+'</c>';
	    updatePostXMLByRowId(newXML,objColumnFeatureSel.index,val);
        return true;

	}
	if(FeatSelectionTypevalue == "MustSelectAtLeastOne"){
		val="Must Select At Least One";
        var newXML = '<c a=\"&lt;a TITLE=&quot;'+FeatSelectionType+'&quot;&gt;'+FeatSelectionType+'&lt;/a&gt;\" edited=\"true\">'+FeatSelectionType+'</c>';
	    updatePostXMLByRowId(newXML,objColumnFeatureSel.index,val);
       return true;
	}

 }
}else {
        
        var newXML = "<c a=\"&lt;a TITLE=&quot;"+FeatSelectionType+"&quot;&gt;"+FeatSelectionType+"&lt;/a&gt;\" edited=\"true\"><%=XSSUtil.encodeForHTML(context,strMaySelectOnlyOneValue)%></c>";
	    updatePostXMLByRowId(newXML,objColumnFeatureSel.index,FeatSelectionType);
       return true;
}
}

/********************************************************************************/
/* function validateSeqNumberOnApply() - validates the Sequence Number on Apply.*/
/* This method is setting for table "FTRAllFeatureTypeTable"					*/
/* on the column "Seq No".														*/
/* R208-Added for 377890															*/
/********************************************************************************/
var count = 1;
var arrSeqNoError = new Array();
function validateSeqNumberOnApply(){
    var returnMsgSeqNo = "";
    try{
        var returnMsgSeqNo = "";
        if(seqNoUniqueness.toLowerCase()=="true"){

            var objColumnSeqNum = colMap.getColumnByName(attSeqNumber);
            var nodeList = emxUICore.selectNodes(oXML.documentElement, "//c["+ objColumnSeqNum.index +"][@edited = 'true']");
            var totalRows = nodeList.length;
            var mCurrentRow = nodeList[count-1].parentNode;
            var currentRowValue = arguments[0];
            var alevel = mCurrentRow.getAttribute("level");    
            var arowId = mCurrentRow.getAttribute("id");

            var currentParentRowId = mCurrentRow.parentNode.getAttribute("id");

            var aSiblingRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@level = '" + alevel + "' and @id != '" + arowId + "']");

            for(var i=0;i < aSiblingRows.length; i++){
                var siblingParentRowId = aSiblingRows[i].parentNode.getAttribute("id");
                if(siblingParentRowId != currentParentRowId){
                    continue;
                }

                var status = aSiblingRows[i].getAttribute("status");
                if(status != null && (typeof status != 'undefined') && status == 'cut'){
                    continue;
                }
                var lastobj = emxUICore.selectSingleNode(aSiblingRows[i], "c[" + objColumnSeqNum.index + "]").lastChild;
                if (lastobj) {
                    var val = lastobj.nodeValue;
                    //if(val!=""){
                    if(val && val!=""){
                        if(trim(val) == trim(currentRowValue)){
                            var pattern = val+" at level "+alevel;
                            var error = arrSeqNoError.toString();
                            if(error.indexOf(pattern) == -1){
                                arrSeqNoError.push(val+" at level "+alevel);
                                //arrSeqNoError.push(SEQNO_UNIQUE_MSG);
                            }
                        }
                    }
                }
            }

            if(totalRows == count){
                count = 1;
                if(arrSeqNoError.length > 0){
                    returnMsgSeqNo = SEQNO_UNIQUE_MSG+" ["+arrSeqNoError+"]";
                }
                arrSeqNoError = new Array();
            }
            else{
                count++;
            }
        }
    }
    catch(e){
        returnMsgSeqNo = SEQNO_VALIDATION+e.message;
    }
    return returnMsgSeqNo;
}

/*******************************************************************************/
/* function isInteger()                                 */
/* Check Number enter is Integer or not.           */
/*******************************************************************************/
function isInteger(str)
{
	 	var num = "0123456789";
	 	for(var i=0;i<str.length;i++)
	 	{
	 		if(num.indexOf(str.charAt(i))==-1){ 		  
	 		  return false;
	 		}
	 	}
	 	return true;
}

/*******************************************************************************/
/* function validateSequenceNumberForPositve()                                 */
/* Validates the Sequence Number entered from indented table edit  .           */
/*******************************************************************************/

function validateSequenceNumberForPositve()
{
    //var cellData = getColumnDataAtLevel();
    var inputSequenceNumber = trim(arguments[0]);   
   
    if(!isNumeric(inputSequenceNumber)){
    alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        return false;
    }    
    if(isEmpty(inputSequenceNumber)){
          alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.checkBlankForSequenceNumber</emxUtil:i18nScript>");
            return false;
    }
    if(inputSequenceNumber<=0){
            alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceNumericPositive</emxUtil:i18nScript>");
            return false;
    }
    if(!isInteger(inputSequenceNumber)){
            alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.SequenceNumericDecimal</emxUtil:i18nScript>");
            return false;
    }
    return true;
}


function validateDesignUsage()
{
var currentCellValue    = trim(arguments[0]);
var currentRowId = currentRow.getAttribute("id");
var seperatorLastIndex = currentRowId.lastIndexOf(",");
var parentRowId = currentRowId.slice(0,seperatorLastIndex);

if(parentRowId != "0")
{
var objColumnSelectionType = colMap.getColumnByName("Selection Type");
var parentObjId = currentRow.getAttribute("p");

var ParentSelectionTypeValue="";
if(objColumnSelectionType == undefined){
  var url = "../configuration/LogicalFeatureAddExistingPreProcess.jsp";
  var queryString ="mode=getLFSelectionType&ParentObjId=" + parentObjId;
  var vRes = emxUICore.getDataPost(url,queryString);
  var iIndex = vRes.indexOf("SelectionType=");
  var iLastIndex = vRes.indexOf("#");
  ParentSelectionTypeValue = vRes.substring(iIndex+"SelectionType=".length , iLastIndex );
}else{
  ParentSelectionTypeValue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + parentRowId + "']/c["+objColumnSelectionType.index+"][@a]/text()");
}
if(ParentSelectionTypeValue == null)
{
   return true;
}
if(typeof ParentSelectionTypeValue ==  'object')
    {
      ParentSelectionTypeValue = ParentSelectionTypeValue.xml
    }
var selTypeSingle = "<emxUtil:i18nScript localize="i18nId">emxConfiguration.SelectionType.Single</emxUtil:i18nScript>";

if(ParentSelectionTypeValue == selTypeSingle)
   {
     if(currentCellValue == "Required")
     {
         alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.PFLUsage.Error.NotCompatible</emxUtil:i18nScript>");
         return false;
     }else{
         return true
     }
   }else{
     return true;
   }
}
else
{

return true;
}

}


function validateLogicalSelectionType()
{
     
     var currentRowId = currentRow.getAttribute("id");
     var objColumnPFLUsage = colMap.getColumnByName("PFLUsage");
     
     if(objColumnPFLUsage){
     
     var currentSelTypeValue = trim(arguments[0]);
     var PFLUsageRequired = "<emxUtil:i18nScript localize="i18nId">emxConfiguration.Range.FeatureUsage.Required</emxUtil:i18nScript>";
     if(typeof currentSelTypeValue ==  'object' && currentSelTypeValue!=null)
    {
      currentSelTypeValue = currentSelTypeValue.xml
      
    }
     var i=0;
     while(true)
     {
     
     var childRowId = currentRowId+","+i;
     var childPFLUsageValue = emxUICore.selectSingleNode(oXML.documentElement, "/mxRoot/rows//r[@id ='" + childRowId + "']/c["+objColumnPFLUsage.index+"][@a]/text()");
     if(childPFLUsageValue == null || childPFLUsageValue == undefined)
        {
           break;
        }
     else{
     if(typeof childPFLUsageValue ==  'object')
    {
      childPFLUsageValue = childPFLUsageValue.xml
      if(childPFLUsageValue == PFLUsageRequired && currentSelTypeValue == "Single")
      {
            alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.LogicalSelectionType.Error.NotCompatible</emxUtil:i18nScript>");
            return false;
      }
    }
        i++;
        }
     }
      }
     
     return true;
}

function removeActionIcon(href, actioCustom,strObjId)
{
    var contentFrameObj = "";
    var msg = "";
    var success = "";
    var warningMsg = "";
    try{
    if(actioCustom == "ActiveGBOM")
    {
        contentFrameObj =findFrame(getTopWindow(), "FTRContextInactiveParts");        
        warningMsg =  "<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.CannotReactivateReplacedParts</emxUtil:i18nScript>";

    }
    else{
    var alertMsg = "";
    if(actioCustom == "RemoveGBOM")
    {
    alertMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Remove</emxUtil:i18nScript>";
    contentFrameObj =findFrame(getTopWindow(), "FTRProductContextGBOMPartTable");
    warningMsg = "";
    }
    if(actioCustom == "InactiveGBOM")
    {
    alertMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.MakeInactivePart</emxUtil:i18nScript>";
    contentFrameObj =findFrame(getTopWindow(), "FTRProductContextGBOMPartTable");
    warningMsg =  "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CanOnlySelectPart</emxUtil:i18nScript>";

    }    
    msg = confirm(alertMsg); 
    }
    if(contentFrameObj==null)
    contentFrameObj =findFrame(getTopWindow(), "FTRContextGBOMPartTable");
     if(msg || actioCustom == "ActiveGBOM")
                      {  
        var temp = "/mxRoot/rows//r[@r ='" + strObjId + "']";
        var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,temp);
        var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
        var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
        var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
        var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
        var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId
        var prentRowIds = new Array(1);
        prentRowIds[0] = parentRowIDs;
        var paramSeparatorIdx = href.indexOf('?');
        var urlPage = href.substring(0, paramSeparatorIdx);
        var params = href.substring(paramSeparatorIdx + 1);
        success = emxUICore.getDataPost(urlPage, params); 
        var responseStatus = success.search(/responseMsg=true#/i);
        if(responseStatus > 0 || actioCustom == "RemoveGBOM"){
            contentFrameObj.emxEditableTable.removeRowsSelected(prentRowIds);
    		var cntFrame = findFrame(getTopWindow(), "content");
            if(cntFrame !== null && cntFrame !== undefined){
            if(actioCustom == "ActiveGBOM"){
            if(typeof cntFrame.addMultipleStructureNodes !== 'undefined' && 
                   typeof cntFrame.addMultipleStructureNodes === 'function')
    	        {
    		     cntFrame.addMultipleStructureNodes(oId, pId, '', '', false);
    	        }
            }else{
            if(typeof cntFrame.deleteObjectFromTrees !== 'undefined' && 
                   typeof cntFrame.deleteObjectFromTrees === 'function')
    	        {
    		     cntFrame.deleteObjectFromTrees(oId, false);
    	        }
    	      }
            }
        }
        else{
        if(actioCustom != "RemoveGBOM")
         alert(warningMsg);
      }
      }
      }
      catch (e){
      alert(e);
                      }
  }
  
function removeLeafLevelLF(level)
{
	var contentFrame   = findFrame(getTopWindow(),"listHidden");
	var rowIds = new Array();	
	rowIds[0]=level;
	contentFrame.parent.editableTable.cut(rowIds);
}

function addDuplicateRowForLF(level)
{
	var contentFrame   = findFrame(getTopWindow(),"listHidden");
	var rowIds = new Array();	
	rowIds[0]=level;
	contentFrame.parent.editableTable.copy(rowIds);
	var pasterowIds = new Array();	
	contentFrame.parent.editableTable.pasteBelow(rowIds);

          var xmlRef 	= contentFrame.parent.oXML;
          var rowRXML 	=	emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r[@id='"+level+"']");
		  var visualCue = '';
		  var partUsageColmn = '';
	      var stdActIcnColmn = '';
		   var cstActIcnColmn = '';
		   var ActionIcons = '';
          
          for(var k = 0; k < rowRXML.length; k++){
        	  var childNodes=rowRXML[k].childNodes;
			  var q = 0;
        	  for(var count1 = 0; count1 < childNodes.length ; count1++){
        		  if(childNodes[count1].tagName == "c"){
					  columnName = contentFrame.parent.colMap.getColumnByIndex(q).name;
					  if(columnName=='Visual Cue'){
						columnvalue = childNodes[count1].xml;
						visualCue = columnvalue;
					  } else if(columnName=='Force Part Reuse'){
						columnvalue = childNodes[count1].xml;
						partUsageColmn = columnvalue;
					  }else if(columnName=='Std Action Icons'){
						columnvalue = childNodes[count1].xml;
						stdActIcnColmn = columnvalue;
					  }else if(columnName=='Custom Actions Icons'){
						columnvalue = childNodes[count1].xml;
						cstActIcnColmn = columnvalue;
					  }else if(columnName=='ActionIcons'){
						columnvalue = childNodes[count1].xml;
						ActionIcons = columnvalue;
					  }
					  
					  q++;
        		  }
        	  }
          }
          // iterate if multiple adds
          var newRowXML 	=	emxUICore.selectNodes(xmlRef,"/mxRoot/rows//r[@status='add']");
          var visualCueColName = contentFrame.parent.colMap.getColumnByName("Visual Cue");
            var stdActIcnColmnName = contentFrame.parent.colMap.getColumnByName("Std Action Icons");
            var cstActIcnColmnName = contentFrame.parent.colMap.getColumnByName("Custom Actions Icons");          
			var partUsageColmnName = contentFrame.parent.colMap.getColumnByName("Force Part Reuse");
			var ActionIconsName = contentFrame.parent.colMap.getColumnByName("ActionIcons");   	
			
		  var tempLevel = level;
		  var newRowID = '';
          
          for(var kk = 0; kk < newRowXML.length; kk++){
        	  var childNodes=newRowXML[kk].childNodes;
        	  var rowId=newRowXML[kk].getAttribute("id");
			  var tempOriginalRow = (tempLevel.substr(tempLevel.lastIndexOf(",")+1,tempLevel.length)).replace(/,/g,"");
			  var currentRowId = (rowId.substr(rowId.lastIndexOf(",")+1,rowId.length)).replace(/,/g,"");

			  var correctOriginalRowId = (level.substr(0,level.lastIndexOf(","))).replace(/,/g,"");
			  var correctNewRowId = (rowId.substr(0,rowId.lastIndexOf(","))).replace(/,/g,"");
			  
			  if(parseInt(currentRowId)>parseInt(tempOriginalRow)&& parseInt(correctOriginalRowId)==parseInt(correctNewRowId)){
				tempLevel = currentRowId;
				newRowID = rowId;
			  }
			}
		  var stdAct = stdActIcnColmn.split(level);
		  stdActIcnColmn = stdAct.join(newRowID);

		  var custAct = cstActIcnColmn.split(level);
		  cstActIcnColmn = custAct.join(newRowID);

		  var visual = visualCue.split(level);
		  visualCue = visual.join(newRowID);
		  
		  cstActIcnColmn = cstActIcnColmn.replace(/IconSmallReplacePartNewPart/g, "iconSmallCreatePart");
		  cstActIcnColmn = cstActIcnColmn.replace(/Replace\sby\sCreate\sPart\sas\sCustom/g, "Create Part as Custom");
		  cstActIcnColmn = cstActIcnColmn.replace(/IconSmallReplacePartExistingPart/g, "IconSmallAddExistingPart");
		  cstActIcnColmn = cstActIcnColmn.replace(/Replace\sby\sAdd\sExisting\sPart\sas\sCustom/g, "Add Existing Part as Custom");
		  cstActIcnColmn = cstActIcnColmn.replace(/IconSmallReplaceNewGeneratedPart/g, "IconSmallGenerateParts");
		  cstActIcnColmn = cstActIcnColmn.replace(/Replace\sby\sGenerate\sPart\sas\sCustom/g, "Generate Part as Custom");
		 
		  stdActIcnColmn = stdActIcnColmn.replace(/IconSmallReplacePartNewPart/g, "iconSmallCreatePart");
		  stdActIcnColmn = stdActIcnColmn.replace(/Replace\sby\sCreate\sPart\sas\sDefault/g, "Create Part as Default");
		  stdActIcnColmn = stdActIcnColmn.replace(/IconSmallReplacePartExistingPart/g, "IconSmallAddExistingPart");
		  stdActIcnColmn = stdActIcnColmn.replace(/Replace\sby\sAdd\sExisting\sPart\sas\sDefault/g, "Add Existing Part as Default");
		  stdActIcnColmn = stdActIcnColmn.replace(/IconSmallReplaceNewGeneratedPart/g, "IconSmallGenerateParts");
		  stdActIcnColmn = stdActIcnColmn.replace(/Replace\sby\sGenerate\sPart\sas\sDefault/g, "Generate Part as Default");
		  
		  contentFrame.parent.editableTable.updateXMLByRowId(newRowID,visualCue,visualCueColName.index);
		  contentFrame.parent.editableTable.updateXMLByRowId(newRowID,stdActIcnColmn,stdActIcnColmnName.index);
		  contentFrame.parent.editableTable.updateXMLByRowId(newRowID,cstActIcnColmn,cstActIcnColmnName.index);      
		  contentFrame.parent.editableTable.updateXMLByRowId(newRowID,partUsageColmn,partUsageColmnName.index);
		  contentFrame.parent.editableTable.updateXMLByRowId(newRowID,ActionIcons,ActionIconsName.index);                	        
}	
getTopWindow().isgenerateBOMClicked=false;
function generateBOM(){
	if(!getTopWindow().isgenerateBOMClicked){
		getTopWindow().isgenerateBOMClicked = true;
		var objId = "";	
		var objForm = this.emxTableForm;
		for (var i=0; i < objForm.elements.length; i++) {
		      if(objForm.elements[i].name == "objectId"){
		      	objId = objForm.elements[i].value;
		      	break;
		      }
		}
		
		var frame = findFrame(getTopWindow(),"listHidden");
		submitWithCSRF("../configuration/PreviewBOMProcess.jsp?mode=generateEngineeringEBOM&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=" + objId+"&parentOID=" +objId,frame.window);
	}else{	
		alert(BOM_PROCESS_ALERT);
	}
	
}	

function refreshBOMVisualCue(){
  var contentFrame   = findFrame(getTopWindow(),"listHidden");
  var xmlRef 	= contentFrame.parent.oXML;
  var changedRXML 	=	emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r[@status='changed']");
  var bomAttributeOverrideName = contentFrame.parent.colMap.getColumnByName("IsComingFromGBOM");  
  var bomAttributeOverrideImage = '<c><img src="../common/images/iconSmallBOMAttributeOverride.gif"/></c>';
    for(var k = 0; k < changedRXML.length; k++){
    	var childNodes=changedRXML[k].childNodes;
    	var rowId=changedRXML[k].getAttribute("id");  	
    	var q = 0;
    	 
    	  for(var count = 0; count < childNodes.length ; count++){
        		  var IsEdited = childNodes[count].getAttribute("edited");
        		  if(childNodes[count].tagName == "c"){
        		  var columnName = contentFrame.parent.colMap.getColumnByIndex(q).name;
            		  if(IsEdited=='true' &&  (columnName=='FindNumber' || columnName=='Quantity' || columnName=='Usage' || columnName=='ReferenceDesignator')){
            			  contentFrame.parent.editableTable.updateXMLByRowId(rowId,bomAttributeOverrideImage,bomAttributeOverrideName.index);     			
            		  }
            		}
            		q++;
         }
    }
  emxEditableTable.performXMLDataPost();                      
  return "";                      
}

/**
* This function is use to validate Default Selection Column Values. 
* 
*/

function validateDefaultSelectionValue(){

 	//-----------------------------------------------------------------------------------
 	//getting Default selection value Yes/No from SB UI--
 	//current change is missing in this list
 	//-----------------------------------------------------------------------------------
 	var varObjType   = currentRow.getAttribute("type");
 	var varParentId  = currentRow.getAttribute("p");
 	if(varObjType == "Variability Option"){
 	    return true;
 	}
 	else if(varObjType == "Variant Value")
 	{
 	    var columnVals = getActualDefaultSelectionValue();
		//-----------------------------------------------------------------------------------
	 	//need to reset SB UI Default selection value with new value from argument
	 	//-----------------------------------------------------------------------------------
	 	//console.log("beforemodifycolumnvalue"+columnVals);
	 	if(currentCell.target){//current cell modifying
			var rmbrow = currentCell.target.getAttribute("rmbrow");//here 3rd value(2nd index) value is change which need to updated in columnVals
			var strText1= [];
			strText1 = rmbrow.split(",");
			var l1 = "";
			if(strText1.length == 2){
			   l1 = strText1[1];
			}else{
			   l1 = strText1[2];
			}
			columnVals[l1]=trim(arguments[0]);// will replace value at index l1 with value from argument
			//console.log("aftermodifycolumnvalue"+columnVals);
			var flag = false;
			var temp1=0;
			for(var i = 0; i< columnVals.length ; i++){
				if("Yes"==columnVals[i] || varYesDefaultSelection==columnVals[i]){ 
					temp1++;
					if(temp1>=2){
						flag=true;
						break;
					}
				}
		    }
		}
		 	
 	}
 	else if(varObjType == "Configuration Option")
 	{
 	    // Call to get Selection Type for Configuration Feature
        var vRes = emxUICore.getDataPost("../configuration/ConfigurationFeaturePreProcess.jsp","mode=getSelectionType&ConfFeatId="+varParentId);
        var iIndex = vRes.indexOf("SelectionType=");
		var iLastIndex = vRes.indexOf(";");
		var selectionType = vRes.substring(iIndex + "SelectionType=".length, iLastIndex);
        selectionType = selectionType.trim();
        
 		var columnVals = getActualDefaultSelectionValue();
		//-----------------------------------------------------------------------------------
	 	//need to reset SB UI Default selection value with new value from argument
	 	//-----------------------------------------------------------------------------------
	 	//console.log("beforemodifycolumnvalue"+columnVals);
	 	if(currentCell.target){//current cell modifying
			var rmbrow = currentCell.target.getAttribute("rmbrow");//here 3rd value(2nd index) value is change which need to updated in columnVals
			var strText1= [];
			strText1 = rmbrow.split(",");
			var l1 = "";
			if(strText1.length == 2){
			   l1 = strText1[1];
			}else{
			   l1 = strText1[2];
			}
			columnVals[l1]=trim(arguments[0]);// will replace value at index l1 with value from argument
			//console.log("aftermodifycolumnvalue"+columnVals);
			var flag = false;
			var temp1=0;
			for(var i = 0; i< columnVals.length ; i++){
				if("Yes"==columnVals[i] || varYesDefaultSelection==columnVals[i]){ 
					temp1++;
					if(temp1>=2 && "Single"==selectionType){
						flag=true;
						break;
					}
				}
		    }
		}
 	}
 	
 	if (flag) {//if Yes value more than 1 and selection type is single- give alert
		alert("<%=i18nStringNowUtil("emxConfiguration.Alert.DefaultSelectionValueConfirm","emxConfigurationStringResource",context.getSession().getLanguage())%>");
		return false;
	}
 	 
 	return true;
 	
}
 


/**
 * This function is use to get all Default Selection Column Values of Configuration Options of Current Configuration Feature..
 * This function returns array of Default Selection Column Values.
*/
 
function getActualDefaultSelectionValue(){
    var level = currentRow.getAttribute("level");
    var xpath = "r";
    var aRowsAtLevel = null;
    if (level == "0") {
        aRowsAtLevel = emxUICore.selectNodes(oXML, "/mxRoot/rows/r");
    } else {
        aRowsAtLevel = emxUICore.selectNodes(currentRow.parentNode, "r");
    }

    var colIndex = currentColumnPosition;
    
    var returnArray = new Array();
    for(var i=0;i < aRowsAtLevel.length; i++){
        if(emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("edited")=="true") 
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("newA");
        else
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("a");
    }
    return returnArray;
}

/**
*  This function is use to validate Selection Type Column Value for Current Configuration Feature.
*
*/

function validateSelectionTypeValue(){
 	//-----------------------------------------------------------------------------------
 	//getting Default Selection Type value for current modified row ---------------------
 	//-----------------------------------------------------------------------------------
 	var columnDefaultSelectionVals = getActualDefaultSelectionTypeValue();
 	//console.log("columnDefaultSelectionVals-->"+columnDefaultSelectionVals);
 	var SelectionTypeValue = "";
 	var colIndex = colMap.getColumnByName("Selection Type").index;
 	SelectionTypeValue = trim(arguments[0]);//curent updated selection type from arugument
  	var flag = false;
  	var temp1=0;
  	for(var i = 0; i< columnDefaultSelectionVals.length ; i++){
		 if(varYesDefaultSelection==columnDefaultSelectionVals[i] || "Yes" == columnDefaultSelectionVals[i] ){
			  temp1++;
			  if(temp1>=2 && (SelectionTypeValue == 'Single' || SelectionTypeValue == varSingleSelect )){
				   flag=true;
				   break;
			 }
		}
	}
    if (flag) {
	 alert("<%=i18nStringNowUtil("emxConfiguration.Alert.DefaultSelectionValueConfirm","emxConfigurationStringResource",context.getSession().getLanguage())%>");
	 return false;
    } 
    return true;
}


/**
 *  This function is use to get all Default Selection Column Values of Configuration Options of Current Configuration Feature.
 *  This function returns array of Default Selection Column Values.
*/
 
function getActualDefaultSelectionTypeValue(){
    var level = currentRow.getAttribute("level");
    var xpath = "r";
    var aRowsAtLevel = null;
    
    aRowsAtLevel = emxUICore.selectNodes(currentRow, "r");
    var colIndex = colMap.getColumnByName("Default Selection").index;
    
    var returnArray = new Array();
    for(var i=0;i < aRowsAtLevel.length; i++){
        if(emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("edited")=="true") 
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("newA");
        else
        returnArray[i] = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + colIndex + "]").getAttribute("a");
    }
    
    return returnArray;
    
}

getTopWindow().isPBOMApplyClicked=false;
function previewBOMApply(){
	if(!getTopWindow().isPBOMApplyClicked){
		getTopWindow().isPBOMApplyClicked = true;
		var objId = "";	
		var objForm = this.emxTableForm;
		for (var i=0; i < objForm.elements.length; i++) {
		      if(objForm.elements[i].name == "objectId"){
		      	objId = objForm.elements[i].value;
		      	break;
		      }
		}
		
		var frame = findFrame(getTopWindow(),"listHidden");
		submitWithCSRF("../configuration/PreviewBOMProcess.jsp?mode=apply&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&objectId=" + objId+"&parentOID=" +objId,frame.window);
	}else{	
		alert(BOM_PROCESS_ALERT);
	}
	
}
function quickActionsDV(href, actioCustom,strObjId)
{
    var contentFrameObj = "";
    var msgFrozen = "";
    msgFrozen = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.DVActionsDisabledReleasedorBeyond</emxUtil:i18nScript>";
    var msgNoModify = "";
    msgNoModify = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.nochangetype</emxUtil:i18nScript>";

    var success = "";
    var warningMsg = "";
    try{
        if(actioCustom == "RemoveDV"){
			warningMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Remove</emxUtil:i18nScript>";
			contentFrameObj =findFrame(getTopWindow(), "slideInFrame");
		}
		if(actioCustom == "ToggleDVToInactive")
		{
			warningMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.ConfirmToMakeDVInactive</emxUtil:i18nScript>";
			contentFrameObj =findFrame(getTopWindow(), "slideInFrame");
		}
		if(actioCustom == "ToggleDVToActive")
		{
			warningMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.ConfirmToMakeDVActive</emxUtil:i18nScript>";
			contentFrameObj =findFrame(getTopWindow(), "slideInFrame");
		}     
		msg = confirm(warningMsg); 
		if(msg){  
			var temp = "/mxRoot/rows//r[@r ='" + strObjId + "']";
			var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,temp);
			var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
			var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
			var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
			var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
			var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId
			var prentRowIds = new Array(1);
			prentRowIds[0] = parentRowIDs;
			var paramSeparatorIdx = href.indexOf('?');
			var urlPage = href.substring(0, paramSeparatorIdx);
			var params = href.substring(paramSeparatorIdx + 1);
			success = emxUICore.getDataPost(urlPage, params); 
			var responseStatus = success.search(/responseMsg=true#/i);
			var responseStatusFrozen = success.search(/responseMsg=FROZEN#/i);
			var responseStatusNOMODIFY = success.search(/responseMsg=NOMODIFY#/i);
			if(responseStatusFrozen > 0 ){
			  alert(msgFrozen);
			}else if(responseStatusNOMODIFY > 0 ){
			  alert(msgNoModify);
			}else{
				if(responseStatus > 0 && actioCustom == "RemoveDV")
				 contentFrameObj.emxEditableTable.removeRowsSelected(prentRowIds);
				else if(responseStatus > 0 && (actioCustom == "ToggleDVToActive"||actioCustom == "ToggleDVToInactive")){
	             contentFrameObj.editableTable.loadData();
	             contentFrameObj.rebuildView();
				}else{
					var iIndex = success.indexOf("responseMsg=");
		            var iLastIndex = success.indexOf("#");
		            var actualString = success.substring(iIndex+"responseMsg=".length , iLastIndex );
		            if(actualString != null)
				    alert(actualString);
				}
		  }
		 }
    }catch (e){
      alert(e);
    }
}

function showheader()
{
var hv = $('#dvMode').val();
if(hv === "slideindv"){
	setTimeout(function(){
		$("#contentHeader").css('display', 'inline-block');
		var closeHeight = $('#pageHeadDiv').height() + "px";
		$("#mx_divBody").css("top",closeHeight);
	}, 500);
 }
}

emxUICore.addEventHandler(window, "DOMContentLoaded", showheader);

/**
 * This method is used to refresh the Structure Tree on Add/Remove of Objects.
 * For Logical Features, Manufacturing Features, Configuration Features, Configuration Options
*/

function refreshTreeForAddObj(xmlResponse,type)
{
   
   // Below code is used to refresh Structure Tree
   var cntFrame;
   if(type == "Logical Feature"){
     cntFrame = getTopWindow().findFrame(getTopWindow(),"FTRContextLFLogicalFeatures");  
     if(cntFrame == undefined || cntFrame == null){
     cntFrame = getTopWindow().findFrame(getTopWindow(),"FTRSystemArchitectureLogicalFeatures");
     }
   }
   if(type == "Manufacturing Feature"){
     cntFrame = getTopWindow().findFrame(getTopWindow(),"FTRMFContextManufacturingFeatures");  
     if(cntFrame == undefined || cntFrame == null){
     cntFrame = getTopWindow().findFrame(getTopWindow(),"FTRSystemArchitectureManufacturingFeatures");
     }
   }
   if(type == "Variant" || type == "Variability Group"){
     cntFrame = getTopWindow().findFrame(getTopWindow(),"detailsDisplay");
   }
   var oXML           = "";
   var NewlyAddedRows = new Array();
   var editedRows     = new Array();
   if(cntFrame != undefined && cntFrame != null){
   oXML           = cntFrame.oXML;
   NewlyAddedRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@status='add' or @status='cut']");
   editedRows     = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@status='changed']");
   }
                
   // Updated the edited rows.
   
   for(var k = 0; k < editedRows.length; k++){
    	var aRows=editedRows[k]; 
	    aRows.removeAttribute("status");  
        for(var j = 0 ; j < aRows.childNodes.length ; j++)	
        {
			 var value = emxUICore.getText(aRows.childNodes[j]);
			 if(aRows.childNodes[j].tagName =="c"){
			  aRows.childNodes[j].setAttribute("a",value);
			 }
			 aRows.childNodes[j].setAttribute("edited","false");
        }		
   }
                                       
   // Below code is used to Add and Remove node from Tree
   
   var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");                    
   for(var i = 0; i < NewlyAddedRows.length; i++){
		var objectId = NewlyAddedRows[i].getAttribute("o");
		var parentId = NewlyAddedRows[i].getAttribute("p");
        var status   = NewlyAddedRows[i].getAttribute("status");	
        
        if(status == "add"){
		contentFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
		}
		else if(status == "cut"){
		contentFrame.deleteObjectFromTrees(objectId, false);
		}
   }
        
   // Below code is used to save Mark Up and update oXML On Structure Browser. 
   arrUndoRows = new Object();
   var aMassUpdate = new Array();   
           
   updateoXML(xmlResponse);
   postDataXML.loadXML("<mxRoot/>");
      
   rebuildView();            
}

function showReplaceBySelector(strobjectId,parentOID,strTypes,policyType,partState,strTimeStamp,strConnectionId)
{
    var sURL="../common/emxFullSearch.jsp?objectId="+strobjectId+
		"&excludeOID="+strobjectId+
		"&contextObjectId="+parentOID+
		"&suiteKey=Configuration"+
		"&field=TYPES="+strTypes+":POLICY!="+policyType+":CURRENT!="+partState+
		"&table=PLCSearchPartsTable"+
		"&Suite=Configuration"+
		"&selection=single"+
		"&hideHeader=true"+
		"&HelpMarker=emxhelpfullsearch"+
	    "&submitURL=../configuration/GBOMReplacePostProcess.jsp&submitAction=doNothing&mode1=ActionIcon&relId="+strConnectionId+
		"&suiteKey=configuration&SuiteDirectory=configuration&parentOID="+parentOID+
		"&timestamp="+strTimeStamp+
		"&objectId="+strobjectId;
    showChooser(sURL, 850, 630);
}
function showAlertAfterPCClone(alertMessage)
{
	if(alertMessage != undefined && alertMessage != null && alertMessage != ""){
	alert(alertMessage);
	}
}

/**
 * This function is used to show or render the Create Variant Value Icon for Variant.
 * This function will get call in Product Line/Model/Model Version for Variability Category. 
*/

function showCreateVariantValueSlideIn(strObjectId,strCtxObjectId)
{

    var sURL= "../common/emxCreate.jsp?objectId="+strObjectId+"&type=type_VariantValue&showApply=true&typeChooser=false&autoNameChecked=false"
         + "&nameField=both&submitAction=none&vaultChooser=true&form=type_CreateVariantValue&header=emxConfiguration.Form.Heading.CreateVariantValue"
         + "&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariantValue"
         + "&HelpMarker=emxhelpvariantvaluecreate&policy=policy_ConfigurationOption&postProcessURL=../configuration/VariantValueCreatePostProcess.jsp?objectId="+strObjectId+"&parentOID="+strObjectId+"&contextObjID="+strCtxObjectId+"&UIContext=context";

    getTopWindow().showSlideInDialog(sURL, 850, 630);
}

/**
 * This function is used to show or render the Create Variability Option Icon for Variability Group.
 * This function will get call in Product Line/Model/Model Version for Variability Category. 
*/

function showCreateVariabilityOptionSlideIn(strObjectId,strCtxObjectId)
{
    var sURL= "../common/emxCreate.jsp?objectId="+strObjectId+"&type=type_VariabilityOption&showApply=true&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=none"
         + "&vaultChooser=true&form=type_CreateVariabilityOption&header=emxConfiguration.Form.Heading.CreateVariabilityOption&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource"
         + "&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariabilityOption"
         + "&HelpMarker=emxhelpvariantoptioncreate&policy=policy_ConfigurationOption&postProcessURL=../configuration/VariabilityOptionCreatePostProcess.jsp?objectId="+strObjectId+"&parentOID="+strObjectId+"&contextObjID="+strCtxObjectId+"&UIContext=context";
    getTopWindow().showSlideInDialog(sURL, 850, 630);
}

/**
 * This function is used to show or render the Create Configuration Option Icon for Configuration Feature.
 * This function will get call in Product Line/Model/Model Version for Variability Category. 
*/

function showCreateConfigurationOptionSlideIn(strObjectId,strCtxObjectId)
{
    var sURL= "../common/emxCreate.jsp?objectId="+strObjectId+"&type=type_ConfigurationOption&showApply=true&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=none"
         + "&vaultChooser=true&form=type_ConfigurationOptionCreate&header=emxConfiguration.Form.Heading.OptionCreate&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource"
         + "&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createAndConnectConfigurationOption"
         + "&HelpMarker=emxhelpconfigurationoptioncreate&policy=policy_ConfigurationOption&postProcessURL=../configuration/ConfigurationFeatureCreatePostProcess.jsp?objectId="+strObjectId+"&parentOID="+strObjectId+"&contextObjID="+strCtxObjectId+"&UIContext=context";
    getTopWindow().showSlideInDialog(sURL, 850, 630);
}

/**
 * This function is used to Allocate/De-allocate Configuration Options on Model Version.
 * This function will get call in Model Version context for Allocation Matrix. 
*/

function toggleAllocation(rowId)
{
   current = document.getElementById(rowId);
   var isChecked = false;
   if(current.checked==true){
	   isChecked = true;
   }
   else if(current.checked==false){
	   isChecked = false;
   }
   
  var warningMsg = "";   
  var url = "../configuration/ToggleAllocation.jsp";
  var queryString ="mode=toggleAllocation&rowId=" + rowId + "&isChecked=" + isChecked;
  var vRes = emxUICore.getDataPost(url,queryString);
  var iIndex = vRes.indexOf("toggleAllocation=");
  var iLastIndex = vRes.indexOf("$");
  isToggleAllocationSuccessful = vRes.substring(iIndex+"toggleAllocation=".length , iLastIndex );
  if(isToggleAllocationSuccessful == 'SUCCESS'){
       return true;
   }else{
       current.checked = !isChecked;
       warningMsg = "<emxUtil:i18nScript localize="i18nId">emxProduct.VariabilityAllocation.Alert.ToggleAllocationFailed</emxUtil:i18nScript>";
       alert(warningMsg +" "+ isToggleAllocationSuccessful);
       return false;
   }
}

function configurationFeatureCopyOperation() {

    var resXML;
    var selectedStuff = '';
    var isFromPropertyPage;
    var i = 0;
    var url = '../configuration/ConfigurationFeatureCopyToPostProcess.jsp?';
    var firstChannelFrame = getTopWindow().frames['portalDisplay'].frames['FTRConfigurationFeatureCopyToFirstStep'];
    var firstStepFrame = firstChannelFrame.document.forms['ProductCopy'];

    isFromPropertyPage = firstStepFrame.isFromPropertyPage.value;
    url = url + '&isFromPropertyPage=' + isFromPropertyPage;
    if (firstStepFrame.Clone.checked == 0) {
        url = url + '&clone=off&share=on';
    } else {
        url = url + '&clone=on&share=off';
    }
    while (typeof(firstStepFrame[i]) !== 'undefined') {
        if (firstStepFrame[i].type == 'checkbox') {
            if (firstStepFrame[i].checked == 0) {
                var temp = '&' + firstStepFrame[i].name + '=off';
                url += temp;
            } else {
                var temp = '&' + firstStepFrame[i].name + '=on'
                url += temp;
            }
        }
        i++;
    }
    var temp_oXML = oXML;
    var aSelectedCheckboxes = emxUICore.selectNodes(temp_oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
    for (var n = 0; n < aSelectedCheckboxes.length; n++) {
        var objID = aSelectedCheckboxes[n].getAttribute('o');
        var relID = aSelectedCheckboxes[n].getAttribute('r');
        var levelID = aSelectedCheckboxes[n].getAttribute('id');
        var parentID = aSelectedCheckboxes[n].getAttribute('p');
        selectedStuff += '&emxTableRowId=' + relID + '|' + objID + '|' + parentID + '|' + levelID;
    }
    url = url + selectedStuff;
    var xml = emxUICore.getDataPost(url);
    if (xml.match('mxRoot')) {
        //------------------
        var bcrExp = "";
        var resXMLBefore = ""
        if (xml.match('ALERT_DUP::')) {
            var iIndex = xml.indexOf('ALERT_DUP::=');
            var iLastIndex = xml.indexOf('#');
            bcrExp = xml.substring(iIndex + 'ALERT_DUP::='.length, iLastIndex);
            resXMLBefore = xml.substring(iLastIndex + 1, xml.length);
            resXML = resXMLBefore.split('^');
        } else {
            resXML = xml.split('^');
        }
        for (var i = 0; i < resXML.length; i++) {
            self.emxEditableTable.addToSelected(resXML[i]);
        }
        //------------------
        if (bcrExp != "") {
            alert(bcrExp);
        }
        //------------------        
    } else if (xml.match('CONFIRM::')) {
        xml = xml.replace('CONFIRM::', '');
        var msg = confirm(xml);
        if (!msg) {} else {
            url = url + '&RDO=YES';
            xml = emxUICore.getDataPost(url);
            if (xml.match('mxRoot')) {
                resXML = xml.split('^');
                for (var i = 0; i < resXML.length; i++) {
                    self.emxEditableTable.addToSelected(resXML[i]);
                }
            } else {
                alert(xml);
            }
        }
    }else if (xml.match('ALERT_DUP::')) {
	            var iIndex = xml.indexOf('ALERT_DUP::=');
	            var iLastIndex = xml.indexOf('#');
	            bcrExp = xml.substring(iIndex + 'ALERT_DUP::='.length, iLastIndex);
	          alert(bcrExp);
    }else {
        alert(xml);
    }
}

function logicalFeatureCopyOperation() {

    var resXML;
    var selectedObjId;
    var isFromPropertyPage;
    var selectedStuff = '';
    var i = 0;
    var url = '../configuration/LogicalFeatureCopyToPostProcess.jsp?';
    var firstChannelFrame = getTopWindow().frames['portalDisplay'].frames['FTRLogicalFeatureCopyToFirstStep'];
    var firstStepFrame = firstChannelFrame.document.forms['ProductCopy'];
    selectedObjId = firstStepFrame.txtToFeatureId.value;
    isFromPropertyPage = firstStepFrame.isFromPropertyPage.value;
    url = url + 'objectId=' + selectedObjId + '&isFromPropertyPage=' + isFromPropertyPage;
    if (firstStepFrame.Clone.checked == 0) {
        url = url + '&clone=off&share=on';
    } else {
        url = url + '&clone=on&share=off';
    }
    while (typeof(firstStepFrame[i]) !== 'undefined') {
        if (firstStepFrame[i].type == 'checkbox') {
            if (firstStepFrame[i].checked == 0) {
                var temp = '&' + firstStepFrame[i].name + '=off';
                url += temp;
            } else {
                var temp = '&' + firstStepFrame[i].name + '=on';
                url += temp;
            }
        }
        i++;
    };
    var temp_oXML = oXML;
    var aSelectedCheckboxes = emxUICore.selectNodes(temp_oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
        for (var n = 0; n < aSelectedCheckboxes.length; n++) {
            var objID = aSelectedCheckboxes[n].getAttribute('o');
            var relID = aSelectedCheckboxes[n].getAttribute('r');
            var levelID = aSelectedCheckboxes[n].getAttribute('id');
            var parentID = aSelectedCheckboxes[n].getAttribute('p');
            selectedStuff += '&emxTableRowId=' + relID + '|' + objID + '|' + parentID + '|' + levelID;
        }
        url = url + selectedStuff;
        var xml = emxUICore.getDataPost(
            url);
            
        if (xml.match('mxRoot')) {
            //--------
	        var bcrExp = "";
	        var resXMLBefore = ""
	        if (xml.match('ALERT_DUP::')) {
	            var iIndex = xml.indexOf('ALERT_DUP::=');
	            var iLastIndex = xml.indexOf('#');
	            bcrExp = xml.substring(iIndex + 'ALERT_DUP::='.length, iLastIndex);
	            resXMLBefore = xml.substring(iLastIndex + 1, xml.length);
	            resXML = resXMLBefore.split('^');
	        } else {
	            resXML = xml.split('^');
	        }
            for (var i = 0; i < resXML.length; i++) {
                self.emxEditableTable.addToSelected(resXML[i]);
            }
            //------------------
	        if (bcrExp != "") {
	            alert(bcrExp);
	        }
            //------------------  
        } else if (xml.match('CONFIRM::')) {
            xml = xml.replace('CONFIRM::', '');
            var msg = confirm(xml);
            if (!msg) {} else {
                url = url + '&RDO=YES';
                xml = emxUICore.getDataPost(url);
                if (xml.match('mxRoot')) {
                    resXML = xml.split('^');
                    for (var i = 0; i < resXML.length; i++) {
                        self.emxEditableTable.addToSelected(resXML[i]);
                    }
                } else {
                    alert(xml);
                }
            }
        }else if (xml.match('ALERT_DUP::')) {
	            var iIndex = xml.indexOf('ALERT_DUP::=');
	            var iLastIndex = xml.indexOf('#');
	            bcrExp = xml.substring(iIndex + 'ALERT_DUP::='.length, iLastIndex);
	          alert(bcrExp);
        } 
        else {
            alert(xml);
        }
    }
