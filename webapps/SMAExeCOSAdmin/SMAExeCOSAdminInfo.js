define('DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
    [],
    /*
	 * stores data to be used by widget processing
     */
    function ( ) {
         'use strict';
         var AdminInfo = {};

         // holds the skeleton
         var bones = null;

         // holds the outer container of the widget body
         var outerContainer = null;

         // holds the widget
         var adminWidget = null;

         // holds event log dialog line editor for filtering event messages
         var eventMsgFilter = null;

         // holds event log dialog line editor for filtering cluster member
         var eventMemberFilter = null;
         
         // holds map by server name of the member's facet tab 
         // so it can be shown or hidden based on deploy type
         var memberFacetMap = new Map();

         // holds event log dialog more button for getting additional event messages
         var eventMoreBtn = null;
         AdminInfo = {
        		 // define gettr and settr methods for the data
            	 setBones : function (val) {
            		 bones = val;
            	 },
            	 getBones : function () {
            		 return bones;
            	 },
            	 setContainer : function (val) {
            		 outerContainer = val;
            	 },
            	 getContainer : function () {
            		 return outerContainer;
            	 },
            	 setWidget : function (val) {
            		 adminWidget = val;
            	 },
            	 getWidget : function () {
            		 return adminWidget;
            	 },
            	 setMemberFilter : function (val) {
            		 eventMemberFilter = val;
            	 },
            	 getMemberFilter : function () {
            		 return eventMemberFilter;
            	 },
            	 setFilter : function (val) {
            		 eventMsgFilter = val;
            	 },
            	 getFilter : function () {
            		 return eventMsgFilter;
            	 },
            	 setMoreBtn : function (val) {
            		 eventMoreBtn = val;
            	 },
            	 getMoreBtn : function () {
            		 return eventMoreBtn;
            	 },
            	 setMemberFacet : function (name,facet) {
					 memberFacetMap.set(name,facet);
				 },
			 	 getMemberFacet : function (name) {
            	 	return memberFacetMap.get(name);
				 }

         };


        return AdminInfo;
});
