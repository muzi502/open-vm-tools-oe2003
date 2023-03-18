FROM openeuler/openeuler:20.03 as builder
RUN sed -i "s#repo.openeuler.org#repo.huaweicloud.com/openeuler#g" /etc/yum.repos.d/openEuler.repo && \
    dnf install rpmdevtools* dnf-utils -y && \
    rpmdev-setuptree

# clone open-vm-tools source code and update spec file for fixes oe2003 build error
ARG COMMIT_ID=8a7f961
ARG GIT_REPO=https://gitee.com/src-openeuler/open-vm-tools.git
WORKDIR /root/rpmbuild/SOURCES
RUN git clone $GIT_REPO . && \
    git reset --hard $COMMIT_ID && \
    sed -i 's#^%{_bindir}/vmhgfs-fuse$##g' open-vm-tools.spec && \
    sed -i 's#^%{_bindir}/vmware-vmblock-fuse$##g' open-vm-tools.spec && \
    sed -i 's#gdk-pixbuf-xlib#gdk-pixbuf2-xlib#g' open-vm-tools.spec

# install open-vm-tools rpm build dependencies
RUN yum-builddep -y open-vm-tools.spec
RUN rpmbuild --define "dist .oe1" -ba open-vm-tools.spec --quiet

FROM scratch
COPY --from=builder /root/rpmbuild/RPMS/ /
