<%--  emxEngrFindLikeQueryFS.jsp  -  Search summary frameset
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<jsp:useBean id="emxEngrFindLikeQueryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxEngrFindLikeQueryFS";

  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String fromDelete = emxGetParameter(request,"fromDelete");

  String strParams    = "";
  String vaultAwarenessString="";
  Enumeration paramNames = emxGetParameterNames(request);

  if(fromDelete == null || "".equals(fromDelete) || "null".equals(fromDelete)) {
    Map paramMap = new HashMap();
    while(paramNames.hasMoreElements()) {
     String paramName = (String)paramNames.nextElement();
     String paramValue = emxGetParameter(request,paramName);
     if(paramName.equals("Vault")){
        /*******************************Vault Code Start***************************************/
        // Get the user's vault option & call corresponding methods to get the vault's.
        String txtVault   ="";
        String strVaults="";
        StringList strListVaults=new StringList();

        if(paramValue==null) {
          paramValue="";
        }
        vaultAwarenessString = (String)JSPUtil.getCentralProperty(application, session, "eServiceEngineeringCentral", "VaultAwareness");
        if(vaultAwarenessString==null){
          vaultAwarenessString="";
        }
        if(vaultAwarenessString.equalsIgnoreCase("true")){

          if(paramValue.equals("ALL_VAULTS"))
          {
            strListVaults = com.matrixone.apps.common.Person.getCollaborationPartnerVaults(context,null);
            StringItr strItr = new StringItr(strListVaults);
            if(strItr.next()){
              strVaults =strItr.obj().trim();
            }
            while(strItr.next())
            {
              strVaults += "," + strItr.obj().trim();
            }
            txtVault = strVaults;
          }
          else if(paramValue.equals("LOCAL_VAULTS"))
          {
            com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
            Company company = person.getCompany(context);
            txtVault = company.getLocalVaults(context);
          }
          else if (paramValue.equals("DEFAULT_VAULT"))
          {
            txtVault = context.getVault().getName();
          }
          else
          {
            txtVault = paramValue;
          }
        }
        else
        {
          if(paramValue.equals("ALL_VAULTS"))
          {
            // get ALL vaults
            Iterator mapItr = VaultUtil.getVaults(context).iterator();
            if(mapItr.hasNext())
            {
              txtVault =(String)((Map)mapItr.next()).get("name");

              while (mapItr.hasNext())
              {
                Map map = (Map)mapItr.next();
                txtVault += "," + (String)map.get("name");
              }
            }

          }
          else if(paramValue.equals("LOCAL_VAULTS"))
          {
            // get All Local vaults
          com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
          Company company = person.getCompany(context);
          strListVaults = OrganizationUtil.getLocalVaultsList(context, company.getObjectId());

			StringItr strItr = new StringItr(strListVaults);
            if(strItr.next()){
              strVaults =strItr.obj().trim();
            }
            while(strItr.next())
            {
              strVaults += "," + strItr.obj().trim();
            }
            txtVault = strVaults;
          }
          else if (paramValue.equals("DEFAULT_VAULT"))
          {
            txtVault = context.getVault().getName();
          }
          else
          {
            txtVault = paramValue;
          }
        }
        //trimming
        paramValue = txtVault.trim();
     }
        /*******************************Vault Code End***************************************/
     paramMap.put(paramName, paramValue);
    }
    session.setAttribute("strParams", paramMap);
  }


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxEngrFindLikeQuery.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);

  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue != null && !"".equals(filterValue))
  {
    contentURL.append("&mx.page.filter=");
    contentURL.append(filterValue);
    fs.setFilterValue(filterValue);
  }

  fs.setBeanName(tableBeanName);

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.Common.Search";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearch";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,true,true,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  /*StringBuffer roleList = new StringBuffer("role_DesignEngineer,role_ECRChairman,role_ECRCoordinator,role_ECREvaluator,");
  roleList.append("role_ManufacturingEngineer,role_OrganizationManager,role_PartFamilyCoordinator,");
  roleList.append("role_ProductObsolescenceManager,role_SeniorDesignEngineer,role_SeniorManufacturingEngineer,role_ComponentEngineer");*/
  StringBuffer roleList = new StringBuffer("role_GlobalUser");

  fs.writePage(out);
%>
