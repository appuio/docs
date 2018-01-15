FROM centos/php-56-centos7

USER root


RUN yum -y install python \
    python-devel \
    python-pip \
    && yum clean all && pip install -r requirements.txt

ADD ./ /tmp/src

ENV SPHINXOPTS="-D language='en'"

RUN chmod -R 777 /opt/app-root/src
RUN cd /tmp/src && make -e html && mv /tmp/src/_build/html/* /opt/app-root/src

USER 1001

CMD $STI_SCRIPTS_PATH/run
