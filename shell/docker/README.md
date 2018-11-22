# Docker On CentOS 7

## 使用方式

* **执行权限**

```bash
$ chmod +x ./docker-deploy.sh
```

* **安装**

```bash
$ # 默认版本是 1.13.1
$ ./docker-deploy.sh install

$ # 安装 1.12.6 版本
$ ./docker-deploy.sh install 1.12.6
```

* **卸载**

```bash
$ ./docker-deploy.sh remove
```

* **卸载并移除所有数据**

```bash
$ ./docker-deploy.sh purge
```


## 检查

```bash
$ sudo docker info
```


## 参考

* [Get Docker for CentOS](https://docs.docker.com/v1.13/engine/installation/linux/centos/)