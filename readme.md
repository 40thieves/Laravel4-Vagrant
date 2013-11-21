# Laravel 4 w/ Vagrant

A basic Ubuntu 12.04 Vagrant setup with [Laravel4](http://laravel.com/docs) and PHP 5.5.

### Custom changes
A more stripped down version of [bryannielsen's](https://github.com/bryannielsen/Laravel4-Vagrant) Laravel 4 Vagrant box. I stripped out phpmyadmin, beanstalkd, redis, postgresql and memcached, mainly because I don't use them (if you want them go hit up his repo). Plus it was a good excuse to mess around with Vagrant/Puppet.

Additional changes I made - added a new module, `github_app` that pulls an existing Laravel repo from Github. You just need drop in the relevant Github url.

Quick note: I've had occasional issues creating the vm, when creating the Laravel app itself. It's possible that it's timing out, but I'm not an expert so any advice is appreciated.

## Setup

* Clone this repository `git clone http://github.com/40thieves/Laravel4-Vagrant.git`
* Run `vagrant up` inside the newly created directory
* (The first time you run `vagrant` it will need to fetch the virtual box image which is ~300mb so depending on your download speed this could take some time)
* Vagrant will then use Puppet to provision the base virtual box with our LAMP stack (this could take a few minutes) also note that composer will need to fetch all of the packages defined in the app's composer.json which will add some more time to the first provisioning run
* You can verify that everything was successful by opening http://localhost:8888 in a browser

*Note: You may have to change permissions on the www/app/storage folder to 777 under the host OS* 

For example: `chmod -R 777 www/app/storage/`

## Usage

Some basic information on interacting with the vagrant box

### Port Forwards

* 8888 - Apache
* 8889 - MySQL 

### Default MySQL Database

* User: root
* Password: (blank)
* DB Name: database

### PHP XDebug

XDebug is included in the build but **disabled by default** because of the effect it can have on performance.  

To enable XDebug:

1. Set the variable `$use_xdebug = "1"` at the beginning of `puppet/manifests/phpbase.pp`
2. Then you will need to provision the box either with `vagrant up` or by running the command `vagrant provision` if the box is already up
3. Now you can connect to XDebug on **port 9001**

**XDebug Tools**

* [MacGDBP](http://www.bluestatic.org/software/macgdbp/) - Free, Mac OSX
* [Codebug](http://www.codebugapp.com/) - Paid, Mac OSX


_Note: All XDebug settings can be configured in the php.ini template at `puppet/modules/php/templates/php.ini.erb`_


### Vagrant

Vagrant is [very well documented](http://vagrantup.com/v1/docs/index.html) but here are a few common commands:

* `vagrant up` starts the virtual machine and provisions it
* `vagrant suspend` will essentially put the machine to 'sleep' with `vagrant resume` waking it back up
* `vagrant halt` attempts a graceful shutdown of the machine and will need to be brought back with `vagrant up`
* `vagrant ssh` gives you shell access to the virtual machine

----

##### Virtual Machine Specifications #####

* OS     - Ubuntu 12.04
* Apache - 2.4.6
* PHP    - 5.5.4
* MySQL  - 5.5.32
