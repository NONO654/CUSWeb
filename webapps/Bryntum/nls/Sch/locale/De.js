/**
 * English translations for the Scheduler component
 *
 * NOTE: To change locale for month/day names you have to use the corresponding Ext JS language file.
 */
Ext.define('Sch.locale.De', {
    extend      : 'Sch.locale.Locale',
    singleton   : true,

    l10n        : {
        'Sch.util.Date' : {
            unitNames : {
                YEAR        : { single : 'Jahr',    plural : 'Jahre',   abbrev : 'J' },
                QUARTER     : { single : 'Quartal', plural : 'Quartale',abbrev : 'Q' },
                MONTH       : { single : 'Monat',   plural : 'Monate',  abbrev : 'Mo' },
                WEEK        : { single : 'Woche',    plural : 'Wochen',   abbrev : 'Wo' },
                DAY         : { single : 'Tag',     plural : 'Tage',    abbrev : 'T' },
                HOUR        : { single : 'Stunde',    plural : 'Stunden',   abbrev : 'h' },
                MINUTE      : { single : 'Minute',  plural : 'Minuten', abbrev : 'min' },
                SECOND      : { single : 'Sekunde',  plural : 'Sekunden', abbrev : 's' },
                MILLI       : { single : 'Millisekunde',      plural : 'Millisekunden',      abbrev : 'ms' }
            }
        },

        'Sch.view.SchedulerGridView' : {
            loadingText : 'Ereignisse werden geladen...'
        },

        'Sch.plugin.CurrentTimeLine' : {
            tooltipText : 'Aktuelle Zeit'
        },

        'Sch.plugin.EventEditor' : {
            saveText    : 'Speichern',
            deleteText  : 'Löschen',
            cancelText  : 'Abbrechen'
        },

        'Sch.plugin.SimpleEditor' : {
            newEventText    : 'Neue Buchung...'
        },

        'Sch.widget.ExportDialog' : {
            generalError                : 'Ein Fehler ist aufgetreten, bitte versuchen Sie es erneut.',
            title                       : 'Einstellungen exportieren',
            formatFieldLabel            : 'Papierformat',
            orientationFieldLabel       : 'Ausrichtung',
            rangeFieldLabel             : 'Exportbereich',
            showHeaderLabel             : 'Seitennummer hinzufügen',
            orientationPortraitText     : 'Hochformat',
            orientationLandscapeText    : 'Querformat',
            completeViewText            : 'Vollständige Ansicht',
            currentViewText             : 'Aktuelle Ansicht',
            dateRangeText               : 'Zeitraum',
            dateRangeFromText           : 'Exportieren ab',
            pickerText                  : 'Spalten/Reihen auf gewünschten Wert ändern.',
            dateRangeToText             : 'Exportieren bis',
            exportButtonText            : 'Exportieren',
            cancelButtonText            : 'Abbrechen',
            progressBarText             : 'Exportieren...',
            exportToSingleLabel         : 'Exportieren als einzelne Seite',
            adjustCols                  : 'Spaltenbreite anpassen',
            adjustColsAndRows           : 'Spaltenbreite und Höhe anpassen',
            specifyDateRange            : 'Datumsbereich festlegen'
        },

        // -------------- View preset date formats/strings -------------------------------------
        'Sch.preset.Manager' : {
            hourAndDay  : {
                displayDateFormat   : 'G:i',
                middleDateFormat    : 'G:i',
                topDateFormat       : 'D, d. M.'
            },

            secondAndMinute : {
                displayDateFormat   : 'G:i:s',
                topDateFormat       : 'D, d g:iA'
            },

            dayAndWeek      : {
                displayDateFormat   : 'd.m. h:i:A',
                middleDateFormat    : 'd.m.Y'
            },

            weekAndDay      : {
                displayDateFormat   : 'd.m.',
                bottomDateFormat    : 'd. M',
                middleDateFormat    : 'd.F.Y.'
            },

            weekAndMonth : {
                displayDateFormat   : 'd.m.Y',
                middleDateFormat    : 'd.m.',
                topDateFormat       : 'd.m.Y'
            },

            weekAndDayLetter : {
                displayDateFormat   : 'd.m.Y',
                middleDateFormat    : 'D, d. M. Y'
            },

            weekDateAndMonth : {
                displayDateFormat   : 'd.m.Y',
                middleDateFormat    : 'd',
                topDateFormat       : 'F.Y.'
            },

            monthAndYear : {
                displayDateFormat   : 'd.m.Y',
                middleDateFormat    : 'M. Y',
                topDateFormat       : 'J'
            },

            year : {
                displayDateFormat   : 'd/m/Y',
                middleDateFormat    : 'J'
            },

            manyYears : {
                displayDateFormat   : 'd.m.Y',
                middleDateFormat    : 'J'
            }
        }
    }
});
