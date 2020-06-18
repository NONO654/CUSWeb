define('ds/PublicAPI', ['DS/UWPClientCode/PublicAPI', 'DS/Logger/Logger'], function (Deprecated, Log) {
    'use strict';
    Log.warn('Please do not use `ds/PublicAPI` since it is deprecated in favor of `DS/UWPClientCode/PublicAPI`');
    return Deprecated;
});
