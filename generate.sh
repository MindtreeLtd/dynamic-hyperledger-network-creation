#!/bin/bash
#
#  Copyrights 2018, Mindtree Ltd. - All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#        http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#


export FABRIC_CFG_PATH=${PWD}/artifacts/channel

# Declaring global array to store no of peers in each organization 
   declare -gA peerArray
      
# Getting no of organizations from the user 
   noOfOrgs()
   {
    read -p "How many organizations do you want ?" no_of_orgs
    if [[ $no_of_orgs != *[[:digit:]]* ]]; then
    echo "Please Enter Correct No Of Orgs"
	noOfOrgs
   fi
   }
    
 # Getting no of peers in each org from the user 
    
      noOfPeers()
      {
	i=1 
       while [ "$i" -le "$no_of_orgs" ]
       do
        read -p "How many peers do you want in org $i ?"   no_of_peers
        if [[ $no_of_peers != *[[:digit:]]* ]]; then
        echo "Please Enter Correct No Of Peers"
	    continue
        fi
	    peerArray[$((i-1))]=$no_of_peers
		if [ $no_of_peers -gt 5 -o $no_of_peers -lt 2 ]; then
		echo "Please you cant make more than 5 or less than 2 peers per org"
                continue
		fi
		i=$((i + 1))
	   done
      }
      
 
      noOfOrgs
	
      # Check for max no of orgs-here 5
    while [ "$no_of_orgs" -gt 5 -o "$no_of_orgs" -lt 1 ]
     do
      echo "Please you cant make more than 5 orgs or less than 1 orgs"
      noOfOrgs
     done

     noOfPeers

     # Getting domain name from the user(if your domain name is say 'mindtree.com' , please enter 'mindtree')
    getDomainName()
    {	
	    echo -n "Enter Domain Name ? ,if your domain name is say 'mindtree.com' , please enter 'mindtree'"
        read domain_name

        compressed="$(echo $domain_name | sed -e 's/[^[:alnum:]]//g')"

        if [ "$compressed" != "$domain_name" ] ; then
        echo "Domain_name not valid, please enter domain name in alphanumeric characters"
		getDomainName
        fi
	
	}
	getDomainName

	
	
# Getting channel name from user	
    getchannelName()
    {	
	    echo -n "Enter Channel Name ?"
        read channel_name

        compressed="$(echo $channel_name | sed -e 's/[^[:alnum:]]//g')"

        if [ "$compressed" != "$channel_name" ] ; then
        echo "Channel_name not valid, please enter channel name in alphanumeric characters"
		getchannelName
        fi
	
	}
	getchannelName
	
# Generate crypto-config.yaml file from crypto-config-template.yaml template

   generateCryptoConfig()
   {
    i=1
    sed -n -e '1,33p'  crypto-config-template.yaml > crypto-config.yaml
    while [ "$i" -le "$no_of_orgs" ]
     do
      sed -n -e '34,39p'  crypto-config-template.yaml > crypto-config-temp-file.yaml
      sed -i "s/ORG_NO/$i/g" crypto-config-temp-file.yaml
	  sed -i "s/NO_OF_PEERS/$no_of_peers/g" crypto-config-temp-file.yaml
      cat < crypto-config-temp-file.yaml >> crypto-config.yaml
      i=$((i + 1))
	 done
	 rm -rf crypto-config-temp-file.yaml
	 sed -i "s/DOMAIN_NAME/$domain_name/g" crypto-config.yaml
	 mv crypto-config.yaml artifacts/channel/ 
   }
 
# Generate configtx.yaml file from configtx-template.yaml template 
   generateConfigTx()
   {
       sed -n -e '1,35p'  configtx-template.yaml > configtx.yaml
	   j=2
       while [ "$j" -le "$no_of_orgs" ]
       do
        sed -n -e '35,35p'  configtx-template.yaml > configtx-template2.yaml
        sed -i "s/*Org1/*Org$j/g" configtx-template2.yaml
        cat < configtx-template2.yaml >> configtx.yaml
        j=$((j + 1))
       done
       sed -n -e '36,41p'  configtx-template.yaml > configtx-template2.yaml
       cat < configtx-template2.yaml >> configtx.yaml
	   j=2
       while [ "$j" -le "$no_of_orgs" ]
       do
        sed -n -e '41,41p'  configtx-template.yaml > configtx-template2.yaml
        sed -i "s/*Org1/*Org$j/g" configtx-template2.yaml
        cat < configtx-template2.yaml >> configtx.yaml
        j=$((j + 1))
       done
       sed -n -e '42,65p'  configtx-template.yaml > configtx-template2.yaml
       cat < configtx-template2.yaml >> configtx.yaml
       j=1
       while [ "$j" -le "$no_of_orgs" ]
       do
        sed -n -e '66,81p'  configtx-template.yaml > configtx-template2.yaml
        sed -i "s/ORG_NO/$j/g" configtx-template2.yaml
        k=$(($((7050+$j))+$(($j-1))))
        sed -i "s/PORT_NO/$k/g" configtx-template2.yaml
        cat < configtx-template2.yaml >> configtx.yaml
        j=$((j + 1))
      done
      sed -n -e '82,139p'  configtx-template.yaml > configtx-template2.yaml
      cat < configtx-template2.yaml >> configtx.yaml
      sed -i "s/DOMAIN_NAME/$domain_name/g" configtx.yaml
      sed -i "s/PROFILE/${no_of_orgs}Orgs/g" configtx.yaml 
	  rm -rf configtx-temp-file.yaml
	  rm -rf configtx-template2.yaml
	  mv configtx.yaml artifacts/channel/

   }
  
# Generate docker-compose-base.yaml file from docker-compose-base-template.yaml
    generateDockerComposeBase()
	{
	  k=1
	  i=1
	  arrayIndex=0
	  sed -n -e '1,43p'  docker-compose-base-template.yaml > artifacts/base/docker-compose-base.yaml
	  while [ "$i" -le "$no_of_orgs" ]
      do


	     echo "${#peerArray[@]}"
		 count=1

        while [ "$count" -le "${peerArray[$arrayIndex]}" ]
		do
		  echo "peer"
		  echo "$((count-1))"
		  sed -n -e '44,60p'  docker-compose-base-template.yaml > docker-compose-base-template2.yaml
          sed -i "s/ORG_NO/$i/g" docker-compose-base-template2.yaml
		  sed -i "s/PEER_PORT/$((7051+(k-1)*1000))/g" docker-compose-base-template2.yaml
		  sed -i "s/PEER_EVENT_PORT/$((7053+(k-1)*1000))/g" docker-compose-base-template2.yaml
		  sed -i "s/PEER_NO/$((count-1))/g" docker-compose-base-template2.yaml
		  cat < docker-compose-base-template2.yaml >> artifacts/base/docker-compose-base.yaml 
		  count=$((count+1))
		  k=$((k+1))
		done
        arrayIndex=$((arrayIndex+1))
        i=$((i + 1))
      done
	  sed -i "s/DOMAIN_NAME/$domain_name/g" artifacts/base/docker-compose-base.yaml
	  rm -rf docker-compose-base-template2.yaml	  
	}
	
# Generate docker-compose.yaml file from docker-compose-e2e-template.yaml
    generateDockerCompose()
	{
	  sed -n -e '1,20p'  docker-compose-e2e-template.yaml > docker-compose.yaml
	  i=1
	  while [ "$i" -le "$no_of_orgs" ]
      do
        sed -n -e '21,37p'  docker-compose-e2e-template.yaml > docker-compose-e2e-template2.yaml
        sed -i "s/CA_ORG/$((i - 1))/g" docker-compose-e2e-template2.yaml
        sed -i "s/CA_PORT/$((7054+(i-1)*1000))/g" docker-compose-e2e-template2.yaml
        sed -i "s/ORG_NO/$i/g" docker-compose-e2e-template2.yaml
        cat < docker-compose-e2e-template2.yaml >> docker-compose.yaml
        i=$((i + 1))
     done
	  sed -n -e '38,45p'  docker-compose-e2e-template.yaml > docker-compose-e2e-template2.yaml
	  cat < docker-compose-e2e-template2.yaml >> docker-compose.yaml
      	  
	  i=1
	  arrayIndex=0
	  while [ "$i" -le "$no_of_orgs" ]
      do
	     echo "${#peerArray[@]}"
		 count=1
        while [ "$count" -le "${peerArray[$arrayIndex]}" ]
         do
           sed -n -e '46,52p'  docker-compose-e2e-template.yaml > docker-compose-e2e-template2.yaml
	       sed -i "s/PEER_NO/$((count-1))/g" docker-compose-e2e-template2.yaml
	       sed -i "s/ORG_NO/$i/g" docker-compose-e2e-template2.yaml
           cat < docker-compose-e2e-template2.yaml >> docker-compose.yaml
		  count=$((count+1))
         done
		 arrayIndex=$((arrayIndex+1))
		 i=$((i + 1))
	  done
	  sed -i "s/DOMAIN_NAME/$domain_name/g" docker-compose.yaml
	  rm -rf docker-compose-e2e-template2.yaml
	  mv docker-compose.yaml artifacts

	  
	}


# Generate certificates
 function generateCerts ()
 {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. downloading"
    export VERSION=1.0.2
    export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
    curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${VERSION}/hyperledger-fabric-${ARCH}-${VERSION}.tar.gz | tar xz
    export PATH=$PATH:$(pwd)/bin
    echo $PATH
    echo "cryptogen tool downloaded"
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  cryptogen generate --config=./artifacts/channel/crypto-config.yaml
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
  mv crypto-config/ artifacts/channel/
}


# Generate channel artifacts
function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
   echo "configtxgen tool not found. downloading"
    export VERSION=1.0.2
    export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
    curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${VERSION}/hyperledger-fabric-${ARCH}-${VERSION}.tar.gz | tar xz
     export PATH=$PATH:$(pwd)/bin
     echo $PATH
     echo "configtxgen tool downloaded"
  fi

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!

  a=$no_of_orgs
  a+=OrgsOrdererGenesis
  echo $a


  configtxgen -profile $a -outputBlock genesis.block
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo
  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"

    a=$no_of_orgs
  a+=OrgsChannel
  echo $a
  echo ${PWD}
  configtxgen -profile $a -outputCreateChannelTx ${channel_name}.tx -channelID $channel_name

  if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for OrgsMSP  ##########"
  echo "#################################################################"
  a=$no_of_orgs
  a+=OrgsChannel
  echo $a
  j=1


  while [ "$j" -le "$no_of_orgs" ]
  do
       MSPANCHORS=Org
       MSPANCHORS+=$j
       MSPANCHORS+=MSPanchors.tx
       ORGMSP=Org
       ORGMSP+=$j
       ORGMSP+=MSP
      configtxgen -profile $a -outputAnchorPeersUpdate ${MSPANCHORS} -channelID $channel_name -asOrg $ORGMSP
      
      if [ "$?" -ne 0 ]; then
        echo "Failed to generate anchor peer update for Org1MSP..."
        exit 1
      fi

   j=$((j + 1))
  done

}


  # Replace private key in docker-compose.yaml file
function replacePrivateKey () {


  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the  CAs.
    cd artifacts/
    CURRENT_DIR=$PWD
    j=1
    while [ "$j" -le "$no_of_orgs" ]
    do
       cd channel/crypto-config/peerOrganizations/org${j}.${domain_name}.com/ca/
       PRIV_KEY=$(ls *_sk)
       echo ${PRIV_KEY}
       cd $CURRENT_DIR
       echo ${PWD}
       sed -i "s/CA${j}_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
       j=$((j + 1))
    done  
    cd channel

}
	

	generateCryptoConfig
	generateConfigTx
	generateDockerComposeBase
	generateDockerCompose
	generateCerts
        replacePrivateKey
        generateChannelArtifacts
 
#   to start docker containers   
#    docker-compose -f docker-compose.yaml up -d
   
   
 
