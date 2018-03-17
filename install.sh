export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install --no-install-recommends -y \
  wget curl git vim tmux jq mc net-tools less  \
  htop unzip locales                           \
  ca-certificates build-essential              \
  librdkafka-dev libev-dev libsnappy-dev zlib1g-dev netcat-traditional >/dev/null

echo 'Fixing locale ...'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen >/dev/null
echo -e '\nexport LANG=en_US.UTF-8' >> /root/.bashrc

echo 'Downloading JDK ...'
wget -qO /opt/zzzjdk.tgz \
         https://cdn.azul.com/zulu/bin/zulu8.28.0.1-jdk8.0.163-linux_x64.tar.gz
echo 'Extracting JDK ...'
tar -xf /opt/zzzjdk.tgz -C /opt
mv /opt/zulu* /opt/jdk
rm /opt/zzzjdk.tgz

echo 'Downloading Spark ...'
wget -qO /opt/zzzspark.tgz \
         http://apache.javapipe.com/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz
echo 'Extracting Spark ...'
tar -xf /opt/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

echo 'Downloading Hadoop ...'
wget -qO /opt/zzzhadoop.tgz \
         http://apache.javapipe.com/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz
echo 'Extracting Hadoop ...'
tar -xf /opt/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/zzzhadoop.tgz

echo 'Downloading MovieLens File ...'
wget -qO /opt/zzzmovielens.zip \
         http://files.grouplens.org/datasets/movielens/ml-20m.zip
echo 'Extracting MovieLens File ...'
cd /opt
unzip zzzmovielens.zip >/dev/null
mv ml-20m movielens
rm /opt/zzzmovielens.zip
cd /opt/movielens
mv ratings.csv ratings.csv.orig
cut -d, -f1-3 /opt/movielens/ratings.csv.orig | tail -n +2 > /opt/movielens/ratings.csv
mv movies.csv movies.csv.orig
tail -n +2 movies.csv.orig > movies.csv

echo 'Downloading Scala ...'
wget -qO /opt/zzzscala.tgz \
         https://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
echo 'Extracting Scala ...'
tar -xf /opt/zzzscala.tgz -C /opt
mv /opt/scala-* /opt/scala
rm /opt/zzzscala.tgz

echo 'Installing sbt ...'
export SBTV=0.13.15
curl -sL http://dl.bintray.com/sbt/native-packages/sbt/${SBTV}/sbt-${SBTV}.tgz | \
  gzip -d                                                                      | \
  tar -x -C /usr/local
echo 'Running sbt update ...'
cd /root/scala
sbt update >/dev/null
echo "" | sbt console >/dev/null

echo 'Building container, this may take a while ...'
