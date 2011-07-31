# Campo

A lightweight BBS.

Author: Rei(chloerei@gmail.com)

## Dependencies

- Ruby 1.9.2
- mongodb 1.8.2+
- redis 2.0+
- Ruby on Rails 3.0.7

Gems Dependencies see Gemfile.

## Getting Started

Assume you have installed mongodb and redis.

### 1. Download the sources:

    git clone git://github.com/chloerei/campo.git

    cd campo/

### 2. Install gems

    bundle install

### 3. Configure the application

    cp config/campo.example.yml config/campo.yml
    cp config/mongoid.example.yml config/mongoid.yml
    edit config/campo.yml
    edit config/mongoid.yml

### 4. Setup Data

Make sure mongodb is running.

    rake db:seed

### 5. Start the server

    rails s

### 6. Run resque worker

    QUEUE=* rake environment resque:work

## For Production Environment

This project is low degree of completion, db schema is changing and not well migration support. not suggest used in production environment. But if you want, there are some notes.

### 1. Reset secret token (importance for security)

    rake secret

Copy the output string and set secret\_token column in config/campo.yml

### 2. Config mongo connection.

    edit config/mongoid.yml

Change production params.

## For Update

### 1. Pull source

    cd /path/to/your_source
    git pull

### 2. Backup data and run migration.(If you are no first time to setup)

Backup mongo data first.

    mongodump -o /path/to/your_want_to_dump_mongo

Run migration.

    rake db:migrate

## Community

http://codecampo.com is the main website running Campo with develop branch.

Feedback in codecampo.com or github issues(https://github.com/chloerei/campo/issues).

## LICENSE 

Copyright (c) 2011 Rei http://chloerei.com.

Release under MIT-LICENSE
