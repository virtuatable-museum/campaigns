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

See [this wiki page](https://github.com/jdr-tools/campaigns/wiki/Environment-variables) to learn more about environment variables

# Launch

## Use the environment variables

Execute the command `source .env`

## Launch the server

Use the command `rackup --port $PORT`
