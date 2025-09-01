---
title: "CSC1109: Data Speed and Scale"
---

{{ "# " ~ page.meta.title ~ " #" }}

## Introduction ##

Welcome to CSC1109! This lab will teach you how to handle big data at high speed and large scale.
In the modern data-driven world of online algorithmic engines and machine learning this is an
essential skill that no computer scientist or programmer should ignore.

This course will provide an introduction to the essential tools that underpin much of  our modern
big data processing infrastructure, including:

- &nbsp; Hadoop
- 󱀏&nbsp; Cluster computing
- 󰾡&nbsp; Hive
- 󱀆&nbsp; Pig
- &nbsp; Storm
- &nbsp; Spark

By the end of this lab, we will be putting all these newly learned skills to practical use by
creating a basic algorithm for movie recommendation. These kinds of algorithms are central to much
of the modern internet's data-driven, algorithmically curated content delivery platforms you
interact with every day.

### Core Skills ###

For this lab, students are expected to have some core skills that will be needed to effectively
follow along. If you struggle with the basics any of these skills, we recommend that you revise and
practice these skills to get the most out of this lab. These skills include:

- &nbsp; Shell usage and familiarity with basic CLI tools
- &nbsp; Familiarity with docker
- &nbsp; Basic java programming
- &nbsp; Basic python programming

NOTE: This domain of computing is dominated by tools, remote nodes, and distributed systems that
can only really be used in a CLI. We understand that many programmers prefer GUI tools and are not
very comfortable working in the CLI. For those programmers: don't be intimidated! The environment
provided for this module has been pre-configured to create a user friendly, efficient, and modern
CLI environment.

!!! NOTE "A note on **Big Data** and **HPC**"
    Throughout this lab, you will frequently see mention of tools and practises for High
    Performance Computing (HPC), so much so that you might be forgiven for thinking this is a
    HPC lab! Rest assured, you are in the right lab: "Data Speed and Scale", focused on handling
    extremely large datasets effectively. However, the topics of "Big Data" and HPC are somewhat
    inseparable because if we have **BIG** data, we inherently need **BIG** computational power if
    we want results in a reasonable timeframe. Your courses on HPC will have significant and
    important overlap with this one, so consider them complimentary to one another. After all: if
    you ever write code for a supercomputer or have to work on a massive cloud at an internet tech
    giant you'll be glad you know how to handle your data with speed **and** scale!

## Getting Set Up ##

For these labs, the host computer must have a working docker engine installed and configured.
Generally, working within docker is done via the command line. Because of this, we recommend for
students to have a command line environment they are comfortable working within configured.

>? TIP: As an optional extra quality-of-life feature the lab environment includes CLI symbols
> rendered via the popular `nerdfonts` glyph library. For the best possible experience in the CLI
> you may want to consider installing [one of these fonts](https://www.nerdfonts.com/font-downloads).

### Docker Setup ###

The first step is to ensure you have Docker installed and running. To verify your Docker
installation, run the following command in your terminal:

```sh
docker run hello-world
```

>? DANGER: Depending on your operating system and configuration, you might need to run Docker
> commands with `sudo`. On Linux, you can avoid this by adding your user to the `docker` group. See
> the Linux installation notes below for more details.

If the command runs successfully, you will see a confirmation message from Docker, and you can
proceed. If not, please follow the installation instructions for your operating system below.

<!-- pyml disable MD046 -->
=== "&nbsp; Windows and &nbsp; MacOS"

    For Windows and MacOS, you will need to install **Docker Desktop**. Follow the official
    installation instructions for your operating system:

    - [Windows ](https://docs.docker.com/desktop/install/windows-install/)
    - [MacOS ](https://docs.docker.com/desktop/install/mac-install/)

    Docker Desktop includes the Docker Engine, the `docker` command-line interface (CLI), and other
    tools in a single application.

=== "&nbsp; Linux"

    For Linux distributions, it is recommended to install the Docker Engine from Docker's official
    repositories to ensure you have the latest version. While you can install from your
    distribution's default repositories, the package may be outdated.

    Here is a general guide for `systemd`-based distributions like Fedora, Ubuntu, and others:

    **Install Docker Engine**

    Follow the official instructions for your specific distribution:

    - [&nbsp; Fedora](https://docs.docker.com/engine/install/fedora/)
    - [󰕈&nbsp; Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    - [&nbsp; Other distributions](https://docs.docker.com/engine/install/)

    For example, on Fedora, the commands would be:

    ```sh
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo [https://download.docker.com/linux/fedora/docker-ce.repo](https://download.docker.com/linux/fedora/docker-ce.repo)
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

    **Start and enable the Docker service**

    ```sh
    sudo systemctl start docker
    sudo systemctl enable docker
    ```

    **Manage Docker as a non-root user (Optional)**

    This setup step is optional, but recommended for convenience. To run `docker` commands without
    sudo, you need to add your user to the `docker` group.

    ```sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```

    You will need to log out and log back in for this change to take effect.

    >? TIP: Alternatively, you can install **Docker Desktop for Linux**, which provides a graphical
    > user interface and integrates with your desktop environment. You can find the installation
    > instructions [here](https://docs.docker.com/desktop/install/linux-install/).
<!-- pyml enable MD046 -->

In addition to installation, you may also need to increase the resources available to docker to
ensure you can reliably run the simulated distributed systems that we will be running in this lab.
To do this, you can follow the instructions below.

=== "&nbsp; Windows and &nbsp; MacOS (Docker Desktop)"

    For Windows and MacOS, resource limits are managed through the Docker Desktop graphical interface.

    >? DANGER: **Allocate Sufficient Resources to Docker**
    >
    > Data processing frameworks like Spark and Hadoop can be very resource-intensive. By default,
    > Docker Desktop limits the amount of CPU and memory (RAM) it can use, which is often too low for
    > big data tasks. Insufficient resources can cause your programs to fail with cryptic errors
    > that are difficult to debug.
    >
    > Before proceeding, you **must** configure Docker to provide more resources.
    >
    > 1.  Open **Docker Desktop**.
    > 2.  Go to **Settings** (the gear icon ⚙️).
    > 3.  Navigate to the **Resources** > **Advanced** section.
    > 4.  Adjust the sliders to allocate **at least**:
    >     * **CPUs:** 4
    >     * **Memory:** 8 GB
    > 5.  Click **Apply & Restart**.
    >
    > > NOTE: If your computer has more resources available (e.g., 16GB of RAM or more), allocating
    > > more to Docker will result in better performance.

=== "&nbsp; Linux (Docker Engine CLI)"

    When using Docker Engine directly on Linux, resource limits are not set globally. Instead, they
    are specified for **each container** when you launch it using flags on the `docker run` command.
    containers deployed via the CLI are generally deployed in a more resource aware fashion than
    those deployed via the GUI, so you may not need to do this. However, if you find you are having
    frequent crashes try the following.

    >? DANGER: **Allocate Sufficient Resources to Your Container**
    >
    > Data processing frameworks like Spark and Hadoop can be very resource-intensive. You must
    > tell Docker to allocate enough CPU and memory to the lab container, otherwise your programs
    > may fail with cryptic errors.
    >
    > You will need to add the `--cpus` and `--memory` flags to the `docker run` command **every
    > time you start the lab environment.**
    >
    > For example, to start the base lab environment with 4 CPU cores and 8 GB of RAM, you would
    > modify the command like this:
    >
    > ```sh
    > docker run --cpus="4.0" --memory="8g" --privileged --hostname csc1109-base -it ghcr.io/ca4022/csc1109-base:latest
    > ```
    >
    > We recommend allocating **at least 4 CPUs and 8GB of memory** for the labs.
    >
    > > TIP: For a more graphical experience similar to Windows and macOS, you can install **Docker
    > > Desktop for Linux**. It provides a settings panel to manage default resource allocations for
    > > all containers, which can be more convenient.

## The Lab Environment ##

To ensure a predictable and reliable environment in which students can engage with these labs, we
have provided a collection of docker images, packaging tools and files needed for each lab. These
containers will act as a ready-to-go sandbox for students to follow along and explore the tools
being featured in each lab.

The base environment includes carefully curated quality of life tools
to ensure students can comfortably learn and practice in a command line environment. If you wish
to test the lab CSC1109 environment without any lab-specific tools or data being loaded into it
you can do so by running the following command:

```sh
docker run --hostname csc1109-base -it ghcr.io/ca4022/csc1109-base:latest
```

### Operating System ###

The image for this lab environment is based on OpenSUSE Leap. This is a community driven linux
distribution that acts as the non-enterprise stream for SUSE Linux Enterprise Server (SLES). SLES
is the most commonly used enterprise server operating system in Europe, so many students will be
likely to encounter this operating system regularly during the course of their careers. It offers
an extremely stable and reliable base on which to build server infrastructure, and has long been a
favourite as an underlying operating system for European cloud infrastructure.

### Startup ###

Upon running any lab environment image, the user will be prompted to select their preferred shell
environment and editor. The lab instructions are tested on each of these shells so any choice
should work for this lab. Because of this the choice of shell is left up to the user. However, for
those who are unsure we offer the following recommendations:

- 󰈺&nbsp; Fish: best for those who are less comfortable in a CLI environment
- &nbsp; Bash: recommended for those who prefer to stick with common, time-tested defaults
- &nbsp; Zsh: recommended for those who are reasonably familiar with CLI, particularly mac users
    as it is the OS X default shell
- ❯&nbsp; Nushell: good for advanced users, especially those already familiar with data processing paradigms

>? TIP: Each of these shells will look the same, but will give a visual indicator of which shell
> you are currently using in the form of a "prompt token". For example, if you chose `bash` as your
> shell you will see a `$` prompt token next to your cursor. In CLI documentation it is very
> important to pay attention to prompt tokens as they often tell us what environment a command is
> expected be executed within. Common prompt token shorthands include:
>
> - `#`: Root shell of any kind
>
> - `$`: Bash user shell
>
> - `%`: Zsh user shell
>
> - `>`: Fish user shell
>
> - `❯`: Nushell user shell
>
> These prompt token shorthands are not standardised by anyone, but are generally observed as
> convention among programmers.

As this lab will take place primarily in a command line environment, the editor options offered
include only a selection of CLI editors. These options include some of the most popular CLI editors
in current use, and we have included a selection that should be comfortable for users from complete
beginners to CLI editing to those who work primarily in a CLI. Recommendations on these options
for those who are unsure are:

- μ&nbsp; Micro: most beginner friendly of these editors, great for those who are less comfortable
    in a CLI
- &nbsp; Vim: for users who prefer modal editing, has a steep learning curve for new users
- &nbsp; Neovim: same advice as for Vim, but a bit more modern and customisable
- &nbsp; Emacs: non-modal modifier key based editing, has a similarly steep learning curve to Vim

Whichever of these editors are chosen, they will all include some basic quality-of-life plugins
such as LSP support and filetree navigation so that users can use them efficiently.

>? NOTE: For those who are relatively new to these CLI tools, we encourage you to take some time to
> try the various options and decide what you prefer. All of these tools are available in the lab
> environment regardless of which defaults you choose, so you can swap between them and experiment
> as much as you like until you find your favourites.

### Command Line Tools ###

As the lab environment is based on OpenSUSE, it's package manager is `zypper`. Packages can be
found using `zypper search` and installed using `zypper install`. For information on other
subcommands `zypper` makes available, you can type `zypper --help` for a comprehensive overview,
or `tldr zypper` for a quick cheatsheet.

The lab environment image base also includes a collection of carefully curated quality of life
tools to help you use the CLI more effectively. These include some drop-in modern equivalents of
common GNU coreutils and tools to help users navigate unfamiliar aspects of the environment. For
example, a cheatsheet can be displayed for (most) commands using the `tldr` command. e.g:

```sh
tldr compgen
```

## Oops, I Broke It! &nbsp; ##

We encourage students in this lab to play around with, explore, and discover the limits of the
tools we are teaching the use of. Of course, this does mean we expect that there will probably be
some weird and wonderful bugs and breakages encountered during the semester of labs. Should you
find one of these, we encourage you to see if you can figure out what went wrong. Lab time is,
however, limited and we recommend that you do not spend too long trying to figure it out yourself
before turning to ask your colleagues or supervisors for help! Debugging may be a key skill for
computer scientists, but so is collaboration and knowing when to ask for help tackling a problem.
We aim for these labs to act as environments for exploration, learning, and collaboration so we
encourage both the discovery of and collaborative fixing of bugs.

![XKCD 1739](https://imgs.xkcd.com/comics/fixing_problems.png#center)
