import boto3
import base64
from botocore.exceptions import ClientError
import datetime
import logging
import json
import os
from pymongo import MongoClient
from datetime import timedelta

# Logger settings - CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_secret_dict(secret_name, region_name):

    logger.debug("Getting the secrets as a dictionary")

    # Create a Secrets Manager client
    session = boto3.session.Session()
    secretClient = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = secretClient.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
            # Decrypts secret using the associated KMS CMK.
            # Depending on whether the secret is a string or binary, one of these fields will be populated.
            if 'SecretString' in get_secret_value_response:
                secret = get_secret_value_response['SecretString']
            else:
                secret = base64.b64decode(get_secret_value_response['SecretBinary'])
            logger.debug("Got the secrets as a dictionary")

    return json.loads(secret)  # returns the secret as dictionary


def age_off_form(form_id, friendly_form_name, age_off_days, submissions):

    logger.debug("Attempting to age off form {}".format(form_id))
    ageOffStatusCode = 200
    numFormsAgedOff = 0
    numFormSubmissionsRemaining = 0

    try:
        # Calculate the ageOffDate given the num of days to retain data
        ageOffDelta = timedelta(days=age_off_days)
        ageOffDate = datetime.datetime.today() - ageOffDelta

        # query submissions for forms with formId and created before ageOffDate
        logger.debug("getting the submissions older than {}".format(ageOffDate))

        ageOffResults = submissions.find({ 
            "$and": [ { 
                    "form": form_id 
                },
                { 
                    "created": { "$lt": ageOffDate }
                }]
        })

        # age off each form in the results
        for ageOffResult in ageOffResults:
            response = submissions.delete_one({ "_id" : ageOffResult['_id'] })
            logger.debug("Successfully aged off {} form {} created {}".format(friendly_form_name, ageOffResult['_id'], ageOffResult['created']))
            numFormsAgedOff+=1

        # get the count of all submissions for the form
        formSubmissions = submissions.find({ "form": form_id })
        numFormSubmissionsRemaining = len(list(formSubmissions.clone()))

    except Exception as e:
        logging.info(e)
        ageOffStatusCode = 500
    finally:
        logger.info("Aged off {} {} forms, {} forms remain".format(numFormsAgedOff, friendly_form_name, numFormSubmissionsRemaining))

    return ageOffStatusCode


def lambda_handler(event, context):
    
    try:
        logger.debug("Starting lambda_handler")
        
        logger.debug("Getting Environment Variables") 
        region_name = os.environ['REGION_NAME']
        secret_name = os.environ['SECRET_NAME']
        db_cluster_path = os.environ['DB_CLUSTER_PATH']
        
        logger.debug("Getting Secrets")    
        secrets = get_secret_dict(secret_name, region_name)
        doc_db_master_username = secrets["doc_db_master_username"]
        doc_db_master_password_sub = secrets["doc_db_master_password_sub"]

        # Initialize the db submissions collection
        connectionTxt = "mongodb://{db_name}:{db_pwd}@{db_path}/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
        client = MongoClient(connectionTxt.format(db_name = doc_db_master_username, db_pwd = doc_db_master_password_sub, db_path = db_cluster_path))
        db = client.formio
        submissions = db.submissions


        # BEGIN Processing Forms
        statusFlag = "success"

        # TODO: For each new form in this submission collection, copy the below four lines, paste before "END Processing Forms" and modify, 
        # providing the formid, friendly form name, and number of days for age-off

        #Age-off the Made in America non-availability waiver
        miaStatusCode = age_off_form("6185938ddadb6b9de5580647", "Made in America Nonavailability Proposed Waiver - Dev SubSvr Test Stage", 111, submissions)
        if miaStatusCode == 500:
            statusFlag = "failure"
        
        #Age-off the X waiver
        form2StatusCode = age_off_form("617c033f4f0d388f532316b5", "StephanieTestMapping - Dev SubSvr Test Stage", 111, submissions)
        if form2StatusCode == 500:
            statusFlag = "failure"

        # END Processing Forms


        # get the count of all submissions for the collection
        allSubmissions = submissions.find({})
        numSubmissionsRemaining = len(list(allSubmissions.clone()))
        logger.info("All Submissions Remaining {}".format(numSubmissionsRemaining))

        # Create a CloudWatch Manager client
        cwClient = boto3.client('cloudwatch')
        
        # TODO:  Set this as a metric
        metricResponse = cwClient.put_metric_data(
            Namespace='AgeOff',
            MetricData=[
                {
                    'MetricName': 'TotalSubmissionsMiA_DevSub',
                    'Value': numSubmissionsRemaining,
                },
            ]
        )
        if metricResponse == 500:
            statusFlag = "failure"

    except Exception as e:
        logging.info(e)
        statusFlag = "failure"
    finally:
        client.close()

        if statusFlag == "failure":
            statusCode = 500
            content = "Error completing AgeOff of forms, please check logs"
        else:
            statusCode = 200
            content = "AgeOff of forms completed successfully"

        response = {
            "statusCode": statusCode,
            "body": content,
            "headers": {
                'Content-Type': 'text/html',
            }
        }
    return response




