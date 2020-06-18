<%--  emxTypeSelectorLoadFullTree.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTypeChooserCountTypes.jsp.rca 1.5 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%!
int countJSChildren ( matrix.db.Context context, String sTypeName, String languageStr, boolean observeHidden, boolean showIcons)
{
    int count = 0;
    
    try {

        String sSmallIcon=UINavigatorUtil.getTypeIconFromCache(sTypeName);
        if (sSmallIcon == null || sSmallIcon.length() == 0 )
        {
                sSmallIcon = "iconSmallDefault.gif";
        }

        //get child types
        StringList lstChildren = UINavigatorUtil.getChildrenTypeFromCache(sTypeName, observeHidden);

        //if there are any children
        if (lstChildren != null)
        {
            count += lstChildren.size();
            
                for (int i=0; i < lstChildren.size(); i++)
                {
                        String sBaseTypeName = (String) lstChildren.elementAt(i);
                        if(!observeHidden || !UINavigatorUtil.isHidden(sBaseTypeName)) {
                                count += countJSChildren(context, sBaseTypeName, languageStr, observeHidden, showIcons);
                        }
                }
        }

    } catch (Exception e) {
    
    }

    return count;
  }
%><%

  boolean showIcons = Boolean.parseBoolean(emxGetParameter(request, "showIcons"));
  int count = 0;
  
  try {
      String languageStr = request.getHeader("Accept-Language");
      String sType = emxGetParameter(request,"txtName");
      String ObserveHidden = emxGetParameter(request,"ObserveHidden");
      boolean bObserveHidden = true;
      if(ObserveHidden != null && ObserveHidden.equalsIgnoreCase("false"))
      {
         bObserveHidden=false;
      }

      int iNumTypes = Integer.parseInt(emxGetParameter(request, "numTypes"));
      count = iNumTypes;
      
      for (int i=0; i < iNumTypes; i++) {
        String sTypeName = emxGetParameter(request, "type" + String.valueOf(i));
        count += countJSChildren(context, sTypeName, languageStr, bObserveHidden, showIcons);
      }
    } catch (Exception e) {
    } %>
<%=count%>
