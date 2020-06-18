<%--  emxPrefHomePageProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefHomePageProcessing.jsp.rca 1.7 Wed Oct 22 15:47:55 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    // check if change has been submitted or just refresh mode
    // Get Home Page
    String homePage = emxGetParameter(request, "homePage");

    // if change has been submitted then process the change
    if (homePage != null)
    {
        try
        {
            ContextUtil.startTransaction(context, true);

            if ("default".equals(homePage) || "AEFPowerViewHome".equals(homePage) || "AEFChannelUIHomePage".equals(homePage))
            {
                PersonUtil.setMenu(context, homePage);
                PersonUtil.setCommand(context, homePage);
            }
            else
            {
                StringTokenizer st = new StringTokenizer(homePage, "|");
                if (st.countTokens() == 2)
                {
                    PersonUtil.setMenu(context, st.nextToken());
                    PersonUtil.setCommand(context, st.nextToken());
                }
            }
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxPrefHomePage:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
    }
%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

