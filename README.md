# Prerequisites

## Install Ruby Version Manager

To correctly install Ruby, first install Ruby Version Manager (or RVM for short). Go to [their site](https://rvm.io/) and follow the instructions.

## Install ruby

When RVM is correctly installed, use it to install Ruby 2.3.4 :

```
rvm install 2.3.4
```

## Install dependencies

Just navigate in the folder of the project in the console :

```
cd /path/to/campaigns
```

it will automatically create the gemset for the application, if it does not, use the following command :

```
rvm use 2.3.4@arkaan-campaigns --create
```

When the gemset is correctly created, just use `bundle install` to install dependencies.

## Environment variables

Here is an example of a complete `.env` file you can complete to launch the application :

```
export AWS_ACCESS_KEY_ID=<Your amazon public key>
export AWS_SECRET_ACCESS_KEY=<Your amazon secret key>
export AWS_REGION=<Your amazon region>
export MONGODB_URL=<your complete mongoDB url with credentials>
export OAUTH_TOKEN=<Heroku connection token>
export PORT=<port of your choice>
export RACK_ENV=<either production or development>
export SERVICE_URL=<the complete URL where this instance can be accessed>
```

# Launch

## Use the environment variables

Execute the command `source .env`

## Launch the server

Use the command `rackup --port $PORT`