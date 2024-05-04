#!/bin/bash

start_vmtoolsd(){
    # libgmodule和libgobject等库和系统本身的库文件有重叠，不适合直接覆盖/复制
    # 启动vmtoolsd需要设置LD_LIBRARY_PATH参数，该参数会被ld-linux-x86-64.so.2读取
    # 之后LD_LIBRARY_PATH下的链接库会被优先选中
    cd $INSTALL_DIR && LD_LIBRARY_PATH=. ./bin/vmtoolsd 2>/dev/null &
    echo 'tried to start vmtoolsd'
    echo "vmtoolsd pid is $(pidof vmtoolsd)"
}
# 解压时将会考虑权限递归问题
#fix_permissions(){
#    chmod 777 $INSTALL_DIR/ld-linux-x86-64.so.2
#    chmod 777 $INSTALL_DIR/libDeployPkg.so.0.0.0
#    chmod 777 $INSTALL_DIR/libc.so.6
#    chmod 777 $INSTALL_DIR/libdl.so.2
#    chmod 777 $INSTALL_DIR/libffi.so.7
#    chmod 777 $INSTALL_DIR/libgcc_s.so.1
#    chmod 777 $INSTALL_DIR/libglib-2.0.so.0
#    chmod 777 $INSTALL_DIR/libgmodule-2.0.so.0
#    chmod 777 $INSTALL_DIR/libgobject-2.0.so.0
#    chmod 777 $INSTALL_DIR/libguestStoreClient.so.0.0.0
#    chmod 777 $INSTALL_DIR/libguestlib.so.0.0.0
#    chmod 777 $INSTALL_DIR/libhgfs.so.0.0.0
#    chmod 777 $INSTALL_DIR/libpcre.so.3
#    chmod 777 $INSTALL_DIR/libpthread.so.0
#    chmod 777 $INSTALL_DIR/libtirpc.so.3.0.0
#    chmod 777 $INSTALL_DIR/libvgauth.so.0.0.0
#    chmod 777 $INSTALL_DIR/libvmtools.so.0
#    chmod a+x $INSTALL_DIR/bin/*
#    chmod -R 777 $INSTALL_DIR/etc/vmware-tools/
#}
install() {
    # 复制从 ubuntu 系统提取的 loader
    ln -s $INSTALL_DIR/files/ld-linux-x86-64.so.2  /lib64/ld-linux-x86-64.so.2
    # 链接 poweroff 为 shutdown
    ln -s /sbin/poweroff /sbin/shutdown
    # 链接 vmtoolsd 插件目录
    ln -s $INSTALL_DIR/files/open-vm-tools /usr/lib/x86_64-linux-gnu

    # 复制etc下的文件，并赋权，如果跳过，则会出现vmware报错说
    ln -s $INSTALL_DIR/files/etc/vmware-tools /etc/vmware-tools
    chmod -R 777 /etc/vmware-tools/
    start_vmtoolsd
    exit 0
}

uninstall() {
    # 建议重启生效，
    kill -s SIGUSR1 $(pidof vmtoolsd) 2>/dev/null

    rm -rf /lib64/ld-linux-x86-64.so.2
    rm -rf /sbin/shutdown
    rm -rf /usr/lib/x86_64-linux-gnu
    rm -rf /etc/vmware-tools

    echo "vmtoolsd is removed"

    exit 0
}