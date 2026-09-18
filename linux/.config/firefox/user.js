// Required for chrome/userChrome.css to load.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// GPU video decode on NVIDIA; VA-API is blocklisted and nvidia-vaapi-driver refuses the RDD sandbox.
user_pref("media.hardware-video-decoding-vulkan.enabled", true);
