/**
 * @overview Translate UWA string into corresponding platform language.
 */
define('ds/TranslateUWA',
[
    // UWA
    'UWA/Core'
],
/**
 * Translate UWA string into corresponding platform language.
 *
 * @module ds/TranslateUWA
 *
 * @requires UWA/Core
 */
function (UWA) {

    'use strict';

    function init () {
        UWA.i18n({

            // UWA/js/Controls/DatePicker.js
            '{0} to {1}'  : '@@dateTodate@@',
            '{0} to now'  : '@@dateToNow@@',
            'Start'       : '@@startDate@@',
            'set end date': '@@setEndDate@@',
            'End'         : '@@endDate@@',

            // UWA/js/Controls/FeedView.js
            'There is no news in this feed.': '@@noItemFeed@@',
            'Load more news.'               : '@@loadMoreFeed@@',
            'Go to website'                 : '@@websiteLinkFeed@@',
            'Read more'                     : '@@readMoreFeed@@',

            // UWA/js/Controls/FeedView/Ticker.js
            'Share': '@@share@@',

            // UWA/js/Controls/Flash.js
            'You need Flash to display this Content.': '@@needFlash@@',

            // UWA/js/Controls/FlashPlayer.js
            'Full screen'     : '@@fullScreen@@',
            'Close Video'     : '@@closeVideo@@',
            'Close FullScreen': '@@closeFullScreen@@',

            // UWA/js/Controls/Form.js
            'Done': '@@done@@',

            // UWA/js/Controls/Input.js
            'Foo'      : '@@foo@@',
            'Foo 1'    : '@@foo1@@',
            'Foo 2'    : '@@foo2@@',
            'Bar'      : '@@bar@@',
            'Browse...': '@@browseInput@@',

            // UWA/js/Controls/Pager.js
            'prev': '@@prev@@',
            'next': '@@next@@',
            'more': '@@more@@',

            // UWA/js/Controls/SearchForm.js
            'Clear'                : '@@clear@@',
            'Search'               : '@@search@@',
            'Clear recent searches': '@@clearRecentSearches@@',

            // UWA/js/Controls/TabView.js
            'Loading...': '@@loading@@',

            // UWA/js/Environment.js
            'Widget by': '@@widgetBy@@',
            'Version'  : '@@version@@',

            // UWA/js/Environments/Frame.js
            'Edit'               : '@@edit@@',
            'Refresh'            : '@@refresh@@',
            'Share this widget'  : '@@shareThisWidget@@',
            'Powered by Netvibes': '@@poweredByNetvibes@@',

            // UWA/js/Plugins/Auth.js
            'Login'                                     : '@@login@@',
            'Password'                                  : '@@password@@',
            'Logout'                                    : '@@logout@@',
            'Sign In'                                   : '@@signIn@@',
            'Credentials validation loading...'         : '@@credentialsValidationLoading@@',
            'Authentication required!'                  : '@@authenticationRequired@@',
            'Login / Password combination is incorrect.': '@@loginPasswordIncorrect@@',

            // UWA/js/Plugins/Ecosystem.js
            'Unavailable Application'                                           : '@@unavailableApplication@@',
            'This Application is not available because it\'s under maintenance.': '@@applicationUnderMaintenance@@',
            'This Application is not available because it\'s suspended.'        : '@@applicationSuspended@@',

            // UWA/js/Services/Feed.js
            'Unknown Error'    : '@@unknownError@@',
            'Application Error': '@@applicationError@@',

            // UWA/js/String.js
            'less than a minute ago': '@@lessThanAMinuteAgo@@',
            'about a minute ago'    : '@@aboutAMinuteAgo@@',
            '{0} minutes ago'       : '@@minutesAgo@@',
            'about an hour ago'     : '@@aboutAnHourAgo@@',
            'about {0} hours ago'   : '@@aboutHoursAgo@@',
            'yesterday'             : '@@yesterday@@',
            '{0} days ago'          : '@@daysAgo@@'
        });
    }

    init();
});
