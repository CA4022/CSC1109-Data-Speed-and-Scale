---
title: "Bonus Lab 1: Big Data Cloud"
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

High level steps (follow step-by-step
[here](https://cloud.google.com/dataproc/docs/tutorials/gcs-connector-spark-tutorial)):

- Make sure your project is linked to a billing account (you will see automatically that this
shows your credit.
- You will need three services: Cloud DataProc, Compute Engine and Cloud Storage: looking for
them in the Library page and Enable them if not enabled.
- Create a Storage bucket
- Activate the GCP shell and upload your file `my-file.py` using the upload menu option (or from
git)
- Create a cluster, remember to change your worker nodes to work with 2CPUs instead of 4 to stay
within the free tier quota (you find the "create cluster"option in the Big Data section of the
menu, under Dataproc)
- Submit job (using the `gcloud` command)

```sh
gcloud dataproc jobs submit pyspark my-file.py \
    --cluster=${CLUSTER} \
    --region=${REGION} \
    -- gs://${BUCKET_NAME}/input/ gs://${BUCKET_NAME}/output/
```

- View output via the GCP shell
- Delete cluster

### DataProc Resources ###

- Details on how to redeem your credits can be found online
- General Introduction to Google Cloud Platform (GCP)
[Youtube Videos](https://youtu.be/4D3X6Xl5c_Y)
- Intro to Hadoop and Spark on GCP [Youtube Video](https://www.youtube.com/watch?v=h1LvACJWjKc)
- Qwik Start lab on Dataproc [Run by Google Cloud Platform](http://bit.ly/2KZaZJM)
