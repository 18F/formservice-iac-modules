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
logger.setLevel(logging.DEBUG)


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


def age_off_form(form_id, age_off_days, doc_db_master_username, doc_db_master_password_sub, connectionTxt):

    logger.debug("Attempting to age off form {}".format(form_id))

    try:
        # # Set client
        client = MongoClient(connectionTxt.format(db_name = doc_db_master_username, db_pwd = doc_db_master_password_sub))
        
        # # Set database
        db = client.formio
            
        # # Initialize the collection
        submissions = db.submissions
        
        
        logger.info("getting the count of all submissions for the form")
        
        result_1 = submissions.find({ "form": form_id })
        logger.info("Count: {}".format(len(list(result_1.clone()))))
        #logger.info(len(list(result_1.clone())))
        
        ageOffDelta = timedelta(days=age_off_days)
        ageOffDate = datetime.datetime.today() - ageOffDelta
        
        logger.info("getting the submissions older than {}".format(ageOffDate))
        ageOffResults = submissions.find({ 
            "$and": [ { 
                    "form": form_id 
                },
                { 
                    "created": { "$lt": ageOffDate }
                }]
        })
        for ageOffResult in ageOffResults:
            logger.info(ageOffResult['_id'])
            logger.info(ageOffResult['created'])
            response = submissions.delete_one({ "_id" : ageOffResult['_id'] })
            logger.info(response)

    except Exception as e:
        # Error while opening connection or processing
        logging.info(e)
    finally:
        client.close()
        
    logger.debug("Aged off form {}".format(form_id))


def lambda_handler(event, context):
    
    #####  TODO NEED TO FINALIZE MESSAGING AND ERROR HANDLING (RESPONSE CODE RETURN VALUE)
    #####  NEED TO GET SOME OF THE INFORMATION FROM ENV VARS
    #####  NEED TO DO BETTER HANDLING OF DB CONNECTION?  MAYBE NOT WORTH IT, JUST HAVE TWO JOBS.
    #####  RIGHT NOW, ONLY RUNS FOR SPECIFIED FORM.  DO WE NEED IT TO RUN FOR ALL?
    
    try:
        logger.debug("Starting lambda_handler")
        
        secret_name = ""
        region_name = "us-gov-west-1"
        
        logger.debug("Getting Secrets")    
        secrets = get_secret_dict(secret_name, region_name)
        doc_db_master_username = secrets["doc_db_master_username"]
        doc_db_master_password_sub = secrets["doc_db_master_password_sub"]
        
        connectionTxt = "mongodb://{db_name}:{db_pwd}@faas-dev-runtime-submission-docdb.cluster-clh7f7tmo3dk.us-gov-west-1.docdb.amazonaws.com:27017/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
        
        #Age-off the Made in America non-availability waiver
        age_off_form("6185938ddadb6b9de5580647", 111, doc_db_master_username, doc_db_master_password_sub, connectionTxt)
        
    except Exception as e:
        # Error while opening connection or processing
        logging.info(e)
        content = "Exception!!"
    finally:
        content = "In finally"

    
    # content =  "Selected %d items from RDS MySQL table" % (item_count)
    response = {
        "statusCode": 200,
        "body": content,
        "headers": {
            'Content-Type': 'text/html',
        }
    }
    return response




