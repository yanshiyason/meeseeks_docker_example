# MeeseeksDockerExample

1. Build image
```
docker build . --tag meeseeks_example:0.1
```

2. Start the iex shell
```
docker run -it --rm meeseeks_example:0.1 ./rel/bin/meeseeks_docker_example start_iex
```

3. Test a meeseeks command
```
iex> Meeseeks.parse("<div></div>")
```
