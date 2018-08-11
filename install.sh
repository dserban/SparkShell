export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install --no-install-recommends -y \
  wget curl git vim tmux jq mc lynx net-tools  \
  less htop unzip locales                      \
  ca-certificates build-essential              \
  librdkafka-dev libev-dev libsnappy-dev zlib1g-dev netcat-traditional >/dev/null

echo 'Fixing locale ...'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen >/dev/null
echo -e '\nexport LANG=en_US.UTF-8' >> /root/.bashrc

mkdir /opt/tmp

echo 'Setting up the JDK ...'
JDK_TGZ_URL=$(lynx -dump https://www.azul.com/downloads/zulu/zulu-linux/ | grep -o http.*jdk8.*x64.*gz$ | head -1)
echo "From ${JDK_TGZ_URL}"
wget -qO /opt/tmp/zzzjdk.tgz ${JDK_TGZ_URL}
tar -xf /opt/tmp/zzzjdk.tgz -C /opt
mv /opt/zulu* /opt/jdk
rm /opt/tmp/zzzjdk.tgz

CLOSER="https://www.apache.org/dyn/closer.cgi?as_json=1"
MIRROR=$(curl --stderr /dev/null ${CLOSER} | jq -r '.preferred')

echo 'Setting up Spark ...'
SPARK_DIR_URL=$(lynx -dump ${MIRROR}spark/ | grep -o 'http.*/spark/spark-[0-9].*$' | sort -V | tail -1)
SPARK_TGZ_URL=$(lynx -dump ${SPARK_DIR_URL} | grep -o http.*bin-hadoop.*tgz$ | tail -1)
echo "From ${SPARK_TGZ_URL}"
wget -qO /opt/tmp/zzzspark.tgz ${SPARK_TGZ_URL}
tar -xf /opt/tmp/zzzspark.tgz -C /opt
mv /opt/spark-* /opt/spark
rm /opt/tmp/zzzspark.tgz
cd /opt/spark/conf
sed 's/INFO/FATAL/;s/WARN/FATAL/;s/ERROR/FATAL/' log4j.properties.template > log4j.properties

echo 'Setting up Hadoop ...'
HADOOP_TGZ_URL=$(lynx -dump ${MIRROR}hadoop/common/stable/ | grep -o http.*gz$ | grep -v src | head -1)
echo "From ${HADOOP_TGZ_URL}"
wget -qO /opt/tmp/zzzhadoop.tgz ${HADOOP_TGZ_URL}
tar -xf /opt/tmp/zzzhadoop.tgz -C /opt
mv /opt/hadoop-* /opt/hadoop
rm /opt/tmp/zzzhadoop.tgz

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

echo 'Setting up Scala 2.11.8 ...'
wget -qO /opt/tmp/zzzscala.tgz https://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
echo 'Extracting Scala ...'
tar -xf /opt/tmp/zzzscala.tgz -C /opt
mv /opt/scala-* /opt/scala
rm /opt/tmp/zzzscala.tgz

echo 'Setting up Ammonite ...'
export AMMV=1.1.2
wget -qO /opt/scala/bin/amm https://github.com/lihaoyi/Ammonite/releases/download/${AMMV}/2.11-${AMMV}
chmod +x /opt/scala/bin/amm

echo 'Setting up sbt 1.2.1 ...'
export SBTV=1.2.1
wget -qO /opt/tmp/zzzsbt.tgz https://github.com/sbt/sbt/releases/download/v${SBTV}/sbt-${SBTV}.tgz
tar -xf /opt/tmp/zzzsbt.tgz -C /opt
rm /opt/tmp/zzzsbt.tgz
echo 'Running sbt update ...'
mkdir /root/scala/project
echo "sbt.version=${SBTV}" > /root/scala/project/build.properties
cd /root/scala
sbt update > /dev/null
echo "" | sbt console > /dev/null

echo 'Building container, this may take a while ...'
