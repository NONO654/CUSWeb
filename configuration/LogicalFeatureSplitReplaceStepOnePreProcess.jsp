<%--  LogicalFeatureSplitReplaceStepOnePreProcess.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<html>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.Part"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<%

try
{
    String strMode    = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request,"jsTreeID");  
    String regisateredSuite = emxGetParameter(request,"SuiteDirectory");    
    String initSource = emxGetParameter(request,"initSource");
    String strObjectId    = emxGetParameter(request, "objectId");
    String relID = emxGetParameter(request, "relId");
    String strContext    = emxGetParameter(request, "context");
    String strParentOId = emxGetParameter(request, "parentOID");
   
    LogicalFeature logicalFeature = new LogicalFeature();
    if(strMode.equalsIgnoreCase("SplitReplace"))
    {
        com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
        //Processing the form using FormBean.processForm
        formBean.processForm(session,request);
        //Instantiating the LogicalFeature bean
        String step = emxGetParameter(request,"Step");
        try
        {
            if(step!=null && step.equals("SplitReplace"))
            {
                String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
                String strRelId = "";
                String strFeatureId = "";
                String strProdId = "";
                boolean showPopup = false;

                if(strContext!= null && strContext.equals("RMB"))
                {
                    strRelId = relID;
                    strFeatureId = strObjectId;
                    strProdId = strParentOId;
                }
                else
                {
                    StringTokenizer strRowIdTZ = new StringTokenizer(strTableRowIds[0],"|");
                    if(strRowIdTZ.countTokens()>2)
                    {
                        strRelId = strRowIdTZ.nextToken();
                        strFeatureId = strRowIdTZ.nextToken();
                        strProdId = strRowIdTZ.nextToken();
                    }
                    else
                    {
                        strRelId = strRowIdTZ.nextToken();
                        strFeatureId = strRowIdTZ.nextToken();
                    }
                }
                
                
                String strSelectedType = "";
                if(strFeatureId!=null && !strFeatureId.equals("") && !strFeatureId.equals("0")){
              	  DomainObject domFeature = new DomainObject(strFeatureId);
              	  strSelectedType = domFeature.getInfo(context,DomainObject.SELECT_TYPE);
                }
                
				if(strContext!= null && strContext.equals("RMB") && strObjectId.equals("")){
                    %>
                    <script>
                       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
                    </script>
                    <%
				}
				else if(strProdId.equals("") || strProdId.equals(strFeatureId))
                {
                    %>
                    <script>
                       alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.CannotPerform</emxUtil:i18nScript>");
                    </script>
                    <%
                }else if( !strSelectedType.equals("") && mxType.isOfParentType(context, strSelectedType,
						ConfigurationConstants.TYPE_PRODUCTS) ){
                    %>
                    <script>                  
                     alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.Alert.MergeandReplace.CannotPerform</emxUtil:i18nScript>");
                    </script>
                    <% 
                }
                else
                    showPopup = true;
                
                if(showPopup)
                {
                    
                	 boolean inValidState = logicalFeature.InvalidStateforMergeReplace(context, strFeatureId);
                	                     
                    
                if(!inValidState)
                  {
                        showPopup = false;
                        %>
                        <script>
                           alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.AllProdReleased</emxUtil:i18nScript>");
                        </script>
                        <%
                  } 
               
                if(showPopup)
                {
                	%>     
                    <body>   
                    <form name="FTRConfigurationLogicalFeatureSplitReplace" method="post">
                    <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=strTableRowIds%></xss:encodeForHTMLAttribute>" />
                    <script language="Javascript">        
                        //window.open('about:blank','newWin','height=600,width=900');
                        //document.FTRConfigurationLogicalFeatureSplitReplace.target="newWin";                      
                        //document.FTRConfigurationLogicalFeatureSplitReplace.action="../components/emxCommonFS.jsp?functionality=LogicalFeatureSplitAndReplace&suiteKey=Configuration&HelpMarker=emxhelpfeaturesplitreplace&featureType=Configuration&objIdContext=<%=strContext%>&initSource=<%=initSource%>&jsTreeID=<%=jsTreeID%>&objectId=<%=strFeatureId%>&parentOID=<%=strParentOId%>&strProdId=<%=strProdId%>&RelId=<%=strRelId%>";
                        //document.FTRConfigurationLogicalFeatureSplitReplace.submit();
                        //alert("1");
                        var url ="../components/emxCommonFS.jsp?functionality=LogicalFeatureSplitAndReplace&suiteKey=Configuration&HelpMarker=emxhelpfeaturesplitreplace&featureType=Configuration&objIdContext=<%=XSSUtil.encodeForURL(context,strContext)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context,strFeatureId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentOId)%>&strProdId=<%=XSSUtil.encodeForURL(context,strProdId)%>&RelId=<%=XSSUtil.encodeForURL(context,strRelId)%>";   
                        //showDetailsPopup(url);
                        showModalDialog(url, 875, 550,true,'Large');                               
                    </script>     
                    </form>
                    </body>         
                    <%
                }
                
                
                }

            }
            else if(step!=null && step.equals("IncludeData"))
            {
            	String strSourceFeatureId = (String) formBean.getElementValue("sourceObjectId");
                int numberInstances = Integer.parseInt(((String) formBean.getElementValue("numberOfInstance")).trim());
                String strProductID = (String) formBean.getElementValue("prodId");
                String strRelId = (String) formBean.getElementValue("RelId");
                String strnumberInstances = (String) (formBean.getElementValue("numberOfInstance"));
                String strSpecification = (String) formBean.getElementValue("Specification");
                String refrenceDocuments = (String) formBean.getElementValue("Refrence_Documents");
                String useCases = (String) formBean.getElementValue("Use_Cases");
                String testCases = (String) formBean.getElementValue("Test_Cases");
                String images = (String) formBean.getElementValue("Images");                
                String configurableRules = (String) formBean.getElementValue("Configurable_Rules");
                
                
                Map mplogicalCopySelectables = new HashMap();
                mplogicalCopySelectables.put("Specifications" ,strSpecification);
                mplogicalCopySelectables.put("Reference Documents" ,refrenceDocuments);
                mplogicalCopySelectables.put("Use Case" ,useCases);
                mplogicalCopySelectables.put("TestCases" ,testCases);
                mplogicalCopySelectables.put("Images" ,images);
                mplogicalCopySelectables.put("Configurable Rules" , configurableRules);
                
                
               // Map returnMap = new HashMap();
                
            	Map returnMap =  logicalFeature.splitFeature(context,strSourceFeatureId,strProductID,
            			           		mplogicalCopySelectables,numberInstances,strRelId);
            	returnMap.put("SuiteDirectory",regisateredSuite);
            	returnMap.put("strParentOId",strParentOId);
            	returnMap.put("numberOfInstance",strnumberInstances);
            	session.putValue("ProductDetails" ,returnMap);
            	
            	String url = logicalFeature.URLforSplitReplace(context,returnMap,"StepTwo");
            	
                
                %>     
                <body>   
                <form name="FTRConfigurationLogicalFeatureStepTwoSplitReplace" method="post">
                <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=returnMap%></xss:encodeForHTMLAttribute>" />
                <script language="Javascript">        
                    //window.open('about:blank','newWin','height=575,width=575');
                    //document.FTRConfigurationLogicalFeatureStepTwoSplitReplace.target="newWin";                      
                    //document.FTRConfigurationLogicalFeatureStepTwoSplitReplace.action='<%=url%>';
                    //document.FTRConfigurationLogicalFeatureStepTwoSplitReplace.submit();
                    getTopWindow().location.href = "<%=XSSUtil.encodeForURL(context,url)%>";      
                </script>     
                </form>
                </body>         
                <%
               
            }
            
            else if(step!=null && step.equals("CancelSplit"))
            {

                int noOfInstaces = Integer.parseInt(emxGetParameter(request,"NumberOfInstances"));
                for(int i =0; i<noOfInstaces;i++)
                {
                    String  strTarId = emxGetParameter(request,"TargetID"+i);
                    DomainObject newFeatureDomObj = new DomainObject(strTarId);
                    newFeatureDomObj.deleteObject(context, true);
                }
            
            }
            else{}
        }
        catch(Exception e)
        {
            e.printStackTrace();
            %>
            <Script>
            alert("<emxUtil:i18nScript localize="i18nId">emxProduct.Alert.Exception</emxUtil:i18nScript>");
            </Script>
            <%
        }
     
    	
    }
    
}
    
    catch(Exception ex) 
{
        session.putValue("error.message", ex.getMessage());
} 
%>
</body>
</html>


