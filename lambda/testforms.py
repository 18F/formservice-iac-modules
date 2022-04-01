        # BEGIN Processing Forms

        # TODO: For each new form in this submission collection, copy the below line, paste before "END Processing Forms" and modify, 
        # providing the formid, friendly form name, number of days for age-off, and initialized submissions collection

        # FaaS
        # ADD STUFF HERE

        # Made in America
        age_off_form("61e5b93b396609452b8c91c4", "Made in America Nonavailability Proposed Waiver - Test SubSvr Dev Stage", 111, submissions)
        age_off_form("6232204fcdde27d6b1131d45", "Made in America Urgent Requirements Report - Test SubSvr Dev Stage", 111, submissions)
        age_off_form("6244b27966318114374ac1f9", "Made in America Financial Assistance Waiver - Test SubSvr Dev Stage", 111, submissions)

        age_off_form("6206a05273b8ea8eaefa0645", "Made in America Nonavailability Proposed Waiver - Test SubSvr Test Stage", 111, submissions)
        age_off_form("6238bff54f763d7f2e7c9d40", "Made in America Urgent Requirements Report - Test SubSvr Test Stage", 111, submissions)

        # EPA CSB
        age_off_form("61f1bd4f874e70a755b27791", "EPA CSB Rebate Application - Test SubSvr Dev Stage", 111, submissions)
        age_off_form("62449f0ebe9c76ef5e8b9a1e", "EPA CSB Rebate Application - Test SubSvr Test Stage", 111, submissions)

        # Hacker One
        age_off_form("61f17ce8874e70a755b25040", "HackerOne Sample Form - Test SubSvr Live Stage", 111, submissions)

        # END Processing Forms


        # BEGIN Get Resource Counts

        # TODO: For each new resource in this submission collection, copy the below line, paste before "END Get Resource Counts" and modify, 
        # providing the formid for the resource, the initialized submissions collection, and friendly resource name

        # FaaS
        # ADD STUFF HERE

        # Made in America
        print_submissions_count(get_form_submissions_count("61e5b93b396609452b8c91bd", submissions), "Made in America Approver Resource - Test SubSvr Dev Stage")
        print_submissions_count(get_form_submissions_count("6206a05273b8ea8eaefa063e", submissions), "Made in America Approver Resource - Test SubSvr Test Stage")

        # EPA CSB
        # n/a - no resources at this time

        # Hacker One
        # n/a - no resources at this time

        # END Get Resource Counts


                #Age-off the Made in America non-availability waiver
        miaStatusCode = age_off_form("6185938ddadb6b9de5580647", "Made in America Nonavailability Proposed Waiver - Dev SubSvr Test Stage", 111, submissions)
        if miaStatusCode == 500:
            statusFlag = "failure"
        
        #Age-off the X waiver
        form2StatusCode = age_off_form("617c033f4f0d388f532316b5", "StephanieTestMapping - Dev SubSvr Test Stage", 111, submissions)
        if form2StatusCode == 500:
            statusFlag = "failure"

        # END Processing Forms