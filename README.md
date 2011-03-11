# Campo

A lightweight BBS.

Author: Rei(chloerei@gmail.com)

## Dependencies

- Ruby 1.9.2 (1.8.6+ maybe work, but not test yet)
- mongodb 1.6.5+
- Ruby on Rails 3.0.4

## Getting Started

### 1. Download the sources:

    git clone git://github.com/chloerei/campo.git

    cd campo/

### 2. Configure the application

    cp config/campo.example.yml config/campo.yml
    cp config/mongoid.example.yml config/mongoid.yml
    edit config/campo.yml
    edit config/mongoid.yml

### 3. Make sure mongodb is running

### 4. Start the server

    rails s

## For production environment

This project is low degree of completion, db schema is changing and not well migration support. not suggest used in production environment. But if you want, there are some notes.

### 1. Reset secret token (importance for security)

    rake secret

Copy the output string and set secret\_token column in config/campo.yml

### 2. Config mongo connection.

    edit config/mongoid.yml

Change production params.

## Community

http://codecampo.com is the main website running Campo with develop branch.

Feedback in codecampo.com or github issues(https://github.com/chloerei/campo).

## LICENSE 

Copyright (c) 2011 Rei http://chloerei.com.

Release under MIT-LICENSE
