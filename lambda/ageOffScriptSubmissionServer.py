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
    numFormsAgedOff = 0
    numFormSubmissionsRemaining = 0

    try:
        # Calculate the ageOffDate given the num of days to retain data
        ageOffDelta = timedelta(days=age_off_days)
        ageOffDate = datetime.datetime.today() - ageOffDelta

        # query submissions for forms with formId and created before ageOffDate
        logger.debug("getting the submissions older than {}".format(ageOffDate))

        ageOffResults = submissions.find({ 
            "$and": [{ 
                    "form": form_id
                },
                { 
                    "created": { "$lt": ageOffDate }
                }]
        })

        # age off each form in the results
        for ageOffResult in ageOffResults:
            submissions.delete_one({ "_id" : ageOffResult['_id'] })
            logger.debug("Successfully aged off {} form {} created {}".format(friendly_form_name, ageOffResult['_id'], ageOffResult['created']))
            numFormsAgedOff+=1

        # get the count of all submissions remaining for the form after age off
        numFormSubmissionsRemaining = get_form_submissions_count(form_id, submissions)

    except:
        raise
    finally:
        logger.info("{} {} submissions remain, {} were aged off after {} days".format(numFormSubmissionsRemaining, friendly_form_name, numFormsAgedOff, age_off_days))

    return None


def get_form_submissions_count(form_id, submissions):
    formSubmissions = submissions.find({ "form": form_id })
    return len(list(formSubmissions.clone()))


def get_all_submissions_count(submissions):
    allSubmissions = submissions.find({})
    return len(list(allSubmissions.clone()))


def print_submissions_count(submissionsCount, friendly_form_name):
    logger.info("{} {} submissions".format(submissionsCount, friendly_form_name))
    return None


def lambda_handler(event, context):
    
    try:
        logger.debug("Starting lambda_handler")
        statusFlag = "success"
        
        logger.debug("Getting Environment Variables") 
        region_name = os.environ['REGION_NAME']
        secret_name = os.environ['SECRET_NAME']
        db_path = os.environ['DB_CLUSTER_PATH']
        metricName = os.environ['METRIC_NAME']
        database_name = os.environ['DB_NAME']
        
        logger.debug("Getting Secrets")    
        secrets = get_secret_dict(secret_name, region_name)
        db_user = secrets["doc_db_master_username"]
        db_pwd = secrets["doc_db_master_password_sub"]

        # Initialize the db submissions collection
        connectionTxt = f'mongodb://{db_user}:{db_pwd}@{db_path}/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false'
        client = MongoClient(connectionTxt)
        db = client[database_name]
        submissions = db.submissions

        # BEGIN Processing Forms

        # TODO: For each new form in this submission collection, copy the below line, paste before "END Processing Forms" and modify, 
        # providing the formid, friendly form name, number of days for age-off, and initialized submissions collection

        age_off_form("6179b6894a1dcb14ae235ec0", "Made in America Nonavailability Proposed Waiver - Prod SubSvr Live Stage", 30, submissions)
        age_off_form("62717a07f616dae9c0003b69", "Made in America Urgent Requirements Report - Prod SubSvr Live Stage", 30, submissions)
        age_off_form("61f4540da7496979170c2582", "FaaS SmokeTest - Prod SubSvr Live Stage", 30, submissions)

        # END Processing Forms


        # BEGIN Get Resource Counts

        # TODO: For each new resource in this submission collection, copy the below line, paste before "END Get Resource Counts" and modify, 
        # providing the formid for the resource, the initialized submissions collection, and friendly resource name

        print_submissions_count(get_form_submissions_count("6152373e22b35596706d584f", submissions), "Made in America Approver Resource - Prod SubSvr Live Stage")
        
        # END Get Resource Counts


        # Print the count of all submissions for the collection
        numSubmissionsRemaining = get_all_submissions_count(submissions)
        print_submissions_count(numSubmissionsRemaining, "total")

        # Set the total number of submissions in this db collection as an AWS Metric
        cwClient = boto3.client('cloudwatch')
        cwClient.put_metric_data(
            Namespace='AgeOff',
            MetricData=[
                {
                    'MetricName': metricName,
                    'Value': numSubmissionsRemaining,
                },
            ]
        )

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
