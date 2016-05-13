get_user <- function() return(system('whoami', wait=T, intern=T))
hive2_connect <- function(debug = FALSE, 
                          rjdbcJarPath = paste0('/home/',get_user(),'/Library/R/3.1/library/RJDBC/java/RJDBC.jar'),
                          clouderaDir = '/opt/cloudera/parcels/CDH/jars/',
                          port = 10000) {
  if(!is.logical(debug))
    stop('illegal value for debug')
  if(!is.character(rjdbcJarPath))
    stop('illegal value for rjdbcJarPath')
  if(!file.exists(rjdbcJarPath))
    stop('RJDBC jar path does not exist')
  if(!is.character(clouderaDir))
    stop('illegal value for clouderaDir')
  if(is.null(port) | is.na(port))
    stop('illegal value for port')
  
  
  ## Set Java options
  if(debug) {
    options(java.parameters = c("-Xmx100g", "-Dsun.security.krb5.debug=true", "-Djavax.net.debug=ssl", "-Djavax.security.auth.useSubjectCredsOnly=false", "-DrJava.debug=true"))
  } else {
    options(java.parameters = c("-Xmx100g", "-Djavax.security.auth.useSubjectCredsOnly=false"))
  }
  
  
  ## If these packages aren't installed, it'll exit here
  library(rJava)
  library(RJDBC)
  
  
  ## Where is the hive jdbc jar?
  path_prefix <- clouderaDir
  cloudera_jars <- list.files(path_prefix)
  standaloneJar <- paste0(path_prefix,cloudera_jars[grepl('hive-jdbc', cloudera_jars) & grepl('standalone', cloudera_jars)])
  hadoopCommJar <- paste0(path_prefix,cloudera_jars[grepl('hadoop-common', cloudera_jars) & !grepl('tests', cloudera_jars)])
  hadoopAuthJar <- paste0(path_prefix,cloudera_jars[grepl('hadoop-auth', cloudera_jars) & !grepl('tests', cloudera_jars)])
  
  ## Start Java
  exitCode <- .jinit()
  if(0 != exitCode) stop('could not start Java')
  
  ## Add jars to the classpath
  tryCatch({
    ## I don't know why it wants it explicitly added, but when you don't, it throws an exception later...
    .jaddClassPath(rjdbcJarPath)
    .jaddClassPath(standaloneJar)
    .jaddClassPath(hadoopCommJar)
    .jaddClassPath(hadoopAuthJar)
  }, error = function(e) {
    message('could not add jars to classpath. Current classpath:')
    .jclassPath()
    stop(e)
  })
  
  ## Init driver, connect to JDBC
  hive_drv <- JDBC("org.apache.hive.jdbc.HiveDriver", standaloneJar, identifier.quote="`")
  dbc <- paste0("jdbc:hive2://da74wbedge2.opr.statefarm.org:",port,"/default;principal=hive/da74wbedge2.opr.statefarm.org@OPR.STATEFARM.ORG")
  hive_conn <- dbConnect(hive_drv, dbc) 
  
  return(hive_conn)
}

