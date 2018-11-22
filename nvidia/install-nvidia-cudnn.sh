install-nvidia-cudnn.sh

> https://developer.nvidia.com/cudnn

```bash
tar -zxvf cudnn-7.0-linux-x64-v3.0-prod.tgz  


sudo cp cuDNN/cuda/include/cudnn.h /usr/local/cuda/include  
sudo cp cuDNN/cuda/lib64/* /usr/local/cuda/lib64  

sudo rm -rf libcudnn.so libcudnn.so.7.0
sudo ln -s libcudnn.so.7.0.64 libcudnn.so.7.0  
sudo ln -s libcudnn.so.7.0 libcudnn.so
```