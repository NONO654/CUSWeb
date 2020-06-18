<%--  emxEngrRevisionsSummary.jsp - common revisions summary page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%

    DomainObject bo = DomainObject.newInstance(context);

    //Determine if we should use printer friendly version
    //
    boolean isPrinterFriendly = false;
    String languageStr = request.getHeader("Accept-Language");
    String jsTreeID    = emxGetParameter(request,"jsTreeID");
    String objectId    = emxGetParameter(request,"objectId");
    String initSource  = emxGetParameter(request,"initSource");
    String suiteKey    = emxGetParameter(request,"suiteKey");
    String parentId    = emxGetParameter(request,"parentId");
    String copyFiles   = emxGetParameter(request,"copyFiles");
// IR-052864V6R2011x Begins
    if(parentId == null || "null".equals(parentId) || "".equals(parentId) ) {
        parentId    = emxGetParameter(request,"parentID");
    }
// IR-052864V6R2011x Ends

    //Declare display variables
    String sObjName= null;
    String sObjId  = null;
    String sPolicy = null;

    bo.setId(objectId);
    SelectList busSelects = bo.getObjectSelectList(6);

    busSelects.add(DomainConstants.SELECT_ID);
    busSelects.add(DomainConstants.SELECT_NAME);
    busSelects.add(DomainConstants.SELECT_REVISION);
    busSelects.add(DomainConstants.SELECT_TYPE);
    busSelects.add(DomainConstants.SELECT_CURRENT);
    busSelects.add(DomainConstants.SELECT_DESCRIPTION);
    busSelects.add(DomainConstants.SELECT_POLICY);
    busSelects.add(DomainConstants.SELECT_VAULT);
    Map boInfo = bo.getInfo(context, busSelects);
    String reviseDialog = "eServiceBlank.jsp";
    String type = (String)boInfo.get(DomainConstants.SELECT_TYPE);
    // get the symbolic name for this type
    String alias = FrameworkUtil.getAliasForAdmin(context, "type", type, true);

    if (alias != null && !alias.equals("") && !alias.equals("null"))
    {
        // See if there is a create dialog in the properties file for this type
        reviseDialog = JSPUtil.getCentralProperty(application, session, alias, "ReviseDialog");
        //368099 - Starts
        // If there is no create dialog, attempt to get it from the top level parent type
        // if there is one
        if (reviseDialog == null || reviseDialog.equals("") || reviseDialog.equals("null"))
        {
            String sTopLevelType=JSPUtil.getCentralProperty(application,session,alias,"BaseTypeObjectGenerator");

            if (sTopLevelType != null && !sTopLevelType.equals("") && !sTopLevelType.equals("null"))
            {
                reviseDialog = JSPUtil.getCentralProperty(application, session, sTopLevelType, "ReviseDialog");
            }

            // If property is not defined then attempt to get it from immediate parent type
            // by default atleast one property has the revise dialog defined.
            if (reviseDialog == null || "".equals(reviseDialog.trim()) || "null".equals(reviseDialog.trim()))
            {
              Vault sVault = context.getVault();
              while (reviseDialog == null || "".equals(reviseDialog.trim()) || "null".equals(reviseDialog.trim()))
              {
                try
                {
                  BusinessType busType = new BusinessType(type, sVault);
                  busType.open(context);

                  type = busType.getParent(context);
                  if (!type.equals(""))
                  {
                    alias = FrameworkUtil.getAliasForAdmin(context, DomainConstants.SELECT_TYPE, type, true);
                    reviseDialog = JSPUtil.getCentralProperty(application, session, alias, "ReviseDialog");
                  }
                  busType.close(context);
                }catch(Exception e){}
              }
            }
        }
		//368099 - Ends
        reviseDialog+="?objectId="+objectId;
        reviseDialog+="&parentId="+parentId;
        if(copyFiles != null && !copyFiles.equals("") && !copyFiles.equals("null"))
        {
            reviseDialog+="&copyFiles=true";
        }

    }
%>

<script language="javascript" src="../emxUIPageUtility.js"></script>

<script language="Javascript">
    function openWin()
    {
        var iWidth = "700";
        var iHeight = "600";
        var strFeatures = "width=" + iWidth  + ",height= " +  iHeight + ",resizable=no";
        var bScrollbars = false;
        var winleft = parseInt((screen.width - iWidth) / 2);
        var wintop = parseInt((screen.height - iHeight) / 2);
        if (isIE)
        {
            strFeatures += ",left=" + winleft + ",top=" + wintop;
        }
        else
        {
            strFeatures += ",screenX=" + winleft + ",screenY=" + wintop;
        }

        strFeatures +=  ",toolbar=no,location=no";

        if (bScrollbars) {strFeatures += ",scrollbars=yes"};

        var pDialog=null;
	//XSSOK
      emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context,reviseDialog)%>",iWidth,iHeight,false);
      
      }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<body onLoad="openWin()">

</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "emxDesignBottomInclude.inc"%>


