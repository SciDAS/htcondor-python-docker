FROM python:2.7

COPY resources/htcondor.so /usr/local/lib/python2.7/
COPY resources/classad.so /usr/local/lib/python2.7/
COPY resources/libpyclassad2.7_8_6_2.so /usr/local/lib/
COPY resources/libcondor_utils_8_6_2.so /usr/local/lib/
#COPY resources/libboost_python.so.1.63.0 /usr/local/lib/
COPY resources/libclassad.so.8.6.2 /usr/local/lib/
COPY resources/libcrypto.so.1.0.1e /usr/local/lib/
COPY resources/libpcre.so.1.2.0 /usr/local/lib/
COPY condor_config /etc/condor/

RUN cd /usr/local/lib && \
    ln -s libclassad.so.8.6.2 libclassad.so.8 && \
    ln -s libcrypto.so.1.0.1e libcrypto.so.10 && \
    ln -s libpcre.so.1.2.0 libpcre.so.1

