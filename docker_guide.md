# Download Docker from apt (Docker Engine): https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker CLI is there:
 sudo systemctl status docker
 sudo systemctl start docker
 
 sudo docker run hello-world

# Download Docker Desktop: https://docs.docker.com/desktop/setup/install/linux/ubuntu/
 sudo apt-get update

 # Acquire the .deb for Ubuntu / Debian based syste (under 'Install Docker Desktop', part 2.)
 https://docs.docker.com/desktop/setup/install/linux/ubuntu/
 
 
sudo apt install ./docker-desktop-amd64.deb
 
# Verify Docker Desktop exists (start, enable, stop):
  systemctl --user start docker-desktop
  systemctl --user enable docker-desktop
  systemctl --user stop docker-desktop

# Open the Docker Desktop and Must Accept to continue working
Tick the box

# Change any settings ('send usage statistics etc'):
Docker Desktop -> Settings -> ...

# Confirm login, and enable credential storing into .password
docker login 
# Generate a key to allow use of command 'pass init'
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=short
# You will see something like this:
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/user/.gnupg/pubring.kbx
sec <algorithm, secret, date> <KEYSTRING in hexadecimal>
uid [ultimate] <name> <email>
ssb <...> <date>

# Verify the existance.
user@PC:~$ ls -la ~/.gnupg
total 32
drwx------  4 user user 4096 Jul 16 07:37 .
drwxr-x--- 41 user user 4096 Jul 16 07:35 ..
drwx------  2 user user 4096 Jul 16 07:33 openpgp-revocs.d
drwx------  2 user user 4096 Jul 16 07:33 private-keys-v1.d
-rw-rw-r--  1 user user 2520 Jul 16 07:33 pubring.kbx
-rw-------  1 user user   32 May  2 22:04 pubring.kbx~
-rw-------  1 user user  600 Jul 16 07:37 random_seed
-rw-------  1 user user 1280 Jul 16 07:35 trustdb.gpg
user@PC:~$ 


# Take the KEYSTRING and run the code
pass init <KEYSTRING in hexadecimal>

docker login
# Insert the password set during key generation and wait (nothing happens)
# Confirm login with a new command:
docker login

#####
# Docker has a 'getting started image', go ahead and pull it down to your local machine
docker pull docker/getting-started

# Use 'images' command to view all the images you have saved. You should see 'docker/getting-started' listed:
docker images

# Open the Docker Desktop App, you should see the images there under the 'images' tab:
# Now that you have the 'getting-started' image, let's use it to run a new 'container' with 'docker run'

# this is just an example, don't run this
docker run -d -p hostport:containerport namespace/name:tag

-d: Run in detached mode (doesn't block your terminal)
-p: Publish a container's port to the host (forwarding)
hostport: The port on your local machine
containerport: The port inside the container
namespace/name: The name of the image (usually in the format username/repo)
tag: The version of the image (often latest)

#### Use the run command to start a new container from the "getting started" image:
docker run -d -p 8965:80 docker/getting-started:latest

# You should see the container running in the 'Containers' tab of Docker Desktop.
# Run this on the command line to see the running containers:
docker ps

# On one of the columns you should see this:
PORTS
0.0.0.0:8965->80/tcp

# This is saying that port 8965 on your local "host" machine is being forwarded to port 80 on the running container. 
# Port 80 is conventionally used for HTTP web traffic.
Navigate to http://localhost:8965 and you should see a webpage served from the container!

# Stop a Container
docker ps
docker stop CONTAINER_ID

## Running multiple container (new port number each time)
# Remember, Docker containers are very lightweight. It's normal to run many containers on a single host machine.
# Remember, each container is its own isolated environment and process. 
docker run -d -p 8965:80 docker/getting-started
docker run -d -p 8966:80 docker/getting-started
docker run -d -p 8967:80 docker/getting-started
docker run -d -p 8968:80 docker/getting-started
docker run -d -p 8969:80 docker/getting-started

# Storing - Docker volumes
By default, Docker containers don't retain any state from past containers. For example, if I:

    Start a container from an image
    Make some changes to the filesystem (like installing a new package) in that container
    Stop the container
    Start a new container from the same image
    The new container does not have the changes I made in step 2.
    
    All this said, Docker does have ways to support "persistent state" through storage volumes. They're basically a filesystem that lives outside of the container, but can be accessed by the container.

# Create a new empty volume called ghost-vol:
docker volume create ghost-vol

# make sure it worked:
docker volume ls

# Inspect the volume to see where it is on your local machine
docker volume inspect ghost-vol

# Volume Ready, now run the 'Ghost' in Docker. Docker hosts an official image for Ghost on DockerHub.
# 1 Pull the Ghost image from Docker Hub:
docker pull ghost

# 2 Run the Ghost image in a new container:
docker run -d -e NODE_ENV=development -e url=http://localhost:3001 -p 3001:2368 -v ghost-vol:/var/lib/ghost ghost

    -d runs the image in detached mode to avoid blocking the terminal.
    -e NODE_ENV=development sets an environment variable within the container. This tells Ghost to run in "development" mode (rather than "production", for instance)
    -e url=http://localhost:3001 sets another environment variable, this one tells Ghost that we want to be able to access Ghost via a URL on our host machine.
    We've used -p before.
    -p 3001:2368 does some port-forwarding between the container and our host machine.
    -v ghost-vol:/var/lib/ghost mounts the ghost-vol volume that we created before to the /var/lib/ghost path in the container. Ghost will use the /var/lib/ghost directory to persist stateful data (files) between runs.
    
# 3 Navigate to http://localhost:3001/ in your browser, you should see your new Ghost CMS!

# Remove a container with volume
# List docker containers
docker ps -a 
# Stop a specific container
docker stop CONTAINER_ID
# Remove a container
docker rm CONTAINER_ID
# Commands for volume configuration
docker volume --help

# List the volume
docker volume list

# Remove the volume
docker volume rm VOLUME_ID


# Now that it's gone, let's see what happens if we try to start the Ghost container back up and attach it to a volume that doesn't exist.
docker run -d -e NODE_ENV=development -e url=http://localhost:3001 -p 3001:2368 -v ghost-vol:/var/lib/ghost ghost

# Check the volumes. 
# It turns out the -v ghost-vol:/var/lib/ghost flag binds to a "ghost-vol" volume if it exists, otherwise, it creates it automatically!
docker volume ls

#####
# Clean up
docker ps -a
docker rm <CONTAINER-ID>
docker volume ls 
docker volume rm <name>

# Quick commands:
# Stop and Remove all Docker Containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Stop and Remove all Docker images, and container (not volumes)
docker system prune
docker volume prune

################################
# Execute inside Docker
## similar to ssh'ing into docker.

docker ps
docker run -d -p 8965:80 docker/getting-started

# ensure it is running
docker ps

# Run an 'ls' command <inside the container> using 'docker exec'
docker exec CONTAINER_ID ls

##### LIVE SHELL IN CONTAINER #####
-i makes the exec command interactive
-t gives us a tty (keyboard) interface
Running /bin/sh gives us a shell session inside the container

# command to have interactive shell inside container
docker ps
docker exec -it CONTAINER_ID /bin/sh

# fun experiment -> overwrite index.html of 'localhost:8965'
# change into directory 'usr/share/nginx/html'
cd usr/share/nginx/html
echo "I hacked you!" > index.html

# open brauser on local machine and go into browser with http://localhost:8965

#################################################
##### OFFLINE MODE (airgapped container) ########
- You're running 3rd party code that you don't trust, and it shouldn't need network access
- You're building an e-learning site, and you're allowing students to execute code on your machines
- You know a container has a virus that's sending malicious requests over the internet, and you want to do an audit
##################################################



##### Run a container in offline mode (not spread potential virus)
# Stop and remove the container 'getting started' container if running
docker ps
docker stop CONTAINER_ID
docker rm CONTAINER_ID

# Start a New "Getting started" container in ' --network none' mode.
docker run -d --network none docker/getting-started

# Run the ping command with a timeout of 2 seconds inside the container
docker exec CONTAINER_id ping google.com -W 2


###### Load balancing ######
# Use open-source load balancer and webserver -> Caddy (written in Go)

# Popular alternatives are Nginx and Apache

#1 Pull caddy official image
docker pull caddy

#2 Create an index.html in your working directory
<html>
  <body>
    <h1>Hello from server 1</h1>
  </body>
</html>

#3 Create an index2.html file in your working directory
<html>
  <body>
    <h1>Hello from server 2</h1>
  </body>
</html>

#4 Run a container for index1.html for port 8881
docker run -d -p 8881:80 -v $PWD/index1.html:/usr/share/caddy/index.html caddy

#5 Run a container for index2.html for port 8882
docker run -d -p 8882:80 -v $PWD/index2.html:/usr/share/caddy/index.html caddy

#6 Navigate to localhost:8881 in a browser. You'll see "Hello from server 1"
#7 Navigate to localhost:8882 in a browser. You'll see "Hello from server 2"

##################################################################
# Bridge Network between containers to communicate with each other
##################################################################
- We can create custom bridge networks so that containers can communicate with each other if we want them to, but still otherwise remain isolated. 
- Let's build a system where our application servers are hidden within a custom network, and only our load balancer is exposed to the host.
- This is a very common setup in backend architecture. The load balancer is exposed to the public internet, but the application servers are only accessible via the load balancer.

#1 Create a custom bridge network called 'caddytest'
docker network create caddytest

#2 See if worked by listing all the networks
docker network ls

#3 Stop the containers and spin new ones, but attach them to 'caddytest' network:
Use the --network caddytest flag to attach them to the network
Use the --name flag to name them caddy1 and caddy2 respectively so it's easier to reference them later
Place these flags before the image name (caddy) in your docker run command. For example: 
>>>
#3.1 Index1.html
docker run -d --name caddy1 --network caddytest -v $PWD/index1.html:/usr/share/caddy/index.html caddy
#3.2 Index2.html
docker run -d --name caddy2 --network caddytest -v $PWD/index2.html:/usr/share/caddy/index.html caddy

#4 Create another "getting started" container on the same network and start a shell session within it:
docker run -it --network caddytest docker/getting-started /bin/sh

By giving our containers some names, caddy1 and caddy2, and providing a bridge network, Docker has set up name resolution for us! The container names resolve to the individual containers from all other containers on the network.

# Check 

#5 Within your docker/getting-started container shell, 'curl' your first container
curl caddy1

#6 Also 'curl' the second container:
curl caddy2

#7 If you get the HTML responses you expect, exit out of your shell session withing the 'getting started' container

#OPTIONAL: if you need to restart your caddy application servers after naming them,
# you can then use 'docker start caddy1' and 'docker start caddy2'

# Verify the network bridge is running with caddy1 and caddy2
docker network inspect caddytest  | grep caddy1
docker network inspect caddytest  | grep caddy2

## Configuring the Load Balancer.
 + We've confirmed that we have 2 application servers (Caddy) working properly on a custom bridge network.
 + Let's create a load balancer that balances network requests between the two! We'll use a round-robin balancing strategy, so each request should route back and forth between the servers.
 
 + Caddy works great as a file server, which is what our little HTML servers are, but it also works great as a load balancer! 
 + To use Caddy as a load balancer we'll need to create a custom Caddyfile to tell Caddy how we want it to balance the traffic. It's just a config file for Caddy.

#8 Stop and remove any containers that aren't the 2 caddy servers we're working with currently.
docker ps
docker stop CONTAINER_ID
docker rm CONTAINER_ID

#9 Create a new file in your local directory called Caddyfile
sudo nano Caddyfile
# Contents:
localhost:80

reverse_proxy caddy1:80 caddy2:80 {
	lb_policy       round_robin
}

# 
+ This tells Caddy to run on localhost:80, and to round robin any incoming traffic to caddy1:80 and caddy2:80.
+ Remember, this only works because we're going to run the loadbalancer on the same network, so caddy1 and caddy2 will automatically resolve to our application server's containers.

#10 Start the load balancer container on port 8880. Instead of an index.html, give it our custom Caddyfile:
docker run -d --network caddytest -p 8880:80 -v $PWD/Caddyfile:/etc/caddy/Caddyfile caddy

# 11 Hit the load balancer on http://localhost:8880/! You should either get a response from server 1 or server 2, and if you hard refresh the page, it should swap back and forth.
curl http://localhost:8880/


##################################################################
### Dockerfile
###############
#1 Create file 'Dockerfile' in your working directory.
nano Dockerfile

#2 Inside the Dockerfile, add these lines of text:
    # This is a comment

    # Use a lightweight debian os
    # as the base image
    FROM debian:stable-slim

    # execute the 'echo "hello world"'
    # command when the container runs
    CMD ["echo", "hello world"]
    


#3 Build a new image from the Dockerfile and call it 'helloworld':
docker build . -t helloworld:latest

+ The -t helloworld:latest flag tags the image with the name "helloworld" and the "latest" tag. Names are used to organize your images, and tags are used to keep track of different versions.

#4 Run the image in a new container
docker run helloworld

#5 Run 'docker ps'. You'll notice that your container is not running
docker ps

+  All it did was print and exit.
+ Just like regular programs, docker containers can execute simple commands that exit quickly,
+ or they can execute servers that run until killed. It just depends on the command you give it.

#6 See stopped container with 'docker ps -a'
docker ps -a
#7 Delete the Dockerfile, you will not need it any longer.
#########################################################

#########################################################
# Building a server with Dockerfile
#########################################################
#0 Compile the Go program into binary
go build -o goserver

#1 Create a 'Dockerfile'
nano Dockerfile

#2 Add the contents
    # This is a comment

    # Use a lightweight debian os
    # as the base image
    FROM debian:stable-slim

    # add a COPY command on command.
    # in the case of simple compiled Go server, all we need is a compiled program itself
    COPY goserver /bin/goserver

    # add a CMD command.
    # This automatically starts the server process in the container when we run it
    CMD ["/bin/goserver"]

#3 Build your 'Dockerfile' into an image
docker build . -t goserver:latest

+  The -t goserver:latest flag tags the image with the name "goserver" and the "latest" tag. Names are used to organize your images, and tags are used to keep track of different versions.

#4 Start a new container from the image. Be sure to forward the ports to your hostname
docker run -p 8010:8010 goserver

#5 Optional: resolve error
    If you get an exec format error, it's probably because you built the go server for your local architecture, but you're trying to run it on a Linux OS! To fix it, rebuild the binary (and then the Dockerfile) with these environment variables:

GOOS=linux GOARCH=amd64 go build

#6 You should be able to access your server from the browser just like before, but this time it's running inside of Docker!

###########################################
# Creating environment - Docker containers
###########################################

#1 In main.go, change an hardcoded exposed port to an environment variables:
> main.go
port := os.Getenv("PORT")

#2 Assign a value to as an environment variable in your shell,
# that we stated above as "PORT" in main.go
> 
export PORT="8999"

#3 Rebuild and run your program, make sure it serves on port 8999
go build -o goserver && ./goserver

#4 Add an ENV command to your Dockerfile to set the port within the image.
## 'Dockerfiles' content:
    # This is a comment
    # Use a lightweight debian os
    # as the base image
    FROM debian:stable-slim

    # add a COPY command on command.
    # in the case of simple compiled Go server, all we need is a compiled program itself
    COPY goserver /bin/goserver

    # set the port within the image. 
    # must be fore 'CMD' command, so that environment variable is set before server starts
    ENV PORT=8991

    # add a CMD command.
    # This automatically starts the server process in the container when we run it
    CMD ["/bin/goserver"]


## You'll need to do it before the CMD command so that the environment variable is set before the server starts.

#5 Rebuild your Docker image
docker build . -t goserver:latest

#6 Rerun your Docker container, be sure to expose the correct port:
docker run -p 8991:8991 goserver

################################################
## Docker Logs 
################################################
# docker logs [options] CONTAINER
## CONTAINER can be name or ID

#1 Let's run the Linux 'alpine' image in a new container in 'detached mode'
## and give it simple command to run to generate some standard output:

docker run -d --name logdate alpine sh -c 'while true; do echo "LOGGING: $(date)"; sleep 1; done'

 + The sh -c 'while true; do echo "LOGGING: $(date)"; sleep 1; done' part is just a simple shell script to execute inside the container that prints the current date and time every second.

#2 Find the ID of the running container with 'docker ps'
docker ps

#3 Use 'docker logs' command to view the logs of the container
docker logs -f CONTAINER-ID

#4 View only the 5 most recent logs with --tail option
docker logs --tail 5 CONTAINER_ID

################################################
## Guide to use 'docker stats'
################################################
docker stats [OPTIONS] [CONTAINER...]

#1 Start pre-build 'stress-ng' image to create container.
## This artificially uses a lot of CPU/memory resources. 
## Start a container that uses a full CPU core:
docker run -d --name cpu-stress alexeiled/stress-ng --cpu 2 --timeout 10m

#2 Start another container that uses memory
docker run -d --name mem-stress alexeiled/stress-ng --vm 1 --vm-bytes 1G --timeout 10m

#3 Run 'docker stats' to see live resource usage of the two containers.
## CPU, memory, network I/O, block I/O for each container
docker stats

#4 Check the running containers (docker ps)
docker ps --no-trunc

# ASSIGN RESOURCE LIMITS AND CHECK RESOURCE USAGE NOW

#5 Run the same alexeiled/stress-ng container as before, but this time limit the CPUs to only 0.25 (1/4th of a CPU core):
docker run -d --cpus="0.25" --name cpu-stress alexeiled/stress-ng --cpu 2 --timeout 10m

#6 Run 'docker stats' to see resource usage again
docker stats
##################################################

################################################
###### Publish Docker IMAGE onto DockerHub #####
#1 Rebuild the Go binary:
GOOS=linux GOARCH=amd64 go build

#2 Rebuild the image. You'll need to use a name that corresponds to your namespace on DockerHub
# docker build . -t <docker_hub_username>/goserver
docker build . -t frkirc/goserver

#3 Run your image in a container to make sure it workds
# docker run -p 8991:8991 <docker_hub_username>/goserver
docker run -p 8991:8991 frkirc/goserver

#4 Push the image to DockerHub
docker push frkirc/goserver

#5 Verify 'docker push' was successful with <Delete and Pull> method
#Optional, find the IMAGE ID OR NAME
docker image list

docker image rm frkirc/goserver --force

#6 Pull it back down FROM Docker Hub. 
docker pull frkirc/goserver

#7 Run it to make sure it works
docker run -p 8991:8991 frkirc/goserver
#####################################################

#####################################################
##### Tags
#####################################################
#0 Let's publish a new version of our web server
+  With Docker, a tag is a label that you can assign to a specific version of an image, similar to a tag in Git.

+ The latest tag is the default tag that Docker uses when you don't specify one. It's a convention to use latest for the most recent version of an image, but it's also common to include other tags, often semantic versioning tags like 0.1.0, 0.2.0, etc.

#1 Optional: Create some changes in the Go code
#2 Compile the new Go program 'go build -o NEW_NAME_OUTPUT_FILE'
go build -o goserver

#3 Rebuild the Docker image. Make sure to use same name as before, but add a new tag to end of the image name.
docker build . -t frkirc/goserver:0.2.0

#4 Run the new image
docker run -p 8991:8991 frkirc/goserver:0.2.0

#5 Open the browser and navigate to localhost:8991. You should see new version of server running.

#6 Push the new image up to Docker Hub. MUST SPECIFY THE TAG AS WELL!
docker push frkirc/goserver:0.2.0

#7 Navigate to your repository on Docker Hub and you'll see 2 images with different tags
https://hub.docker.com/repositories/frkirc

#8 Stop and remove the new container you started.
docker ps -a

#9 Delete the local images so that you have no reference on your local machine
docker rm --force CONTAINER_ID

#10 Pull and run the new version from Docker Hub.
docker pull USERNAME/goserver:0.2.0
docker run -p 8991:8991 USERNAME/goserver:0.2.0

#11 Update this new version as 'latest' on your local machine
docker build -t frkirc/goserver:0.2.0 -t frkirc/goserver:latest .

#12 Push change onto Docker Hub
docker push frkirc/goserver --all-tags

####################################################


The Deployment Process

    The developer (you) writes some new code
    The developer commits the code to Git
    The developer pushes a new branch to GitHub
    The developer opens a pull request to the main branch
    A teammate reviews the PR and approves it (if it looks good)
    The developer merges the pull request
    Upon merging, an automated script, perhaps a GitHub action, is started
    The script builds the code (if it's a compiled language)
    The script builds a new docker image with the latest program
    The script pushes the new image to Docker Hub
    The server that runs the containers, perhaps a Kubernetes cluster, is told there is a new version
    The k8s cluster pulls down the latest image
    The k8s cluster shuts down old containers as it spins up new containers of the latest image
#######################################################
