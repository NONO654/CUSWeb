<%--  emxProgramCentralCostItemDeleteProcess.jsp

  Performs the action that removes a Cost Item.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralCostItemDeleteProcess.jsp.rca 1.11 Wed Oct 22 15:49:15 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="costItem"      scope="page" class="com.matrixone.apps.program.CostItem"/>

<%
try {
	String[] costItems = emxGetParameterValues(request, "emxTableRowId");
	String strTokenId = "";
	String strSelectedCategoryID = "";
	String financialItemId=null;

    int k=-1;
    int costItemLength = 0;       // [ADDED::PRG:RG6:Feb 17, 2011:IR-071955V6R2012 :R211::Start]
    if(null != costItems)
    {
    	costItemLength = costItems.length;
    }
    String strLanguage = request.getHeader("Accept-Language");
    int deleteObjCount=costItemLength;
    String deleteObjList[]=new String[deleteObjCount*2];
    boolean isCostItemAddedInList = false;          // [ADDED::PRG:RG6:Feb 17, 2011:IR-071955V6R2012 :R211::Start]
	 if (costItemLength > 0) {
		for (int i = 0; i < costItemLength; i++) {
			java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(
					costItems[i], "|");
			int nTokenCount = strTokenizer.countTokens();
			for (int j = 0; j < nTokenCount; j++) {
				strTokenId = strTokenizer.nextToken();
				if (j == 1) {
					strSelectedCategoryID = strTokenId;
					DomainObject dmoObject = new DomainObject(
							strSelectedCategoryID);
					//Modified:di7:22-Aug-2011:IR-126539V6R2012x:Start
					if (!dmoObject.isKindOf(context,Financials.TYPE_FINANCIAL_COST_CATEGORY) && !dmoObject.isKindOf(context,Financials.TYPE_FINANCIAL_ITEM)&& !dmoObject.isKindOf(context,DomainConstants.TYPE_PROJECT_TEMPLATE)) {
					//Modified:di7:22-Aug-2011:IR-126539V6R2012x:End                                      
                        costItem.setId(strSelectedCategoryID);
                        String strIID=costItem.getInfo(context,ProgramCentralConstants.SELECT_INTERVAL_ITEM_DATA_ID);
                        if(i==0)
                        {
                            financialItemId=costItem.getInfo(context,ProgramCentralConstants.SELECT_FINANCIAL_ITEM);
                        }
                        k++;  
                
                        deleteObjList[k+i]=strIID;
                        deleteObjList[k+i+1]=strSelectedCategoryID;
                        
                        isCostItemAddedInList = true; // set this to true whenever cost item is added in the deletecostItem array list
                   }
					else     // [ADDED::PRG:RG6:Feb 17, 2011:IR-071955V6R2012 :R211::Start]
					{
						// error msg please select the cost item needs to be added here
			            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			      			  "emxProgramCentral.Budget.SelectCostItem", strLanguage);
	               %>
				         <script language="JavaScript" type="text/javascript">
				                                               alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                         </script>
	               <%
	                     return;     
					}// [ADDED::PRG:RG6:Feb 17, 2011:IR-071955V6R2012 :R211::End]
      
                   } 
				}
			}
		
		if(isCostItemAddedInList)      // [ADDED::PRG:RG6:Feb 17, 2011:IR-071955V6R2012 :R211::]
		{
		DomainObject.deleteObjects(context,deleteObjList);
		 HashMap requestMap=new HashMap();
	        
	        requestMap.put("objectId",financialItemId);
	        requestMap.put("isCostItem","true");
	        String methodArgs[] = JPO.packArgs(requestMap);
	   
	        JPO.invoke(context,"emxFinancialItem",null,"rollupAmountOnDelete",methodArgs);
	 }
	 }
}catch (Exception e)
{
    
    session.putValue("error.message", e.getMessage());
    throw new MatrixException(e);
}
%>
 <script language="JavaScript">
                                window.parent.location.href =  window.parent.location.href;
                                
                    </script>
