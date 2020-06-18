<%-- emxEngrBOMManualAddExistingIntermediateProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ page import="com.matrixone.apps.engineering.*" %>
<%@ page import="com.matrixone.apps.engineering.Part" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxengchgUtil.inc"%>

<html>
  <body>

<%

 String uiType = emxGetParameter(request, "uiType");
  

try{
  String strObjectId = emxGetParameter(request,"objectId");
  String languageStr = request.getHeader("Accept-Language");
  StringBuffer errMessage = new StringBuffer();
  String error = "";

  String part1Id = null;
  String part2Id = null;
  String part3Id = null;
  String part4Id = null;
  String part5Id = null;

  String part1 = emxGetParameter(request,"part1");
  String part2 = emxGetParameter(request,"part2");
  String part3 = emxGetParameter(request,"part3");
  String part4 = emxGetParameter(request,"part4");
  String part5 = emxGetParameter(request,"part5");

  String revision1 = emxGetParameter(request,"revision1");
  String revision2 = emxGetParameter(request,"revision2");
  String revision3 = emxGetParameter(request,"revision3");
  String revision4 = emxGetParameter(request,"revision4");
  String revision5 = emxGetParameter(request,"revision5");

  String specificTxt1 = emxGetParameter(request,"specificTxt1");
  String specificTxt2 = emxGetParameter(request,"specificTxt2");
  String specificTxt3 = emxGetParameter(request,"specificTxt3");
  String specificTxt4 = emxGetParameter(request,"specificTxt4");
  String specificTxt5 = emxGetParameter(request,"specificTxt5");

  String focus="";
  StringList strListVaults=new StringList();
  String strVaults="";
  String txtVaultOption = emxGetParameter(request,"vaultOption");
  String vault = "";

  if(txtVaultOption==null) {
    txtVaultOption="";
   }
  	//if(txtVaultOption.equals("ALL_VAULTS") || txtVaultOption.equals(""))
    if(txtVaultOption.equals("ALL_VAULTS"))
    {
          // get ALL vaults
          Iterator mapItr = VaultUtil.getVaults(context).iterator();
          if(mapItr.hasNext())
          {
            vault =(String)((Map)mapItr.next()).get("name");

            while (mapItr.hasNext())
            {
              Map map = (Map)mapItr.next();
              vault += "," + (String)map.get("name");
            }
          }

     }
	 else if(txtVaultOption.equals("LOCAL_VAULTS")) {
          // get All Local vaults
            com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
            com.matrixone.apps.common.Company company = person.getCompany(context);
            strListVaults = OrganizationUtil.getLocalVaultsList(context, company.getObjectId());

          StringItr strItr = new StringItr(strListVaults);
          if(strItr.next()){
            strVaults =strItr.obj().trim();
          }
          while(strItr.next())
          {
            strVaults += "," + strItr.obj().trim();
          }
          vault = strVaults;
     }
	 else if (txtVaultOption.equals("DEFAULT_VAULT")) {
          vault = context.getVault().getName();
     }
	 else {
          txtVaultOption = emxGetParameter(request,"selVaults");
          vault = txtVaultOption;
     }

  //Multitenant
    /* String errPrefix = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.FollowingParts", "emxEngineeringCentralStringResource", languageStr);
    String errSuffix = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.CouldNotFound", "emxEngineeringCentralStringResource", languageStr);
    String errEnd = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.DifferentValueMessage", "emxEngineeringCentralStringResource", languageStr); */
    
    String errPrefix = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.FollowingParts");
    String errSuffix = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.CouldNotFound");
    String errEnd = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.DifferentValueMessage");

    int selCount = 0;
    HashMap map = null;
    if( part1!=null && !part1.equalsIgnoreCase("null") && !part1.trim().equals("")) {
        map = checkPartExistance(context,application,session,request, part1, vault, revision1, "specificTxt1",languageStr);
          part1Id = (String)map.get("id");
          error = (String)map.get("errMessage");
          if(error != null ) {
              errMessage.append(error+", ");
              focus = "part1";
          }
        selCount++;
    }

    if( part2!=null && !part2.equalsIgnoreCase("null") && !part2.trim().equals("")) {
      map = checkPartExistance(context,application,session,request, part2, vault, revision2, "specificTxt2",languageStr);
      part2Id = (String)map.get("id");
      error = (String)map.get("errMessage");
      if(error != null ) {
          if(errMessage.toString().length()==0) {
              focus = "part2";
          }
          errMessage.append(error+", ");
      }
      selCount++;
    }

    if( part3!=null && !part3.equalsIgnoreCase("null") && !part3.trim().equals("")) {
      map = checkPartExistance(context,application,session, request,part3, vault, revision3, "specificTxt3",languageStr);
      part3Id = (String)map.get("id");
      error = (String)map.get("errMessage");
      if(error != null ) {
          if(errMessage.toString().length()==0) {
              focus = "part3";
          }
          errMessage.append(error+", ");
      }
      selCount++;
    }

     if( part4!=null && !part4.equalsIgnoreCase("null") && !part4.trim().equals("")) {
      map = checkPartExistance(context,application,session, request,part4, vault, revision4, "specificTxt4",languageStr);
      part4Id = (String)map.get("id");
      error = (String)map.get("errMessage");
      if(error != null ) {
          if(errMessage.toString().length()==0) {
              focus = "part4";
          }
          errMessage.append(error+", ");
      }
      selCount++;
     }

     if( part5!=null && !part5.equalsIgnoreCase("null") && !part5.trim().equals("")) {
      map = checkPartExistance(context,application,session,request, part5, vault, revision5, "specificTxt5",languageStr);
      part5Id = (String)map.get("id");
      error = (String)map.get("errMessage");
      if(error != null ) {
          if(errMessage.toString().length()==0) {
              focus = "part5";
          }
          errMessage.append(error+", ");
      }
      selCount++;
     }

      error = null;
      StringBuffer url = new StringBuffer("");
      vault=emxGetParameter(request,"vaultOption");
      boolean submitPage= false;

      if(errMessage.toString().endsWith(", ")) {
          error = errPrefix + errMessage.toString().substring(0,errMessage.toString().length()-2) + " "+errSuffix + " "+errEnd;
%>
            <script language="javascript">
              alert("<xss:encodeForJavaScript><%=error%></xss:encodeForJavaScript>");
              //XSSOK
              eval("parent.frames[1].document.addParts.<%=focus%>.focus();");
            </script>
<%
      } else {
          String[] checkBox = new String[selCount];
          int i = 0;
          if(part1 != null && !part1.trim().equals("")) {
              checkBox[i++]=part1Id;
          }
          if(part2 != null && !part2.trim().equals("")) {
              checkBox[i++]=part2Id;
          }
          if(part3 != null && !part3.trim().equals("")) {
              checkBox[i++]=part3Id;
          }
          if(part4 != null && !part4.trim().equals("")) {
              checkBox[i++]=part4Id;
          }
          if(part5 != null && !part5.trim().equals("")) {
              checkBox[i++]=part5Id;
          }
          submitPage= true;
          session.setAttribute("checkBox",checkBox);
      }
%>

  <form name="hFrm" method="post" action="emxEngrBOMAddExistingPartsFS.jsp" target="_top">

  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part1" value="<xss:encodeForHTMLAttribute><%=part1%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part2" value="<xss:encodeForHTMLAttribute><%=part2%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part3" value="<xss:encodeForHTMLAttribute><%=part3%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part4" value="<xss:encodeForHTMLAttribute><%=part4%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part5" value="<xss:encodeForHTMLAttribute><%=part5%></xss:encodeForHTMLAttribute>" />

  <input type="hidden" name="part1Revision" value="<xss:encodeForHTMLAttribute><%=revision1%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part2Revision" value="<xss:encodeForHTMLAttribute><%=revision2%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part3Revision" value="<xss:encodeForHTMLAttribute><%=revision3%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part4Revision" value="<xss:encodeForHTMLAttribute><%=revision4%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="part5Revision" value="<xss:encodeForHTMLAttribute><%=revision5%></xss:encodeForHTMLAttribute>" />

  <input type="hidden" name="specificTxt1" value="<xss:encodeForHTMLAttribute><%=specificTxt1%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="specificTxt2" value="<xss:encodeForHTMLAttribute><%=specificTxt2%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="specificTxt3" value="<xss:encodeForHTMLAttribute><%=specificTxt3%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="specificTxt4" value="<xss:encodeForHTMLAttribute><%=specificTxt4%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="specificTxt5" value="<xss:encodeForHTMLAttribute><%=specificTxt5%></xss:encodeForHTMLAttribute>" />

  <input type="hidden" name="manualAdd" value="true" />
  <input type="hidden" name="vault" value="<xss:encodeForHTMLAttribute><%=txtVaultOption%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=uiType%></xss:encodeForHTMLAttribute>" />

    <script language="javascript">
    <%
      if(submitPage) {
    %>
         document.hFrm.submit();
    <%
      }
    %>
    </script>
<%
} catch(Exception e) {
    }
%>

    </form>
  </body>
</html>

<%!
 public static HashMap checkPartExistance(Context context,ServletContext application,
                                       HttpSession session, HttpServletRequest request, String part1, String vault, String revision1, String revisionTxt, String languageStr) throws Exception {
     String partId = null;
     String errMessage = null;
     HashMap map = new HashMap();
     String strPolicy = "";
     SelectList resultSelects = new SelectList(2);
     resultSelects.add(DomainObject.SELECT_ID);
     resultSelects.add(DomainObject.SELECT_POLICY);
     StringList objectSelects = new StringList(2);
     objectSelects.addElement(DomainObject.SELECT_ID);
     objectSelects.addElement(DomainObject.SELECT_POLICY);

     BusinessObject bus = null;
     String whereExpression = "";
     DomainObject dom = new DomainObject();
     MapList ml = null;
   //Multitenant
     /*  String strHighestReleased = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.HighestReleased", "emxEngineeringCentralStringResource", languageStr);
     String strReleasedRevision = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.ReleasedRevision", "emxEngineeringCentralStringResource", languageStr);
     String strLatestRevision = i18nNow.getI18nString("emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.LatestRevision", "emxEngineeringCentralStringResource", languageStr); */

     String strHighestReleased = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.HighestReleased");
     String strReleasedRevision = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.ReleasedRevision");
     String strLatestRevision = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOMManualAddExisting.ErrorMessage.LatestRevision");

      if(part1 != null && !part1.trim().equals("")) {
           if(revision1.equalsIgnoreCase("specific")) {
              revision1 = emxGetParameter(request,revisionTxt);
              whereExpression = "name == '"+part1+"' && revision=="+revision1+" && policy !='"+DomainObject.POLICY_MANUFACTURER_EQUIVALENT+"'";
              ml = DomainObject.findObjects(context, DomainConstants.TYPE_PART, "*", whereExpression, objectSelects);
              if(ml.size()!=0) {
                  strPolicy = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_POLICY));
                  if(strPolicy.equals(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT)) {
                      errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+revision1;
                  } else {
                      partId = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_ID));
                  }
              }else {
                  errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+revision1;
              }
          }
           else if(revision1.equalsIgnoreCase("HighestReleased")) {
              ml = EngineeringUtil.getHighestRevs(context, application,
                                          session, DomainConstants.TYPE_PART, part1, "*", "*", vault, resultSelects, "", "2");
              if(ml.size()!=0) {
                  strPolicy = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_POLICY));
                  if(strPolicy.equals(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT)) {
                      errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+revision1;
                  } else {
                      partId = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_ID));
                  }
              }else {
                  errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+strReleasedRevision;
              }
          }
            else if(revision1.equalsIgnoreCase("Latest")) {
              whereExpression = "name == '"+part1+"' && revision==last && policy !='"+DomainConstants.POLICY_MANUFACTURER_EQUIVALENT+"'";
              ml = DomainObject.findObjects(context, DomainConstants.TYPE_PART, "*", whereExpression, objectSelects);
              if(ml.size()!=0) {
                  strPolicy = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_POLICY));
                  if(strPolicy.equals(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT)) {
                      errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+revision1;
                  } else {
                      partId = (String)( ((Map)ml.get(0)).get(DomainObject.SELECT_ID));
                  }
              }else {
                  errMessage = DomainConstants.TYPE_PART+" "+part1+ " "+strLatestRevision;
              }

          }
    }
    map.put("id",partId);
    map.put("errMessage",errMessage);
    return map;
}
%>
