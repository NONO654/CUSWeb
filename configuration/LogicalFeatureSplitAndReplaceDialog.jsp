<%--
  LogicalFeatureSplitAndReplaceDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<html>
<%@include file="emxValidationInclude.inc"%>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.*"%>

<body>
<%
String functionality = emxGetParameter (request,"functionality") ;
String strObjectId    = emxGetParameter(request, "objectId");

%>
<script type="text/javascript">
var action = "<%= XSSUtil.encodeForJavaScript(context,functionality )%>";
</script>
<%

String strName =  "";
StringList strLstIncludeData = new StringList();
String IncludedData=EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.SplitAndRepalce.IncludedData");

StringTokenizer st = new StringTokenizer(IncludedData,",");

while(st.hasMoreTokens())
{
  String Value = st.nextToken();
  strLstIncludeData.add(Value);
}

String strMaxNoObj = EnoviaResourceBundle.getProperty(context,"emxProduct.Value.MaxNoOfObjects");
strName = new DomainObject (strObjectId).getAttributeValue(context, "Display Name") ;

com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean () ;
formBean.processForm (session, request) ;
String strObjId = null ;
    
String strProductId = emxGetParameter(request, "parentOID");
String strRelId = emxGetParameter(request, "RelId");
%>
<script type="text/javascript">
   var objID = "<%= XSSUtil.encodeForJavaScript(context,strObjId)%>";
</script>

<form name="SplitAndReplaceFeature" method="post" action=javascript:moveNext()><input type="hidden" name="sourceObjectId" value="<xss:encodeForHTMLAttribute><%=strObjectId %></xss:encodeForHTMLAttribute>" />
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
<table border="0" cellpadding="5" cellspacing="2" width="100%" >
    <%-- Display the input fields. --%>
    <tr>
        <td width="150" nowrap="nowrap" class="label"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.SourceFeature</emxUtil:i18nScript></td>
        <td nowrap="nowrap" class="field"><%=strName%><input type="hidden" name="sourceFeature" value="<xss:encodeForHTMLAttribute><%=strName %></xss:encodeForHTMLAttribute>"/></td>
    </tr>
    <tr>
        <td width="150" nowrap="nowrap" class="label" rowspan="1"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.NoofObjects</emxUtil:i18nScript></td>
        <td nowrap="nowrap" class="field"><input type="text"
            name="numberOfInstance" size="20"           
            value='1' /></td>
    </tr>
    <tr>
        <td width="150" nowrap="nowrap" class="label" rowspan="3"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.Includes</emxUtil:i18nScript></td>
    </tr>
    <tr>
        <td nowrap="nowrap" class="field"><emxUtil:i18nScript localize="i18nId">emxConfiguration.Form.Label.LogicalFeatures</emxUtil:i18nScript></td>

    </tr>
    <tr>
        <td nowrap="nowrap" class="field"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.DesignVariants</emxUtil:i18nScript></td>
    </tr>
    <tr>
        <td width="150" nowrap="nowrap" class="label" rowspan="8"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.IncludeRelatedData</emxUtil:i18nScript></td>
    </tr>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox" name="All"
            size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.All</emxUtil:i18nScript></td>
    </tr>
    <%
    if(strLstIncludeData.contains("Specifications"))
    {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="Specification" size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.Specification</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    if(strLstIncludeData.contains("Reference Documents"))
    {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="Refrence_Documents" size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.ReferenceDocuments</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    if(strLstIncludeData.contains("UseCases"))
    {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="Use_Cases" size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.UseCases</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    if(strLstIncludeData.contains("TestCases"))
    {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="Test_Cases" size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.TestCases</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    if(strLstIncludeData.contains("Images"))
    {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox" name="Images"
            size="20" onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.Images</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    if(strLstIncludeData.contains("Configuration Rules"))
    {
    %>      
     <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox" name="Configurable_Rules" size="20" 
            onclick="checkAll(this)" /><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.ConfigurableRules</emxUtil:i18nScript></td>
    </tr>
    <%
    }
    %>
</table>
</form>

<script language="javascript" type="text/javaScript">
  //<![CDATA[

  var  formName = document.SplitAndReplaceFeature;

  function validateInstance(instance)
  { 
   var noOfInstances = instance.value;
   var maxNoOfObjs = <%=XSSUtil.encodeForJavaScript(context,strMaxNoObj)%>;
   var mssgLessThan = "<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.ReplaceSplitDialog</emxUtil:i18nScript> "+maxNoOfObjs+".";
   
   if(noOfInstances>0)
   {
     if(noOfInstances<=maxNoOfObjs)
     {
        var DecimalFound = false
        for (var i = 0; i < noOfInstances.length; i++) {
            var ch = noOfInstances.charAt(i)            
            if (ch == "." && !DecimalFound) {
                  DecimalFound = true;
                  continue;
            }
         }
         if (DecimalFound)  
         { 
           alert(mssgLessThan);
           return false;
         }
         else
         {
           return true;
         }
     }
     else
     {       
       alert(mssgLessThan);      
       return false;
     }
   }
   else
   {
      alert(mssgLessThan);
      return false;
   }
  }

  function checkAll(element)
  { 
    var input = document.getElementsByTagName("input");    
    var status = element.checked;
     var otherStatus = element.checked;    
    var all = element; 
     
    try{
   
    for (var i = 0; i<input.length ; i++) 
    { 
      if(input[i].type=='checkbox')
      {
         if(input[i].name!= 'All' && otherStatus==true )
             otherStatus = input[i].checked;
         if(element.name=='All' )
           input[i].checked=status;  
         else
         {
             if(input[i].name=='All' && input[i].checked == true)
               input[i].checked = status; 
             else if(input[i].name=='All' && input[i].checked == false)
               all = input[i];
         }  
       }
     }     
     if(otherStatus == true )
       all.checked = true;  
     }  
      catch(e)
      {
       alert(e.message);
      }   
  }

  
 //when 'Cancel' button is pressed in Dialog Page
 function closeWindow()
 {
    parent.window.close();
 }
 
 function moveNext()
 {
    var formName = document.SplitAndReplaceFeature;
    if(validateInstance(formName.numberOfInstance))
    {
            var tableRowIds="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>"; 
            var submitURL;
            
            formName.method = "post";
        // Modified for bug 373918
            submitURL='../configuration/LogicalFeatureSplitReplaceStepOneProcess.jsp?mode=SplitReplace&Step=IncludeData&RelId=<%=XSSUtil.encodeForURL(context,strRelId)%>&prodId=<%=XSSUtil.encodeForURL(context,strProductId)%>';  
            formName.action=submitURL; 
            formName.submit();  
            self.close();                  
     }    
   }

    //When Enter Key Pressed on the form
   function submitForm()
   {
       var formName = document.SplitAndReplaceFeature;
     if(validateInstance(formName.numberOfInstance))
     {         
            var tableRowIds="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";  
            var submitURL;
            
            formName.method = "post";
            submitURL='../configuration/LogicalFeatureSplitReplaceStepOneProcess.jsp?mode=SplitReplace&Step=IncludeData';   
            formName.action=submitURL;             
            formName.submit();  
            self.close(); 
     }
   }

   
  //]]>
  </script>
 </body>
 </html>

