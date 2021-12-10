# Magazynier Docker

## Build
```
git clone https://github.com/majudev/magazynier-docker.git
cd magazynier-docker
sudo docker build -t majudev/magazynier:0.1.1-ALPHA .
```

## Run
```
sudo docker run \
	--name="magazynier" \		#container name
	-p 127.0.0.1:2233:80/tcp \	#redirect container's port 80 to localhost:2233
	-v /tmp/data:/data \		#mount /tmp/data as directory with Magazynier config & data
	majudev/magazynier:0.1.1-ALPHA	#docker image name
```
