- [Overview](#overview)
- [Demo](#demo)
  - [Start docker containers](#start-docker-containers)
  - [Create dbt project and configure profile](#create-dbt-project-and-configure-profile)
  - [Macros](#macros)
  - [Sources](#sources)
  - [Packages](#packages)
  - [Models](#models)
  - [Tests](#tests)
  - [Docs](#docs)
- [Clean the demo resources](#clean-the-demo-resources)
- [References](#references)
- [Resources:](#resources)

# Overview
Welcome to your dbt demo workshop. In this demo we will try to cover the basics for dbt and will create an data pipeline to load dims and facts using dbt.

<p align="center">
  <img src="./assets/dbt-postgress-dw-overview.png" alt="Overview" width="738">
</p>

We will use the following 

- `dbt` installed in docker container
- `postgres` DB installed in docker container

> Docker containers will give us standardized platform for development, but dbt can be also installed in any Linux instance with Python 3.8

> `postgres` will give us a database platform to without worrying about cloud database bills, but if you need more processing power choose the [supported cloud database](https://docs.getdbt.com/docs/available-adapters) 

# Demo
## Start docker containers

- Clone this repo and navigate to `dbt-docker` directory. This directory contains infra components for this demo

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
  cd /C/
  ```

- Create dbt project by running
  ```
  dbt init dbt-postgres
  ```

  > - Just for the ease of this demo, copy the contents from `dbt-postgres` directory of this repo into the newly created `dbt-postgres` directory.
  > 
  > - Delete the contents from `macros`, `models` and `snapshots` directories to follow along this demo

- Inside `dbt-postgres` directory, create a new dbt profile file `profiles.yml` and update it with postgres database connection details

  ```yaml
  dbt-postgres:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres
      user: postgres
      password: postgres
      port: 5432
      dbname: postgres
      schema: dbt
      threads: 3
      keepalives_idle: 0 # default 0, indicating the system default
    ```

## Configure dbt project

- Edit the `dbt_project.yml` to connect to the profile which we just created. The value for profile should exactly match with the name in `profiles.yml`

- Run `dbt-set-profile` to update DBT_PROFILES_DIR.

  > dbt-set-profile is alias to `unset DBT_PROFILES_DIR && export DBT_PROFILES_DIR=$PWD`

- Validate the dbt profile and connection by running
  ```
  dbt debug
  ```

## Seeds
[Seeds](https://docs.getdbt.com/docs/building-a-dbt-project/seeds) are CSV files in your dbt project that dbt can load into your data warehouse.

- Review the seed configuration in [dbt_project.yml](dbt_project.yml)

- Load the seed files by running below command 

  ```bash
  dbt seed
  ```

- Data will be loaded into a schema with `dbt_` prefix, to fix this we will create a small macro

## Macros
[Macros](https://docs.getdbt.com/docs/building-a-dbt-project/jinja-macros#macros) are pieces of code that can be reused multiple times.

- Copy the macros from `dbt-postgres\demo-artifacts\macros\utils` to `dbt-postgres\macros\utils`
  
- Macro `generate_schema_name` uses the custom schema when provided.

- Seed all files by running below command 

  ```bash
  dbt seed
  ```
  > This time data will be loaded into the correct schema without the `dbt_` prefix

- Seed select files by running `dbt seed --select address`

## Sources
[Sources](https://docs.getdbt.com/docs/building-a-dbt-project/using-sources) make it possible to name and describe the data loaded into your warehouse by your Extract and Load tools.

> We could either use [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) or [`source`](https://docs.getdbt.com/reference/dbt-jinja-functions/source) function to use the data which we seeded, but to stay close to a real use case, we will use source function.

- Copy the source definition from `dbt-postgres\demo-artifacts\models\sources\` to `dbt-postgres\models\sources\`

- Test sources by running below command
  
  ```bash
  dbt test --models source:*
  ```

## Packages
[dbt packages](https://docs.getdbt.com/docs/building-a-dbt-project/package-management) are in fact standalone dbt projects, with models and macros that tackle a specific problem area.

- Add a packages.yml file to your dbt project. This should be at the same level as your dbt_project.yml file
  
- Specify the package(s) you wish to add
  
  ```yaml
  packages:
    - package: fishtown-analytics/dbt_utils
      version: 0.6.6
  ```  

- Install the packages by running
  
  ```bash
  dbt deps
  ```

## Models
[Model](https://docs.getdbt.com/docs/building-a-dbt-project/building-models) is a select statement. Models are defined in .sql file.

- Review the model configuration in [dbt_project.yml](dbt_project.yml)
 
- Build models by running below command
  
  ```bash
  dbt run
  dbt run --models staging.*
  dbt run --models +tag:presentation-dim
  dbt run --models +tag:presentation-fact --var '{"start_date": "2005-05-24"}'
  ```

## Tests
[Tests](https://docs.getdbt.com/docs/building-a-dbt-project/tests) are assertions you make about your models and other resources in your dbt project (e.g. sources, seeds and snapshots).

Types of tests:
- schema tests (more common)
- data tests: specific queries that return 0 records

- Generate the yaml for existing models by running
  
  ```bash
  dbt run-operation generate_model_yaml --args '{"model_name": "dim_customer"}'
  ```

- Execute tests by running below commands
  
  ```bash
  dbt test --models +tag:presentation-dim
  dbt test --models +tag:presentation-fact
  ```

## Docs
[dbt docs](https://docs.getdbt.com/docs/building-a-dbt-project/documentation) provides a way to generate documentation for your dbt project and render it as a website. 

- You can add descriptions to models, columns, sources in the related yml file
  
- dbt also supports docs block using the jinja docs tag
  
- Generate documents by running 
  
  ```bash
  dbt docs generate
  ```

- Publish the docs by running

  ```bash
  dbt docs serve --port 8085
  ```

# Clean the demo resources
Run below command to delete the docker containers and related volumes

```bash
docker-compose down --volume --remove-orphans
```

# References
- [dbt blog](https://docs.getdbt.com/docs/introduction)
- [Entechlog blog](https://www.entechlog.com/blog/data/exploring-dbt-with-snowflake)

# Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
