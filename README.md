## Dynamic Hyperledger network creation

A sample application which will help the developers to concentrate on working with hyperledger fabric framework without worrying about setting up the whole network.
It will ask you about the number of organisations , no of peers in each organisations ,domain name and channel name and setup the whole network accordingly.

The project has been tested on Ubuntu 16.04.

### Prerequisites :

1. Docker - v1.12 or higher,

2. Docker Compose - v1.8 or higher,

3. Git client - needed for clone commands,

4. A linux machine , the script is for a linux machine.


Once you have completed the above setup

Go inside this project's main directory,

```
cd dynamic-hyperledger-network-creation
```


and run the bash script with the command:

```
bash generate.sh
```


So if you dont have the cryptogen tool or configtx tool , this script will download it for you inside 'bin' folder of the same project(i.e. inside dynamic-hyperledger-network-creation/bin). Please add
the path to this  bin folder  to your path variable($PATH) in '.bashrc' file or '.profile' file, so that this script wont download these tools everytime you run it.

Crypto material will be  generated using the cryptogen tool from Hyperledger Fabric and mounted to all peers, the orderering node and CA containers. 
An Orderer genesis block (genesis.block) and channel configuration transaction will be  generated using the configtxgen tool from Hyperledger Fabric and will be  placed within the artifacts folder.


#### You can get all the certificates and other material generated inside the 'artifacts' folder , you can copy that to your project and start working with your application.

### Discover Peer Ports

If you want to see the addresses of all the peers and orderers just go to

```
cd dynamic-hyperledger-network-creation/artifacts
```

There will be a 'docker-compose.yaml' file , from which you can get the addresses needed.


### Note
Please do not change the templates given in the project as generate.sh script will stop working if the lines get changed.

If you want to understand how it is working , you can have a look at the script -  generate.sh

Right now for demo purpose, we are taking maximum 5 organizations and maximum  5 peers under each organization, if you want to change this change it in the generate.sh script.

## License

This Project's source code files are made available under the Apache License, Version 2.0 (Apache-2.0), located in the license file under this repo.


