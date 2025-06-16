export alias cat = bat
export alias grep = rg
export alias find = fd

def edit [...files] {
    if ($env.EDITOR | is-empty) {
        error make {
            msg: "The '$env.EDITOR' environment variable is not set."
            label: "You can set it in your config.nu file, for example: let-env EDITOR = nvim"
        }
        return
    }
    ^$env.EDITOR ...$files
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
