# Current status

Year 1 of labs have been run successfully.

## Notes

- Hive lab is prone to breakage, just switch to Tez
- RAM usage is a consistent problem. wasting several GB just for JVMs in containers. Try finding some solution for reducing JVM overhead. Maybe switch to OpenJ9 with shared object cache?
- Current curriculum is somewhat out-of-date re: streaming. Streaming is far more relevant nowadays than it was back when course materials were first written. Need to expand beyond just Storm.
- Deploying in cloud made it clear that the sandbox should have more tools for java/scala packaging. add maven and sbt. (DONE)
- Need fallback for deploying without a lab.md file (DONE)

## Ideas

- Add "fresh" as editor for more VSCode-like experience (DONE)
- Add rudimentary observability without abstracting away programs, e.g: btm and podman-tui (DONE)
- Maybe switch to a more efficient and maintainable build system? e.g: kiwi? (probably best) nix? guix? Even just asdf?
- For higher level tools, maybe replace java with kotlin? or somehow add kotlin as a more sane alternative to raw java
- Add newer *important* tools if time will allow: e.g. ceph, flink, kafka
