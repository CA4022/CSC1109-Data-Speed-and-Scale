# Lists available just commands
default:
    @just --list

# Commands below delegate to justfiles in subfolders
# Base image commands
base command *args:
    cd ./containers/base/ && just {{command}} {{args}}
