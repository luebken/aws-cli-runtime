FROM debian:stable-slim
WORKDIR /work
RUN apt update && \
    apt install -y curl unzip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
RUN unzip awscliv2.zip
RUN ./aws/install
CMD [ "/bin/bash", "-c", "while true; do echo hello; sleep 10;done"]
