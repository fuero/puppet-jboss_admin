Jboss Admin Puppet Module
=========================

This module manages the resources within a running Jboss Wildfly (>= 7) or EAP 
(>= 6) container. For now it does not install the container, please refer to 
[example42/puppet-jboss](https://github.com/example42/puppet-jboss) for a
puppet module which handles initial Jboss installation.

This module can be used to configure any resource which can be managed from the
Jboss CLI, including but not limited to:

* subsystems
* data-sources
* security-domains
* system-properties
* thread-pools
* etcetera

Status
------

This module is currently in **beta**. This module has been used in a large
scale implementation, and in general is functional.

Please reference the issues for this project to understand the current defects
and functionality under implementation.

Founding Concepts
-----------------

This module is divided into three different sets of types: plumbing, porcelain and 
pattern. The intent is that the plumbing types will provide full coverage of
container configuration with a generic interface. The porcelain types
provide easy to use interfaces for specific container resources. Porcelain
types have enhanced documentation, validation, and error handling that is
specific to a single resource. Pattern types have enhanced documenation,
validation, and error handling that is specific to a common pattern that combines
multiple related plumbing and porcelain types.

Currently there are three plumbing types on which all porcelain types are built:

* jboss_resource: Ensures that a specific resource path is present or absent, and that all 
  attributes have the specified values. Non-specified attributes are ignored.
* jboss_exec: Executes the specified command within the Jboss CLI. Executing the command
  can be made conditional based on the result of another command. This support
  is not dependent on a specific version if EAP/Wildfly.
* jboss_batch: Allows an ordered list of JBoss resources and JBoss CLI commands to be specified
  that will be ensured and executed in the specified ordered. The specifics of the specified
  JBoss resources and CLI commands work the same as they would in an individual jboss_resource
  or jboss_exec. That is if an address is specified for a resource with an ensure value and optional
  options then the jboss_batch operation will ensure that state of the resource. If any CLI commands
 are specified they they will be run. The jboss_batch will only execute if there are specified resources
 that are out of sync, or there are any CLI commands listed. But these cases will be ignored if an
 unless or onlyif statement fails its given test.

There are currently over 100 porcelain types. For example, here are a few
porcelain types:

* access-log
* acl
* admin-objects
* archive-validation
* async-handler
* audit
* authentication_classic
* authentication_jaas
* authentication_jaspi
* authentication_ldap
* authentication_properties
* authentication_truststore
* authorization_classic
* authorization_properties 

There is currently one pattern type:

* security_domain_with_authentication_classic

###Dependency Ordering###

This module attempts to decrease the amount of explicit dependency management
needed by automatically requiring ancestor resources for any type. For example,
`/subsystem=datasources` will always be configured before 
`/subsystem=datasources/data-source=ExampleDS`. 

Similarly, any `jboss_exec` is
only executed after the resource it is being executed against has been 
configured. This can be seen in the plumbing example below, where 
`Jboss_exec[Enable Data Source]` will always run after the data source has been
created.

An explicit dependency must be declared when two resources that are not an
ancestor and child are dependent.

How to Use
----------

Following are some brief examples of using this modules types. Refer to each
types documentation for more details.

The two provided examples both accomplish the same general task of ensuring a
data source exists and is enabled. The main difference is that the porcelain 
type can validate parameter values when the puppet catalogue is compiled 
instead of causing an error while applying to the container. I would suggest 
using the porcelain types when possible.

###Porcelain Types###

```Puppet
jboss_admin::server {'main':
  base_path => '/opt/jboss'
}

jboss_admin::resource::data_source{'/subsystem=datasources/data-source=ExampleDS':
  ensure         => present,
  connection_url => 'jdbc:h2:mem:test;DB_CLOSE_DELAY=-1',
  driver_name    => h2,
  jndi_name      => 'java:jboss/datasources/ExampleDS2',
  jta            => true,
  user_name      => sa,
  password       => sa,
  server         => main
}

jboss_exec {'Enable Data Source':
  command => '/subsystem=datasources/data-source=ExampleDS:enable',
  unless  => '(result == true) of /subsystem=datasources/data-source=ExampleDS:read-attribute(name=enabled)',
  server  => main
}
```

###Plumbing Types###

```Puppet
jboss_admin::server {'main':
  base_path => '/opt/jboss'
}

jboss_resource {'/subsystem=datasources/data-source=ExampleDS':
  ensure => present,
  options => {
    'connection-url' => 'jdbc:h2:mem:test;DB_CLOSE_DELAY=-1',
    'driver-name'    => 'h2',
    'jndi-name'      => 'java:jboss/datasources/ExampleDS2',
    'jta'            => true,
    'user-name'      => 'sa',
    'password'       => 'sa'
  },
  server => main
}

jboss_exec {'Enable Data Source':
  command => '/subsystem=datasources/data-source=ExampleDS:enable',
  unless  => '(result == true) of /subsystem=datasources/data-source=ExampleDS:read-attribute(name=enabled)',
  server  => main
}

jboss_batch { "Datasource Batch":
  batch  => [
    { address => '/subsystem=datasources/data-source=ExampleDS',
      options => {
        'connection-url' => 'jdbc:h2:mem:test;DB_CLOSE_DELAY=-1',
        'driver-name'    => 'h2',
        'jndi-name'      => 'java:jboss/datasources/ExampleDS2',
        'jta'            => true,
        'user-name'      => 'sa',
        'password'       => 'sa'
      },  
      ensure  => present
    }   
  ],  
  server => main,
}

jboss_batch { "Datasource Batch":
  batch  => [
    { command => '/subsystem=datasources/data-source=ExampleDS:add',
      options => {
        'connection-url' => 'jdbc:h2:mem:test;DB_CLOSE_DELAY=-1',
        'driver-name'    => 'h2',
        'jndi-name'      => 'java:jboss/datasources/ExampleDS2',
        'jta'            => true,
        'user-name'      => 'sa',
        'password'       => 'sa'
      },  
      ensure  => present
    }   
  ],  
  server => main,
}
```

Generating Resources
--------------------

Most of the resources inside the `manifests/resource` directory are generated
based on the schema exported by jboss instead of hand made. The hope is that as
new resources are added this will simplify the process of adding manifests for 
them. The code backing generation is in `lib/tasks/schema_generate.rb`, and the
template is `lib/tasks/manifest.erb`.

Some types do not produce a great result when autogenerate, mostly when the 
jboss schema departs from its normal conventions. Any hand writeen resource
manifests should go in `manifests/internal/custom_resource`. The generation
task will overlay these files over the autogenerated version.

To regenerate resources, execute `rake resource:generate` within the project 
folder.

Make sure that the underlying schema in `config/schema.json` is up to date.
It can be generated from a running Wildfly instance by using JBoss HTTP Management
API (make sure you can access JBoss Management console in your browser first!):

    curl --digest http://localhost:9990/management \
      --header "Content-Type: application/json" \
      -d '{"operation":"read-resource-description", \
           "recursive":"true","json.pretty":1}' \
      -u 'admin:password' \
    > config/schema.json

For the rake tasks to work, you will need these gems and puppet installed:

json
puppet-lint
backports
puppetlabs_spec_helper

Developer Setup
---------------

This project is provided with a [Vagrant](www.vagrantup.com) setup for 
development of the module. The created VM has a running Jboss AS 7 instance
at `/opt/jboss` for testing purposes.

To execute a test manifest, first execute `bundle` within the vagrant 
directory, then use the following pattern:

    sudo puppet apply tests/enable_ExampleDS2.pp --modulepath=/modules
    
The server is setup for local authentication, and can be accessed with:

    sudo -u jboss /opt/jboss/bin/jboss-cli.sh --connect
