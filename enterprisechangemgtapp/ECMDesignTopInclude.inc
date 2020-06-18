<%-- ECMDesignTopInclude.inc   -  Top Level Include File for EnterpriseChangeMgt Suite

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.util.*,
                   java.util.List"%>

<%@ page import =  "com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.EngineeringChange,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager" %>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*,
                   com.dassault_systemes.enovia.enterprisechangemgt.common.*, 
                   com.dassault_systemes.enovia.enterprisechangemgt.admin.*,
                   com.dassault_systemes.enovia.enterprisechangemgt.util.*" %>

<%@include file = "../common/emxNavigatorInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript" src="../emxUIFilterUtility.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICommonHeaderBeginJavaScriptInclude.js"></script>
<script language="JavaScript" src="../common/scripts/emxUISlideIn.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>




