FROM jupyter/scipy-notebook
RUN pip install joblib
RUN pip install flask
WORKDIR /root/
EXPOSE 5000
