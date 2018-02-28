#
# Lean Python Environment
#
# Build:
#
#     docker build -t yujikosuga/lean_python .
#
# Usage:
#     
#     mkdir Launcher
#     curl -o Launcher/config.json https://raw.githubusercontent.com/QuantConnect/Lean/master/Launcher/config.json
#
#     Manually edit the following lines of Volume/Launcher/config.json:
#
#        "algorithm-type-name": "MyTradingAlgorithm",
#        "algorithm-language": "Python",
#        "algorithm-location": "../../../Algorithm.Python/MyTradingAlgorithm.py",
#
#     mkdir -p Volume/Algorithm.Python
#     touch Volume/Algorithm.Python/MyTradingAlgorithm.py
#
#     Write your trading algorithm in Volume/Algorithm.Python/MyTradingAlgorithm.py
#
#     This command runs your algorithm in MyTradingAlgorithm.py.
#     docker run -v "$PWD/Volume:/root/Lean/Volume" yujikosuga/lean_python:latest
#

FROM quantconnect/lean:foundation

RUN \
  wget https://github.com/QuantConnect/Lean/archive/master.zip && \
  unzip master.zip && \
  mv Lean-master /root/Lean

WORKDIR /root/Lean

ADD ./Launcher/config.json /root/Lean/Launcher/config.json

# Fix: update nuget itself because Newtonsoft.Json 10.0.3 requires nuget client 2.12+ but was 2.8.60717.93.
RUN \
  wget https://nuget.org/nuget.exe && \
  mono nuget.exe update -self && \
  mono nuget.exe restore QuantConnect.Lean.sln -NonInteractive &&\
  xbuild QuantConnect.Lean.sln

# Fix: /usr/lib/.../libstdc++.so.6 lacks support for CXXABI_1.3.11. 
RUN cp /opt/miniconda3/lib/libstdc++.so.6.0.24 /usr/lib/x86_64-linux-gnu/libstdc++.so.6

# Note: create a symbolic link because Lean executes py files under Lean/Algorithm.Python.
RUN ln -s /root/Lean/Volume/Algorithm.Python/MyTradingAlgorithm.py /root/Lean/Algorithm.Python/MyTradingAlgorithm.py

WORKDIR /root/Lean/Launcher/bin/Debug

CMD ["mono", "QuantConnect.Lean.Launcher.exe"]
