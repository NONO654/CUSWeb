define('ds/PubSub', ['DS/PubSub/PubSub', 'DS/Logger/Logger'], function (Deprecated, Log) {
    'use strict';
    Log.warn('Please do not use `ds/PubSub` since it is deprecated in favor of `DS/PubSub/PubSub`');
    return Deprecated;
});
