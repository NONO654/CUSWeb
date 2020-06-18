<%-- emxMQLNoticeWrapper.jsp 

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMQLNoticeWrapper.jsp.rca 1.1.6.4 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $";
--%>

<%@ page import = "matrix.db.*, matrix.util.*,
                           com.matrixone.util.*,
                           com.matrixone.servlet.*,
                           com.matrixone.apps.framework.ui.*,
                           com.matrixone.apps.domain.util.*, 
                           com.matrixone.apps.domain.*, 
                           java.util.*, 
                           java.io.*, 
                           com.matrixone.jsystem.util.*"
                           errorPage="../common/emxNavigatorErrorPage.jsp"%>
                           


<%@include file = "emxNavigatorComponentSideDoorInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxNavigatorBaseInclude.inc"%>


<!-- ESAPI -->
<script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/esapi-min.js"></script>
<script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/resources/i18n/ESAPI_Standard_en_US.properties.js"></script>
<script type="text/javascript" language="JavaScript" src="../plugins/esapi4js/resources/Base.esapi.properties.js"></script>
<script type="text/javascript" language="JavaScript">
      org.owasp.esapi.ESAPI.initialize();
</script>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
