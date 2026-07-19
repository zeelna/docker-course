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
