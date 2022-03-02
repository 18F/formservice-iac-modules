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

logger.info("Loading function")

def get_secret_dict():

    secret_name = ""
    region_name = "us-gov-west-1"
    
    logger.info("Creating secrets manager client")

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
        logger.info("getting secret value response")
        get_secret_value_response = secretClient.get_secret_value(
            SecretId=secret_name
        )
        logger.info("after get_secret_value")
        # logger.info("value response: " + get_secret_value_response)
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
            logger.info("decrypting secret")
            if 'SecretString' in get_secret_value_response:
                logger.info("secret string")
                secret = get_secret_value_response['SecretString']
                print("secret string:" + secret)
            else:
                logger.info("base64 secret")
                secret = base64.b64decode(get_secret_value_response['SecretBinary'])
                print("secret binary:" + secret)
                
#         if 'SecretString' in get_secret_value_response:
#             secret = get_secret_value_response['SecretString']
#             j = json.loads(secret)
#             password = j['password']
#         else:
#             decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
#             print("password binary:" + decoded_binary_secret)
#             password = decoded_binary_secret.password   
    
    return json.loads(secret)  # returns the secret as dictionary


def age_off_form(form_id, age_off_days):

    #Age-off the Made in America non-availability waiver
#    age_off_form("6182fbd5dadb6b9de5557950", 30)
    
    
    try:
        # openConnection()
        # # Introducing artificial random delay to mimic actual DB query time. Remove this code for actual use.
        # time.sleep(random.randint(1, 3))
        # with conn.cursor() as cur:
        #     cur.execute("select * from Employees")
        #     for row in cur:
        #         item_count += 1
        #         print(row)
        #         # print(row)
        
        
        # # Set client
        # client = MongoClient('mongodb://{}:27017/'.format(os.environ['DB_HOST'] ))
        
        doc_db_master_username = ""
        doc_db_master_password_sub = ""
        
        connectionTxt = "mongodb://{db_name}:{db_pwd}@faas-dev-runtime-submission-docdb.cluster-clh7f7tmo3dk.us-gov-west-1.docdb.amazonaws.com:27017/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
        logger.info(connectionTxt.format(db_name = doc_db_master_username, db_pwd = doc_db_master_password_sub))
        
        client = MongoClient(connectionTxt.format(db_name = doc_db_master_username, db_pwd = doc_db_master_password_sub))
        
        #client = MongoClient('mongodb://<username>:<pwd>@faas-dev-runtime-submission-docdb.cluster-clh7f7tmo3dk.us-gov-west-1.docdb.amazonaws.com:27017/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false')

        #'mongodb://' + doc_db_master_username + ':' + doc_db_master_password_sub + '@faas-dev-runtime-submission-docdb.cluster-clh7f7tmo3dk.us-gov-west-1.docdb.amazonaws.com:27017/?ssl=true&ssl_ca_certs=rds-combined-ca-us-gov-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false' 

        # # Set database
        db = client.formio
            
            
        logger.info("initializing the collection")
        submissions = db.submissions
             
        logger.info("getting the count of all submissions for the form")

        #result_1 = submissions.find({ "form": "6182fbd5dadb6b9de5557950"})
        result_1 = submissions.find({ "form": form_id })
        logger.info("Count: ")
        logger.info(len(list(result_1.clone())))
        
        delta = timedelta(days=age_off_days)
        logger.info("The delta is : {}".format(delta))
        
        datetime2 = datetime.datetime.today() - delta
        
        logger.info("The create datetime is : {}".format(datetime2))
        
        logger.info("getting the submissions older than 30 days (720 hours)")
        result_2 = submissions.find({ 
            "$and": [ { 
                    "form": form_id 
                },
                { 
                    "created": { "$lt": datetime2 }
                }]
        })
        for i in result_2:
            #logger.info(i)
            logger.info("a value")
        #logger.info("Count 2: ")
        #logger.info(len(list(result_2.clone())))
        # for i in result_1:
        #     logger.info(i)
        #     logger.info("deleting the submission... TODO ADD SUBMISSION ID HERE")
        #     submissions.deleteOne({"_id" : ObjectId("get from cursor")}) 
        #     response = submissions.delete_one({ "email": event["email"] })
    
    except Exception as e:
        # Error while opening connection or processing
        logging.info(e)
    finally:
        logging.info("Closing Connection")
        # if(conn is not None and conn.open):
        #     conn.close()
        # invokeConnCountManager(False)




def lambda_handler(event, context):
    
    try:
        logger.info("Starting lambda_handler")
        
        logger.info("Getting Secrets")    
        secrets = get_secret_dict()
        
        print("got admin email secret:" + secrets["ADMIN_EMAIL"])
        
        
        #construct_connection_string()
        

        
        

        
        
        #Age-off the Made in America non-availability waiver
        age_off_form("6182fbd5dadb6b9de5557950", 30)
        
        

        
        
    except Exception as e:
        # Error while opening connection or processing
        logging.info(e)
    finally:
        logging.info("Closing Connection")
        # if(conn is not None and conn.open):
        #     conn.close()
        # invokeConnCountManager(False)
    
    
    content = "Selected stuff"
    # content =  "Selected %d items from RDS MySQL table" % (item_count)
    response = {
        "statusCode": 200,
        "body": content,
        "headers": {
            'Content-Type': 'text/html',
        }
    }
    return response





#     return { "operation": "success" }



    #raise Exception('Something went wrong')
    






# In an environment variable, provide a list of the form IDs on the submission server to query for production data.
# "form": "6182fbd5dadb6b9de5557950",
# https://portal-dev.forms.gov/formssandbox-dev/stephaniedevtestencryptionsub/submission

# query mongo submission server submissions table for all submission IDs that are older than 30 days.
# connect to db
# use formio
# result_1 = db.submissions.find({ $and: [ {"form": "6182fbd5dadb6b9de5557950"} , submitted: { $lt: today - 30 }   ]   })
# for i in result_1:
#     print(i)

# For each submission id returned, run deleteOne command.
# db.submissions.deleteOne({"_id" : ObjectId("get from cursor")}) 
# e.g.  db.submissions.deleteOne({"_id" : ObjectId("6189bb2d13652678239e71be")}) 







# import sys
# import pymysql
# import boto3
# import botocore
# import json
# import random
# import time
# import os
# from botocore.exceptions import ClientError

# # rds settings
# rds_host = os.environ['RDS_HOST']
# name = os.environ['RDS_USERNAME']
# db_name = os.environ['RDS_DB_NAME']
# helperFunctionARN = os.environ['HELPER_FUNCTION_ARN']

# secret_name = os.environ['SECRET_NAME']
# my_session = boto3.session.Session()
# region_name = my_session.region_name
# conn = None

# # Get the service resource.
# lambdaClient = boto3.client('lambda')


# def invokeConnCountManager(incrementCounter):
#     # return True
#     response = lambdaClient.invoke(
#         FunctionName=helperFunctionARN,
#         InvocationType='RequestResponse',
#         Payload='{"incrementCounter":' + str.lower(str(incrementCounter)) + ',"RDBMSName": "Prod_MySQL"}'
#     )
#     retVal = response['Payload']
#     retVal1 = retVal.read()
#     return retVal1


# def openConnection():
#     print("In Open connection")
#     global conn
#     password = "None"
#     # Create a Secrets Manager client
#     session = boto3.session.Session()
#     client = session.client(
#         service_name='secretsmanager',
#         region_name=region_name
#     )
    
#     # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
#     # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
#     # We rethrow the exception by default.
    
#     try:
#         get_secret_value_response = client.get_secret_value(
#             SecretId=secret_name
#         )
#         print(get_secret_value_response)
#     except ClientError as e:
#         print(e)
#         if e.response['Error']['Code'] == 'DecryptionFailureException':
#             # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
#             # Deal with the exception here, and/or rethrow at your discretion.
#             raise e
#         elif e.response['Error']['Code'] == 'InternalServiceErrorException':
#             # An error occurred on the server side.
#             # Deal with the exception here, and/or rethrow at your discretion.
#             raise e
#         elif e.response['Error']['Code'] == 'InvalidParameterException':
#             # You provided an invalid value for a parameter.
#             # Deal with the exception here, and/or rethrow at your discretion.
#             raise e
#         elif e.response['Error']['Code'] == 'InvalidRequestException':
#             # You provided a parameter value that is not valid for the current state of the resource.
#             # Deal with the exception here, and/or rethrow at your discretion.
#             raise e
#         elif e.response['Error']['Code'] == 'ResourceNotFoundException':
#             # We can't find the resource that you asked for.
#             # Deal with the exception here, and/or rethrow at your discretion.
#             raise e
#     else:
#         # Decrypts secret using the associated KMS CMK.
#         # Depending on whether the secret is a string or binary, one of these fields will be populated.
#         if 'SecretString' in get_secret_value_response:
#             secret = get_secret_value_response['SecretString']
#             j = json.loads(secret)
#             password = j['password']
#         else:
#             decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
#             print("password binary:" + decoded_binary_secret)
#             password = decoded_binary_secret.password    
    
#     try:
#         if(conn is None):
#             conn = pymysql.connect(
#                 rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)
#         elif (not conn.open):
#             # print(conn.open)
#             conn = pymysql.connect(
#                 rds_host, user=name, passwd=password, db=db_name, connect_timeout=5)

#     except Exception as e:
#         print (e)
#         print("ERROR: Unexpected error: Could not connect to MySql instance.")
#         raise e


# def lambda_handler(event, context):
#     if invokeConnCountManager(True) == "false":
#         print ("Not enough Connections available.")
#         return False

#     item_count = 0
#     try:
#         openConnection()
#         # Introducing artificial random delay to mimic actual DB query time. Remove this code for actual use.
#         time.sleep(random.randint(1, 3))
#         with conn.cursor() as cur:
#             cur.execute("select * from Employees")
#             for row in cur:
#                 item_count += 1
#                 print(row)
#                 # print(row)
#     except Exception as e:
#         # Error while opening connection or processing
#         print(e)
#     finally:
#         print("Closing Connection")
#         if(conn is not None and conn.open):
#             conn.close()
#         invokeConnCountManager(False)

#     content =  "Selected %d items from RDS MySQL table" % (item_count)
#     response = {
#         "statusCode": 200,
#         "body": content,
#         "headers": {
#             'Content-Type': 'text/html',
#         }
#     }
#     return response   




