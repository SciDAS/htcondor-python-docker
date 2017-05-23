The beginnings of a Docker container image that can communicate with HTCondor using the Python API.

_Make sure your HTCondor cluster (the submit node) has a `condor_pool` user_
`useradd -m -s /bin/bash -U condor_pool`

See Status section.

## Dependencies
This doesn't necessarily seem like the best way to do this…
In `resources/`:
* ~~HTCondor libs, extracted from a zip file in [Anaconda](https://anaconda.org/kreczko/htcondor-python/files): [htcondor-python-8.6.0-py27_1.tar.bz2](https://anaconda.org/kreczko/htcondor-python/8.6.0/download/linux-64/htcondor-python-8.6.0-py27_1.tar.bz2)~~
* HTCondor libs, copied from Centos container after `yum install condor-python`
* ~~boost-python/libboost_python.so built from source: [boost_1_63_0.tar.bz2](https://pilotfiber.dl.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.tar.bz2)~~
* ~~libpcre/libpcre.so.1 symlinked from provided debian libpcre.so.3~~
* libpcre and libcrypto copied from Centos container

## See Also:
* HTCondor [Python Bindings](http://research.cs.wisc.edu/htcondor/manual/v8.6/6_7Python_Bindings.html)

## Example:
Using [htcondor-docker-centos](https://github.com/SciDAS/htcondor-docker-centos) to run a small HTCondor cluster in the docker network `htcondor`:
```
$ docker run --rm -it --net=htcondor htcondor-python
Python 2.7.13 (default, May  1 2017, 22:44:36)
[GCC 4.9.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import htcondor
>>> import classad
>>> coll = htcondor.Collector("condor-master")
>>> results = coll.query(htcondor.AdTypes.Startd, "true", ["Name"])
>>> len(results)
4
>>> results
[[ MyType = "Machine"; Name = "slot3@condor-executor"; TargetType = "Job" ], [ MyType = "Machine"; Name = "slot4@condor-executor"; TargetType = "Job" ], [ MyType = "Machine"; Name = "slot1@condor-executor"; TargetType = "Job" ], [ MyType = "Machine"; Name = "slot2@condor-executor"; TargetType = "Job" ]]
>>> scheddAd = coll.locate(htcondor.DaemonTypes.Schedd, "condor-submitter")
>>> schedd = htcondor.Schedd(scheddAd)
>>> results = schedd.query()
>>> len(results)
0
```

## Status:
The [htcondor_test.py](https://github.com/SciDAS/htcondor-python-docker/blob/master/examples/htcondor_test.py) script demonstrates very simple job submission to remote condor-submitter node.

