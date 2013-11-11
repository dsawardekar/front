# Front

### Speed up your Vagrant workflow

Booting up a fresh virtual machine takes time. `Front` speeds up VM boot
time by preinitializing a pool of VMs. When you need a fresh instance,
use `front next` and you are ready to work instantly. And while you work
it rebuilds the old VM for your next refill!

## Installation

Install with rubygems:

    $ gem install front

## Usage

When starting a work session, create a new Vagrantfile for your project.
Then create a new pool with `create`. Without an inventory file, front
uses a default Vagrantfile with a Ubuntu `precise64` box.

    $ front create

As soon as the 1st VM is ready control is returned to you while the
other instances in the pool are being preloaded. You can now login to
this VM with,

    $ front ssh

After you are done with this instance, and need a fresh one, you can
fetch it with `front next`.

    $ front next

An inventory file is maintained with the SSH port every time you switch
instances. This can be accessed with the `inventory` action.

    $ front inventory

Finally when done, dispose of the pool with the `destroy` action.

    $ front destroy

## Implementation

`Front` clones your project Vagrantfile into a `.front` directory
containing the virtual machine instances. When you access the
`front` commands it steps into these subdirectories and calls the
corresponding vagrant command. Most actions run in the background
allowing you to continue working while they complete.

## Complete Usage

    $ front [options] [action]

    Actions
      create     : create a new pool
      destroy    : destroy pool
      next       : switch to next instance in pool
      ssh        : ssh to current instance => vagrant ssh
      ssh_config : print ssh config for current instance
      inventory  : print inventory file

Options

    -s, --size <size>                Size of instance pool
    -V, --version                    Print Front version
    -h, --help                       Print Front help

## Caveats

* Running multiple VMs requires a fast computer with lots of RAM.
  The actual amount depends on the number of VMs, and their configuration.
  Eg:- For a Ubuntu box with 512MB ram with a pool of size 4, you need
  at least 2GB for Virtual Box. Plus additional RAM for the host system.
* Default pool size is 2.

## TODO

* Needs to handle Vagrant errors better.
* Pool size once created should be persistent.
* If an instance isn't ready should be able to show it's status.
* Allow running of other vagrant subcommands

## Contributing

* This project uses the gitflow branching model. PR's go against `develop`.
