// Required for chrome/userChrome.css to load.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// DOM fullscreen fills the content area, not the monitor, so video obeys the niri tile.
user_pref("full-screen-api.ignore-widgets", true);
