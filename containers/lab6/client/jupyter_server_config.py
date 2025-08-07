import shutil


c = get_config()  # noqa
c.IdentityProvider.token = ""
c.ServerApp.password = ""
c.ServerApp.allow_unauthenticated_access = True
c.ServerApp.open_browser = False
c.ContentsManager.allow_hidden = True

c.LanguageServerManager.language_servers = {
    "pyright": {
        "argv": [shutil.which("pyright-langserver"), "--stdio"],
        "languages": ["python"],
        "version": 2,
        "mime_types": ["text/x-python"],
        "display_name": "Python Language Server (Pyright)",
    },
    # "metals": {
    #     "argv": [shutil.which("metals")],
    #     "languages": ["scala", "java", "java-source"],
    #     "version": 2,
    #     "mime_types": ["text/x-scala", "text/x-java", "text/x-java-source"],
    #     "display_name": "Scala/Java Language Server (Metals)",
    # },
}
