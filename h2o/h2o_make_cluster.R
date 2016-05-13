### script by Brad Sliz (d7oz)


library(h2o)
library(stringr)

### first, kdestroy; kinit

file.remove('h2o_launch.log'
            ,showWarnings = F)

# input parameters --------------------------------------------------------

n_nodes <- 1             # number of nodes
node_size <- 4           # size of each node in GB

# invoke command line arguments -------------------------------------------

output_log <- format(Sys.time(), format = '%m%d%Y_%H%M%S')

# clean up old logs?

system2('hadoop'
        ,args = paste('jar /opt/h2o/latest_hadoop/h2odriver.jar -mapperXmx '
                      ,node_size
                      ,'g -nodes '
                      ,n_nodes
                      ,' -output out'
                      ,output_log
                      ,sep = '')
        ,stdout = 'h2o_launch.log'
        ,wait = F)

# wait for log file to exist ----------------------------------------------

start_time <- Sys.time()

while(1) {
     
     if(file.exists('h2o_launch.log')) {
          
          if (length(readLines('h2o_launch.log') ) > 1) break
          
     }
     
     if ( difftime(Sys.time()
                   ,start_time
                   ,units = 'secs') > 180 ) {
          
          stop('h2o launch timed out')
          
     }
     
}

# scan log file until cluster ip is available -----------------------------

while (1) {
     
     log_lines <- readLines('h2o_launch.log')
     
     for (L in log_lines) {
          
          # look for the right line
          
          vm_ready <- grepl(paste('H2O cluster size', n_nodes), L)
          
          
          if (vm_ready) {
               
               # extract ip & port of a h2o vm node
               
               ip_front <- str_locate_all(pattern = 'H2O node ', L) [[1]] [1,2]
               
               colon <- str_locate_all(pattern = ':', L) [[1]] [1,1]
               
               port_end <- str_locate_all(pattern = ' reports', L) [[1]] [1,1]
               
               h2o_ip <- substring(L, ip_front + 1, colon - 1)
               
               h2o_port <- substring(L, colon + 1, port_end - 1)
               
               break
               
          }
          
          # stop if there is an error in the log
          
          if (grepl('ERROR', L)) stop(L)
          
     }
     
     if (vm_ready) break
     
}

file.remove('h2o_launch.log'
            ,showWarnings = F)

# initialize h2o vm -------------------------------------------------------

my_h2o <- h2o.init(ip = h2o_ip
                   ,port = as.numeric(h2o_port)
                   ,startH2O = F)

# clean up folder ---------------------------------------------------------

# alias <- system('whoami', intern = T)
# 
# system(paste('hadoop fs -rmdir /user/'
#              ,alias
#              ,'/'
#              ,output_log
#              ,sep = '') )

# clear environment, except h2o client ------------------------------------

rm(list = c("colon" 
            ,"h2o_ip"
            ,"h2o_port"
            ,"ip_front"
            ,"L"
            ,"log_lines"
            ,"n_nodes"
            ,"node_size" 
            ,"output_log"
            ,"port_end"
            ,"start_time"
            ,"vm_ready") )


