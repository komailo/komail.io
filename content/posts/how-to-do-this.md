+++ 
draft = false
date = 2024-02-16T14:15:12-07:00
title = "How To Create Your Own Website Like This One with Hugo and Cloudflare Pages"
description = "A post walking through the process of how to create your own website like this one using Hugo and Cloudflare Pages."
slug = ""
authors = ["Komail Kanjee"]
tags = ["hugo", "cloudflare", "cloudflare-pages"]
categories = ["How To"]
externalLink = ""
series = ["How To"]
+++

While I have my own home lab setup where I run many production grade services, I decided to host this website on an external service and keeping the stack simple.

This setup while does not require you to understand all the ins and outs of web hosting, some knoweldge about working with Git repositories, DNS, Markdowns, HTML and Linux is required.

To setup your own website like this you will need:

1. Cloudflare Account
1. GitHub Account (You can use any SCM)
1. Domain name
1. Ideas to share or just something you would like to talk about

# Setting up the Git Repository

You can create a GitHub repository from the template [Komailio/template-hugo-coder](https://github.com/Komailio/template-hugo-coder). The template does have a README file on how to setup the repository and how to use it.

# Getting a Domain Name

While this is an optional step, it is recommended to get a domain name. You can get a domain name from Cloudflare or any other domain registrar. If you are using Cloudflare, you can use the free plan.

# Setting up Cloudflare Pages

To set up Cloudflare Pages for hosting your website, follow these steps:

1. **Sign Up/Login to Cloudflare**: If you don't already have an account, sign up for one on the Cloudflare website. If you have an account, log in.

2. **Add Your Website to Cloudflare**: Once logged in, click on the "Add a Site" button and enter your domain name. Cloudflare will scan your DNS records and import them.

3. **Configure DNS Settings**: Ensure that your DNS settings are correctly configured to point to Cloudflare's nameservers. This usually involves updating your domain registrar's nameservers to those provided by Cloudflare.

4. **Enable Cloudflare Pages**: After your domain is added to Cloudflare, navigate to the "Pages" section. Click on "Create a Project" and select your GitHub repository where your Hugo website is hosted. Follow the prompts to connect your repository.

5. **Configure Build Settings**: Once your repository is connected, configure the build settings according to your project requirements. You may need to specify the build command and output directory for Hugo.

6. **Deploy Your Website**: After configuring the build settings, Cloudflare Pages will automatically deploy your website whenever changes are pushed to your GitHub repository.

7. **Customize Domain Settings (Optional)**: If you have a custom domain, you can configure it in the "Custom Domains" section of Cloudflare Pages. This allows you to use your own domain for your website.

8. **SSL Configuration**: Cloudflare provides free SSL certificates for all websites. Ensure that SSL is enabled for your domain to secure your website traffic.

9. **Testing and Monitoring**: Once your website is deployed, test it to ensure everything is working correctly. You can also monitor your website's performance and traffic using Cloudflare's analytics tools.
