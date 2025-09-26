Inspired by / based on https://github.com/JakeWharton/docker-gphotos-sync (thanks Jake!)

## Initial authentication

Clone this repo and make sure to have `docker` and `make` installed, then use 

    make auth

to create an authenticated profile dir. 

**IMPORTANT**: Follow the instructions in the terminal to complete authentication, you'll be prompted to open Chrome at URL http://localhost:6080 and click on `open-chrome.sh` to perform Google authentication. This will create a `profile` directory in your current folder, that will be reused for subsequent actions.

Plase note you can also optionally customize the following parameters in .env

    TZ=Europe/Berlin # timezone
    CRON_SCHEDULE=27 * * * *
    RESTART_SCHEDULE=26 1 * * 0
    HEALTHCHECK_ID=d6e4a333-ce52-4129-9d3e-6722c3333333 # from healthcheck.io
    ALBUMS=ALL

To check everything's ok and run the initial (massive) download 

    make test

You can let it complete for your initial sync.

## Notes 

Files deleted on Google Photos after being downloaded will not be deleted locally, but a list of such files will be saved to `.removed`.

Each synced item will be downloaded to its own subfolder in your download directory. This folder may contain multiple items in case of live photos, edited photos, etc. If you delete this folder or its contents, it will be downloaded again at the next run.

## Downloading an album

Set ALBUMS to a comma seperated list of album IDs, where the album URL is:

```
https://photos.google.com/album/{ALBUM_ID}
```

You can provide just the album ID for normal albums, or the whole relative path in case of other types of albums (e.g. `shared/<SHARED_ALBUM_ID>`). By default all albums will be downloaded due to default `ALBUMS=ALL`

## Regarding language

It may be necessary to set your account language to "English (United States)" for this to work (see [#2](https://github.com/spraot/gphotos-sync/issues/2)). This is the likely cause if you see date parsing errors or similar. Help localizing [gphotos-cdp](https://github.com/spraot/gphotos-cdp/issues/2) is welcome.

## Issues caused by highlight videos

Google Photos has a feature that automatically generates highlight videos. If you save these to your account, they can cause issues with syncing. Generally they cannot be downloaded or viewed from the browser and they occasionally cause the Google Photos UI (and therefore this sync service) to freeze. I suggest deleting these from your account and restarting the sync service. If you still see issues check that your .lastdone file does not contain the URL to a highlight video.

## ~~Legacy mode (not available anymore)~~

Setting `GPHOTOS_CDP_ARGS=-legacy` will cause the sync to run in "legacy" mode. This mode is *much* slower at scanning through your entire library, but is much faster at doing the initial synchronization (where all files need to be downloaded). Thus using -legacy for the initial synchronization can be helpful. Switching between regular and legacy mode can be done at any time.

In legacy mode, syncs always start where the last run ended, so if we want to check for new files that have a 'date taken' older than that file, you will need to delete the `.lastdone` file. RESTART_SCHEDULE automates this by deleting .lastdone file on the cron schedule givenso that the next sync will start from the beginning (skipping already downloaded files).

Note: if using -legacy mode and ALBUMS, the albums must be sorted newest first, otherwise files added after the initial sync will not be downloaded.