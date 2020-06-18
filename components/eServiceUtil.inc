<%--  eServiceUtil.inc   - utility functions for eService apps

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: eServiceUtil.inc.rca 1.9 Wed Oct 22 16:18:54 2008 przemek Experimental przemek $
--%>

<%!
  //
  // return the requested attribute value from BusinessObject
  //
  static public String getAttribute(matrix.db.Context context, HttpSession session,
                                    BusinessObject busObj,
                                    String attrName) throws MatrixException
  {

    //matrix.db.Context context = getPageContext();
    StringList selectStmts = new StringList();
    selectStmts.addElement("attribute[" + attrName + "]");

    BusinessObjectWithSelect _objectSelect = null;
    try {
      _objectSelect = busObj.select(context, selectStmts);
    }
    catch (MatrixException e)
    {
      busObj.open(context);
      _objectSelect = busObj.select(context, selectStmts);
      busObj.close(context);
    }
    finally {
      return _objectSelect.getSelectData("attribute[" + attrName + "]");
    }
  }
%>

