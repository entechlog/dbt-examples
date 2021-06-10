- [Overview](#overview)
- [Demo](#demo)
  - [Start docker containers](#start-docker-containers)
  - [Create dbt project and configure profile](#create-dbt-project-and-configure-profile)
  - [Seeds](#seeds)
  - [Sources](#sources)
  - [Models](#models)
  - [Macros](#macros)
  - [Packages](#packages)
  - [Tests](#tests)
  - [Docs](#docs)
- [Resources:](#resources)

# Overview
Welcome to your dbt demo workshop. In this demo we will use the following 

- `dbt` installed in docker container
- `postgres` DB installed in docker container

> Docker containers will give us standardized platform for development, but dbt can be also installed in any Linux instance with Python 3.8

> `postgres` will give us a database platform to without worrying about cloud database bills, but if you need more processing power choose the [supported cloud database](https://docs.getdbt.com/docs/available-adapters) 

# Demo
## Start docker containers
- Start dbt container by running
  ```
  docker-compose up -d --build
  ```

- Start postgres container by running
  ```
  docker-compose -f docker-compose-postgres.yml up -d --build
  ```

- Validate the container by running
  ```
  docker ps
  ```

## Create dbt project and configure profile

- SSH into the dbt container by running
  ```
  docker exec -it dbt /bin/bash
  ```

- Validate dbt by running
  ```
  dbt --version
  ```

- cd into your preferred directory
  ```
  cd /c/
  ```

- Create dbt project by running
  ```
  dbt init dbt-postgres
  ```

- Create `profiles.yml` for postgres connection and update in  
  ```yaml
  dbt-postgres:
  target: dev
  outputs:
    dev:
      type: postgres
      host: [hostname]
      user: [username]
      password: [password]
      port: [port]
      dbname: [database name]
      schema: [dbt schema]
      threads: [1 or more]
      keepalives_idle: 0 # default 0, indicating the system default
    ```

## Configure dbt project

- Edit the `dbt_project.yml` to connect to the profile which we just created. The value for profile should exactly match with the name in `profiles.yml`

- Validate the dbt profile and connection by running
  ```
  dbt debug
  ```

## Seeds

## Sources

## Models

## Macros

## Packages

## Tests

## Docs

# Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
