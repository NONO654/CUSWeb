<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%--
   emxDocumentCentralCommonBottomInclude.inc

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   Description: Bottom include page which catches the exception & format it.

   Author     : Anil

   Date       : 12/1/2002

   History    :

   static const char RCSID[] = "$Id: emxDocumentCentralCommonBottomInclude.inc.rca 1.7 Wed Oct 22 16:02:41 2008 przemek Experimental przemek $"
--%>

<%

    }
    catch(Exception e)
    {
        StringTokenizer st = new StringTokenizer((e.toString()).trim(), "\n");

        String msg = "";

        while(st.hasMoreTokens())
        {
         msg = (String)st.nextToken();
        }

        int index = msg.lastIndexOf(":");

        if(index == -1)
        {
         emxErrorString = msg;
        }
        else
        {
         emxErrorString = msg.substring(index+1);
        }

    }
    finally
    {
        emxNavErrorObject.addMessage(emxErrorString);
    }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
