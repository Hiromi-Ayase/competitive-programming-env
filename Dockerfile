FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git curl wget zip unzip make software-properties-common sudo

# Add repositories.
RUN add-apt-repository -y ppa:pypy/ppa
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y universe
RUN apt-get update

# Install Python 3.8.1
RUN apt-get install -y python3.8 python3.8-dev python3-pip
RUN python3.8 -m pip install -U Cython numba numpy scipy scikit-learn networkx

# Install gcc 9.2.1
RUN apt-get install -y gcc-9 g++-9 gdc-9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10
RUN update-alternatives --install /usr/bin/gdc gdc /usr/bin/gdc-9 10

# Install boost 1.72.0
# RUN cd /tmp \
#     && wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz  \
#     && tar xfs boost_1_72_0.tar.gz \
#     && cd boost_1_72_0 \
#     && ./bootstrap.sh --with-toolset=gcc --without-libraries=mpi,graph_parallel --with-python=python3.8 \
#     && ./b2 -j3 toolset=gcc variant=release link=static runtime-link=static cxxflags="-std=c++17" stage \
#     && ./b2 -j3 toolset=gcc variant=release link=static runtime-link=static cxxflags="-std=c++17" --prefix=/opt/boost/gcc install

# Install clang 9.0.0
RUN apt-get install -y clang-9 clang++-9 libc++-9-dev libc++abi-9-dev
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 10
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 10

# Install PyPy 7.3
RUN apt-get install -y pypy pypy3

# Install C# 3.1.101
RUN cd /tmp \
    && wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb\
    && dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install apt-transport-https
RUN apt-get install -y dotnet-sdk-3.1 dotnet-runtime-3.1

# Add user "ubuntu"
RUN useradd -m -u 1000 -s "/bin/bash" ubuntu
RUN gpasswd -a ubuntu sudo
RUN echo "ubuntu:ubuntu" | chpasswd
USER ubuntu
WORKDIR /home/ubuntu

# Install Rust 1.42.0 / cargo-atcoder
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN $HOME/.cargo/bin/rustup toolchain install 1.42.0
RUN $HOME/.cargo/bin/rustup component add rls rust-analysis rust-src
RUN $HOME/.cargo/bin/cargo install cargo-atcoder

# Install Java 11.0.7/Kotlin 1.3.72/Scala 2.13.2
RUN curl -s "https://get.sdkman.io" | bash
RUN /bin/bash -l -c "source $HOME/.sdkman/bin/sdkman-init.sh; sdk install java 11.0.7.hs-adpt"
RUN /bin/bash -l -c "source $HOME/.sdkman/bin/sdkman-init.sh; sdk install kotlin 1.3.72"
RUN /bin/bash -l -c "source $HOME/.sdkman/bin/sdkman-init.sh; sdk install scala 2.13.2"

# Install code-server 3.4.1
RUN mkdir -p $HOME/.local/lib $HOME/.local/bin
RUN curl -fL https://github.com/cdr/code-server/releases/download/v3.4.1/code-server-3.4.1-linux-amd64.tar.gz | tar -C $HOME/.local/lib -xz
RUN mv $HOME/.local/lib/code-server-3.4.1-linux-amd64 $HOME/.local/lib/code-server-3.4.1
RUN ln -s $HOME/.local/lib/code-server-3.4.1/bin/code-server $HOME/.local/bin/code-server

# Install code-server-extensions
RUN $HOME/.local/bin/code-server --install-extension MS-CEINTL.vscode-language-pack-ja
RUN $HOME/.local/bin/code-server --install-extension vscjava.vscode-java-pack
RUN $HOME/.local/bin/code-server --install-extension rust-lang.rust
RUN $HOME/.local/bin/code-server --install-extension vadimcn.vscode-lldb
RUN $HOME/.local/bin/code-server --install-extension ms-python.python
RUN $HOME/.local/bin/code-server --install-extension ms-dotnettools.csharp
RUN $HOME/.local/bin/code-server --install-extension ms-vscode.cpptools

# Install online-judge-tools
RUN pip3 install --user online-judge-tools

# Make workspaces directory.
COPY --chown=ubuntu:ubuntu data/ $HOME
RUN chmod 0755 ./docker-entrypoint.sh

# Modify shell.
ENV USER=ubuntu
ENV SHELL=/bin/bash
ENV JAVA_HOME=/home/ubuntu/.sdkman/candidates/java/current
ENV PATH=$PATH:/home/ubuntu/.local/bin:/home/ubuntu/.cargo/bin
ENV RUST_BACKTRACE=1

# Run code-server
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]
