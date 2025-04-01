# dbt Docs Hosting Solutions

- [dbt Docs Hosting Solutions](#dbt-docs-hosting-solutions)
  - [Overview](#overview)
  - [How to Generate and Serve dbt Docs Locally](#how-to-generate-and-serve-dbt-docs-locally)
  - [Hosting Options](#hosting-options)
    - [Github Pages](#github-pages)
    - [Netlify](#netlify)
    - [S3 and CloudFront](#s3-and-cloudfront)
    - [S3, CloudFront, and Microsoft Entra ID SSO](#s3-cloudfront-and-microsoft-entra-id-sso)
    - [S3, CloudFront, and Cognito](#s3-cloudfront-and-cognito)
  - [Deployment Steps](#deployment-steps)
  - [Reference](#reference)

## Overview
This repository contains demo code showcasing various options for hosting dbt (data build tool) documentation.

## How to Generate and Serve dbt Docs Locally

To generate and serve dbt docs locally, follow these simple steps:

1. **Generate the Documentation:** Open your terminal or command prompt and run the following command to generate the dbt documentation:

   ```
   dbt docs generate
   ```
   
   This command will create the necessary documentation files based on your dbt project.

2. **Serve the Documentation:** After generating the documentation, use the following command to serve it locally:
   
   ```
   dbt docs serve
   ```
   
   By default, the documentation will be served on port 8080. To specify a custom port, use:
   
   ```
   dbt docs serve --port 3000
   ```
   
   This will serve the documentation on port 3000 (replace "3000" with any port of your choice).

3. **View the Documentation:** Open your web browser and navigate to [http://localhost:8080/](http://localhost:8080/) (or your custom port) to access and view your dbt documentation.

That's it! Now you have your dbt documentation generated and served locally for easy access and review.

## Hosting Options
Here are several user-friendly hosting options for static websites like dbt docs:

### Github Pages
The simplest and most straightforward option. It comes with no extra cost, but there's a limitation: sites hosted on Github Pages will be public in the free tier. For private access and authentication setup, an enterprise tier is required.

### Netlify
A powerful serverless platform with an intuitive git-based workflow. Netlify allows you to host static websites with ease. This is simple as well but ranked below Github Pages only because it sits outside the GitHub ecosystem.

### S3 and CloudFront
A cost-effective option that offers the ability to add basic authentication for restricted access. S3 (Simple Storage Service) provides reliable storage for your static content, and CloudFront serves as a content delivery network for faster and more efficient distribution.

### S3, CloudFront, and Microsoft Entra ID SSO
A robust enterprise solution that leverages your existing Microsoft identity system. This option allows you to authenticate users with their Microsoft Entra ID (formerly Azure AD) credentials, making it ideal for organizations already using Microsoft services. The implementation uses Lambda@Edge for authentication at the edge, providing a seamless and secure user experience without requiring server-side components.

See the [cloudfront-microsoft-sso](./terraform/cloudfront-microsoft-sso/README.md) module for implementation details.

### S3, CloudFront, and Cognito
Another comprehensive option that provides the ability to let users sign up for access. In addition to S3 and CloudFront, Amazon Cognito is used to manage user identities and authentication. This setup allows you to control who can access your dbt docs by creating user pools and defining user sign-up and sign-in processes.

## Deployment Steps
To deploy your dbt docs website, follow these steps:

1. **Configure AWS Credentials:**
   Run the following command to set up your AWS CLI credentials profile for Terraform to use. Replace `terraform` with your desired profile name if you have multiple profiles.

   ```
   aws configure --profile terraform
   ```

2. **Initialize Terraform:**
   Initialize Terraform in the project directory using the following command:

   ```
   terraform init
   ```

3. **Format Terraform Configuration:**
   Ensure that your Terraform configuration files are properly formatted for consistency:

   ```
   terraform fmt -recursive
   ```

4. **Deploy the Infrastructure:**
   Apply the Terraform configuration to deploy your infrastructure:

   ```
   terraform apply
   ```

## Reference
Here are some useful references and resources related to hosting dbt docs and implementing authentication:

- [AWS Static Website Hosting with Cognito and S3](https://howtoember.wordpress.com/2020/06/11/aws-static-website-hosting-with-cognito-and-s3/)
- [CloudFront Authorization at Edge (AWS Samples GitHub)](https://github.com/aws-samples/cloudfront-authorization-at-edge)
- [Authorization Lambda@Edge (AWS Samples GitHub)](https://github.com/aws-samples/authorization-lambda-at-edge)
- [Cognito Auth Example (sashee GitHub)](https://github.com/sashee/cognito-auth-example)
- [Terraform AWS Lambda@Edge Cognito Authentication (disney GitHub)](https://github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication)
- [Validate User Email Domain AWS Cognito](https://andreybleme.com/2020-01-18/validate-user-email-domain-aws-cognito/)
- [Microsoft Entra ID Documentation](https://docs.microsoft.com/en-us/azure/active-directory/)
