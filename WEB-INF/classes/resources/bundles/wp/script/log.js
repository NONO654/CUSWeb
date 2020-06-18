define('ds/log', ['DS/Logger/Logger'], function (Log) {
    'use strict';
    Log.warn('Please do not use `ds/log` since it is deprecated in favor of `DS/Logger/Logger`');
    return Log;
});
