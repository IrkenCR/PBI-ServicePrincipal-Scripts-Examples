# How to: Using a Service Principal to take dataset ownsership and refresh the dataset 

Many customers who work with Service Principal wonder if it's possible to automate dataset refreshes using this tool. The answer is a resounding yes! In fact, using a Service Principal to set up credentials and perform refreshes can be extremely beneficial.

One of the main advantages of using a Service Principal is the ability to fully automate the publishing and deployment of solutions. This can save a significant amount of time and effort for your team.

Additionally, some companies experience high employee turnover, which can lead to issues with cloud credentials. By using a Service Principal, you can ensure that these credential issues are avoided when someone leaves the company.

This article will provide a step-by-step guide on how to use a Service Principal for dataset ownership and refresh, so that you can take full advantage of the benefits of automating these tasks.

We will do two scripts for the two possible scenarios:

![Service Principal Image](https://dsm04pap003files.storage.live.com/y4mc7Jn2qd7aPy8T6Zh3vTeLtq-8iGklBegbsRgz_2avfGbdirW1UamujvtB8tbj4rFaxu_cIzE3ilGnZGxOiH9SrrOXEnsfn0eLVkhq6VqkK8H__DkZv3sp-l-koz8vYcINgVJSGNla93DU3-8sifALMnYjqo6VGLHs5zcRVOktFe2RLYSN4YprEDvA_nFsa6w?encodeFailures=1&width=696&height=372)


## Scenario 1: Dataset using cloud credentials

The first scenario is more challenging, as each user has a virtual-personal gateway to store their cloud credentials. When you edit credentials for cloud connections on a dataset, those connections are stored in this virtual gateway.

To use cloud credentials for a Service Principal, you will need to locate the virtual gateway, add the data source connection, and update the credentials. This process can be tricky, but our script will guide you through each step.

## Scenario 2: Dataset using gateway connection

The second scenario is straightforward and does not require finding a virtual gateway. You can easily update the dataset credentials by using the gateway connection. Our script will walk you through the steps required to complete this scenario. 

## Knowledge share: On-Premises Data Gateways & Personal-Virtual Data Gateways

Both Users and Service Principals have dedicated virtual Data Gateways to securely store their cloud credentials. These Gateways serve as the intermediary between Power BI and the data source, enabling seamless data retrieval. Refer to the image below for a visual representation.

![Gateway Example](https://dsm04pap003files.storage.live.com/y4mSRucrJ1OZn0dydmxBSLALOshoLw9qTpb3ErC8NTQHMIAbS_l9HDzmbAIaMyWF5_8hmwMOqMV_K6OClZzux4mUdrVh_oKL9T5mPSgwtsrRu4pC2cijWaB5777QF8hM8Zdd5f2uscTgVq0LaBu1umrwtTAcxphsGozvkx6UY2vWM4yq9QebchhZ4OcIoAOHUbaiM-CGD2xKm94_LsiKSxZ9qnVxwA031AsYadbchLAaBA?encodeFailures=1&width=842&height=637)

# Script for Scenario 1:


