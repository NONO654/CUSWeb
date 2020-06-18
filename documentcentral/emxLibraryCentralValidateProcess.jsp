<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxLibraryCentralmportAG.jsp.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>
<jsp:useBean id="formBean" scope="page" class="com.matrixone.apps.common.util.FormBean"/>
<%
    try{
        String resourceBundle           = "emxLibraryCentralStringResource";
        String language                = request.getHeader("Accept-Language");
        String AG_ALREADY_EXISTS        = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxMultipleClassification.AttributeGroup.AttributeGroupAlreadyExists");
        String NO_AG_ERROR              = EnoviaResourceBundle.getProperty(context,resourceBundle, new Locale(language),"emxMultipleClassification.ImportFile.NoErrorMessage");
        formBean.processForm(session, request);
        boolean doOveride=false;
        boolean bkgProcess=false;
        String errorType=null;
        String errorDesc=null;
        HashMap errorMap=new HashMap();
        String jobName=null;
        String isAGImport=(String)formBean.getElementValue("isAGImport");
        String isValidate=(String)emxGetParameter(request,"validate");
        String isOveride=(String)formBean.getElementValue("override");
        String isbkgProcess=(String)session.getAttribute("bkgprocess");
        boolean agImport=Boolean.parseBoolean(isAGImport);
        boolean fromValidate=Boolean.parseBoolean(isValidate);
        if(isOveride != null && isOveride.equals("on"))
            doOveride=true;
        if(isbkgProcess != null)
            bkgProcess=true;
        java.io.File importFile = (java.io.File) formBean.getElementValue("file");
        AttributeGroup atrGrp=new AttributeGroup();
        if((bkgProcess)&& (!fromValidate) &&(!agImport)){
            errorMap=atrGrp.importAndValidateXML(context,importFile.getPath(),agImport,fromValidate,doOveride);
            errorType=(String)errorMap.get("ErrorType");
            errorDesc=(String)errorMap.get("ErrorDescription");
            //No errors in xml, hence create Job
            if(errorType==null){
                LibraryCentralJobs lcJobs=new LibraryCentralJobs();
                jobName=lcJobs.importLibraryASync(context,importFile.getPath(),fromValidate);
            }
        }
        else if((!bkgProcess)&& (fromValidate) &&(!agImport)){
            errorMap=atrGrp.importAndValidateXML(context,importFile.getPath(),agImport,fromValidate,doOveride);
            errorType=(String)errorMap.get("ErrorType");
            errorDesc=(String)errorMap.get("ErrorDescription");
        }
        else if((bkgProcess)&& (!fromValidate) &&(agImport)){
            errorMap=atrGrp.importAndValidateXML(context,importFile.getPath(),agImport,fromValidate,doOveride);
            errorType=(String)errorMap.get("ErrorType");
            errorDesc=(String)errorMap.get("ErrorDescription");
            //No errors in xml, hence create Job
            if(errorType==null){
                LibraryCentralJobs lcJobs=new LibraryCentralJobs();
                jobName=lcJobs.importAttributeGroupASync(context,importFile.getPath(),fromValidate,doOveride);
            }
        }
        
        else{
            errorMap=atrGrp.importAndValidateXML(context,importFile.getPath(),agImport,fromValidate,doOveride);
            errorType=(String)errorMap.get("ErrorType");
            errorDesc=(String)errorMap.get("ErrorDescription");
        }
        
%>
<script>
var elementId=getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId");
getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId").style.fontWeight='bold';
var error="<xss:encodeForJavaScript><%=errorDesc%></xss:encodeForJavaScript>";
var errorType="<xss:encodeForJavaScript><%=errorType%></xss:encodeForJavaScript>";
var IsAsynchronous="<xss:encodeForJavaScript><%=isbkgProcess%></xss:encodeForJavaScript>";
var jobname="<xss:encodeForJavaScript><%=jobName%></xss:encodeForJavaScript>";
var isValidate="<xss:encodeForJavaScript><%=fromValidate%></xss:encodeForJavaScript>";
if(error!="null"){
    getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId").style.color='red';
    getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId").value=error;
}
else if((error=="null") && ("true" ==(IsAsynchronous)) && (isValidate=="false")){
    alert("<emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreated</emxUtil:i18nScript>" + jobname + "\n" +" <emxUtil:i18nScript localize="i18nId">emxMultipleClassification.Job.JobCreatedPostMsg</emxUtil:i18nScript>");
    getTopWindow().closeSlideInDialog();
    var contentFrame = findFrame(getTopWindow(),"content");
    if(contentFrame.location.href.indexOf("emxIndentedTable.jsp") >= 0){
       contentFrame.refreshSBTable(contentFrame.configuredTableName);
    }
}
else if((error=="null") && (isValidate=="true")){
    getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId").style.color='blue';
    getTopWindow().slideInFrame.pagecontent.document.getElementById("ValidatetxtareaId").value="<xss:encodeForJavaScript><%=NO_AG_ERROR%></xss:encodeForJavaScript>";
}
else if((error=="null") && (isValidate=="false")){
    getTopWindow().closeSlideInDialog();
     var contentFrame = findFrame(getTopWindow(),"content");
     if(contentFrame.location.href.indexOf("emxIndentedTable.jsp") >= 0){
        contentFrame.refreshSBTable(contentFrame.configuredTableName);
     }
}
else{
    getTopWindow().closeSlideInDialog();
     var contentFrame = findFrame(getTopWindow(),"content");
     if(contentFrame.location.href.indexOf("emxIndentedTable.jsp") >= 0){
        contentFrame.refreshSBTable(contentFrame.configuredTableName);
     }
}

</script>
<%      
    }catch(Exception err){
        err.printStackTrace();
    }
%>
