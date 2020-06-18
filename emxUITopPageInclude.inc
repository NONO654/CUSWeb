<%--  emxUITopPageInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "emxUITopInclude.inc"%>
<%
 String retstr = "";
String languageStr = request.getHeader("Accept-Language");

  boolean portalMode = false;
  String portalModeParam = emxGetParameter(request, "portalMode");

  if (portalModeParam != null && "true".equals(portalModeParam)) {
    portalMode = true;
  }

  String pageType = emxGetParameter(request, "pageType");

  String PageHeading            = emxGetParameter(request,"phead");
  String subPageHeading         = emxGetParameter(request,"shead");
  String objectIdParam          = emxGetParameter(request,"oidp");
  String stringResourceFile     = emxGetParameter(request,"strfile");

  if(PageHeading != null && PageHeading.indexOf("%") > -1){
        PageHeading = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(PageHeading);
  }
  String req            = emxGetParameter(request,"req");
  boolean doTranslate = true;
  if ((stringResourceFile == null) || ("".equals(stringResourceFile))){
	    doTranslate  = false;
	}

  if("header".equals(req) && !portalMode){
	  //CHANGES FOR COLLECTION
	  String actualPageHeading = "";
	  if(PageHeading!=null){
	    actualPageHeading = PageHeading;
	  }
	  //CHANGES FOR COLLECTION

	  //if no param, don't translate
	  if (doTranslate){
	    PageHeading = i18nNow.getI18nString(PageHeading,stringResourceFile,acceptLanguage);
	    if ((objectIdParam != null) && (!"".equals(objectIdParam))){
	      PageHeading = com.matrixone.apps.framework.ui.UINavigatorUtil.parseStringMacro(context,session,PageHeading,objectIdParam);
	      PageHeading = com.matrixone.apps.framework.ui.UIExpression.substituteValues(context, pageContext, PageHeading, objectIdParam);
	    }
	    else
	    {
		PageHeading = com.matrixone.apps.framework.ui.UIExpression.substituteValues(context, pageContext, PageHeading, null);
	    }

	  //CHANGES FOR COLLECTION
	    if ((PageHeading != null) && ("".equals(PageHeading))){
		PageHeading = actualPageHeading;
	    }

	    retstr = XSSUtil.encodeForHTMLAttribute(context, PageHeading);
	    }
	  } else if("subheader".equals(req)){
	    String stractualSubheading = "";
	    if(subPageHeading!=null)
	    {
	        stractualSubheading = subPageHeading;
	    }
	    if (doTranslate){
	    if (subPageHeading != null && !"".equals(subPageHeading) && !"null".equals(subPageHeading))
	    {
	    	StringList sHeadList = (StringList) FrameworkUtil.splitString(subPageHeading, "||~||");
	    	if (sHeadList.size() > 1) {
				subPageHeading = i18nNow.getI18nString((String) sHeadList.get(1),stringResourceFile, languageStr);
				subPageHeading = (String) sHeadList.get(0) + " "+ subPageHeading;
	    	} else {
				subPageHeading = i18nNow.getI18nString(subPageHeading,stringResourceFile, languageStr);
	    	}
	      if ((objectIdParam != null) && (!"".equals(objectIdParam)))
	      {
	        subPageHeading = com.matrixone.apps.framework.ui.UINavigatorUtil.parseStringMacro(context,session,subPageHeading,objectIdParam);
	        subPageHeading = com.matrixone.apps.framework.ui.UIExpression.substituteValues(context, pageContext, subPageHeading, objectIdParam);
	      }
	      else
	      {
	        subPageHeading = com.matrixone.apps.framework.ui.UIExpression.substituteValues(context, pageContext, subPageHeading, null);
	      }

	 //  Changing subpageheading as given in FS page if the subpageheading content is not defined in properties file.
	      if((subPageHeading != null) && ("".equals(subPageHeading)))
	      {
	          subPageHeading = stractualSubheading;
	      }

	    }
	  }
	  if(subPageHeading == null) {
		  subPageHeading = "";
	  }
	  retstr =  XSSUtil.encodeForHTMLAttribute(context, subPageHeading);
  } else if("filt".equals(req)){

  String UseFilter    = emxGetParameter(request,"useft");
      String PageFilter     = emxGetParameter(request,"mx.page.filter");
  if (PageFilter == null){
    PageFilter = "";
  }

        String filterSelect = "";
        String tryselect = "";
        String catchselect = "";
        if (!portalMode && "true".equalsIgnoreCase(UseFilter) && "table".equalsIgnoreCase(pageType)) {
            int numFilterOptions        = new Integer(emxGetParameter(request,"fltnum")).intValue();
        	if(numFilterOptions >= 1) {
            	filterSelect = "try {";
        	String filterDisplay = "";
                String filterParam = "";
                String strSelected = "";
                // Filter Option Fix: Previously --> for(int opt=1;opt<numFilterOptions+1;opt++)
                int selindex = 0;
                for(int opt=0;opt<numFilterOptions;opt++) {
                        filterDisplay  = emxGetParameter(request,"fopt" + new Integer(opt).toString());
                        if (doTranslate) filterDisplay = i18nNow.getI18nString(filterDisplay,stringResourceFile,acceptLanguage);
                        filterParam    = emxGetParameter(request,"fparam" + new Integer(opt).toString());
                        if (PageFilter.equals(filterParam)) {
                        	selindex = opt;
    	                    tryselect += "filterselect.add(new Option(\"" + filterDisplay + "\", \"" + filterParam + "\", true), null);";
    	                    catchselect += "filterselect.add(new Option(\"" + filterDisplay + "\", \"" + filterParam + "\",false, true));";
                        } else {
	                    tryselect += "filterselect.add(new Option(\"" + filterDisplay + "\", \"" + filterParam + "\"), null);";
	                    catchselect += "filterselect.add(new Option(\"" + filterDisplay + "\", \"" + filterParam + "\"));";
                        }
                        strSelected = " ";
	            }
	            filterSelect += tryselect;
	            filterSelect += "} catch(e) {";
	            filterSelect += catchselect;
	            filterSelect += "}";
	            filterSelect += "filterselect.options[" + selindex + "].selected=true";
                }
         }else{
             filterSelect += "";
         }
        retstr = filterSelect;
  } else if("pt".equals(req)){
	  retstr = com.matrixone.apps.framework.ui.UINavigatorUtil.getProcessingText(context, acceptLanguage);
  }else if("pages".equals(req)){
	String beanName = emxGetParameter(request,"bean");
	int pages = 1;
	if( beanName != null && !"".equals(beanName)) {
		com.matrixone.apps.framework.ui.UITable pageTableBean = (com.matrixone.apps.framework.ui.UITable) session.getAttribute(beanName);
		if(pageTableBean != null)
		{
			pages = pageTableBean.getPages(context);
			if(pages <= 0) {
				pages = 1;
			}
		}
	}
	retstr = String.valueOf(pages);
  }
%>
 
  <%=retstr%>

