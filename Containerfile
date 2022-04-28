FROM rocm/rocm-terminal:latest

ENV DEBIAN_FRONTEND noninteractive
ARG VIRTUALGL_VER=3.0.1

RUN UBUNTU_VERSION=$(cat /etc/os-release | grep UBUNTU_CODENAME | sed 's/UBUNTU_CODENAME=//') && \
  curl -s https://xpra.org/gpg.asc | sudo apt-key add - && \
  echo "deb https://xpra.org/ $UBUNTU_VERSION main" | sudo tee /etc/apt/sources.list.d/xpra.list && \
  sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends xpra xpra-html5 python3-requests libegl1-mesa libxv1 && \
  sudo apt-get install -y --no-install-recommends fluxbox eterm stterm && \
  curl -fsSL -O https://s3.amazonaws.com/virtualgl-pr/main/linux/virtualgl_${VIRTUALGL_VER}_amd64.deb && \
  sudo dpkg -i virtualgl_${VIRTUALGL_VER}_amd64.deb && \
  rm virtualgl_${VIRTUALGL_VER}_amd64.deb && \
  sudo rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./xpra.conf /etc/xpra/xpra.conf
COPY ./menu /etc/X11/fluxbox/fluxbox-menu

WORKDIR /work
RUN sudo cp /etc/xpra/ssl-cert.pem ./ssl-cert.pem && sudo chown $(id -u):$(id -g) ./ssl-cert.pem
ENV DISPLAY=":100"
ENV VGL_DISPLAY="/dev/dri/card0"
ENV XPRA_PASSWORD=password
EXPOSE 14500

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sh", "-c", "/usr/bin/xpra start-desktop ${DISPLAY} --daemon=no --start='fluxbox'"]
