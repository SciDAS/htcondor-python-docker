import htcondor
import classad
import os

# need to have a user that is also in the HTCondor cluster
#os.system("useradd -m -s /bin/bash dmr")
#os.system("groupadd -g 996 condor")
#os.system("useradd -m -s /bin/bash -u 998 -g 996 condor")
#os.system("useradd -U -m -s /bin/bash dmr")
#os.system("cat /etc/passwd")

# check configuration
for key, value in htcondor.param.items():
    #print key + ": " + str(value)
    pass

# Connect to HTCondor
coll = htcondor.Collector("condor-master")
scheddAd = coll.locate(htcondor.DaemonTypes.Schedd, "condor-submitter")
schedd = htcondor.Schedd(scheddAd)

# submit a test job
print str(schedd.submit({"Cmd": "/bin/echo"}))
#print str(schedd.submit(classad.ClassAd( { "Cmd": "/bin/echo", "NumCkpts": "0", "MinHosts": "1", "JobNotification": "0", "LastSuspensionTime": "0" })))

ad = classad.parseOne(open("/examples/echo_test.submit.ad"))
#print schedd.submit(ad)

