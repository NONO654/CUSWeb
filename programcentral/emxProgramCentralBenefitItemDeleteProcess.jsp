<%--  emxProgramCentralBenefitItemDeleteProcess.jsp

   Deletes the Benefit Items

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralBenefitItemDeleteProcess.jsp.rca 1.11 Wed Oct 22 15:49:36 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@ page import="java.util.HashMap"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="benefitItem"    scope="page" class="com.matrixone.apps.program.BenefitItem"/>
<jsp:useBean id="financialItem" scope="page" class="com.matrixone.apps.program.FinancialItem"/>

<%
try {
    String[] benefitItems = emxGetParameterValues(request, "emxTableRowId");
    String strLanguage = request.getHeader("Accept-Language");//Added:di7
    String strTokenId = "";
    String strSelectedCategoryID = "";
    int deleteObjCount=benefitItems.length;
    String deleteObjList[]=new String[deleteObjCount*2];
    String financialItemId=null;
    int k=-1;
     if (benefitItems.length != 0) {
        for (int i = 0; i < benefitItems.length; i++) {
            java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(
            		benefitItems[i], "|");
            int nTokenCount = strTokenizer.countTokens();
            
            
            for (int j = 0; j < nTokenCount; j++) {
                strTokenId = strTokenizer.nextToken();
             
                if (j == 1) {
                    strSelectedCategoryID = strTokenId;
                    DomainObject dmoObject = new DomainObject(strSelectedCategoryID);
             
                    if (!dmoObject.isKindOf(context,ProgramCentralConstants.TYPE_FINANCIAL_BENEFIT_CATEGORY) && !dmoObject.isKindOf(context,ProgramCentralConstants.TYPE_FINANCIAL_ITEM)) {
                    	                                         	
                    	benefitItem.setId(strSelectedCategoryID);
                    	String strIID=benefitItem.getInfo(context,ProgramCentralConstants.SELECT_BENEFIT_INTERVAL_ITEM_DATA_ID);
                    	if(i==0)
                    	{
                    		financialItemId=benefitItem.getInfo(context,ProgramCentralConstants.SELECT_FINANCIAL_ITEM);
                       	}
                    	k++;  
            	
                        deleteObjList[k+i]=strIID;
                        deleteObjList[k+i+1]=strSelectedCategoryID;
                        
      
	               }
                   else{
                	 //ADDED:di7:22-Aug-2011:IR-126539V6R2012x:Start
                	   String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                				  "emxProgramCentral.ProjectBenefit.SelectBenefitItem", strLanguage);
                	   
                	   %>
                	   
                   <script language="JavaScript">
                    //alert("<framework:i18nScript localize="i18nId">emxProgramCentral.ProjectBenefit.SelectBenefitItem</framework:i18nScript>");
                    alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                   </script>
                	   
                	   <%
                	   //ADDED:di7:22-Aug-2011:IR-126539V6R2012x:End
                   }
                }
            }
        }
        
        DomainObject.deleteObjects(context,deleteObjList);
     
        
        HashMap requestMap=new HashMap();
        
        requestMap.put("objectId",financialItemId);
        requestMap.put("isCostItem","false");
        String methodArgs[] = JPO.packArgs(requestMap);
   
        JPO.invoke(context,"emxFinancialItem",null,"rollupAmountOnDelete",methodArgs);
  
     }
}catch (Exception e)
{
    e.printStackTrace();//ADDED:di7:22-Aug-2011:IR-126539V6R2012x
}
                   
                    
%>
 <script language="JavaScript">
      window.parent.location.href =  window.parent.location.href;           
  </script>
