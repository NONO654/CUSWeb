/*global
    define
*/

define('DS/TopBar/assets/nls/TopBar_temp', [
    'UWA/Core'
], function (Core) {

    'use strict';

    var _trads = {
        en: {
            search: 'Search'
        },
        fr: {
            search: 'Rechercher'
        },
        de: {
            search: 'Suchen'
        },
        ja: {
            search: '検索'
        },
        zh: {
            search: '搜索'
        }
    };

    return {
        init: function (options) {
            options = options || {};
            return Core.extend(this, _trads[options.lang] || _trads.en);
        }
    };
});
