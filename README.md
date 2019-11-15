# PolyLogyx Endpoint Security Platform (ESP) - Community Edition
PolyLogyx ESP leverages the [osquery](https://osquery.io/) tool, with [PolyLogx Extension](https://github.com/polylogyx/osq-ext-bin) to provide endpoint visibility and monitoring. To get the details of the architecture of the full platform, please read the [platform docs](https://github.com/polylogyx/platform-docs). This repository provides the community release of the platform which focuses on the Osquery based agent management to provide visbility into endpoint activities, query configuration management, a live query interface and alerting capabilities based on security critical events.

## Prerequisites
- git client software
- Internet connectivity
- 5000 and 9000 ports should be available and accessible through firewall
- Docker(18.03.1-CE or above) and [docker-compose (1.21.1 or above)](https://docs.docker.com/compose/install/#install-compose)


## Build and Deploy

After you install Docker and Docker Compose, you can install the PolyLogyx
server.

1.  Clone the PolyLogyx ESP repository.

    ```~/Downloads$ git clone https://github.com/polylogyx/plgx-esp.git```
     ```<snip>
    Cloning into 'plgx-esp'...
   
2.  Switch to the folder where the repository is cloned.

    ```~/Downloads\$ cd plgx-esp/```
3.  Run the certificate-generate.sh script file to generate certificates for
    osquery.  
    ```~/Downloads/plgx-esp$ sh ./certificate-generate.sh <IP address>```
    ```x.x.x.x
    Generating a 2048 bit RSA private key
    .........................................................................................+++
    .........................+++
    writing new private key to 'nginx/private.key'
    ``` 
            
    In the syntax, \<IP address\> is the IP address of the system on which to host the PolyLogyx server. This will generate 
    the certificate for osquery (used for provisioning clients) and place the certificate in the nginx folder.

4.  Modify and save the .env file.

    1.  Edit the following configuration parameters in the file. In the syntax, replace the values in angle brackets with required values.
    ```
    ENROLL_SECRET=<secret value>
    POLYLOGYX_USER=<user login name> 
    POLYLOGYX_PASSWORD=<login password> 
    RSYSLOG_FORWARDING=true
    VT_API_KEY=<VirusTotal Api Key> 
    IBMxForceKey=<IBMxForce Key> 
    IBMxForcePass=<IBMxForce Pass>
    PURGE_DATA_DURATION=<number of days>  
    THREAT_INTEL_LOOKUP_FREQUENCY=<number of minutes>
     ```   
| Parameter | Description                                                                                                                                                                                  |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ENROLL_SECRET | Specifies the enrollment shared secret that is used for authentication.                                                                                                                              |
| POLYLOGYX_USER       | Refers to the user login name for the PolyLogyx server.                                                                                                         |
| POLYLOGYX_PASSWORD       | Indicates to the password for the PolyLogyx server user.                                                                                                              |
| RSYSLOG_FORWARDING       | Set to true to enable forwarding of osquery and PolyLogyx logs to the syslog receiver by using rsyslog. |                                                                         |  
| VT_API_KEY       | Represents the VirusTotal API key.                                                                            | 
| IBMxForceKey       | Represents the IBMxForce key.                                                                            | 
| IBMxForcePass       | Specifies the IBMxForce pass.                                                                            | 
| PURGE_DATA_DURATION       | Specifies the frequency (in number of days) for purging the data.                                                                            | 
| THREAT_INTEL_LOOKUP_FREQUENCY       | Specifies the frequency (in minutes) for fetching threat intelligence data.                                                                            |   
 
 2. Save the file.
    
6.  Run the following command to start Docker compose.

    ```docker-compose -p 'plgx-esp' up -d```
    
    Typically, this takes approximately 10-15 minutes. The following lines appear on
    the screen when Docker starts:
    ````Starting plgx-esp_rabbit1_1  ... done
        Starting plgx-esp_postgres_1 ... done
        Starting plgx-esp_plgx-esp_1     ... done
        Attaching to plgx-esp_rabbit1_1, plgx-esp_postgres_1, plgx-esp_plgx-esp_1
        .
        .
        .
        Server is up and running```
        
7.  Log on to server using following URL using the latest version of Chrome or
    Firefox browser.
    
    ```https://<ip address>:5000/manage```

    In the syntax, `<IP address>` is the IP address of the system on which the
    PolyLogyx server is hosted. This is the IP address you specified in step 3.

8.  Ignore the SSL warning, if any.

9.  Log on to the server using the credentials provided above at step 5a.

10.  Provision the clients. For more information, see [Provisioning the PolyLogyx
    Client for Endpoints](https://github.com/polylogyx/platform-docs/tree/master/03_Provisioning_Polylogyx_Client).

## Uninstalling the Server 
------------------------

To uninstall the PolyLogyx server, run the following command to clean-up
existing Docker images and containers.

```~/Downloads\$ sh ./docker-cleanup.sh```

**Note:** This will clean **all** the images and containers.

## PolyLogyx ESP Components
- plgx-esp - Manages requests coming from endpoint
- plgx-esp-ui - Mangement server for taking actions, modifying properties  of an endpoint.
- RabbitMQ
- nginx
- rSysLogF
- postgres

## Agent Configuration
PolyLogyx ESP leverages osquery's TLS configuration, logger, and distributed read/write endpoints and provides a basic set of default configurations to simplify Osquery deployment. The platform also provides a Client Provisioning Tool (CPT) that wraps the agent installation via a thin installer. The CPT tool can be downloaded from the main page on the server UI which also gives the instruction on running the CPT at individual endpoint. For mass deployment, a centralized system like SCCM can be used.

## Supported Endpoints
Osquery is cross platform agent that supports 64 bit variants of Windows (7 and above), MacOS and all the popular Linux distributions (Ubuntu, Centos, RedHat etc). PolyLogyx ESP's agent is built upon Osquery and therefore the supported endpoints are the ones as supported by Osquery.

## PolyLogyx ESP API SDK
PolyLogyx ESP can be programatically interacted with using the extensive  [REST API](https://github.com/polylogyx/platform-docs/tree/master/13_Rest_API) interface. This allows for multiple use case like Incident Response, Threat Hunting, Compromise Assessment, Compliance checks etc to be easily served with the platform. This also provides an easy for integration with [SOAR platforms](https://youtu.be/XbpleymXpSg) 

## Integration with Big Data/Analytic systems
PolyLogyx ESP is packaged with an rSysLog container. This container can be configured to stream the query results and other logs from the endpoint population to the back-end systems like Splunk, ELK, GrayLog etc for cross-product correlation, alert enrichments and other SIEM related use cases.

To configure rsyslog forwarding modify the [rsyslogd.conf](rSysLogF/rsyslogd.conf) and specify the destination address of the server accepting logs in syslog format.

## PolyLogyx ESP - Community Edition License
Please read the [LICENSE](LICENSE) file for details on the license.

## PolyLogyx ESP - Enterprise Edition
PolyLogyx ESP comes with an enterprise flavor with advanced set of features and dedicated support. More about the enterprise edition of ESP can be learned [here](https://github.com/polylogyx/platform-docs)  or send an email to info@polylogyx.com

