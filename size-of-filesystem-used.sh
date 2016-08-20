# cat size
df -h | grep cdr | awk '{print $3}' > /tmp/1
cat /tmp/1 | grep M | sed -e 's/M//g' > /tmp/m
cat /tmp/1 | grep G | sed -e 's/G//g' > /tmp/g
cat /tmp/1 | grep T | sed -e 's/T//g' > /tmp/t
sum=0
export sum
for i in `cat t`
do
sum=$sum+$i
done
echo $sum | bc > /tmp/sumt

sum=0
export sum
for i in `cat g`
do
sum=$sum+$i
done
echo $sum | bc > /tmp/sumg

sum=0
export sum
for i in `cat m`
do
sum=$sum+$i
done
echo $sum | bc > /tmp/summ

echo `cat /tmp/summ`/1024/1024+`cat /tmp/sumg`/1024+`cat /tmp/sumt` | bc > /tmp/total

echo "`cat /tmp/total` TB restored so far"
#
