# AbstractDAQ


## Introduction: Julia in the Lab

There are many data acquisition, for all kinds of purposes and scopes. There are simple data acquisition boards that can read one or more voltage. There pressure scanners, improvised systems using Arduino and related technologies. Usually each system has its own software stack or something like it.

Often the software only talks to a single device and usually not the way you want it. It works only on windows and often on an old version of windows (one might say that Windows XP reigns supreme in the lab...). And if you need to use more than one device, things start to get complicated.

There are tools that claim to solve this problem, such as LabView and to a large extent it does solve the problem. But it has problems of its own:

 - It is very expensive
 - Many instruments do not interface with it yet or the drivers are not very good.
 - The graphical language it uses is very appealing to novices but to more experienced programmers it is a little painful.
 - Two language problem (the other one in this case...): you acquire data with LabView and and process it somewhere else.

Another alternative is Matlab's DAQ toolbox. It certainly solves the "two language" problem, it doesn't use a graphical programming language but even fewer instruments are compatible with it and it is very expensive (the toolbox and Matlab).

[The Julia programming language](https://julialang.org) claims to solve the two language problem (the *real* two language problem...) and it is a very nice programming language with a good and rapidly growing ecosystem in many areas and specially in scientific computing. The fact that Julia solves the (real) two language problem is important for us: it means we can do efficiently low level stuff such as interfacing with instruments. And the fact that it has a good and grouwing ecosystem in scientific computing means that it is in a very good position to solve *our* two language problem. But work needs to be done...

## AbstractDAQs

Here is where `AbstractDAQs` package comes in. It tries to provide a common interface to instruments:

 - Adding inputs (daq channels) with `daqaddinput`
 - Configuring the device with `daqconfig` and `daqconfigdev`
 - Synchronous data acquisition with `daqacquire`
 - Asynchronous data acquisition with `daqstart` and `daqread`
 - Handling more thant one instrument with `DeviceSet`
 - Saving data using HDF5 files

The package `AbstractDAQs` also provides tools to help develop interfaces to other instruments.


## Devices using AbstractDAQs

 * [Scanivalve.jl](https://github.com/pjsjipt/Scanivalve.jl). An interface to [Scanivalve](http://scanivalve.com) pressure scanners. For now only model DSA3217.
 * [DTCInitium.jl](https://github.com/pjsjipt/DTCInitium.jl). An interface to [DTC Initium](https://www.te.com/usa-en/product-CAT-SCS0010.html) pressure scanners. It is more commonly known byt its old name, Pressure Systems (PSI).
 * [DAQnidaqmx.jl](https://github.com/pjsjipt/DAQnidaqmx.jl). An interface to [NIDAQmx](https://www.ni.com/pt-br/support/downloads/drivers/download.ni-daqmx.html#428058). Now, only minimal functionality is provided. It uses the Julia package [NIDAQ.jl](https://github.com/JaneliaSciComp/NIDAQ.jl) to interface
 * More to come...


## The basic interface

Each device has its own method of creating a connection to the instrument. But after that there are several generic functions that handle the data acquisition process.

### Adding input channels

The function `daqaddinput` adds analog input channels. How to characterize the input channels is device dependent. But usually you need to specify the channels and, optionally give the channels a name.

### Configuring data acquisition

Here we have two options:

 - `daqconfigdev` configures the device using native parameters and options. What do I mean by that? Manufacturers develop their own protocols and software and use different terminology and names for data acquisition parameters. This interface uses this terminology. It is the recommended interface
 _ `daqconfig` uses a more generic interface where the user can specify parameters such as `rate` for sampling rate or `dt` for sampling time. The user can specify the number of samples with `nsamples` or total data acquisition time with `time`. In many cases this is straight forward but it can be tricky to do this correctly in some systems (DTC Initium, I'm talking about you...)

### Synchronous data acquisition

This is done with the function `daqacquire`. Just call this function and wait for data acquisition to end.

### Asynchronous data acquisition

In this case the data acquisition happens in the background. To start the data acquisition, use the function `daqstart`. To read the data, use `daqread`. There are methods for checking if data acquisition is going on (`isreading` and `isdaqfinished`) or even how many samples where acquired (`samplesread`).

The method `daqread` waits for data acquisition to end and returns the acquired data. One special situation is continous data acquisition. This is still not well developed but for situations such as this, calling `daqread` will stop data acquisition with `daqstop` and return the acquired data. The function `daqpeek` (not implemented yet) will allow the user to take a look at the data already acquired without interrupting the process.

How is this asynchronous data acquisition done one might ask. It depends on the interface. For NIDAQmx, for example, this handled by the driver itself. We don't do anything. But for cases such as [`Scanivalve.jl`](https://github.com/pjsjipt/Scanivalve.jl) or [DTCInitium.jl](https://github.com/pjsjipt/DTCInitium.jl) where the device communicates with the computer using TCP/IP and everything is implemented in Julia, the driver can use the asynchrownous stuff in Julia (`@async`) or multithreads (`@spawn`). This is chosen when the interface is created.

## Tools to help develop drivers

 * `CircMatBuffer` is a circular buffer, very similar to what is provided by the package [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl) except that it uses a matrix to store the data and each column corresponds to a sample. This sample might be sequence of bytes acquired or data on each channel.
 * `DAQConfig` is a struct that is useful to store configuration. It can store stuff such as model, serial number, storage tag, ip address and integer, floating point or string parameters.
 * `DAQTask` is a helper structure to deal with asynchronous data acquisition. It stores number of samples read, date and time of when the data acquisition started, timinf stuff (to calculate sampling rates).

## Data acquisition from more than one device

This a very common issue. You can create a "meta" device that handles multiple devices with `DeviceSet`.

## Data storage

Function `savedaqdata` stores data acquired in a HDF5 file. The device configuration can be stored with `savedaqconfig`.

## Other related work

In an experiment, you measure stuff but you also need to chage things. Move an instrument, change the rotation of a fan and stuff like this. Package [`AbstractActuators.jl`](https://github.com/pjsjipt/AbstractActuators.jl) tries to handle such things.

## Future

This is an ongoing work and it is bound to change as more experience is gained with the system. For now it is basically an abstract interface but in the future it could be used as to develop interactive DAQ GUI.

The approach used here could be called the classical approach is inspired by the Matlab DAQ toolbox. Probably better alternatives are possible. And certainly tweaks will be required as more experience is gained.


