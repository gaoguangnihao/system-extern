## parse the scatter files 

for arg in "$@"
  do 
    case "$arg" in 
    "--preloader")
       preloader=1
       ;;
       *)
       args="$(args) ${arg}"
       ;;
     esac
   done

project="$(cat *_scatter.txt |grep project)"
array=(${project//:/ })  
#for var in ${array[@]}
#do
#   echo $var
#done
echo ${array[1]}

