#!/bin/bash



start_vmtoolsd(){
    # libgmodule和libgobject等库和系统本身的库文件有重叠，不适合直接覆盖/复制
    # 启动vmtoolsd需要设置LD_LIBRARY_PATH参数，该参数会被ld-linux-x86-64.so.2读取
    # 之后LD_LIBRARY_PATH下的链接库会被优先选中
    cd $INSTALLDIR && LD_LIBRARY_PATH=. ./bin/vmtoolsd 2>/dev/null &
    echo 'tried to start vmtoolsd'
    echo "vmtoolsd pid is $(pidof vmtoolsd)"
 
}
fix_permissions(){
    chmod 777 $INSTALLDIR/ld-linux-x86-64.so.2
    chmod 777 $INSTALLDIR/libDeployPkg.so.0.0.0
    chmod 777 $INSTALLDIR/libc.so.6
    chmod 777 $INSTALLDIR/libdl.so.2
    chmod 777 $INSTALLDIR/libffi.so.7
    chmod 777 $INSTALLDIR/libgcc_s.so.1
    chmod 777 $INSTALLDIR/libglib-2.0.so.0
    chmod 777 $INSTALLDIR/libgmodule-2.0.so.0
    chmod 777 $INSTALLDIR/libgobject-2.0.so.0
    chmod 777 $INSTALLDIR/libguestStoreClient.so.0.0.0
    chmod 777 $INSTALLDIR/libguestlib.so.0.0.0
    chmod 777 $INSTALLDIR/libhgfs.so.0.0.0
    chmod 777 $INSTALLDIR/libpcre.so.3
    chmod 777 $INSTALLDIR/libpthread.so.0
    chmod 777 $INSTALLDIR/libtirpc.so.3.0.0
    chmod 777 $INSTALLDIR/libvgauth.so.0.0.0
    chmod 777 $INSTALLDIR/libvmtools.so.0
    chmod a+x $INSTALLDIR/bin/*
    chmod -R 777 $INSTALLDIR/etc/vmware-tools/
}
install() {
    fix_permissions
    # 如果要区分安装和启动两个过程
    # cp -r $EXTRACTDIR $INSTALLDIR
    # 复制从ubuntu系统提取的loader，重启失效
    cp $INSTALLDIR/ld-linux-x86-64.so.2  /lib64/ld-linux-x86-64.so.2
    # 创建shutdown命令，重启失效
    echo "#!/bin/sh" > /sbin/shutdown
    echo "/sbin/poweroff" >> /sbin/shutdown
    chmod a+x /sbin/shutdown
    # 复制vmtoolsd插件目录，重启失效
    mkdir -p /usr/lib/x86_64-linux-gnu/
    cp -r $INSTALLDIR/open-vm-tools/ /usr/lib/x86_64-linux-gnu/

    # 复制etc下的文件，并赋权，如果跳过，则会出现vmware报错说
    cp -r $INSTALLDIR/etc/vmware-tools/ /etc/
    chmod -R 777 /etc/vmware-tools/
    start_vmtoolsd
    exit 0
}

uninstall() {
    # 建议重启生效，
    exit 0
}

if [ -z "$INSTALLDIR" ];then
    export INSTALLDIR="."
fi
if [ "$1" == "install" ]; then
    install
elif [ "$1" == "uninstall" ]; then
    uninstall
else
    echo "unkown action: $1"
fi