<%--  PrimaryImageInclude.inc

Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,
Inc.  Copyright notice is precautionary only and does not evidence any actual
or intended publication of such program.

static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/PrimaryImageInclude.inc 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$"
--%>
<%@page import="com.matrixone.apps.domain.*"%> 

<%

com.matrixone.apps.productline.Image imageBean1 = new com.matrixone.apps.productline.Image();
//Getting the parent object id of Image object
String strParentPrimaryImageOjectId = emxGetParameter(request,"objectId");
//If the mode is FormImage i.e if the Image properties page needs to be displayed
//the primary image object ID will be null and the parent object ID is used instead.
String mode = emxGetParameter(request,"mode");
//Calling the primaryImageObjectId Method of Image.java to get object id of Primary Image
String strPrimaryImageObjectId = imageBean1.primaryImageObjectId(context,strParentPrimaryImageOjectId);
String strFormName = XSSUtil.encodeForURL(context,emxGetParameter(request,"form"));
String strActionBarName = emxGetParameter(request,"actionBarName");
String strFormMode = emxGetParameter(request,"formMode");
if (strFormMode==null){
    strFormMode = "";
}
//String to store the value of the url for the primary image
String strPrimaryUrl ="";

//String to store the total url
String strURL ="";

//StringBuffer for passing the parameters
StringBuffer sQueryString = new StringBuffer("");
  Enumeration eNumParameters = emxGetParameterNames(request);
  while( eNumParameters.hasMoreElements() ) {
    String strParamName = (String)eNumParameters.nextElement();
    String strParamValue = emxGetParameter(request, strParamName);
    if (strParamName.equalsIgnoreCase("mode")) continue;
    else sQueryString.append("&" + strParamName + "=" + XSSUtil.encodeForURL(context,strParamValue));
  }

if (strFormMode.equals("Edit") && strPrimaryImageObjectId.length()==0 && !(mode.equals("FormImage")))
{
    strURL = "../common/emxForm.jsp?form="+strFormName+"&editLink=false";
  sQueryString.append("&mode=edit");  
  strURL = strURL + sQueryString;
}
    
//special processing for display of image form
else if(strFormMode.equals("Edit")){
    //Calling the downloadImageFile Method of Image.java to get details about the object
    if(mode.equals("FormImage")){
        strPrimaryImageObjectId = strParentPrimaryImageOjectId;
    }
  Map fileDetailMap = imageBean1.downloadImageFile(context,strPrimaryImageObjectId);
  StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
  String strFile = (String)(strFileList.get(0));
  String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));  
  strPrimaryUrl = "../components/emxComponentsCheckout.jsp?objectId="+ strPrimaryImageObjectId + "/" + strFile +
    "?format=" +  strFormat +
    "&attachment=" + "true" +
    "&file=" +  strFile ;
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = "../" + strPrimaryUrl;  
  // getting the querystring for passing to form jsp
  strURL = "../common/emxForm.jsp?form="+strFormName+"&editLink=false";
  sQueryString.append("&mode=edit");  
  strURL = strURL + sQueryString;
  strURL = strURL + "&strPrimaryUrl=" + strPrimaryUrl;
}//special processing for display of image form

//if a image connected to parent is primary image
else if (strPrimaryImageObjectId!=null && strPrimaryImageObjectId.length()!=0)
{
  //Calling the downloadImageFile Method of Image.java to get details about the object
  Map fileDetailMap = imageBean1.downloadImageFile(context,strPrimaryImageObjectId);
  StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
  String strFile = (String)(strFileList.get(0));
  String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT));  
  strPrimaryUrl = "../components/emxComponentsCheckout.jsp?objectId=" + strPrimaryImageObjectId + "/" + strFile +
    "?format=" +  strFormat +
    "&attachment=" + "true" +
    "&file=" +  strFile ;
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = "../" + strPrimaryUrl;  
  // getting the querystring for passing to form jsp
  
  //${COMMON_DIR}/emxForm.jsp?form=type_Products&editLink=false&formHeader=emxProduct.Heading.Properties&actionBarName=PLCHardwareProductPropertiesTopActionBar
  strURL = "../common/emxForm.jsp?form="+strFormName+"&editLink=false";
  sQueryString.append("&mode=Form");  
  strURL = strURL + sQueryString;
  strURL = strURL + "&strPrimaryUrl=" + strPrimaryUrl;
}


else if(mode.equals("FormImage")){
//Calling the downloadImageFile Method of Image.java to get details about the object
  Map fileDetailMap = imageBean1.downloadImageFile(context,strParentPrimaryImageOjectId);
  StringList strFileList = (StringList)(fileDetailMap.get(DomainConstants.SELECT_FILE_NAME));
  String strFile = (String)(strFileList.get(0));
  String strFormat = (String)(fileDetailMap.get(DomainConstants.KEY_FORMAT)); 
  strPrimaryUrl = "../components/emxComponentsCheckout.jsp?objectId="+ strParentPrimaryImageOjectId  + strFile +
    "?format=" +  strFormat +
    "&attachment=" + "true" +
    "&file=" +  strFile ;
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = strPrimaryUrl.substring(strPrimaryUrl.indexOf("/")+1, strPrimaryUrl.length());
  strPrimaryUrl = "../" + strPrimaryUrl;  
  // getting the querystring for passing to form jsp
  strURL = "../common/emxForm.jsp?form="+strFormName+"&editLink=false";
  sQueryString.append("&mode=Form");  
  strURL = strURL + sQueryString;
  strURL = strURL + "&strPrimaryUrl=" + strPrimaryUrl;
}
else
{
  strURL = "../common/emxForm.jsp?form="+strFormName+"&editLink=false";
  sQueryString.append("&mode=Form");  
  strURL = strURL + sQueryString;
}
     

%>
  <body>
    <!-- XSSOK -->
    <form name="Test" method="post" action="<%=strURL%>">
      <input type="hidden" name="forNetscape" value="">
    </form>
    
    <script language="javascript" type="text/javaScript">
      
      var formName = document.Test;
      targetFrame = openerFindFrame(getTopWindow(), "detailsDisplay");
      formName.submit();
      self.focus();
      //  alert("test");
    </script>  
  </body>

  
