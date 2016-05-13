import jpype
import jaydebeapi
import os
import glob
import pandas as pd

# define username
user=os.environ['USER']

# Get hadoop jars
KERBEROS_LOGIN_JAR=r"/san-data/shared/lib/KerberosLogin.jar"
HADOOP_LIB_PATH=os.path.pathsep.join(glob.glob('%s.[jJ][aA][rR]' %
                                               r"/opt/cloudera/parcels/CDH-5.4.3-1.cdh5.4.3.p862.534/jars/*"))

#Start JVM
jpype.startJVM(jpype.getDefaultJVMPath(), "-Djava.class.path=%s:%s" % (KERBEROS_LOGIN_JAR, HADOOP_LIB_PATH))

# Kerberos Login
kerbLoginClass = jpype.JClass('org.statefarm.sr.analytics.dax.hadoop.KerberosLogin')
kerbLoginInstance = kerbLoginClass()
kerbLoginInstance.login(user+"@OPR.STATEFARM.ORG", "/home/"+user+"/"+user+".keytab")

# Establish database connection using jaydebeapi (jaydebeapi will use existing jpype jvm)
conn = jaydebeapi.connect('org.apache.hive.jdbc.HiveDriver',
                          'jdbc:hive2://da74wbedge2.opr.statefarm.org:10000/default;'
                        + 'principal=hive/da74wbedge2.opr.statefarm.org@OPR.STATEFARM.ORG')