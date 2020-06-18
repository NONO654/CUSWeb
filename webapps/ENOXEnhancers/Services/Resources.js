define('DS/ENOXEnhancers/Services/Resources', [
    'UWA/Core',
    'UWA/Controls/Abstract'
  ],
  function(
    Core,
    Abstract
  )
  {
    'use strict';
    var Resources = {
      SET_PREFERENCE: '/resources/AppsMngt/user/preference',
      GET_PREFERENCE: '/resources/AppsMngt/user/getPreferences',
      PRINT_BUS: '/resources/v1/model/bus',
      _3DPLAY_ERROR_PAGE: '/webapps/3DPlayHelper/assets/images/3DPlayErrorPage.svg',
      _3DPLAY_LANDING_PAGE: '/webapps/3DPlayHelper/assets/images/3DPlayLandingPage.svg',
      CSRF: '/resources/v1/application/E6WFoundation/CSRF',
      SECURITY_CONTEXT: '/resources/pno/person/getsecuritycontext?tenant=',
      GET_TAGS: '/resources/e6w/servicetagdata',
      GET_SEARCH_RESULT: '/resources/e6w/servicetagdata/search'
    };

    return Resources;
  });
