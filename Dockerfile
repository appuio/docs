FROM python:3-alpine

ENV SPHINXOPTS="-D language='en'"
WORKDIR /src

ADD requirements.txt .
RUN pip install -r requirements.txt

CMD ["sphinx-autobuild", ".", "_build_html", "--re-ignore", ".git", "--host", "0.0.0.0"]

# vim: ft=dockerfile
