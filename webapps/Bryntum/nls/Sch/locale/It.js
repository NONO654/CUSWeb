/*

Ext Gantt 2.2.23
Copyright(c) 2009-2014 Bryntum AB
http://bryntum.com/contact
http://bryntum.com/license

*/
/**
 * Italian translations for the Scheduler component
 *
 * NOTE: To change locale for month/day names you have to use the corresponding Ext JS language file.
 */
Ext.define('Sch.locale.It', {
    extend      : 'Sch.locale.Locale',
    singleton   : true,

    l10n        : {
        'Sch.util.Date' : {
            unitNames : {
                YEAR        : { single : 'anno',    plural : 'anni',   abbrev : 'anno' },
                QUARTER     : { single : 'trimestre', plural : 'trimestri',abbrev : 'q' },
                MONTH       : { single : 'mese',   plural : 'mesi',  abbrev : 'mese' },
                WEEK        : { single : 'settimana',    plural : 'settimane',   abbrev : 'sett' },
                DAY         : { single : 'giorno',     plural : 'giorni',    abbrev : 'g' },
                HOUR        : { single : 'ora',    plural : 'ore',   abbrev : 'o' },
                MINUTE      : { single : 'minuto',  plural : 'minuti', abbrev : 'min' },
                SECOND      : { single : 'secondo',  plural : 'secondi', abbrev : 's' },
                MILLI       : { single : 'ms',      plural : 'ms',      abbrev : 'ms' }
            }
        },

        'Sch.view.SchedulerGridView' : {
            loadingText : 'Caricamento eventi...'
        },

        'Sch.plugin.CurrentTimeLine' : {
            tooltipText : 'Tempo attuale'
        },

        'Sch.plugin.EventEditor' : {
            saveText    : 'Salva',
            deleteText  : 'Elimina',
            cancelText  : 'Annulla'
        },

        'Sch.plugin.SimpleEditor' : {
            newEventText    : 'Nuova prenotazione...'
        },

        'Sch.widget.ExportDialog' : {
            generalError                : 'Errore, prova nuovamente.',
            title                       : 'Impostazioni Esportazione',
            formatFieldLabel            : 'Formato carta',
            orientationFieldLabel       : 'Orientamento',
            rangeFieldLabel             : 'Intervallo di esportazione',
            showHeaderLabel             : 'Aggiungi numero pagina',
            orientationPortraitText     : 'Verticale',
            orientationLandscapeText    : 'Orizzontale',
            completeViewText            : 'Programmazione completa',
            currentViewText             : 'Vista attuale',
            dateRangeText               : 'Intervallo date',
            dateRangeFromText           : 'Esporta da',
            pickerText                  : 'Ridimensiona colonne/righe al valore desiderato',
            dateRangeToText             : 'Esporta a',
            exportButtonText            : 'Esporta',
            cancelButtonText            : 'Annulla',
            progressBarText             : 'Esportazione in corso...',
            exportToSingleLabel         : 'Esporta come pagina singola',
            adjustCols                  : 'Imposta larghezza colonna',
            adjustColsAndRows           : 'Imposta larghezza colonna e altezza riga',
            specifyDateRange            : 'Specifica intervallo date'
        },

        // -------------- View preset date formats/strings -------------------------------------
        'Sch.preset.Manager' : {
            hourAndDay : {
                displayDateFormat : 'G:i',
                middleDateFormat : 'G:i',
                topDateFormat : 'D d/m'
            },

            secondAndMinute : {
                displayDateFormat : 'G:i',
                topDateFormat : 'D, d/m G:i'
            },

            dayAndWeek : {
                displayDateFormat : 'd/m h:i A',
                middleDateFormat : 'D d M'
            },

            weekAndDay : {
                displayDateFormat : 'd/m',
                bottomDateFormat : 'd M',
                middleDateFormat : 'Y F d'
            },

            weekAndMonth : {
                displayDateFormat : 'd/m/Y',
                middleDateFormat : 'd/m',
                topDateFormat : 'd/m/Y'
            },

            weekAndDayLetter : {
                displayDateFormat : 'd/m/Y',
                middleDateFormat : 'D d M Y'
            },

            weekDateAndMonth : {
                displayDateFormat : 'd/m/Y',
                middleDateFormat : 'd',
                topDateFormat : 'Y F'
            },

            monthAndYear : {
                displayDateFormat : 'd/m/Y',
                middleDateFormat : 'M Y',
                topDateFormat : 'Y'
            },

            year : {
                displayDateFormat : 'd/m/Y',
                middleDateFormat : 'Y'
            }
        }
    }
});
