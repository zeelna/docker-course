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
