# Outline

For now, this readme is serving as a to-do list and notes page. These will be used for planning the
development of the updated CA4022 computer science module at DCU.

# To Do

- [ ] Implement labs
    - [ ] Use hadoop filesystem + run compiled mapreduce jar
    - [ ] Hadoop + hive for structured data
    - [ ] Hadoop + pig for structured/semistructured data
    - [ ] Hive and Pig on Movielens (guided example)
    - [ ] Spark dataframes + run spark wordcount + a bit of spark-shell (scala examples) + a bit on pyspark
    - [ ] Spark ml (run examples from distribution) + ML pipelines (example email spam classification)
    - [ ] Recommender systems example (collaborative filtering from Spark ML)
    - [ ] STORM (just to run a simple topology)
- [ ] Image building workflows
- [ ] Testing workflows
    - [ ] Every OS
    - [ ] Other OCI container systems? (if time allows. focus on docker primarily though)
        - [ ] Podman
            - [ ] runc
            - [ ] crun
        - [ ] Minikube
- [ ] New lab documentation
    - [ ] mkdocs + readthedocs?
    - [ ] Executable docs
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
