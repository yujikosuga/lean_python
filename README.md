# Lean Python Environment

## Build

```
docker build -t yujikosuga/lean_python .
```

## Usage

Write your trading algorithm in Volume/Algorithm.Python/MyTradingAlgorithm.py, and run it with the following command.

```
docker run -v "$PWD/Volume:/root/Lean/Volume" yujikosuga/lean_python:latest
```
