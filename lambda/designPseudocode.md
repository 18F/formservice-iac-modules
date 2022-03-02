BEGIN

    GET environment variables  (secret_name, region_name, database_cluster_path)
    CALL get_secret_dict RETURNING secrets (doc_db_master_username, doc_db_master_password_sub)
        // question- how to get the db name and pwd for each db???
    create miaDBClient
    create epaDBClient
    set miaDBSubmissionCollection
    set epaDBSubmissionCollection
    GET count of submissions in miaDBSubmissionCollection
    LOG count of submissions in miaDBSubmissionCollection
    GET count of submissions in epaDBSubmissionCollection
    LOG count of submissions in epaDBSubmissionCollection
    NOTIFY if count of mia and epa submissions is 20K or more   //no idea how we want to notify
                                                                // Different status code that will fail
                                                                // and notify admins?
    set statusCode to 500 (Internal Server Error)  //assume failure
    CALL age_off_form(miaFormId, ageOffDays, miaDBSubmissionCollection) RETURNING statusCode
    IF statusCode is 200
        CALL age_off_form(epaFormId, ageOffDays, epaDBSubmissionCollection) RETURNING statusCode
    END IF
    FINALLY
        close miaDBClient
        close epaDBClient

    IF statusCode is 200
        construct response "AgeOff of forms completed successfully"
    ELSE
        construct response "Error completing AgeOff of forms, please check logs" using statusCode 500
    ENDIF
    RETURN response
END


BEGIN age_off_form(formId, ageOffDays, submissionCollection)

    set statusCode to 200 (OK)
    set numberOfFormsAgedOff to 0
    construct the ageOffDate using ageOffDays
    query submissionCollection for forms with formId and created before ageOffDate
    FOR each each form in the cursor
        DELETE the form from the submissions collection
        LOG the deleted form ID
        increment numberOfFormsAgedOff
    END FOR
    EXCEPTION
        LOG exception
        set statusCode to 500 (Internal Server Error)
    FINALLY
        LOG numberOfFormsAgedOff
    RETURN statusCode
END

