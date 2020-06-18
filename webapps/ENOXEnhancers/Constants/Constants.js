define('DS/ENOXEnhancers/Constants/Constants', [
    'UWA/Core',
    'UWA/Controls/Abstract'
  ],
  function(
    Core,
    Abstract
  )
  {
    'use strict';
    var constants = {
      //code readibility constants
      EMPTY_STRING: '',
      SPACE: ' ',
      ACTION: 'Action',
      EMPTY_JSON_OBJECT:
      {},
      EMPTY_JSON_ARRAY: [],
      WILD_CHARACTER: '*',
      AMPERSAND: '&',

      // common constants
      ERROR: 'error',
      PRIMARY: 'primary',
      WARNING: 'warning',
      INFO: 'info',
      SUCCESS: 'success',
      PAD_CURRENT_SECURITY_CONTEXT: 'pad_security_ctx',
      PAD_AVAILABLE_SECURITY_CONTEXT: 'pad_security_ctx_list',
      PAD_PAD_CSRF_TOKEN: 'pad_csrf',
      PLATFORM_SERVICES: 'platformServices',

      //ENOVIA constants
      OBJECT_ID: 'id',
      PHYSICAL_ID: 'physicalid',
      REL_ID: 'id[connection]',
      REL_NAME: 'name[connection]',
      REL_PHYSICAL_ID: 'physicalid[connection]',
      TYPE: 'type',
      NAME: 'name',
      REVISION: 'revision',
      MODIFIED: 'modified',

      //Header constants
      ACCEPT_APPLICATION_JSON: 'application/json',
      SECURITY_CONTEXT_KEY: 'SecurityContext',
      CONTENT_TYPE: 'Content-Type',
      APPLICATION_URL_ENCODED: 'application/x-www-form-urlencoded',

      //Header Verbs
      GET: 'GET',
      POST: 'POST',
      PUT: 'PUT',
      //Tag
      CURRENT_TAG: 'Current-Tag'
    };

    return constants;
  });
