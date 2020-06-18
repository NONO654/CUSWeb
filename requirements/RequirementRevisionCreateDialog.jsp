<%--

  RequirementRevisionCreateDialog.jsp

  Performs the actions that creates a New Revision of objects is PLC

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program


--%>
  <%-- @quickreview T25  OEP 28 Aug 2012  (IR-174854V6R2013x  Revision command could not handle large number of objects ) --%>
  <%-- @quickreview T25  OEP 06 Sep 2012  IR-174854V6R2013x No changes. File time stamp modified for pseudo promotion. --%>
  <%-- @quickreview T25  OEP 26 Sep 2012  IR-174854V6R2014   Revision command could not handle large number of objects ) --%>
  <%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
        respective scriplet
       @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
       @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
	   @quickreview LX6 XXX 21 Apr 2015  HL FUN054695 ENOVIA GOV TRM Revision refactoring.
	   @quickreview QYG     24 Jun 2015  IR-380848-3DEXPERIENCER2016x fix close button.
	   @quickreview HAT1 ZUD 25 Sep 2017 IR-551054-3DEXPERIENCER2018x: Requirement Specification Revision description.
--%>
<%-- Include JSP for error handling --%>
    <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
    <%@include file = "emxProductCommonInclude.inc" %>
    <%@include file = "../emxUICommonAppInclude.inc"%>
    <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <%@include file = "emxValidationInclude.inc" %>
    <%@include file = "../emxTagLibInclude.inc"%>

    <%@page import = "java.util.Map"%>
    <%@page import = "com.matrixone.apps.productline.ProductLineConstants" %>
    <%@page import = "com.matrixone.apps.productline.ProductLineUtil" %>

    <%@page import = "com.matrixone.apps.domain.DomainConstants" %>
    <%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
    <%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

     <%
     String strTableRowId = "";
     String strSuiteKey = "";
     String strTimeStamp = "";
     String uiType = "";
     String strSelectedObjectId = "";
     boolean bIsError=false;
     String strDescription = "";
     
     
     String strName = "";
     String strType = "";
     String strID = "";
     String strDesc = ""; //HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
     String strSelectedIdFromList = "";
     
     StringList slName =new StringList();
     StringList slType =new StringList();
     
     StringBuffer strSelectedID = new StringBuffer();
     String mode="";
     String strkeyRevision ="";
     
     boolean displayForm = true;
     
     try
     {
    	  // Start:IR:174854V6R2013x:T25
    	  //Review:OEP
    	 mode = emxGetParameter(request,"mode");
		 strSuiteKey = emxGetParameter( request,"suiteKey"); 
		 strTimeStamp= emxGetParameter(request,"timeStamp");
    	 
    	 if("Revision".equals(mode))
    	 {
    	    String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    	    //START : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring.
    	    String rootid = emxGetParameter(request,"objectId");
    	    if(rootid.length()>0&&strTableRowIds!=null&&(strTableRowIds.length>1||!rootid.equals(strTableRowIds[0].split("[|]")[1]))){
    	    	displayForm = false;
    	    	String strErrorLabel = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.NotRootObjectSelected"); 
    	    	throw new Exception(strErrorLabel);
    	    }
    	    //END : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring.

		   StringBuffer tmpStrBuf = new StringBuffer();
    	   if(null!=strTableRowIds){
		   for(int i=0; i<strTableRowIds.length; i++) {
		     tmpStrBuf.append(",");
		     tmpStrBuf.append(strTableRowIds[i]);
		     }
         	// Remove the first comma seperator
            tmpStrBuf.deleteCharAt(0);
    	   }else{
    		   tmpStrBuf.append(rootid);
    	   }
             
    	 	 long number = new Random(System.currentTimeMillis()).nextLong();
	         String key = "REV" + System.currentTimeMillis() + "_" + number;
	         session.setAttribute(key, tmpStrBuf.toString());
         
         %>
        <body>
		<form name="RMTRevision" method="post">
			   <script language="javascript" type="text/javascript">
			   		 document.RMTRevision.action="../components/emxCommonFS.jsp?functionality=RequirementRevisionCreateFSInstance&PRCFSParam1=Requirement&multipleTableRowId=true&suiteKey="+"<xss:encodeForJavaScript><%=strSuiteKey%></xss:encodeForJavaScript>"+"&timeStamp="+"<xss:encodeForJavaScript><%=strTimeStamp%></xss:encodeForJavaScript>"+"&key="+"<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>";
     				 document.RMTRevision.submit();
    		   </script>
    	</form>
   		</body>
         <%
    	 }
    	 
    	 strTableRowId = emxGetParameter(request,"emxTableRowId");
    	 if(strTableRowId == null){
    		 strTableRowId = emxGetParameter(request,"objectId");
    	 }
         //END:IR:174854V6R2013x:T25
        
         uiType= emxGetParameter(request,"uiType");

		 // Start:IR:174854V6R2013x:T25
         String strKey = "";
         if(strTableRowId ==  null){
         	strKey = emxGetParameter(request, "key"); 
     		if(strKey != null){ 
     			strTableRowId = (String)session.getAttribute(strKey);
     		}
         }
		 // End:IR:174854V6R2013x:T25
         
         if(uiType != null)
         {
         if(uiType.equalsIgnoreCase("structureBrowser"))
         {
             StringTokenizer parser = new StringTokenizer(strTableRowId,",");
             while(parser.hasMoreTokens()){
                 String strParameter = parser.nextToken();
                 if(strParameter.length() > 1 && strParameter.indexOf("|") >= 0){
                      StringTokenizer sourceTokenTemp = new StringTokenizer(strParameter, ",");
                      while(sourceTokenTemp.hasMoreTokens()){
                          String strParaName  =  sourceTokenTemp.nextToken();
                          StringList objectIdList = FrameworkUtil.split(strParaName, "|");
                        if(objectIdList.size() == 4)
                        {
                        	strSelectedObjectId = (String) objectIdList.get(1);
                        } else if(objectIdList.size() == 3)
                        {
                        	strSelectedObjectId = (String) objectIdList.get(0);
                        }
                      
                        ProductLineCommon commonBean = new ProductLineCommon();
                        Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,strSelectedObjectId);
                        
                        if(mpObjectInfo!=null && mpObjectInfo.size()!=0) {
                            strName = (String) mpObjectInfo.get(DomainConstants.SELECT_NAME);
                            strType = (String) mpObjectInfo.get(DomainConstants.SELECT_TYPE);
                            strID = (String)  mpObjectInfo.get(DomainConstants.SELECT_ID);
		//HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
								strDesc = (String)  mpObjectInfo.get(DomainConstants.SELECT_DESCRIPTION);
                            slName.add(strName);
                            slType.add(strType);
                            strSelectedID.append(strSelectedObjectId);
                            strSelectedID.append(",");
                        }  
                        strSelectedIdFromList = slName.toString();
                        strSelectedIdFromList = strSelectedIdFromList.substring(1,strSelectedIdFromList.length()-1);
                        strType = slType.toString();
                        strType = strType.substring(1,strType.length()-1);
							strDescription = strDesc; //HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
                      }
                    
                  }
             }
             strSelectedID.deleteCharAt(strSelectedID.length()-1);
         }
         else
         {
             StringList strObjectId = FrameworkUtil.split(strTableRowId, ",");
             if(strTableRowId != null)
             {
                 for(int i=0;i < strObjectId.size() ; i++)
                 {
                     strSelectedObjectId = (String) strObjectId.get(i);
                     
                     ProductLineCommon commonBean = new ProductLineCommon();
                     Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,strSelectedObjectId);
                     
                     if(mpObjectInfo!=null && mpObjectInfo.size()!=0) {
                         strName = (String) mpObjectInfo.get(DomainConstants.SELECT_NAME);
                         strType = (String) mpObjectInfo.get(DomainConstants.SELECT_TYPE);
                         strID = (String)  mpObjectInfo.get(DomainConstants.SELECT_ID);
							//HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
							strDesc = (String)  mpObjectInfo.get(DomainConstants.SELECT_DESCRIPTION);
                         slName.add(strName);
                         slType.add(strType);
                         strSelectedID.append(strSelectedObjectId);
                         strSelectedID.append(",");
                        
                      }
                     strSelectedIdFromList = slName.toString();
                     strSelectedIdFromList = strSelectedIdFromList.substring(1,strSelectedIdFromList.length()-1);
                     strType = slType.toString();
                     strType = strType.substring(1,strType.length()-1);
						strDescription = strDesc; //HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
                 }
                 strSelectedID.deleteCharAt(strSelectedID.length()-1);
             }
         }
         }
         else
         {
        	  StringTokenizer parser = new StringTokenizer(strTableRowId,",");
        	  while(parser.hasMoreTokens()){
        		  String strParameter = parser.nextToken();
        		  if(strParameter.length() > 1 && strParameter.indexOf("|") >= 0){
        			  StringTokenizer sourceTokenTemp = new StringTokenizer(strParameter, ",");
                      while(sourceTokenTemp.hasMoreTokens()){
                          String strParaName  =  sourceTokenTemp.nextToken();
                          StringList objectIdList = FrameworkUtil.split(strParaName, "|");
                          
                        if(objectIdList.size() == 4)
                        {
                            strSelectedObjectId = (String) objectIdList.get(1);
                        } else if(objectIdList.size() == 3)
                        {
                            strSelectedObjectId = (String) objectIdList.get(0);
                        }
                        
                        ProductLineCommon commonBean = new ProductLineCommon();
                        Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,strSelectedObjectId);
                        
                        if(mpObjectInfo!=null && mpObjectInfo.size()!=0) {
                            strName = (String) mpObjectInfo.get(DomainConstants.SELECT_NAME);
                            strType = (String) mpObjectInfo.get(DomainConstants.SELECT_TYPE);
                            strID = (String)  mpObjectInfo.get(DomainConstants.SELECT_ID);
		//HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
							strDesc = (String)  mpObjectInfo.get(DomainConstants.SELECT_DESCRIPTION);
                            slName.add(strName);
                            slType.add(strType);
                            strSelectedID.append(strSelectedObjectId);
                            strSelectedID.append(",");
                        }  
                        strSelectedIdFromList = slName.toString();
                        strSelectedIdFromList = strSelectedIdFromList.substring(1,strSelectedIdFromList.length()-1);
                        strType = slType.toString();
                        strType = strType.substring(1,strType.length()-1);
						strDescription = strDesc; //HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
        		  }
        	  } else{
	        	  if(strParameter.contains(".") == true){
	        		  ProductLineCommon commonBean = new ProductLineCommon();
	                  Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,strSelectedObjectId);
	                  
	                  if(mpObjectInfo!=null && mpObjectInfo.size()!=0) {
	                      strName = (String) mpObjectInfo.get(DomainConstants.SELECT_NAME);
	                      strType = (String) mpObjectInfo.get(DomainConstants.SELECT_TYPE);
	                      strID = (String)  mpObjectInfo.get(DomainConstants.SELECT_ID);
							//HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
							strDesc = (String)  mpObjectInfo.get(DomainConstants.SELECT_DESCRIPTION);
	                      slName.add(strName);
	                      slType.add(strType);
	                      strSelectedID.append(strSelectedObjectId);
	                      strSelectedID.append(",");
	                  }  
	                  strSelectedIdFromList = slName.toString();
	                  strSelectedIdFromList = strSelectedIdFromList.substring(1,strSelectedIdFromList.length()-1);
	                  strType = slType.toString();
	                  strType = strType.substring(1,strType.length()-1);
						strDescription = strDesc; //HAT1 ZUD: IR-551054-3DEXPERIENCER2018xFIX
	        	  } 
        	  }
        	}
        	  strSelectedID.deleteCharAt(strSelectedID.length()-1);
         }
    %>

 
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.StringTokenizer"%>

<%@page import="java.util.Enumeration"%><form name = "test" method = "post" onsubmit="submitForm(); return false">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
   <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <%-- Display the input fields. --%>

<%-- Name of the object --%>
   <tr>
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxRequirements.Form.Label.Names
         </framework:i18n>
     </td>
     <td class="field">
     <xss:encodeForHTML><%=strSelectedIdFromList%></xss:encodeForHTML>
     </td>
   </tr>

<%-- Type of the object --%>
<!-- 
   <tr>
     <td width="150" class="label" width="200" align="left">
       Types
     </td>
     <td class="field">
         <!%=strType%>
     </td>
   </tr>
   -->

<%-- Description of the object --%>
   <tr style="display:none;">
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxFramework.Basic.Description
       </framework:i18n>
     </td>
     <td class="field">
       <textarea name="txtDescription" rows="5" cols="25"><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
     </td>
   </tr>

   <tr>
     <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
     <td width="90%">&nbsp;</td>
   </tr>
  </table>
   <input type="image" height="1" width="1" border="0" value="" style="display:none;"/>
 </form>
    <%
    
    // Start:IR:174854V6R2013x:T25
    	  //Review:OEP
    if(strKey!= null){
		session.removeAttribute(strKey);
	}
    
   	 // Start:IR-174854V6R2014:T25
     // Review:OEP
     long lnumber = new Random(System.currentTimeMillis()).nextLong();
     strkeyRevision = "REV" + System.currentTimeMillis() + "_" + lnumber;
     String selectedId = strSelectedID.toString();
     if(selectedId.isEmpty()){
    	 selectedId = strTableRowId;
     }
     session.setAttribute(strkeyRevision, selectedId);
	//END:IR-174854V6R2014:T25
    
     }catch(Exception ex){
        bIsError=true;
        ex.printStackTrace();
        emxNavErrorObject.addMessage(ex.getMessage().toString().trim());
     }
    %>
  <script type="text/javaScript">
  //<![CDATA[ *
  //START : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring.
  if(!<%=displayForm%>){
	  setTimeout(function(){getTopWindow().closeSlideInDialog(); }, 100);
  }
  //END : LX6 FUN054695 ENOVIA GOV TRM Revision refactoring.
  var  formname = document.test;

  //validates form for required field
  function validateForm()
  {
   var iValidForm = true;
    //Validation for Required field Description for bad characters .as well as required field
      if (iValidForm)
        {
          var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Description")%>";
          var field = formname.txtDescription;
          iValidForm = basicValidation(formname,field,fieldName,false,false,true,false,false,false,checkBadChars)
        }
      if (!iValidForm)
      {
          return ;
      }
      if (jsDblClick()) {
         formname.submit();
      }
  }
  //When Enter Key Pressed on the form
  function submitForm()
  {
	  
        submit();
  }
  //when Done button is pressed in Dialog Page
  function submit()
  {
    var strURL = "RequirementRevise.jsp";
    strURL = strURL + "?strkeyRevision=<xss:encodeForJavaScript><%=strkeyRevision%></xss:encodeForJavaScript>&suiteKey=<xss:encodeForJavaScript><%=strSuiteKey%></xss:encodeForJavaScript>&timeStamp=<xss:encodeForJavaScript><%=strTimeStamp%></xss:encodeForJavaScript>";
    formname.action = strURL;
    //formName.target = "jpcharfooter";
      validateForm();
  }
  
 
  //]]>
  </script>

     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script type="text/javaScript">
//when Cancel button is pressed in Dialog Page
function closeWindow()
{
   getTopWindow().closeSlideInDialog();
}
</script>
     <%@include file = "../emxUICommonEndOfPageInclude.inc"%>
       
<%
  if (bIsError)

  {
%>
    <script language="javascript" type="text/javaScript">
      findFrame(parent, 'pagecontent').clicked = false;
      parent.turnOffProgress();
      history.back();
    </script>
<%
  }
%>

