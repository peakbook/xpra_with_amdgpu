FROM rocm/rocm-terminal:latest

ENV DEBIAN_FRONTEND noninteractive
ARG VIRTUALGL_VER=3.1.2

RUN sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends lsb-release fluxbox eterm stterm && \
  sudo curl -fsSL https://xpra.org/gpg.asc -o /etc/apt/trusted.gpg.d/xpra.asc && \
  echo "deb https://xpra.org/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/xpra.list && \
  sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends xpra xpra-x11 xpra-html5 python3-requests libegl1-mesa libxv1 libxtst6 libglu1-mesa && \
  curl -fsSL -O https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VER}/virtualgl_${VIRTUALGL_VER}_amd64.deb && \
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
