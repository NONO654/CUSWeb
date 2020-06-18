<%--  emxUILoadPropertyFiles.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUILoadPropertyFiles.inc.rca 1.28 Wed Oct 22 16:09:45 2008 przemek Experimental przemek $
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*, java.io.*,com.matrixone.apps.framework.ui.*" %>
<%@ page import = "java.lang.reflect.*" %>

<%

  //check if static vars are already loaded
  if (!framesetObject.areStaticsLoaded()){
    //set static constants for framesetObject
    //the following 2 pages reside in the app level directory
    framesetObject.setBottomFrameCommonPage("emxAppBottomPageInclude.jsp");
    framesetObject.setTopFrameCommonPage("emxAppTopPageInclude.jsp");

    //the following 3 pages reside in the ematrix directory
    //specify with the '../' notation. They are used within app directories.
    searchFramesetObject.setSearchLeftMenuPage("../common/emxUIGenericSearchLeftMenu.jsp");
    searchFramesetObject.setSearchHeaderPage("../common/emxUIGenericSearchHeaderPage.jsp");
    searchFramesetObject.setSearchFooterPage("../common/emxUIGenericSearchFooterPage.jsp");
    try
    {
        Class objectTypeArray[] = new Class[1];
        objectTypeArray[0] = String.class;
        Object objectArray[] = new Object[1];
        objectArray[0] = "emxAppBottomPageInclude.jsp";
        Method method = (Class.forName("com.matrixone.framework.ui.framesetObject")).getMethod("setBottomFrameCommonPage", objectTypeArray);
        method.invoke(null,objectArray);

        method = (Class.forName("com.matrixone.framework.ui.framesetObject")).getMethod("setTopFrameCommonPage", objectTypeArray);
        objectArray[0] = "emxAppTopPageInclude.jsp";
        method.invoke(null,objectArray);

        method = (Class.forName("com.matrixone.framework.ui.searchFramesetObject")).getMethod("setSearchLeftMenuPage", objectTypeArray);
        objectArray[0] = "../common/emxUIGenericSearchLeftMenu.jsp";
        method.invoke(null,objectArray);

        method = (Class.forName("com.matrixone.framework.ui.searchFramesetObject")).getMethod("setSearchHeaderPage", objectTypeArray);
        objectArray[0] = "../common/emxUIGenericSearchHeaderPage.jsp";
        method.invoke(null,objectArray);

        method = (Class.forName("com.matrixone.framework.ui.searchFramesetObject")).getMethod("setSearchFooterPage", objectTypeArray);
        objectArray[0] = "../common/emxUIGenericSearchFooterPage.jsp";
        method.invoke(null,objectArray);
    }
    catch (Exception ex)
    {
                     DebugUtil.debug(ex.toString());
    }
  }

  //begin set context vault for SSO
  if (context.getVault().getName() == null || "".equals(context.getVault().getName())){
    try{
    
      String vaultName = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context,"print Person $1 select $2 dump",context.getUser(),"vault");
       if ((vaultName != null) && (!"".equals(vaultName))){

        context.resetVault(vaultName);

      }
    }catch(Exception e){
      String loginPage = Framework.getPropertyValue("ematrix.login.page");
      context.shutdown();
    %>
    //XSSOK
    <jsp:forward page ="<%=loginPage%>"/>
    <%
    }
  }
  //end set context vault for SSO

  String acceptLanguage = request.getHeader("Accept-Language");

  // Setting the range for the Pagination Pages
  String pageRange = FrameworkProperties.getProperty(context, "emxFramework.PaginationRange");

  try {
    UITable.setRange(Integer.parseInt(pageRange));
  } catch(Exception e) {
     DebugUtil.debug("Exception calling method in UITable Bean: " + e);
  }

%>
<%!
  //
  // load the passed in property file name, set into application using its alias
  //
  static public Properties loadPropertyFile(ServletContext application, HttpServletRequest request,String propFileName, String aliasName)
  {
      Properties appProperties = new Properties();
      try{
        String passName = propFileName.substring(0,propFileName.indexOf('.'));
        appProperties = ServletUtil.getPropertiesFromBundle(passName,application);
        application.setAttribute(aliasName, appProperties);
      }catch(Exception e){
         DebugUtil.debug("\n!!!!! ERROR loading file: " + propFileName + "\nAlias: " + aliasName + "\nException:" + e + "\n\n");
        return null;
      }
    return appProperties;
  }
%>


<%!
  // Framework uses 'emxUIFrameworkStringResource'
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
  @Deprecated
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>

