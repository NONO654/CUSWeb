<%--  emxengchgMetricsReportDialog.jsp   - Dialog page to generate Metrics report for ECR/ECO.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants" %>

<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String objectName = emxGetParameter(request,"objectName");

%>
<%
  String sTypeECR = PropertyUtil.getSchemaProperty(context, "type_ECR");
  String sTypeECO = PropertyUtil.getSchemaProperty(context, "type_ECO");
  
  //ECM
  String sGenerate      = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Generate", request.getHeader("Accept-Language"));
  String sMetricsReport = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.DesignTOP.MetricsReport", request.getHeader("Accept-Language"));
  String sGenMetRep     = sGenerate+" "+sMetricsReport;
  String sAccessDenied  = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.AccessDenied", request.getHeader("Accept-Language"));
  String sAlert         = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.DesignTOP.PleaseEnteracharacterValueforDelimiter", request.getHeader("Accept-Language"));
%>
<script language="Javascript">

  //function to validate user entry
  function doneMethod()
  {
      if (document.formMetrix.textfieldDel.value == "" )
      {
    	  //XSSOK
          alert("<%=sAlert%>");
          document.formMetrix.textfieldDel.focus();
      }
      else
      {
          document.formMetrix.submit();
      }
  }

  function createPolicyList()
  {
      var indexx = document.formMetrix.type.selectedIndex;
      var selectedType = document.formMetrix.type[indexx].value;
      //XSSOK
      if(selectedType=="<%=sTypeECR%>")
      {
          document.location.href="emxengchgMetricsReportDialog.jsp?type="+escape("<xss:encodeForURL><%=sTypeECR%></xss:encodeForURL>")+"&contentPageIsDialog=true";
      }
      //XSSOK
      if(selectedType=="<%=sTypeECO%>")
      {
          document.location.href="emxengchgMetricsReportDialog.jsp?type="+escape("<xss:encodeForURL><%=sTypeECO%></xss:encodeForURL>")+"&contentPageIsDialog=true";
      }
      //ECM
      //XSSOK
      if(selectedType=="<%=ChangeConstants.TYPE_CHANGE_ORDER%>")
      {
          document.location.href="emxengchgMetricsReportDialog.jsp?type="+escape("<xss:encodeForURL><%=ChangeConstants.TYPE_CHANGE_ORDER%></xss:encodeForURL>")+"&contentPageIsDialog=true";
      }
      if(selectedType=="<%=ChangeConstants.TYPE_CHANGE_ACTION%>")
      {
          document.location.href="emxengchgMetricsReportDialog.jsp?type="+escape("<xss:encodeForURL><%=ChangeConstants.TYPE_CHANGE_ACTION%></xss:encodeForURL>")+"&contentPageIsDialog=true";
      }
      //XSSOK
      if(selectedType=="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>")
      {
          document.location.href="emxengchgMetricsReportDialog.jsp?type="+escape("<xss:encodeForURL><%=ChangeConstants.TYPE_CHANGE_REQUEST%></xss:encodeForURL>")+"&contentPageIsDialog=true";
      }

  }

  function updateDelimeter()
  {
      var selIndex = document.formMetrix.fileExtension.selectedIndex;
      var fileExt = document.formMetrix.fileExtension.options[selIndex].value;

      if (fileExt == ".csv")
    {
        document.formMetrix.textfieldDel.value=",";
    }
  }

  function cancelMethod()
  {
      parent.closeWindow();
  }
</script>


<%
  try
  {
    String sECOType = PropertyUtil.getSchemaProperty(context,"type_ECO");
    String sECRType = PropertyUtil.getSchemaProperty(context,"type_ECR");
    
    //ECM    
    //check for vault awareness
    String sVaultname = (String)session.getAttribute("emxEngineeringCentral.companyVault");
    if (sVaultname == null) //use person's company vault and do not allow edit
    {
      sVaultname = JSPUtil.getVault(context, session);
    }
    Vault sVault = new Vault(sVaultname);
    BusinessType busTypeECR = new BusinessType(sECRType,sVault);
    BusinessType busTypeECO = new BusinessType(sECOType,sVault);
    busTypeECR.open(context);
    busTypeECO.open(context);
    
    //ECM
    BusinessType busTypeCO = new BusinessType(ChangeConstants.TYPE_CHANGE_ORDER,sVault);
    BusinessType busTypeCA = new BusinessType(ChangeConstants.TYPE_CHANGE_ACTION,sVault);
    BusinessType busTypeCR = new BusinessType(ChangeConstants.TYPE_CHANGE_REQUEST,sVault);
    busTypeCO.open(context);
    busTypeCA.open(context);
    busTypeCR.open(context);
    
    
    PolicyList polListECR = busTypeECR.getPolicies(context);
    PolicyList polListECO = busTypeECO.getPolicies(context);
    
    //ECM
    PolicyList polListCO = busTypeCO.getPolicies(context);
    PolicyList polListCA = busTypeCA.getPolicies(context);
    PolicyList polListCR = busTypeCR.getPolicies(context);

    PolicyItr polItrECR = new PolicyItr(polListECR);
    PolicyItr polItrECO = new PolicyItr(polListECO);
    busTypeECR.close(context);
    busTypeECO.close(context);
    
    //ECM
    PolicyItr polItrCO = new PolicyItr(polListCO);
    PolicyItr polItrCA = new PolicyItr(polListCA);
    PolicyItr polItrCR = new PolicyItr(polListCR);
    busTypeCO.close(context);
    busTypeCA.close(context);
    busTypeCR.close(context);
    
    PolicyItr polItr=null;

    String sTypeMetrics = emxGetParameter(request,"type");
    if(sTypeMetrics==null || sTypeMetrics.equalsIgnoreCase("null"))
    {
      polItr = polItrECR;
    }
    else
    {
     if(sTypeMetrics.equals(sTypeECR))
      {
        polItr = polItrECR;
      }
      if(sTypeMetrics.equals(sTypeECO))
      {
        polItr = polItrECO ;
      }
      //ECM
      if(sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_ORDER))
      {
        polItr = polItrCO;
      }
      if(sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_ACTION))
      {
        polItr = polItrCA ;
      }
      if(sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_REQUEST))
      {
        polItr = polItrCR ;
      }
    }
%>

  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>

  <form name="formMetrix" method="post"  action="emxengchgMetricsReportFS.jsp" target="_parent" onSubmit="javascript:doneMethod();return false">

  <table width="100%" cellpadding="5" cellspacing="2" border="0" >
  <tr>
    <td width="20%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
    <td width="20%" class="field">
    <select name="type" onChange="javascript:createPolicyList()">
<%
    if((sTypeMetrics==null)|| sTypeMetrics.equalsIgnoreCase("null") ||(sTypeMetrics.equals(sECRType)))
    {
%><!-- XSSOK -->
      <option  value="<%=sECRType%>"><%=i18nNow.getTypeI18NString(sECRType,languageStr)%></option>
      <!-- XSSOK -->
      <option  value="<%=sECOType%>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ORDER%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ORDER,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ACTION%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ACTION,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_REQUEST,languageStr)%></option>
<%
    }
    else if (sTypeMetrics.equals(sECOType))
    {
%>	  
      <!-- XSSOK -->
      <option  value="<%=sECOType%>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%></option> 
      <!-- XSSOK -->     
      <option  value="<%=sECRType%>"><%=i18nNow.getTypeI18NString(sECRType,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ORDER%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ORDER,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ACTION%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ACTION,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_REQUEST,languageStr)%></option>
<%
    }
    else if (sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_ORDER))
    {
%>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ORDER%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ORDER,languageStr)%></option>
       <!-- XSSOK -->
 	<option  value="<%=sECOType%>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%></option>  
 	 <!-- XSSOK -->    
      <option  value="<%=sECRType%>"><%=i18nNow.getTypeI18NString(sECRType,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ACTION%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ACTION,languageStr)%></option>
        <option  value="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_REQUEST,languageStr)%></option>
<%
    }
    else if (sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_ACTION))
    {  
    
%>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ACTION%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ACTION,languageStr)%></option>
       <!-- XSSOK -->
	  <option  value="<%=sECOType%>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%></option>
	   <!-- XSSOK -->      
      <option  value="<%=sECRType%>"><%=i18nNow.getTypeI18NString(sECRType,languageStr)%></option>
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ORDER%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ORDER,languageStr)%></option>   
        <option  value="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_REQUEST,languageStr)%></option> 
      <%
    }
    else if (sTypeMetrics.equals(ChangeConstants.TYPE_CHANGE_REQUEST))
    {  
    
%>
      <!-- XSSOK -->
      <option  value="<%=ChangeConstants.TYPE_CHANGE_REQUEST%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_REQUEST,languageStr)%></option>
       <!-- XSSOK -->
	  <option  value="<%=sECOType%>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%></option>
	   <!-- XSSOK -->      
      <option  value="<%=sECRType%>"><%=i18nNow.getTypeI18NString(sECRType,languageStr)%></option>
      <!-- XSSOK -->
      <option  value="<%=ChangeConstants.TYPE_CHANGE_ORDER%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ORDER,languageStr)%></option> 
      <!-- XSSOK --> 
       <option  value="<%=ChangeConstants.TYPE_CHANGE_ACTION%>"><%=i18nNow.getTypeI18NString(ChangeConstants.TYPE_CHANGE_ACTION,languageStr)%></option>    
      <% 
      }
 %>

     </select>
    </td>
  </tr>
  <tr>
    <td width="20%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Delimiter</emxUtil:i18n></td>
    <td width="20%" class="inputField">
      <input type="text" name="textfieldDel" size="1" />
    </td>
  </tr>
  <tr>
    <td width="20%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Policy</emxUtil:i18n></td>
    <td width="20%" class="field">
      <select name="policy">
<%
      while(polItr.next())
      {
%><!-- XSSOK -->
        <option value="<%=polItr.obj().getName()%>"><%=i18nNow.getAdminI18NString("Policy",polItr.obj().getName(),languageStr)%></option>
<%
      }
%>
      </select>
    </td>
  </tr>
  <tr>
    <td width="20%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.FileExtension</emxUtil:i18n></td>
    <td width="20%" class="field">
      <select name="fileExtension" onChange="javascript:updateDelimeter()">
        <option value=".txt"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.FileExtension.txt</emxUtil:i18n></option>
        <option value=".csv"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.FileExtension.csv</emxUtil:i18n></option>
      </select>
    </td>
  </tr>
  </table>

  </form>
<%
  }
  catch(Exception e)
  {
    throw e;
  }
%>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
