---
title: "Bonus Lab 1: Cloudy with a chance of YARN calls &nbsp;&nbsp;"
---

{{ "# " ~ page.meta.title ~ " #" }}

## &nbsp; Amazon Web Services and EMR ##

In this labsheet we will deploy and run a simple MapReduce program onto AWS using Elastic
MapReduce (EMR). Please refer to the [official documentation](https://docs.aws.amazon.com/emr/)
for details.

Currently there is no free tier version of EMR but you can apply to get AWS credits through
[AWS Educate](https://aws.amazon.com/education/awseducate/) as a student.

### Setting up a Cluster ###

The key steps are as follows (see the
[AWS getting started guide](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-gs.html)
for details):

1. Develop your processing app (and identify your data)
2. Upload your application onto Amazon S3
3. Create an S3 bucket and an EC2 Key Pair
4. Configure and launch your EMR cluster
5. Monitor the cluster (optional), see [EMR-view](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-manage-view.html)
6. Retrieve output (on S3 or HDFS)

### AWS EMR Resources ###

- [EMR Masterclass](https://www.youtube.com/watch?v=zc1_Rfb_txQ)
- [What’s new in EMR, 2020](https://www.youtube.com/watch?v=1ZjTtCS3Kjk)
- [Spark on EC2 and EMR](https://www.youtube.com/watch?v=u5dFozl1fW8)

## &nbsp; Google DataProc ##

An alternative managed Hadoop MapReduce cloud service that is recently catching up with AWS is
[Google Cloud DataProc](https://cloud.google.com/dataproc). You can avail of $300 credits as a new
user when you sign in and this is immediate.

Three key steps:

- Creating your application
- Configure and start a cluster
- Submit your job to the cluster
- Delete your cluster

WARNING: Do not forget to delete your cluster to avoid unnecessary billing!

You can run MR jobs on Google DataProc in
[different ways](https://cloud.google.com/dataproc/docs/quickstarts).
We will focus on the use of the console in the steps below.

### Run a simple Spark job on Google DataProc ###

In your GCP console, you will see already that a project named "My First Project" is created. The
following steps are accessible by the menu list at the top left corner of your console window.

High level steps (more detailed step-by-step
[here](https://cloud.google.com/dataproc/docs/tutorials/gcs-connector-spark-tutorial)):

- Go to your [Google Cloud Console](https://console.cloud.google.com/)
- Create your project
- You will need to enable several APIs first:
    - Cloud Resource Manager API
    - Compute Engine API
    - Cloud Storage API
    - DataProc API
- Now, on the IAM dashboard you need to give your "Compute Engine default service account" user
    the following permissions:
    - Dataproc Administrator
    - Storage Admin
- **Optional:** if you need web access in your cluster, go to "Cloud NAT" and create a gateway for
    the "default" network.
- Return to the Dataproc section, choose "Cluster", and create your cluster
- Once your cluster is running, if you click on it you can access its various WebUIs under the
    "Web Interfaces" tab on this page.
- To get a shell on one of your nodes you can click the cloud terminal icon in the top right (or
    open a local terminal if you have the `gcloud` tool configured) and run
    `gcloud compute ssh {node_name}`
- Now you can submit your jobs in the "Jobs" section of the Dataproc panel

NOTE: You will need to ensure that your data and source code are accessible to your cluster nodes
    to run a job successfully. You can achieve this using google cloud storage, or by uploading
    these files to your hadoop cluster as we have been doing in other labs (either by running
    `hdfs dfs -put` or via the Hadoop WebUI).

### DataProc Resources ###

- Details on how to redeem your credits can be found online
- General Introduction to Google Cloud Platform (GCP)
[Youtube Videos](https://youtu.be/4D3X6Xl5c_Y)
- Intro to Hadoop and Spark on GCP [Youtube Video](https://www.youtube.com/watch?v=h1LvACJWjKc)
- Qwik Start lab on Dataproc [Run by Google Cloud Platform](http://bit.ly/2KZaZJM)
