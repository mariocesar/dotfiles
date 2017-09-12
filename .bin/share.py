#!/usr/bin/env python

import os

from wsgidav.fs_dav_provider import FilesystemProvider
from wsgidav.version import __version__
from wsgidav.wsgidav_app import DEFAULT_CONFIG, WsgiDAVApp

__docformat__ = "reStructuredText"

provider = FilesystemProvider(os.getcwd())

config = DEFAULT_CONFIG.copy()
config.update({
    "provider_mapping": {"/": provider},
    "user_mapping": {},
    "verbose": 1,
    "enable_loggers": [],
    "propsmanager": True,      # True: use property_manager.PropertyManager
    "locksmanager": True,      # True: use lock_manager.LockManager
    "domaincontroller": None,  # None: domain_controller.WsgiDAVDomainController(user_mapping)
    })

app = WsgiDAVApp(config)

# For an example. use paste.httpserver
# (See http://pythonpaste.org/modules/httpserver.html for more options)
from paste import httpserver
httpserver.serve(app,
                 host="0.0.0.0",
                 port=8080,
                 server_version="WsgiDAV/%s" % __version__,
                 )
