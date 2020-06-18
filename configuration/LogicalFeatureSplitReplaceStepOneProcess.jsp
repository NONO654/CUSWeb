<%--  LogicalFeatureSplitReplaceStepOneProcess.jsp
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

<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@page import="com.matrixone.apps.configuration.Part"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<html>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<%
	try {
			String strMode = emxGetParameter(request, "mode");
			String regisateredSuite = emxGetParameter(request,
					"SuiteDirectory");
			String strObjectId = emxGetParameter(request, "objectId");
			String strParentOId = emxGetParameter(request, "parentOID");
			String strPrevious =  emxGetParameter(request, "Previous");
			LogicalFeature logicalFeature = new LogicalFeature();

			if (strMode.equalsIgnoreCase("SplitReplace")) {
				String step = emxGetParameter(request, "Step");
				  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
			        //Processing the form using FormBean.processForm
			        formBean.processForm(session,request);
			        //Instantiating the LogicalFeature bean
			        
				if (step != null && step.equals("IncludeData")) {

	                String strSourceFeatureId = (String) formBean.getElementValue("sourceObjectId");
	                
	                String strProductID = (String) formBean.getElementValue("prodId");
	                String strRelId = (String) formBean.getElementValue("RelId");
	                String strnumberInstances = (String) (formBean.getElementValue("numberOfInstance"));
	                String all = (String) formBean.getElementValue("All");
	                String strSpecification = (String) formBean.getElementValue("Specification");
	                
	                String refrenceDocuments = (String) formBean.getElementValue("Refrence_Documents");
	                String useCases = (String) formBean.getElementValue("Use_Cases");
	                String testCases = (String) formBean.getElementValue("Test_Cases");
	                String images = (String) formBean.getElementValue("Images");
	                String configurableRules = (String) formBean.getElementValue("Configurable_Rules");           
	                
	                Map mplogicalCopySelectables = new HashMap();
	                if(ConfigurationUtil.isNotNull(strSpecification))
	                	   mplogicalCopySelectables.put("Specifications" ,strSpecification);
	                else
	                	mplogicalCopySelectables.put("Specifications" ,"");
	                
	                if(ConfigurationUtil.isNotNull(refrenceDocuments))
	                	mplogicalCopySelectables.put("Reference Documents" ,refrenceDocuments);
	                else
	                	mplogicalCopySelectables.put("Reference Documents" ,"");
	                
	                if(ConfigurationUtil.isNotNull(useCases))
	                	mplogicalCopySelectables.put("Use Case" ,useCases);
	                else
	                	mplogicalCopySelectables.put("Use Case" ,"");
	                
	                if(ConfigurationUtil.isNotNull(testCases))
	                    mplogicalCopySelectables.put("TestCases" ,testCases);
	                else
	                	mplogicalCopySelectables.put("TestCases" ,"");
	                
	                if(ConfigurationUtil.isNotNull(images))
	                	mplogicalCopySelectables.put("Images" ,images);
	                else
	                	mplogicalCopySelectables.put("Images" ,"");
	                
	                if(ConfigurationUtil.isNotNull(configurableRules))
                        mplogicalCopySelectables.put("Configurable Rules" ,configurableRules);
                    else
                        mplogicalCopySelectables.put("Configurable Rules" ,"");	                
	               
	                mplogicalCopySelectables.put("GBOM" , "off");
	                mplogicalCopySelectables.put("Design Variants" , "off");
	                
	                Map returnMap = new HashMap();
	                if(strPrevious==null){
	                int numberInstances = Integer.parseInt(((String) formBean.getElementValue("numberOfInstance")).trim());	
	                returnMap =  logicalFeature.splitFeature(context,strSourceFeatureId,strProductID,
	                                        mplogicalCopySelectables,numberInstances,strRelId);
	                }
	                returnMap.put("SuiteDirectory",regisateredSuite);
	                returnMap.put("strParentOId",strParentOId);
	                returnMap.put("numberOfInstance",strnumberInstances);
	                returnMap.put("strObjectId",strObjectId);
	                session.putValue("ProductDetails" ,returnMap);
	                
	                String url = logicalFeature.URLforSplitReplace(context,returnMap,"StepTwo");              
	                
	                %>     
	                <body>   
	                <form name="FTRConfigurationLogicalFeatureStepTwoSplitReplace" method="post">
	                <input type="hidden" name="tableIdArray" value="<xss:encodeForHTMLAttribute><%=returnMap%></xss:encodeForHTMLAttribute>" />
	                <script language="Javascript">
                        getTopWindow().location.href = "<%=XSSUtil.encodeForJavaScript(context,url)%>";                        
	                </script>     
	                </form>
	                </body>         
	                <%
    
				}
			}
		} catch (Exception ex) {

			session.putValue("error.message", ex.getMessage());
		}
%>
  </body>
  </html>

