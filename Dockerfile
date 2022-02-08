FROM jupyter/scipy-notebook

ENV NB_USER=jupyter

COPY . /home/jupyter/peca_classroom
WORKDIR /home/jupyter/peca_classroom

ENTRYPOINT [ "/usr/local/bin/start-notebook.sh", \
    "--ServerApp.password=sha1:34db5e86a5ed:181f8d4839f19ff1b89eb5b9071e1f5759d81939", \
    "--ServerApp.ip=*", \
    "--ServerApp.port=8080" \
 ]