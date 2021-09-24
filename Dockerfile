FROM debian:stable-slim

ENV PATH="/root/.platformio/penv/bin:${PATH}"

RUN apt update && apt install -y curl python3 python3-venv
RUN curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o get-platformio.py && python3 get-platformio.py
RUN platformio platform update
