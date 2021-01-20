# Dockerfile
FROM python:3.8

WORKDIR /usr/app

COPY requirements.txt ./

# Install Python Requirements
RUN pip install -U pip
RUN pip install --no-cache-dir -r requirements.txt

# Set the expected DBT_PROFILES_DIR
ENV DBT_PROFILES_DIR=/secure/profile/

CMD ["dbt", "--version"]