# Outline

For now, this readme is serving as a to-do list and notes page. These will be used for planning the
development of the updated CA4022 computer science module at DCU.

# Current status

Base image is set up, streamlined, automatically publishing and ready-to-go. Next, i will be
creating images derived from this base for each lesson plan.

# To Do

- [ ] Implement labs
    - [X] Use hadoop filesystem + run compiled mapreduce jar
    - [ ] Hadoop + hive for structured data
    - [X] Hadoop + pig for structured/semistructured data
    - [ ] Hive and Pig on Movielens (guided example)
    - [ ] Spark dataframes + run spark wordcount + a bit of spark-shell (scala examples) + a bit on pyspark
    - [ ] Spark ml (run examples from distribution) + ML pipelines (example email spam classification)
    - [ ] Recommender systems example (collaborative filtering from Spark ML)
    - [ ] STORM (just to run a simple topology)
- [X] Image building workflows
- [ ] Testing workflows
    - [ ] Every OS
    - [ ] Other OCI container systems? (if time allows. focus on docker primarily though)
        - [ ] Podman
            - [ ] runc
            - [ ] crun
        - [ ] Minikube
- [X] New lab documentation
    - [X] mkdocs + readthedocs?
    - [X] Executable docs
- [ ] Integrate with moodle? If possible/needed

# Notes

- Might need a shared base image with the core pieces that all of these lessons make use of (e.g: hadoop)
- Testing compatibility with other OCI systems (podman/runc, podman/crun, and minikube) is mostly
    for future-proofing. As long as we are also OCI compatible with both the major container
    engines and in both docker and kubernetes systems we are pretty well covered for any future
    movements in the container ecosystem.
- Executable docs would be great as they would allow us to test the code blocks in the guide to ensure
    that the lesson plan doesn't get broken as we tweak it in the future. Should allow us to focus on
    the content and worry less about minor mistakes that could create a debugging nightmare mid-lab.

# Design decisions

- What container env?
    - Though podman is seeing rapidly growing adoption and k8s is industrially preferred decided to
    stick with docker cos it is:
        - Simple
        - Reliable
        - Ubiquitous
    - Thanks to the OCI standards, we can also test on podman and k8s to ensure we have the option
    to switch easily in the future if needed
- Should docker-in-docker (dind) use parent socket or be 100% isolated?
    - Although setting up an isolated dind envs is more difficult, it also avoids reproducibility
    issues in the future by ensuring everyone running the containers will be using the same
    version, distro, runtimes, etc during labs. Decided tradeoff of extra time in dev was worth
    it here to avoid headaches during labs.
- What docker image to base on?
    - Decided to base on OpenSUSE Leap because:
        - It is stable
        - Students are very likely to encounter it (or SLE) in industry, especially if they stay in
        EU
        - The usual standard for light containers (alpine linux) runs on MUSL and busybox, which
        would add an extra layer of caveats to the labs that we don't need. SUSE allows us to
        go with the usual GNU toolchains (glibc and coreutils instead of MUSL and busybox).
- Decided to add some niceties to the terminal environment
    - Did this because raw terminal can be intimidating for some people, and we want to avoid that
    - Added choice of terminal environments:
        - fish for terminal newbies
        - bash because it's everywhere
        - zsh for students comfortable with macs
        - nu (probably mostly just for me?)
    - Added choice of editors:
        - micro for the complete terminal newbies
        - vim (cos, well, its vim. it has to be everywhere)
        - neovim
        - emacs
    - Added some basic QoL setups for those terminals and editors. Nothing fancy, just the minimum
        most modern users who work in terminals regularly would expect.
        - Added completions, syntax highlighting and other quality-of-life plugins for bash
        - Added a cleaner prompt to help orient students when they land inside the container
        - Added a bunch of modern unix tools to replace basic utilities
        - Added some orientation splashes on startup, to get students comfortable in the lab environment
- Made a fully automated container publishing pipeline for the base image, along with some
    automated script commands for managing calver versioning.
    - This provides us a hook to start building a CI/CD pipeline for course materials from.
    - This can ensure we will always have an up-to-date and working version of the base image to
        build lesson plans around.
    - It will also allow us to trigger rebuilds and testing of lessons whenever the base is changed.
        - Ensures consistent env across all lessons
- Made doc code blocks able to be automatically tested, to ensure that code for lessons does not
    break between changes. This will allow us to move a lot quicker on keeping the course
    up-to-date and in future updates to course materials.
    - Ensures all lesson plans continue to work, without manual testing being needed
    - Quickly lets us know if something does break, without having to wait until mid-labs!
