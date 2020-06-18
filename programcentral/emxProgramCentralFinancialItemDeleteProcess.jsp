<%--  emxProgramCentralFinancialItemDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  Reviewed for Level III compliance by KIP 5/16/2002

  static const char RCSID[] = "$Id: emxProgramCentralFinancialItemDeleteProcess.jsp.rca 1.13 Wed Oct 22 15:49:23 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="financialItem" scope="page" class="com.matrixone.apps.program.FinancialItem"/>

<%
//  com.matrixone.apps.program.FinancialItem financialItem =
//   (com.matrixone.apps.program.FinancialItem) DomainObject.newInstance(context, DomainConstants.TYPE_FINANCIAL_ITEM, "PROGRAM");


  String strProjectId = emxGetParameter(request,"objectId");
  
//[ADDED::PRG:RG6:Jan 5, 2011:R211:IR-075617V6R2012:When invoked from RMB project id is coming as current obj id]
  String isFromRMB = emxGetParameter(request, "isFromRMB");
 if(null != isFromRMB && "true".equalsIgnoreCase(isFromRMB.trim())){
     String strRootObjectId = emxGetParameter(request, "rootObjectId");
     if( null != strRootObjectId && !"Null".equalsIgnoreCase(strRootObjectId.trim()) && !"".equalsIgnoreCase(strRootObjectId.trim())){
    	 strProjectId = strRootObjectId;
     }   
 }
 // [ADDED::PRG:RG6:Jan 5, 2011:IR-075617V6R2012:R211::End]   
     
  DomainObject dmoProject = new DomainObject(strProjectId);
  String strProType = dmoProject.getInfo(context,DomainConstants.SELECT_TYPE);
  String[] financialItems = emxGetParameterValues(request,"emxTableRowId");
  String sPolicyFinancial = PropertyUtil.getSchemaProperty(context,"policy_FinancialItems");
  String sPlanFrozenStateName = PropertyUtil.getSchemaProperty(context,"policy",sPolicyFinancial,"state_PlanFrozen");
  String cannotDelete="";
  String selectBenefit="";
  String deletionFailure="";
  String projFinancialItemRelId    = "to["+financialItem.RELATIONSHIP_PROJECT_FINANCIAL_ITEM+"].id";
  String financialConnId ="";

  StringList busSelect=new StringList(3);
  busSelect.add(financialItem.SELECT_CURRENT);
  busSelect.add(financialItem.SELECT_NAME);
  busSelect.add(financialItem.SELECT_TYPE);
  busSelect.add(projFinancialItemRelId);
  Map objectMap = null;
  StringList deletedFinancials = new StringList();
  String strSelectedFinancialItemID = "";
  String strType= "";
  Map mpTableID = null;
  if (financialItems != null) {
     
      String strTokenId = "";
    
       for (int i = 0; i < financialItems.length; i++) {
    	   mpTableID = ProgramCentralUtil.parseTableRowId(context,financialItems[i]);//Added:di7
           strTokenId = (String)mpTableID.get("objectId");//Added:di7
             
                    if(dmoProject.isKindOf(context,DomainConstants.TYPE_PROJECT_TEMPLATE)){//Modofied:di7:IR-118726V6R2012x
                    strSelectedFinancialItemID = strTokenId;
                    financialItem.setId(strSelectedFinancialItemID);
                    objectMap=financialItem.getInfo(context,busSelect);
                    strType = (String) objectMap.get(financialItem.SELECT_TYPE);
                    if(strType.equals(Financials.TYPE_BUDGET)|| strType.equals(Financials.TYPE_BENEFIT) ){
                        break;
                    }
                 }
                
                    if(dmoProject.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE)){//Modofied:di7:IR-118726V6R2012x
                    	strSelectedFinancialItemID = strTokenId;
                        //Added:di7:24-Aug-2011:IR-123969V6R2012x:start
                        DomainObject dmoObj = DomainObject.newInstance(context,strSelectedFinancialItemID);
                        if(!dmoObj.isKindOf(context,ProgramCentralConstants.TYPE_BUDGET)&&!dmoObj.isKindOf(context,ProgramCentralConstants.TYPE_BENEFIT))
                        {
                        	   String strLanguage = context.getSession().getLanguage();
                        	   String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                        				  "emxProgramCentral.ProjectBenefit.SelectBenefitOrBudget", strLanguage);
                            %>
                                <script language="JavaScript" type="text/javascript">
                                          alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                </script>
                            <%return;
                        }
                        //Added:di7:24-Aug-2011:IR-123969V6R2012x:End
	                    financialItem.setId(strSelectedFinancialItemID);
	                    objectMap=financialItem.getInfo(context,busSelect);
	                    strType = (String) objectMap.get(financialItem.SELECT_TYPE);
	                    if(strType.equals(Financials.TYPE_BUDGET)){
	                        break;
	                    }
	                  
	               }
                
                }
            } 
     // financialItem.setId(financialItems[i]);
     
      String currentState =(String) objectMap.get(financialItem.SELECT_CURRENT);
      financialConnId =  (String) objectMap.get(projFinancialItemRelId);
      if(financialConnId!=null && financialConnId.length()!=0) {
	      if(sPlanFrozenStateName.equalsIgnoreCase(currentState))
	      {
	        cannotDelete = (String) objectMap.get(financialItem.SELECT_NAME);
	        
	      }else{
	        deletedFinancials.add(strSelectedFinancialItemID);
		      try{
		    	ProgramCentralUtil.pushUserContext(context);  
		        financialItem.delete(context, financialConnId);
		      }
		      catch(Exception ex){
		        deletionFailure = (String) objectMap.get(financialItem.SELECT_NAME);
		      }finally{
		    	  ProgramCentralUtil.popUserContext(context);  
		      }
	      }
  }else{
	  selectBenefit="Please Select Benefit/Budget to Delete";
  }

 

%>

  <script language="javascript" type="text/javaScript">//<![CDATA[
  <%-- XSSOK--%> 
    if(<%=!"".equals(cannotDelete)%>)
    {
      alert("<%=XSSUtil.encodeForJavaScript(context,cannotDelete)%> - " + "<framework:i18nScript localize="i18nId">emxProgramCentral.Financial.ObjectCannotDeleted</framework:i18nScript>");
    }
  <%-- XSSOK--%> 
    else if(<%=!"".equals(deletionFailure)%>)
    {
     alert("<%=XSSUtil.encodeForJavaScript(context,deletionFailure)%> - " + "<framework:i18nScript localize="i18nId">emxProgramCentral.Financial.DeleteObjectFailureNotice</framework:i18nScript>");
    }
  <%-- XSSOK--%> 
    else if(<%=!"".equals(selectBenefit)%>)
    {
    <%if(strType.equals(DomainConstants.TYPE_COST_ITEM)){ %>
     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Budget.SelectBudget</framework:i18nScript>");
     <%}else if (strType.equals(DomainConstants.TYPE_BENEFIT_ITEM)){%>
     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.ProjectBenefit.SelectBenefit</framework:i18nScript>");
     <%}%>
     }
      window.parent.location.href =  window.parent.location.href;
     </script>
  }
